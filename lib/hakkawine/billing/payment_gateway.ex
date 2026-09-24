defmodule Hakkawine.Billing.PaymentGateway do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Repo.Types.JSONValue

  @primary_key {:id, :id, autogenerate: true}
  schema "payment_gateways" do
    field :payment_driver, :string
    field :name, :string
    field :icon_url, :string
    field :min_tx_amount, :decimal
    field :max_tx_amount, :decimal
    field :handling_fee_fixed, :decimal
    field :handling_fee_percent, :decimal
    field :config, JSONValue
    field :is_enable, :boolean
    field :is_visible, :boolean
    field :is_default, :boolean
    field :sort_order, :integer

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(payment_gateway, attrs) do
    payment_gateway
    |> cast(attrs, [
      :payment_driver, :name, :icon_url, :min_tx_amount, :max_tx_amount,
      :handling_fee_fixed, :handling_fee_percent, :config, :is_enable,
      :is_visible, :is_default, :sort_order
    ])
  end

  def get_handle_fee(payment_gateway, amount) do
    case {payment_gateway.handling_fee_fixed, payment_gateway.handling_fee_percent} do
      {%Decimal{} = fixed, _} ->
        fixed
      {nil, %Decimal{} = percent} ->
        Decimal.mult(amount, percent)
      _ ->
        Decimal.new(0)
    end
  end

  def exceeds_max_limit?(%__MODULE__{max_tx_amount: nil}, %Decimal{}), do: false
  def exceeds_max_limit?(%__MODULE__{max_tx_amount: max_limit}, %Decimal{} = amount) do
    Decimal.gt?(amount, max_limit)
  end
end
