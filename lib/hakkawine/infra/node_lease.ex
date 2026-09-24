defmodule Hakkawine.Infra.NodeLease do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "node_leases" do
    field :node_id, :integer
    field :subscription_id, :integer
    field :plan_slot_id, :integer
    field :port, :integer
    field :proxy_config, :map
    field :is_active, :integer

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(node, attrs) do
    node
    |> cast(attrs, [:node_id, :subscription_id, :plan_slot_id, :port, :proxy_config, :is_active])
    |> validate_required([:node_id, :subscription_id, :plan_slot_id, :port, :proxy_config, :is_active])
  end
end
