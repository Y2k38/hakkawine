defmodule Hakkawine.Affiliate.CommissionRule do
  use Ecto.Schema

  import Ecto.Changeset

  alias Hakkawine.Catalog.Product

  @primary_key {:id, :id, autogenerate: true}
  schema "commission_rules" do
    field :name, :string
    field :reward_cycle, Ecto.Enum, values: [:first_order, :recurring]
    field :reward_type, Ecto.Enum, values: [:percentage, :fixed]
    field :reward_value, :decimal
    field :is_active, :boolean
    field :sort_order, :integer

    belongs_to :product, Product, foreign_key: :product_id

    timestamps(type: :utc_datetime_usec)
  end
end
