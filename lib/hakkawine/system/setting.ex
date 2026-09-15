defmodule Hakkawine.System.Setting do
  use Ecto.Schema
  import Ecto.Changeset
  import Hakkawine.Utils.ChangesetHelpers
  alias Hakkawine.Repo.Types.JSONValue

  @primary_key {:key, :string, autogenerate: false}

  schema "settings" do
    field :section, :string
    field :value, JSONValue
    field :description, :string

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(setting, attrs) do
    setting
    |> cast(attrs, [:section, :key, :value, :description])
    |> validate_required([:section, :key, :value, :description])
    |> validate_length(:section, min: 1, max: 32, message: "must be between 1 and 32 characters long")
    |> validate_length(:key, min: 1, max: 64, message: "must be between 1 and 64 characters long")
    |> validate_json_field(:value, max_bytes: 4096)
    |> validate_length(:description, min: 1, max: 255, message: "must be between 1 and 255 characters long")
  end
end
