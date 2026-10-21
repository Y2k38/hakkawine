defmodule Hakkawine.Repo.Migrations.CreateAgentsTables do
  use Ecto.Migration

  def up do
    create table(:obfs_domains, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :domain, :string, size: 255, null: false
      add :is_blocked, :boolean, null: false, default: false

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create unique_index(:obfs_domains, [:domain], name: :uk_obfs_domains_domain)

    execute "CREATE TYPE agent_status AS ENUM('pending', 'active', 'offline', 'disabled');"

    create table(:agents, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :name, :string, size: 32, null: false
      add :client_id, :string, size: 64, null: false
      add :client_secret_hash, :string, size: 255, null: false
      add :status, :agent_status, null: false, default: "pending"
      add :address, :string, size: 255, null: false
      add :protocol, :string, size: 16, null: false
      add :port_base, :integer, null: false
      add :stat_base, :integer, null: false
      add :port_capacity, :integer, null: false, default: 4096
      add :max_sub_count, :integer, null: false
      add :rate, :decimal, precision: 5, scale: 4, null: false, default: 1.00
      add :weight, :integer, null: false, default: 1
      add :monthly_traffic_bytes, :bigint
      add :traffic_reset_day, :integer, null: false, default: 1
      add :labels, :jsonb, null: false, default: fragment("'{}'::jsonb")

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create unique_index(:agents, [:client_id], name: :uk_agents_client_id)

    create index(:agents, [:status], name: :idx_agents_status)

    create index(:agents, [:labels], using: :gin, name: :idx_agents_labels)

    create table(:agent_allocations, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :agent_id, :bigint, null: false
      add :subscription_id, :bigint, null: false
      add :plan_slot_id, :bigint, null: false
      add :port, :integer, null: false
      add :proxy_config, :jsonb, null: false
      add :is_active, :boolean, null: false, default: true

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create unique_index(:agent_allocations, [:subscription_id, :plan_slot_id],
             name: :uk_agent_allocations_sub_slot
           )

    create index(:agent_allocations, [:agent_id],
             name: :idx_agent_allocations_agent_id,
             where: "is_active = TRUE"
           )
  end

  def down do
    drop_if_exists index(:agent_allocations, name: :idx_agent_allocations_agent_id)
    drop_if_exists index(:agent_allocations, name: :uk_agent_allocations_sub_slot)
    drop_if_exists index(:agents, name: :idx_agents_labels)
    drop_if_exists index(:agents, name: :idx_agents_status)
    drop_if_exists index(:agents, name: :uk_agents_client_id)
    drop_if_exists index(:obfs_domains, name: :uk_obfs_domains_domain)

    drop_if_exists table(:agent_allocations)
    drop_if_exists table(:agents)
    drop_if_exists table(:obfs_domains)

    execute "DROP TYPE IF EXISTS agent_status;"
  end
end
