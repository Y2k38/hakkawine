defmodule Hakkawine.System.NodeLabel do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "node_labels" do
    field :category, :string
    field :key, :string
    field :name, :string
    field :is_enabled, :string

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(node_label, attrs) do
    node_label
    |> cast(attrs, [:category, :key, :name, :is_enabled])
    |> validate_required([:category, :key, :name, :is_enabled])
    |> validate_length(:category, min: 1, max: 32, message: "must be between 1 and 32 characters long")
    |> validate_length(:key, min: 1, max: 64, message: "must be between 1 and 64 characters long")
    |> validate_length(:name, min: 1, max: 64, message: "must be between 1 and 64 characters long")
  end
end
