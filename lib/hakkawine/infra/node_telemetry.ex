defmodule Hakkawine.Infra.NodeTelemetry do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :reported_at, :utc_datetime_usec
    field :agent_version, :string
    field :uptime_seconds, :integer, default: 0

    field :max_sub_count, :integer, default: 0
    field :assigned_sub_ids, {:array, :integer}, default: []

    field :cpu_cores, :integer, default: 1
    field :cpu_usage_pct, :float, default: 0.0
    field :cpu_load_5m, :float, default: 0.0

    field :ram_used_mb, :integer, default: 0
    field :ram_total_mb, :integer, default: 0
    field :ssd_used_mb, :integer, default: 0
    field :ssd_total_mb, :integer, default: 0

    field :speed_up_bps, :integer, default: 0
    field :speed_down_bps, :integer, default: 0
    field :bandwidth_up_mbps, :integer, default: 0
    field :bandwidth_down_mbps, :integer, default: 0

    field :traffic_up_bytes, :integer, default: 0
    field :traffic_down_bytes, :integer, default: 0
    field :traffic_used_bytes, :integer, default: 0
    field :traffic_limit_bytes, :integer, default: 0
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, __MODULE__.__schema__(:fields))
    |> apply_action(:insert)
  end
end
