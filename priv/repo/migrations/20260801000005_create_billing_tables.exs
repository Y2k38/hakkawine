defmodule Hakkawine.Repo.Migrations.CreateBillingTables do
  use Ecto.Migration

  def up do
    create table(:orders, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :order_no, :string, size: 64, null: false
      add :user_id, :bigint, null: false
      add :type, :string, size: 20, null: false, default: "plan_purchase"
      add :status, :string, size: 20, null: false, default: "pending"
      add :product_id, :bigint
      add :product_price_id, :bigint
      add :subscription_id, :bigint
      add :billing_cycle, :string, size: 20
      add :subtotal_amount, :decimal, precision: 38, scale: 18, null: false
      add :discount_amount, :decimal, precision: 38, scale: 18, null: false
      add :balance_amount, :decimal, precision: 38, scale: 18, null: false
      add :payment_fee, :decimal, precision: 38, scale: 18, null: false
      add :total_amount, :decimal, precision: 38, scale: 18, null: false
      add :coupon_code, :string, size: 32
      add :coupon_snapshot, :map
      add :price_snapshot, :map
      add :payment_method_id, :bigint
      add :payment_driver, :string, size: 32
      add :paid_at, :timestamptz
      add :note, :string

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:orders, :type_must_be_valid,
             check:
               "type IN ('plan_purchase', 'plan_renew', 'plan_upgrade', 'traffic_reset_fee', 'traffic_addon', 'balance_recharge')"
           )

    create constraint(:orders, :status_must_be_valid,
             check:
               "status IN ('pending', 'processing', 'completed', 'cancelled', 'failed', 'refunded', 'disputed')"
           )

    create constraint(:orders, :billing_cycle_must_be_valid,
             check:
               "billing_cycle IN ('monthly', 'quarterly', 'half_yearly', 'yearly', 'one_time')"
           )

    create unique_index(:orders, [:order_no], name: :uk_orders_order_no)

    create index(:orders, [:user_id, :status, "inserted_at DESC"],
             name: :idx_orders_user_status_created
           )

    create table(:payment_methods, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :code, :string, size: 32, null: false
      add :driver, :string, size: 32, null: false
      add :name, :string, size: 64, null: false
      add :description, :string, size: 255, null: false
      add :icon_url, :string, size: 255, null: false
      add :min_tx_amount, :decimal, precision: 38, scale: 18
      add :max_tx_amount, :decimal, precision: 38, scale: 18
      add :handling_fee_fixed, :decimal, precision: 38, scale: 18
      add :handling_fee_percent, :decimal, precision: 38, scale: 18
      add :is_enable, :boolean, null: false, default: true
      add :is_visible, :boolean, null: false, default: true
      add :is_default, :boolean, null: false, default: false
      add :sort_order, :integer, null: false, default: 0

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create unique_index(:payment_methods, [:code], name: :uk_payment_methods_code)

    create table(:payment_accounts, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :payment_method_id, :bigint, null: false
      add :name, :string, size: 64, null: false
      add :is_enable, :boolean, null: false, default: true
      add :weight, :integer, null: false, default: 1
      add :config, :jsonb, null: false, default: "{}"
      add :min_tx_amount, :decimal, precision: 38, scale: 18
      add :max_tx_amount, :decimal, precision: 38, scale: 18
      add :daily_limit_amount, :decimal, precision: 38, scale: 18
      add :daily_accumulated_amount, :decimal, precision: 38, scale: 18, default: 0
      add :daily_limit_count, :integer
      add :daily_accumulated_count, :integer, null: false, default: 0
      add :yearly_limit_amount, :decimal, precision: 38, scale: 18
      add :yearly_accumulated_amount, :decimal, precision: 38, scale: 18, default: 0
      add :last_daily_reset_at, :timestamptz, default: fragment("NOW()")
      add :last_yearly_reset_at, :timestamptz, default: fragment("NOW()")

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create index(:payment_accounts, [:payment_method_id, :is_enable],
             name: :idx_payment_accounts_method
           )

    create table(:payment_records, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :tx_no, :string, size: 128, null: false
      add :gateway_tx_no, :string, size: 128
      add :status, :string, size: 20, null: false, default: "pending"
      add :order_id, :bigint, null: false
      add :user_id, :bigint, null: false
      add :payment_method_id, :bigint, null: false
      add :payment_account_id, :bigint, null: false
      add :payment_driver, :string, size: 32, null: false
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :gateway_currency, :string, size: 16, null: false
      add :gateway_amount, :decimal, precision: 38, scale: 18, null: false
      add :callback_payload, :map
      add :paid_at, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:payment_records, :status_must_be_valid,
             check: "status IN ('pending', 'paid', 'failed', 'expired', 'refunded')"
           )

    create unique_index(:payment_records, [:tx_no], name: :uk_payment_records_tx_no)

    create unique_index(:payment_records, [:payment_method_id, :gateway_tx_no],
             name: :uk_payment_records_gateway_trade,
             where: "gateway_tx_no IS NOT NULL"
           )

    create index(:payment_records, [:order_id, :status], name: :idx_payment_records_order_status)

    create index(:payment_records, [:user_id, :status, "inserted_at DESC"],
             name: :idx_payment_records_user_status_created
           )

    create table(:topup_rules, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :min_amount, :decimal, precision: 38, scale: 18, null: false
      add :max_amount, :decimal, precision: 38, scale: 18
      add :bonus_type, :string, size: 20
      add :bonus_value, :decimal, precision: 38, scale: 18

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:topup_rules, :bonus_type_must_be_valid,
             check: "bonus_type IN ('fixed_amount', 'percentage')"
           )

    create table(:user_balances, primary_key: false) do
      add :user_id, :bigint, primary_key: true, null: false
      add :balance, :decimal, precision: 38, scale: 18, null: false, default: 0

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create table(:user_balance_logs, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :action_type, :string, size: 20, null: false
      add :before_balance, :decimal, precision: 38, scale: 18, null: false
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :after_balance, :decimal, precision: 38, scale: 18, null: false
      add :ref_type, :string, size: 50, null: false
      add :ref_id, :bigint, null: false
      add :operator_id, :bigint
      add :remark, :string, size: 255

      timestamps(
        type: :timestamptz,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create constraint(:user_balance_logs, :action_type_must_be_valid,
             check:
               "action_type IN ('recharge', 'recharge_bonus', 'order_payment', 'order_refund', 'commission_transfer', 'system_bonus', 'system_deduct')"
           )

    create index(:user_balance_logs, [:user_id, "inserted_at DESC"],
             name: :idx_balance_logs_user_id
           )
  end

  def down do
    drop_if_exists table(:user_balance_logs)
    drop_if_exists table(:user_balances)
    drop_if_exists table(:topup_rules)
    drop_if_exists table(:payment_accounts)
    drop_if_exists table(:payment_records)
    drop_if_exists table(:payment_methods)
    drop_if_exists table(:orders)
  end
end
