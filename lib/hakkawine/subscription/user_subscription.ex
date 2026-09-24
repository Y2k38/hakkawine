defmodule Hakkawine.Subscription.UserSubscription do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Billing.Order

  @primary_key {:id, :id, autogenerate: true}
  schema "user_subscriptions" do
    field :uuid, :string
    field :status, Ecto.Enum, values: [:active, :expired, :exhausted, :suspended, :cancelled]
    field :user_id, :integer
    field :product_id, :integer
    field :product_price_id, :integer
    field :billing_cycle, Ecto.Enum, values: Order.billing_cycles()
    field :snap_limit_device_count, :integer
    field :snap_limit_speed_mbps, :integer
    field :snap_limit_speed_up_mbps, :integer
    field :snap_limit_speed_down_mbps, :integer
    field :snap_base_quota_bytes, :integer
    field :extra_quota_bytes, :integer
    field :started_at, :utc_datetime_usec
    field :expired_at, :utc_datetime_usec

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def new_sub_changeset(user_subscription, attrs) do
    user_subscription
    |> cast(attrs, [:status, :user_id, :product_id, :product_price_id, :billing_cycle])
    |> validate_required([:status, :user_id, :product_id, :product_price_id, :billing_cycle])
    |> put_uuid()
  end

  defp put_uuid(%Ecto.Changeset{valid?: true} = changeset) do
    put_change(changeset, :uuid, Ecto.UUID.generate())
  end

  defp put_uuid(changeset), do: changeset

end
