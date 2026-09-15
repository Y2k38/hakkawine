defmodule Hakkawine.Catalog.ProductPrice do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Catalog.Product

  @primary_key {:id, :id, autogenerate: true}
  schema "product_prices" do
    field :type, Ecto.Enum, values: [:recurring, :one_time, :reset]
    field :renew_interval, Ecto.Enum, values: [:monthly, :quarterly, :half_yearly, :yearly, :none]
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
    |> cast(attrs, [:type, :status, :renew_interval, :amount])
    |> validate_required([:type, :status, :renew_interval, :amount])
  end
end
