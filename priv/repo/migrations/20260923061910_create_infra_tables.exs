defmodule Hakkawine.Repo.Migrations.CreateInfraTables do
  use Ecto.Migration

  def up do
    create table(:obfs_domains, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :domain, :string, size: 255, null: false
      add :is_blocked, :boolean, null: false, default: false

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:obfs_domains, [:domain], name: :uk_obfs_domains_domain)

    execute "CREATE TYPE node_status AS ENUM('pending', 'active', 'offline', 'disabled');"

    execute "CREATE TYPE endpoint_pick_strategy AS ENUM ('pick_first', 'prefer_ipv4', 'prefer_ipv6', 'prefer_domain', 'pick_random');"

    create table(:nodes, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :name, :string, size: 32, null: false
      add :secret_hash, :string, size: 255, null: false
      add :status, :node_status, null: false, default: "pending"
      add :endpoints, :"varchar(255)[]", null: false
      add :pick_strategy, :endpoint_pick_strategy, null: false, default: "pick_first"
      add :protocol, :string, size: 16, null: false
      add :port_base, :integer, null: false
      add :stat_base, :integer, null: false
      add :port_capacity, :integer, null: false, default: 4096
      add :cpu_cores, :integer
      add :ram_mb, :integer
      add :ssd_mb, :integer
      add :bandwidth_mbps, :integer
      add :monthly_traffic_bytes, :bigint
      add :traffic_reset_day, :integer, null: false, default: 1
      add :weight, :integer, null: false, default: 1
      add :max_slot_count, :integer, null: false
      add :rate, :decimal, precision: 5, scale: 4, null: false, default: 1.00
      add :labels, :jsonb, null: false, default: fragment("'{}'::jsonb")

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:nodes, [:name], name: :uk_nodes_name)

    create index(:nodes, [:status], name: :idx_nodes_status)

    create index(:nodes, [:labels], using: :gin, name: :idx_nodes_labels)

    create table(:node_leases, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :node_id, :bigint, null: false
      add :subscription_id, :bigint, null: false
      add :plan_slot_id, :bigint, null: false
      add :port, :integer, null: false
      add :proxy_config, :jsonb, null: false
      add :is_active, :boolean, null: false, default: true

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:node_leases, [:subscription_id, :plan_slot_id], name: :uk_node_leases_sub_slot)

    create index(:node_leases, [:node_id], name: :idx_node_leases_node_id, where: "is_active = TRUE")
  end

  def down do
    drop_if_exists index(:node_leases, name: :idx_node_leases_node_id)
    drop_if_exists index(:node_leases, name: :uk_node_leases_sub_slot)
    drop_if_exists index(:nodes, name: :idx_nodes_labels)
    drop_if_exists index(:nodes, name: :idx_nodes_status)
    drop_if_exists index(:nodes, name: :uk_nodes_name)
    drop_if_exists index(:obfs_domains, name: :uk_obfs_domains_domain)

    drop_if_exists table(:node_leases)
    drop_if_exists table(:nodes)
    drop_if_exists table(:obfs_domains)

    execute "DROP TYPE IF EXISTS endpoint_pick_strategy;"
    execute "DROP TYPE IF EXISTS node_status;"
  end
end
