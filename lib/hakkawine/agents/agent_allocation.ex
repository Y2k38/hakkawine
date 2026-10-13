defmodule Hakkawine.Agents.AgentAllocation do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "agent_allocations" do
    field :agent_id, :integer
    field :subscription_id, :integer
    field :plan_slot_id, :integer
    field :port, :integer
    field :is_active, :boolean

    embeds_one :proxy_config, Hakkawine.ProxyDrivers.Config, on_replace: :update

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(allocs, attrs) do
    allocs
    |> cast(attrs, [:agent_id, :subscription_id, :plan_slot_id, :port, :is_active])
    |> validate_required([
      :agent_id,
      :subscription_id,
      :plan_slot_id,
      :port,
      :is_active
    ])
    |> cast_embed(:proxy_config, required: true)
  end
end
