defmodule Hakkawine.Infra.OBFSDomain do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "obfs_domains" do
    field :domain, :string
    field :is_blocked, :boolean

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:domain, :is_blocked])
    |> validate_required([:domain, :is_blocked])
    |> validate_length(:domain, min: 1, max: 255, message: "must be between 1 and 255 characters long")
  end
end
