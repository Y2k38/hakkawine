defmodule Hakkawine.Subscription do
  alias Hakkawine.Repo
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Billing.Order
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
end
