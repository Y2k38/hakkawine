defmodule Hakkawine.Repo.Migrations.CreateCatalogTables do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE product_type AS ENUM('plan', 'addon');"
    execute "CREATE TYPE product_status AS ENUM('draft', 'active', 'archived');"
    execute "CREATE TYPE traffic_reset_policy AS ENUM('recurring_cycle', 'never');"

    create table(:products, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :code, :string, size: 64, null: false
      add :name, :string, size: 64, null: false
      add :description, :string
      add :type, :product_type, null: false, default: "plan"
      add :status, :product_status, null: false, default: "draft"
      add :reset_policy, :traffic_reset_policy, null: false, default: "recurring_cycle"
      add :is_recommended, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      add :traffic_quota_bytes, :bigint
      add :limit_device_count, :integer
      add :limit_speed_mbps, :integer
      add :limit_speed_up_mbps, :integer
      add :limit_speed_down_mbps, :integer

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:products, [:code, :status], name: :uk_products_code_unique_draft_active, where: "status IN ('draft', 'active')")

    execute "CREATE TYPE price_type AS ENUM('recurring', 'one_time', 'reset');"
    execute "CREATE TYPE renew_interval AS ENUM('monthly', 'quarterly', 'half_yearly', 'yearly', 'none');"

    create table(:product_prices, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :product_id, :bigint, null: false
      add :type, :price_type, null: false, default: "recurring"
      add :renew_interval, :renew_interval, null: false, default: "monthly"
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :sort_order, :integer, null: false, default: 0
      add :is_default, :boolean, null: false, default: false

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create index(:product_prices, [:product_id], name: :idx_product_prices_product_id)

    create table(:plan_slots, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :product_id, :bigint, null: false
      add :slot_name, :string, size: 32, null: false
      add :selector, :map, null: false, default: "{}"
    end

    create unique_index(:plan_slots, [:product_id, :slot_name], name: :uk_plan_slots_product_slot_name)
  end

  def down do
    drop_if_exists index(:plan_slots, name: :uk_plan_slots_product_slot_name)
    drop_if_exists index(:product_prices, name: :idx_product_prices_product_id)
    drop_if_exists index(:products, name: :uk_products_code_unique_draft_active)

    drop table(:plan_slots)
    drop table(:product_prices)
    drop table(:products)

    execute "DROP TYPE IF EXISTS renew_interval;"
    execute "DROP TYPE IF EXISTS price_type;"
    execute "DROP TYPE IF EXISTS traffic_reset_policy;"
    execute "DROP TYPE IF EXISTS product_status;"
    execute "DROP TYPE IF EXISTS product_type;"
  end
end
