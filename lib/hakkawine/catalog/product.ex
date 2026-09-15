defmodule Hakkawine.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Catalog.PlanSlot
  alias Hakkawine.Catalog.ProductPrice

  @primary_key {:id, :id, autogenerate: true}
  schema "products" do
    field :code, :string
    field :name, :string
    field :description, :string
    field :type, Ecto.Enum, values: [:plan, :addon]
    field :status, Ecto.Enum, values: [:draft, :active, :archived]
    field :reset_policy, Ecto.Enum, values: [:recurring_cycle, :never]
    field :is_recommended, :boolean, default: false
    field :sort_order, :integer, default: 0
    field :traffic_quota_bytes, :integer
    field :limit_device_count, :integer
    field :limit_speed_mbps, :integer
    field :limit_speed_up_mbps, :integer
    field :limit_speed_down_mbps, :integer

    has_many :prices, ProductPrice, foreign_key: :product_id, on_replace: :delete_if_exists

    has_many :plan_slots, PlanSlot, foreign_key: :product_id, on_replace: :delete_if_exists

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:code])
    |> validate_required([:code])
    |> cast_assoc(:prices)
  end
end
