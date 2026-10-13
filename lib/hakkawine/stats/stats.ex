defmodule Hakkawine.Stats do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Stats.AgentTrafficLogsDaily

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

  def get_subscription_traffic(sub_id, period_start) do
    from(t in AgentTrafficLogsDaily,
      where: t.subscription_id == ^sub_id and t.bucket_day >= ^period_start,
      select: %{
        up: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_upload_bytes),
        down: fragment("COALESCE(SUM(?), 0)::bigint", t.rated_download_bytes)
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
end
