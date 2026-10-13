defmodule Hakkawine.Agents.Payloads.Traffic do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :recorded_at, :integer
    field :subscription_id, :integer
    field :upload_bytes, :integer
    field :download_bytes, :integer
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:recorded_at, :subscription_id, :upload_bytes, :download_bytes])
    |> validate_required([:recorded_at, :subscription_id, :upload_bytes, :download_bytes])
    |> validate_number(:upload_bytes, greater_than_or_equal_to: 0)
    |> validate_number(:download_bytes, greater_than_or_equal_to: 0)
  end

  def new(attrs) do
    %__MODULE__{}
    |> changeset(attrs)
    |> apply_action(:insert)
  end
end
