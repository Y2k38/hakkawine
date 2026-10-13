defmodule Hakkawine.Subscription do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.System
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Billing.Order
  alias Hakkawine.Stats
  alias Hakkawine.ProxyDrivers
  alias Hakkawine.Subscription.Profile
  alias Hakkawine.Subscription.ProxyTemplate
  alias Hakkawine.Subscription.UserSubscription

  def create_user_subscriptions(%UserAccount{} = user, %Order{} = order) do
    started_at = DateTime.utc_now()

    params = %{
      user_id: user.id,
      product_id: order.product_id,
      product_price_id: order.product_price_id,
      status: :active,
      billing_cycle: order.billing_cycle,
      billing_day: started_at.day,
      snap_limit_device_count: 0,
      snap_limit_speed_mbps: 0,
      snap_limit_speed_up_mbps: 0,
      snap_limit_speed_down_mbps: 0,
      snap_base_quota_bytes: 0,
      extra_quota_bytes: 0,
      started_at: started_at,
      expired_at: started_at
    }

    %UserSubscription{}
    |> UserSubscription.new_sub_changeset(params)
    |> Repo.insert()
  end

  def get_template(scope, target) do
    ProxyTemplate
    |> where(scope: ^scope)
    |> where(target: ^target)
    |> where(is_active: true)
    |> Repo.one()
  end

  def get_by_id(id) do
    UserSubscription
    |> where(id: ^id)
    |> Repo.one()
  end

  def get_by_uuid(uuid) do
    UserSubscription
    |> where(uuid: ^uuid)
    |> where(status: :active)
    |> Repo.one()
  end

  def get_recurring_subscription_by_user_id(user_id) do
    UserSubscription
    |> where([sub], sub.user_id == ^user_id)
    |> where([sub], sub.billing_cycle != :one_time)
    |> where([sub], sub.status == :active)
    |> Repo.one()
  end

  def list_active_subscriptions(user_id) do
    UserSubscription
    |> where([sub], sub.user_id == ^user_id)
    |> where([sub], sub.status == :active)
    |> Repo.all()
  end

  def list_history_subscriptions(user_id) do
    UserSubscription
    |> where([sub], sub.user_id == ^user_id)
    |> order_by([sub], desc: sub.created_at)
    |> Repo.all()
  end

  def diff_in_days(%DateTime{} = expired_at, %DateTime{} = from_datetime \\ DateTime.utc_now()) do
    Date.diff(DateTime.to_date(expired_at), DateTime.to_date(from_datetime))
  end

  defp compute_periodic_window(%DateTime{} = now, billing_day) do
    current_date = DateTime.to_date(now)

    current_month_billing_date = safe_date(current_date.year, current_date.month, billing_day)

    {start_date, end_date} =
      if Date.compare(current_date, current_month_billing_date) != :lt do
        start_d = current_month_billing_date

        next_month_date = Date.shift(current_date, month: 1)
        end_d = safe_date(next_month_date.year, next_month_date.month, billing_day)

        {start_d, end_d}
      else
        end_d = current_month_billing_date

        prev_month_date = Date.shift(current_date, month: -1)
        start_d = safe_date(prev_month_date.year, prev_month_date.month, billing_day)

        {start_d, end_d}
      end

    {
      DateTime.new!(start_date, ~T[00:00:00], "Etc/UTC"),
      DateTime.new!(end_date, ~T[00:00:00], "Etc/UTC")
    }
  end

  defp safe_date(year, month, billing_day) do
    {:ok, first_of_month} = Date.new(year, month, 1)

    max_days = Date.days_in_month(first_of_month)

    day = min(billing_day, max_days)

    Date.new!(year, month, day)
  end

  def calculate_current_billing_window(subscription) do
    if subscription.billing_cycle == :one_time do
      {subscription.started_at, subscription.expired_at}
    else
      now = DateTime.utc_now()
      compute_periodic_window(now, subscription.billing_day)
    end
  end

  def billing_summary(%UserSubscription{} = sub) do
    {cycle_start, cycle_end} = calculate_current_billing_window(sub)

    %{up: up, down: down} =
      Stats.get_subscription_summary_by_window(sub.id, cycle_start, cycle_end)

    used = up + down
    total = sub.snap_base_quota_bytes + sub.extra_quota_bytes
    percent = if total > 0, do: min(round(used / total * 100), 100), else: 0
    remaining = total - used

    %{
      up: up,
      down: down,
      used: used,
      total: total,
      remaining: remaining,
      percent: percent,
      extra: sub.extra_quota_bytes,
      cycle_start: cycle_start,
      cycle_end: cycle_end
    }
  end

  def build_userinfo(%UserSubscription{} = subscription) do
    period_start = calculate_period_start(subscription)

    traffic = Stats.get_subscription_traffic(subscription.id, period_start)

    total_bytes = subscription.snap_base_quota_bytes + subscription.extra_quota_bytes

    expire_timestamp = DateTime.to_unix(subscription.expired_at)

    "upload=#{traffic.up}; download=#{traffic.down}; total=#{total_bytes}; expire=#{expire_timestamp}"
  end

  defp calculate_period_start(%UserSubscription{
         billing_cycle: :one_time,
         started_at: started_at
       }),
       do: started_at

  defp calculate_period_start(%UserSubscription{billing_day: nil, started_at: started_at}),
    do: started_at

  defp calculate_period_start(%UserSubscription{billing_day: billing_day, started_at: started_at}) do
    today = Date.utc_today()

    {year, month} =
      if today.day >= billing_day do
        {today.year, today.month}
      else
        prev_month(today.year, today.month)
      end

    max_days = Date.days_in_month(Date.new!(year, month, 1))
    actual_day = min(billing_day, max_days)

    period_start =
      Date.new!(year, month, actual_day)
      |> DateTime.new!(~T[00:00:00], "Etc/UTC")

    if DateTime.compare(period_start, started_at) == :lt do
      started_at
    else
      period_start
    end
  end

  defp prev_month(year, 1), do: {year - 1, 12}
  defp prev_month(year, month), do: {year, month - 1}

  def build_profile(scope, target, %UserSubscription{} = subscription) do
    subscription = Repo.preload(subscription, [:agent_allocations, product: :plan_slots])

    site_name = System.get_setting("site_name", "Hakkawine")
    filename = "#{site_name}-#{subscription.product.name}"

    with proxies = ProxyDrivers.build_proxies(scope, target, subscription),
         tpl = get_template(scope, target),
         content = inject_proxies_into_template(target, tpl.content, proxies) do
      Profile.new(%{
        content: content,
        type: format_to_mime_type(tpl.format),
        title: filename,
        filename: "#{filename}.#{tpl.format}"
      })
    end
  end

  def parse_user_agent(user_agent) when is_binary(user_agent) do
    ua = String.downcase(user_agent)

    cond do
      String.contains?(ua, "clash") -> :clash
      true -> :general
    end
  end

  def parse_user_agent(_), do: :general

  defp inject_proxies_into_template(:clash, template_str, proxies) do
    template_str
    |> YamlElixir.read_from_string!()
    |> Map.put("proxies", proxies)
    |> Ymlr.document!()
  end

  defp inject_proxies_into_template(_target, _template_str, proxies) do
    proxies
    |> Enum.join("\n")
    |> Base.encode64()
  end

  defp format_to_mime_type(format) do
    case to_string(format) do
      fmt when fmt in ["yaml", "yml"] -> "application/yaml"
      "json" -> "application/json"
      _conf -> "text/plain"
    end
  end
end
