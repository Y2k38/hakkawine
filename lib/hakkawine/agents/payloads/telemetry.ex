defmodule Hakkawine.Agents.Payloads.Telemetry do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :cpu_cores, :integer
    field :ram_total_mb, :integer
    field :ram_used_mb, :integer
    field :ssd_total_mb, :integer
    field :ssd_used_mb, :integer

    field :bandwidth_up_mbps, :integer
    field :bandwidth_down_mbps, :integer
  end

  def new(attrs) when is_map(attrs) do
    %__MODULE__{}
    |> cast(attrs, [
      :cpu_cores,
      :ram_total_mb,
      :ram_used_mb,
      :ssd_total_mb,
      :ssd_used_mb,
      :bandwidth_up_mbps,
      :bandwidth_down_mbps
    ])
    |> validate_required([
      :cpu_cores,
      :ram_total_mb,
      :ram_used_mb,
      :ssd_total_mb,
      :ssd_used_mb,
      :bandwidth_up_mbps,
      :bandwidth_down_mbps
    ])
    |> apply_action(:insert)
  end
end
