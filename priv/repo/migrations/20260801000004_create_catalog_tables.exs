defmodule Hakkawine.Repo.Migrations.CreateCatalogTables do
  use Ecto.Migration

  def up do
    create table(:products, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :code, :string, size: 64, null: false
      add :name, :string, size: 64, null: false
      add :description, :string
      add :type, :string, size: 20, null: false, default: "plan"
      add :status, :string, size: 20, null: false, default: "draft"
      add :charge_type, :string, size: 20, null: false, default: "recurring"
      add :tier_rank, :integer, null: false
      add :is_recommended, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0
      add :traffic_quota_bytes, :bigint
      add :limit_device_count, :integer
      add :limit_speed_mbps, :integer
      add :limit_speed_up_mbps, :integer
      add :limit_speed_down_mbps, :integer

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:products, :type_must_be_valid, check: "type IN ('plan', 'addon')")

    create constraint(:products, :status_must_be_valid,
             check: "status IN ('draft', 'active', 'archived')"
           )

    create constraint(:products, :charge_type_must_be_valid,
             check: "charge_type IN ('recurring', 'one_time')"
           )

    create unique_index(:products, [:code, :status],
             name: :uk_products_code_unique_draft_active,
             where: "status IN ('draft', 'active')"
           )

    create table(:product_prices, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :product_id, :bigint, null: false
      add :type, :string, size: 20, null: false, default: "monthly"
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :sort_order, :integer, null: false, default: 0
      add :is_default, :boolean, null: false, default: false

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:product_prices, :type_must_be_valid,
             check:
               "type IN ('monthly', 'quarterly', 'half_yearly', 'yearly', 'onetime', 'reset')"
           )

    create index(:product_prices, [:product_id], name: :idx_product_prices_product_id)

    create table(:plan_slots, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :product_id, :bigint, null: false
      add :slot_name, :string, size: 32, null: false
      add :selector, :map, null: false, default: "{}"
    end

    create unique_index(:plan_slots, [:product_id, :slot_name],
             name: :uk_plan_slots_product_slot_name
           )
  end

  def down do
    drop_if_exists table(:plan_slots)
    drop_if_exists table(:product_prices)
    drop_if_exists table(:products)
  end
end
