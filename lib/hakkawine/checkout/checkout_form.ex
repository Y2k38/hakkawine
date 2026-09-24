defmodule Hakkawine.Checkout.CheckoutForm do
  import Ecto.Changeset
  alias Hakkawine.Billing.Order

  @types %{
    fallback_url: :string,
    order_type: :string,
    subscription_id: :integer,
    target_product_code: :string,
    current_product_code: :string,
    billing_cycle: :string,
    recharge_amount: :decimal,
    payment_driver: :string,
    use_balance: :boolean,
    coupon_code: :string,
    idempotency_key: :string
  }

  @default_values %{
    coupon_code: "",
    payment_driver: "",
    use_balance: false
  }

  def parse(params) do
    params
    |> changeset()
    |> apply_action(:insert)
  end

  def changeset(params \\ %{}) do
    {%{}, @types}
    |> cast(params, Map.keys(@types))
    |> set_default_values()
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

  defp set_default_values(changeset) do
    Enum.reduce(@default_values, changeset, fn {field, default_val}, acc_changeset ->
      case get_field(acc_changeset, field) do
        nil -> put_change(acc_changeset, field, default_val)
        _value -> acc_changeset
      end
    end)
  end

  defp validate_by_order_type(%Ecto.Changeset{valid?: false} = changeset), do: changeset

  defp validate_by_order_type(changeset) do
    case get_field(changeset, :order_type) do
      "plan_purchase" ->
        validate_required(changeset, [:target_product_code, :billing_cycle])

      "plan_renew" ->
        validate_required(changeset, [:subscription_id, :target_product_code, :billing_cycle])

      "plan_upgrade" ->
        validate_required(changeset, [:subscription_id, :current_product_code, :target_product_code])

      "traffic_reset_fee" ->
        validate_required(changeset, [:subscription_id, :target_product_code])

      "traffic_addon" ->
        validate_required(changeset, [:subscription_id, :target_product_code])

      "balance_recharge" ->
        validate_required(changeset, [:recharge_amount])
    end
  end
end
