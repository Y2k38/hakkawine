defmodule Hakkawine.Metrics.NodeTrafficLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "node_traffic_logs" do
    field :recorded_at, :utc_datetime_usec, primary_key: true
    field :node_id, :integer, primary_key: true
    field :user_id, :integer
    field :subscription_id, :integer
    field :upload_bytes, :integer
    field :download_bytes, :integer
    field :rate, :decimal
  end

  def changeset(traffic_log, attrs) do
    traffic_log
    |> cast(attrs, [:recorded_at, :node_id, :user_id, :subscription_id, :upload_bytes, :download_bytes, :rate])
    |> validate_required([:recorded_at, :node_id, :user_id, :subscription_id])
  end
end
