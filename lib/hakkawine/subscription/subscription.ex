defmodule Hakkawine.Subscription do
  import Ecto.Query
  import Hakkawine.Repo.Query

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

    UserSubscription
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

  def get_by_uuid(uuid) do
    UserSubscription
    |> where(uuid: ^uuid)
    |> where(status: :active)
    |> Repo.one()
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
    subscription = Repo.preload(subscription, [:node_leases, product: :plan_slots])

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
