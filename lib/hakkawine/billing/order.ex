defmodule Hakkawine.Billing.Order do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Billing.SequenceNo

  @billing_cycles [:monthly, :quarterly, :half_yearly, :yearly, :one_time]
  def billing_cycles, do: @billing_cycles

  @primary_key {:id, :id, autogenerate: true}
  schema "orders" do
    field :order_no, :string
    field :user_id, :integer
    field :type, Ecto.Enum, values: [:plan_purchase, :plan_renew, :plan_upgrade, :traffic_reset_fee, :traffic_addon, :balance_recharge]
    field :status, Ecto.Enum, values: [:pending, :processing, :completed, :cancelled, :failed, :refunded, :disputed]
    field :product_id, :integer
    field :product_price_id, :integer
    field :subscription_id, :integer
    field :billing_cycle, Ecto.Enum, values: @billing_cycles
    field :subtotal_amount, :decimal
    field :discount_amount, :decimal
    field :balance_amount, :decimal
    field :payment_fee, :decimal
    field :total_amount, :decimal
    field :coupon_code, :string
    field :coupon_snapshot, :map
    field :price_snapshot, :map
    field :payment_gateway_id, :integer
    field :payment_driver, :string
    field :paid_at, :utc_datetime_usec
    field :note, :string

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def enum_strings(field) when field in [:type, :billing_cycle] do
    __MODULE__
    |> Ecto.Enum.values(field)
    |> Enum.map(&to_string/1)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [
      :order_no, :user_id, :type, :status, :product_id, :product_price_id,
      :subscription_id, :billing_cycle, :subtotal_amount, :discount_amount,
      :balance_amount, :payment_fee, :total_amount, :coupon_code,
      :coupon_snapshot, :price_snapshot, :payment_gateway_id,
      :payment_driver, :paid_at, :note
    ])
    |> validate_required([
      :user_id, :type, :status, :subtotal_amount,
      :discount_amount, :balance_amount, :payment_fee, :total_amount
    ])
    |> validate_number(:subtotal_amount, greater_than_or_equal_to: 0)
    |> validate_number(:total_amount, greater_than_or_equal_to: 0)
    |> validate_length(:order_no, max: 32)
    |> validate_length(:payment_driver, max: 64)
    |> validate_length(:coupon_code, max: 32)
    |> put_order_no()
  end

  defp put_order_no(changeset) do
    case get_field(changeset, :order_no) do
      nil -> put_change(changeset, :order_no, SequenceNo.generate())
      _ -> changeset
    end
  end
end
