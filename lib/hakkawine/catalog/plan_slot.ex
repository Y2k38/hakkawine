defmodule Hakkawine.Catalog.PlanSlot do
  use Ecto.Schema
  import Ecto.Changeset
  alias Hakkawine.Catalog.Product

  @primary_key {:id, :id, autogenerate: true}
  schema "plan_slots" do
    field :slot_name, :string
    field :selector, :map

    belongs_to :product, Product
  end

  @doc false
  def changeset(plan_slots, attrs) do
    plan_slots
    |> cast(attrs, [:slot_name, :selector])
    |> validate_required([:slot_name, :selector])
    |> validate_length(:slot_name, max: 32)
  end
end
