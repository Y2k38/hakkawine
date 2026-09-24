defmodule Hakkawine.Repo.Migrations.CreateCheckoutTables do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE order_type AS ENUM('plan_purchase', 'plan_renew', 'plan_upgrade', 'traffic_reset_fee', 'traffic_addon', 'balance_recharge');"
    execute "CREATE TYPE order_status AS ENUM('pending', 'processing', 'completed', 'cancelled', 'failed', 'refunded', 'disputed');"
    execute "CREATE TYPE billing_cycle AS ENUM('monthly', 'quarterly', 'half_yearly', 'yearly', 'one_time');"

    create table(:orders, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :order_no, :string, size: 64, null: false
      add :user_id, :bigint, null: false
      add :type, :order_type, null: false, default: "plan_purchase"
      add :status, :order_status, null: false, default: "pending"
      add :product_id, :bigint
      add :product_price_id, :bigint
      add :subscription_id, :bigint
      add :billing_cycle, :billing_cycle
      add :subtotal_amount, :decimal, precision: 38, scale: 18, null: false
      add :discount_amount, :decimal, precision: 38, scale: 18, null: false
      add :balance_amount, :decimal, precision: 38, scale: 18, null: false
      add :payment_fee, :decimal, precision: 38, scale: 18, null: false
      add :total_amount, :decimal, precision: 38, scale: 18, null: false
      add :coupon_code, :string, size: 32
      add :coupon_snapshot, :map
      add :price_snapshot, :map
      add :payment_gateway_id, :bigint
      add :payment_driver, :string, size: 32
      add :paid_at, :timestamptz
      add :note, :string

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:orders, [:order_no], name: :uk_orders_order_no)
    create index(:orders, [:user_id, :status, "created_at DESC"], name: :idx_orders_user_status_created)

    create table(:payment_gateways, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :payment_driver, :string, size: 32, null: false
      add :name, :string, size: 64, null: false
      add :icon_url, :string, size: 255, null: false
      add :min_tx_amount, :decimal, precision: 38, scale: 18, null: false, default: 0
      add :max_tx_amount, :decimal, precision: 38, scale: 18
      add :handling_fee_fixed, :decimal, precision: 38, scale: 18
      add :handling_fee_percent, :decimal, precision: 38, scale: 18
      add :config, :map, null: false, default: %{}
      add :is_enable, :boolean, null: false, default: true
      add :is_visible, :boolean, null: false, default: true
      add :is_default, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    execute "CREATE TYPE payment_record_status AS ENUM('pending', 'paid', 'failed', 'expired', 'refunded');"

    create table(:payment_records, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :trade_no, :string, size: 128, null: false
      add :gateway_trade_no, :string, size: 128
      add :status, :payment_record_status, null: false, default: "pending"
      add :order_id, :bigint, null: false
      add :user_id, :bigint, null: false
      add :payment_gateway_id, :bigint, null: false
      add :payment_driver, :string, size: 32, null: false
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :gateway_currency, :string, size: 16, null: false
      add :gateway_amount, :decimal, precision: 38, scale: 18, null: false
      add :callback_payload, :map
      add :paid_at, :timestamptz

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:payment_records, [:trade_no], name: :uk_payment_records_trade_no)
    create unique_index(:payment_records, [:payment_gateway_id, :gateway_trade_no], name: :uk_payment_records_gateway_trade, where: "gateway_trade_no IS NOT NULL")
    create index(:payment_records, [:order_id, :status], name: :idx_payment_records_order_status)
    create index(:payment_records, [:user_id, :status, "created_at DESC"], name: :idx_payment_records_user_status_created)

    create table(:user_balances, primary_key: false) do
      add :user_id, :bigint, primary_key: true, null: false
      add :balance, :decimal, precision: 38, scale: 18, null: false, default: 0

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    execute "CREATE TYPE balance_log_type AS ENUM('recharge', 'recharge_bonus', 'order_payment', 'order_refund', 'commission_transfer', 'system_bonus', 'system_deduct');"

    create table(:user_balance_logs, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :action_type, :balance_log_type, null: false
      add :before_balance, :decimal, precision: 38, scale: 18, null: false
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :after_balance, :decimal, precision: 38, scale: 18, null: false
      add :ref_type, :string, size: 50, null: false
      add :ref_id, :bigint, null: false
      add :operator_id, :bigint
      add :remark, :string, size: 255

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create index(:user_balance_logs, [:user_id, "created_at DESC"], name: :idx_balance_logs_user_id)
  end

  def down do
    drop_if_exists index(:orders, name: :idx_balance_logs_user_id)
    drop_if_exists index(:orders, name: :idx_payment_records_user_status_created)
    drop_if_exists index(:orders, name: :idx_payment_records_order_status)
    drop_if_exists index(:orders, name: :uk_payment_records_gateway_trade)
    drop_if_exists index(:orders, name: :uk_payment_records_trade_no)
    drop_if_exists index(:orders, name: :idx_orders_user_status_created)
    drop_if_exists index(:orders, name: :uk_orders_order_no)

    drop_if_exists table(:user_balance_logs)
    drop_if_exists table(:user_balances)
    drop_if_exists table(:payment_records)
    drop_if_exists table(:payment_gateways)
    drop_if_exists table(:orders)

    execute "DROP TYPE IF EXISTS balance_log_type;"
    execute "DROP TYPE IF EXISTS payment_record_status;"
    execute "DROP TYPE IF EXISTS billing_cycle;"
    execute "DROP TYPE IF EXISTS order_status;"
    execute "DROP TYPE IF EXISTS order_type;"
  end
end
