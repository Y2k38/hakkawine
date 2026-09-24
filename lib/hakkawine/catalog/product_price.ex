defmodule Hakkawine.Catalog.ProductPrice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Catalog.Product

  @primary_key {:id, :id, autogenerate: true}
  schema "product_prices" do
    field :type, Ecto.Enum, values: [:monthly, :quarterly, :half_yearly, :yearly, :onetime, :reset]
    field :amount, :decimal
    field :sort_order, :integer
    field :is_default, :boolean

    belongs_to :product, Product

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(product_prices, attrs) do
    product_prices
    |> cast(attrs, [:type, :amount, :sort_order, :is_default])
    |> validate_required([:type, :amount, :sort_order, :is_default])
  end

  def to_snapshot(%__MODULE__{} = price) do
    %{
      id: price.id,
      product_id: price.product_id,
      type: price.type,
      amount: Decimal.to_string(price.amount)
    }
  end

  def to_snapshot(nil), do: nil
end
