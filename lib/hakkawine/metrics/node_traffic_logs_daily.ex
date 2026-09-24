defmodule Hakkawine.Metrics.NodeTrafficLogDaily do
  use Ecto.Schema

  @primary_key false
  schema "node_traffic_logs_daily" do
    field :bucket_5m, :utc_datetime
    field :node_id, :integer
    field :user_id, :integer
    field :subscription_id, :integer
    field :upload_bytes, :integer
    field :download_bytes, :integer
    field :rated_upload_bytes, :integer
    field :rated_download_bytes, :integer
    field :rated_total_bytes, :integer
  end
end
