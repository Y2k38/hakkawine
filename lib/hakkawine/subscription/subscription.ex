defmodule Hakkawine.Subscription do
  alias Hakkawine.Repo
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Billing.Order
  alias Hakkawine.Subscription.Profile
  alias Hakkawine.Subscription.UserSubscription

  def create_user_subscriptions(%UserAccount{} = user, %Order{} = order) do
    started_at = DateTime.utc_now()

    params = %{
      user_id: user.id,
      product_id: order.product_id,
      product_price_id: order.product_price_id,
      status: :active,
      billing_cycle: order.billing_cycle,
      snap_limit_device_count: 0,
      snap_limit_speed_mbps: 0,
      snap_limit_speed_up_mbps: 0,
      snap_limit_speed_down_mbps: 0,
      snap_base_quota_bytes: 0,
      extra_quota_bytes: 0,
      started_at: started_at,
      expired_at: started_at,
    }

    %UserSubscription{}
    |> UserSubscription.new_sub_changeset(params)
    |> Repo.insert()
  end

  def get_by_uuid(uuid) do
    UserSubscription
    |> where(uuid: ^uuid)
    |> where(status: :active)
    |> Repo.one()
  end

  def build_profile(subscription, user_agent) do
    content = ""
    {client_type, content_type, filename} = parse_user_agent(user_agent)

    etag = "\"" <> :crypto.hash(:md5, content) |> Base.encode16(case: :lower) <> "\""

    Profile.build(%{
      content: content,
      type: content_type,
      title: filename,
      filename: filename,
      etag: etag,
      interval: 24*60*60
    })
  end

  defp parse_user_agent(user_agent) when is_binary(user_agent) do
    ua = String.downcase(user_agent)

    cond do
      String.contains?(ua, "clash") -> :clash
      String.contains?(ua, "shadowrocket") -> :shadowrocket
      true -> :general
    end
  end
  defp parse_user_agent(_), do: :general

  defp to_client_content_type(:clash), do: "application/yaml"
  defp to_client_content_type(_client), do: "text/plain"
end
