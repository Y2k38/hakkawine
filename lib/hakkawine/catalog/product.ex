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
    field :charge_type, Ecto.Enum, values: [:recurring, :one_time]
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
    |> cast(attrs, [:code, :name, :description, :type, :status, :charge_type, :is_recommended, :sort_order, :traffic_quota_bytes, :limit_device_count, :limit_speed_mbps, :limit_speed_up_mbps, :limit_speed_down_mbps])
    |> validate_required([:code, :name, :type, :status, :charge_type, :is_recommended, :sort_order])
    |> validate_length(:code, max: 64)
    |> validate_length(:name, max: 64)
    |> cast_assoc(:prices)
    |> validate_length(:prices, min: 1, message: "At least one price configuration must be provided.")
    |> cast_assoc(:plan_slots)
    |> validate_plan_slots_if_plan()
  end

  defp validate_plan_slots_if_plan(changeset) do
    type = get_field(changeset, :type)

    if type in ["plan", :plan] do
      validate_length(changeset, :plan_slots, min: 1, message: "At least one slot configuration must be provided.")
    else
      changeset
    end
  end
end
