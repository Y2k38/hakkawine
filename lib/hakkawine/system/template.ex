defmodule Hakkawine.System.Template do
  use Ecto.Schema
  import Ecto.Changeset
  import Hakkawine.Utils.ChangesetHelpers
  alias Hakkawine.Repo.Types.JSONValue

  @primary_key {:id, :id, autogenerate: true}
  schema "templates" do
    field :name, :string
    field :type, Ecto.Enum, values: [:client, :server]
    field :file_ext, Ecto.Enum, values: [:yaml, :yml, :json, :txt]
    field :match_rules, JSONValue
    field :content, :string

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(node_label, attrs) do
    node_label
    |> cast(attrs, [:name, :type, :file_ext, :match_rules, :content])
    |> validate_required([:name, :type, :file_ext, :match_rules, :content])
    |> validate_length(:name, min: 1, max: 64, message: "must be between 1 and 64 characters long")
    |> validate_json_field(:match_rules, max_bytes: 4096)
  end
end
