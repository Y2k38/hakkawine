defmodule Hakkawine.Checkout.CheckoutForm do
  use Ecto.Schema

  import Ecto.Changeset

  alias Hakkawine.Billing.Order

  # require Logger

  @primary_key false
  embedded_schema do
    field :fallback_url, :string
    field :order_type, :string
    field :subscription_id, :integer
    field :target_product_code, :string
    field :current_product_code, :string
    field :billing_cycle, :string
    field :recharge_amount, :decimal
    field :payment_driver, :string, default: ""
    field :use_balance, :boolean, default: false
    field :coupon_code, :string, default: ""
    field :idempotency_key, :string
  end

  def parse(params) do
    %__MODULE__{}
    |> changeset(params)
    |> apply_action(:insert)
  end

  def changeset(schema, params \\ %{}) do
    schema
    |> cast(params, [
      :fallback_url,
      :order_type,
      :subscription_id,
      :target_product_code,
      :current_product_code,
      :billing_cycle,
      :recharge_amount,
      :payment_driver,
      :use_balance,
      :coupon_code,
      :idempotency_key
    ])
    |> validate_required([:fallback_url, :order_type, :idempotency_key])
    |> validate_inclusion(:order_type, Order.enum_strings(:type))
    |> validate_number(:subscription_id, greater_than: 0)
    |> validate_length(:target_product_code, max: 64)
    |> validate_length(:current_product_code, max: 64)
    |> validate_inclusion(:billing_cycle, Order.enum_strings(:billing_cycle))
    |> validate_number(:recharge_amount, greater_than: 0)
    |> validate_length(:payment_driver, max: 32)
    |> validate_length(:coupon_code, max: 32)
    |> validate_length(:idempotency_key, min: 16, max: 64)
    |> validate_by_order_type()
  end

  defp validate_by_order_type(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp validate_by_order_type(changeset) do
    case get_field(changeset, :order_type) do
      "plan_purchase" ->
        validate_required(changeset, [:target_product_code, :billing_cycle])

      "plan_renew" ->
        validate_required(changeset, [:subscription_id, :target_product_code, :billing_cycle])

      "plan_upgrade" ->
        validate_required(changeset, [
          :subscription_id,
          :current_product_code,
          :target_product_code
        ])

      "traffic_reset_fee" ->
        validate_required(changeset, [:subscription_id, :target_product_code])

      "traffic_addon" ->
        validate_required(changeset, [:subscription_id, :target_product_code])

      "balance_recharge" ->
        validate_required(changeset, [:recharge_amount])
    end
  end
end
