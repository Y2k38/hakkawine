defmodule Hakkawine.Subscription.Profile do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :content, :string
    field :type, :string, default: "application/yaml"
    field :filename, :string, default: "config.yaml"
    field :title, :string
    field :update_interval, :integer, default: 24
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> apply_action(:insert)
  end
end
