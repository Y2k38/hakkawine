defmodule Hakkawine.Agents.Envelope do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :action, :string
    field :req_id, :string
    field :code, :string
    field :message, :string
    field :payload, :map, default: %{}
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> validate_required([:action])
    |> apply_action(:insert)
  end
end
