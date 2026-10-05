defmodule Hakkawine.Subscription.UserSubscription do
  use Ecto.Schema

  import Ecto.Query
  import Ecto.Changeset

  alias Hakkawine.Catalog.Product
  alias Hakkawine.Billing.Order
  alias Hakkawine.Infra.NodeLease

  @primary_key {:id, :id, autogenerate: true}
  schema "user_subscriptions" do
    field :user_id, :integer
    field :product_price_id, :integer
    field :uuid, :binary_id
    field :status, Ecto.Enum, values: [:active, :expired, :exhausted, :suspended, :cancelled]
    field :billing_cycle, Ecto.Enum, values: Order.billing_cycles()
    field :billing_day, :integer
    field :snap_limit_device_count, :integer
    field :snap_limit_speed_mbps, :integer
    field :snap_limit_speed_up_mbps, :integer
    field :snap_limit_speed_down_mbps, :integer
    field :snap_base_quota_bytes, :integer
    field :extra_quota_bytes, :integer
    field :started_at, :utc_datetime_usec
    field :expired_at, :utc_datetime_usec

    belongs_to :product, Product, foreign_key: :product_id

    has_many :node_leases, NodeLease, foreign_key: :subscription_id

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def new_sub_changeset(user_subscription, attrs \\ %{}) do
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
