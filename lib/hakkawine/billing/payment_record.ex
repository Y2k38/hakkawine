defmodule Hakkawine.Billing.PaymentRecord do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Billing.SequenceNo
  # alias Hakkawine.Repo.Types.JSONValue

  @primary_key {:id, :id, autogenerate: true}
  schema "payment_records" do
    field :trade_no, :string
    field :gateway_trade_no, :string
    field :status, Ecto.Enum, values: [:pending, :paid, :failed, :expired, :refunded]
    field :order_id, :integer
    field :user_id, :integer
    field :payment_gateway_id, :integer
    field :payment_driver, :string
    field :amount, :decimal
    field :gateway_currency, :string
    field :gateway_amount, :decimal
    field :callback_payload, :map
    field :paid_at, :utc_datetime_usec

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(payment_gateways, attrs) do
    payment_gateways
    |> cast(attrs, [
      :gateway_trade_no, :status, :order_id, :user_id, :payment_gateway_id,
      :payment_driver, :amount, :gateway_currency, :gateway_amount, :callback_payload, :paid_at
    ])
    |> validate_required([
      :status, :order_id, :user_id, :payment_gateway_id, :payment_driver, :amount,
      :gateway_currency, :gateway_amount
    ])
    |> put_trade_no()
  end

  defp put_trade_no(changeset) do
    case get_field(changeset, :trade_no) do
      nil -> put_change(changeset, :trade_no, SequenceNo.generate())
      _ -> changeset
    end
  end
end
