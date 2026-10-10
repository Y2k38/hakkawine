defmodule Hakkawine.Billing.PaymentMethod do
  use Ecto.Schema

  import Ecto.Changeset

  alias Hakkawine.Repo.Types.JSONValue

  @primary_key {:id, :id, autogenerate: true}
  schema "payment_methods" do
    field :code, :string
    field :payment_driver, :string
    field :name, :string
    field :description, :string
    field :icon_url, :string
    field :min_tx_amount, :decimal
    field :max_tx_amount, :decimal
    field :handling_fee_fixed, :decimal
    field :handling_fee_percent, :decimal
    field :is_enable, :boolean
    field :is_visible, :boolean
    field :is_default, :boolean
    field :sort_order, :integer

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(payment_method, attrs) do
    payment_method
    |> cast(attrs, [
      :code,
      :payment_driver,
      :name,
      :icon_url,
      :min_tx_amount,
      :max_tx_amount,
      :handling_fee_fixed,
      :handling_fee_percent,
      :is_enable,
      :is_visible,
      :is_default,
      :sort_order
    ])
  end

  def get_handle_fee(payment_method, amount) do
    case {payment_method.handling_fee_fixed, payment_method.handling_fee_percent} do
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
