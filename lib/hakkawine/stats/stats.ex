defmodule Hakkawine.Stats do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Stats.TrafficForm
  alias Hakkawine.Stats.AgentTrafficLogs5m
  alias Hakkawine.Stats.AgentTrafficLogsDaily
  alias Hakkawine.Subscription
  alias Hakkawine.Subscription.UserSubscription

  #
  def resolve_time_window(start_at, end_at) do
    min_range_sec = 1 * 60 * 60
    max_range_sec = 31 * 24 * 60 * 60

    # range: 1 hour ~ 31 days
    duration = end_at - start_at
    clamped_range = min(max(duration, min_range_sec), max_range_sec)

    # step: 5~50 minutes
    range_minutes = clamped_range / 60.0
    raw_interval = Float.ceil(range_minutes / 900.0)
    interval_minutes = round(Float.ceil(raw_interval / 5.0) * 5.0)
    interval_minutes = max(5, min(50, interval_minutes))

    interval_sec = interval_minutes * 60

    # alignment
    aligned_end = div(end_at, interval_sec) * interval_sec
    num_buckets = max(1, round(clamped_range / interval_sec))
    aligned_start = aligned_end - num_buckets * interval_sec

    {aligned_start, aligned_end, interval_minutes}
  end

  def get_subscription_traffic_summary(sub_id, period_start) do
    from(t in AgentTrafficLogsDaily,
      where: t.subscription_id == ^sub_id and t.bucket_day >= ^period_start,
      select: %{
        up: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_upload_bytes),
        down: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_download_bytes),
        total: fragment("COALESCE(SUM(?), 0)::bigint", t.total_download_bytes)
      }
    )
    |> Repo.one()
  end

  def get_subscription_summary_by_window(sub_id, cycle_start, cycle_end) do
    from(t in AgentTrafficLogsDaily,
      where:
        t.subscription_id == ^sub_id and t.bucket_day >= ^cycle_start and
          t.bucket_day < ^cycle_end,
      select: %{
        up: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_upload_bytes),
        down: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_download_bytes)
      }
    )
    |> Repo.one()
  end

  defp resolve_raw_time_range(sub, form) do
    cond do
      form.start_time && form.end_time ->
        {form.start_time, form.end_time}

      form.period == :current ->
        Subscription.calculate_current_billing_window(sub, :stats)

      form.period == :last_31d ->
        now = DateTime.utc_now()
        start_dt = DateTime.add(now, -31, :day)
        {start_dt, now}
    end
  end

  defp compute_time_window(sub, form) do
    {start_dt, end_dt} = resolve_raw_time_range(sub, form)

    start_at = DateTime.to_unix(start_dt)
    end_at = DateTime.to_unix(end_dt)

    {aligned_start_sec, aligned_end_sec, interval_minutes} = resolve_time_window(start_at, end_at)

    aligned_start = DateTime.from_unix!(aligned_start_sec)
    aligned_end = DateTime.from_unix!(aligned_end_sec)

    {aligned_start, aligned_end, interval_minutes}
  end

  defp list_subscription_traffic_buckets(sub, aligned_start, aligned_end, interval_minutes) do
    from(t in AgentTrafficLogs5m,
      where: t.subscription_id == ^sub.id and t.user_id == ^sub.user_id,
      where: t.bucket_5m >= ^aligned_start and t.bucket_5m <= ^aligned_end,
      group_by: fragment("1"),
      order_by: [asc: fragment("1")],
      select: %{
        time:
          fragment(
            "time_bucket(make_interval(mins => ?), ?, ?)",
            ^interval_minutes,
            t.bucket_5m,
            type(^aligned_start, :utc_datetime)
          ),
        up: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_upload_bytes),
        down: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_download_bytes),
        total: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_total_bytes)
      }
    )
    |> Repo.all()
  end

  defp fill_missing_buckets(raw_rows, aligned_start, aligned_end, interval_minutes) do
    row_map =
      Map.new(raw_rows, fn row ->
        truncated_time = DateTime.truncate(row.time, :second)
        {truncated_time, row}
      end)

    interval_seconds = interval_minutes * 60

    aligned_start = DateTime.truncate(aligned_start, :second)
    aligned_end = DateTime.truncate(aligned_end, :second)

    Stream.unfold(aligned_start, fn current ->
      if DateTime.compare(current, aligned_end) == :gt do
        nil
      else
        row =
          Map.get(row_map, current, %{
            time: current,
            up: 0,
            down: 0,
            total: 0
          })

        next = DateTime.add(current, interval_seconds, :second)

        {row, next}
      end
    end)
    |> Enum.to_list()
  end

  def get_subscription_traffic_chart(%UserSubscription{} = sub, %TrafficForm{} = form) do
    {aligned_start, aligned_end, interval_minutes} = compute_time_window(sub, form)

    raw_rows =
      list_subscription_traffic_buckets(sub, aligned_start, aligned_end, interval_minutes)

    {total_up, total_down, total_traffic, peak_total} =
      Enum.reduce(raw_rows, {0, 0, 0, 0}, fn row, {u, d, t, p} ->
        {
          u + row.up,
          d + row.down,
          t + row.total,
          max(p, row.total)
        }
      end)

    summary = %{
      total_up: total_up,
      total_down: total_down,
      total_traffic: total_traffic,
      peak_total: peak_total
    }

    traffic_data = fill_missing_buckets(raw_rows, aligned_start, aligned_end, interval_minutes)

    {aligned_start, aligned_end, interval_minutes, summary, traffic_data}
  end
end
