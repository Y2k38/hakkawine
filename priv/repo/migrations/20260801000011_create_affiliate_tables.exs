defmodule Hakkawine.Repo.Migrations.CreateAffiliateTables do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE rule_type AS ENUM('first_order_percent', 'all_order_percent');"

    create table(:commission_rules, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :name, :string, size: 100, null: false
      add :rule_type, :rule_type, null: false
      add :reward_rate, :decimal, precision: 5, scale: 4, null: false, default: 0
      add :user_id, :bigint
      add :is_active, :boolean, null: false, default: true

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    execute "CREATE TYPE settlement_status AS ENUM('pending', 'unlocked', 'cancelled');"

    create table(:commission_settlements, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :referrer_id, :bigint, null: false
      add :buyer_id, :bigint, null: false
      add :order_id, :bigint, null: false
      add :order_amount, :decimal, precision: 38, scale: 18, null: false
      add :commission_rate, :decimal, precision: 5, scale: 4, null: false
      add :commission_amount, :decimal, precision: 38, scale: 18, null: false
      add :status, :settlement_status, null: false, default: "pending"
      add :freeze_days, :integer, null: false, default: 30
      add :unlock_at, :timestamptz, null: false
      add :unlocked_at, :timestamptz

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create index(:commission_settlements, [:status, :unlock_at],
             name: :idx_commission_settlements_unlock,
             where: "status = 'pending'"
           )

    create index(:commission_settlements, [:order_id], name: :idx_commission_settlements_order)

    create table(:user_commissions, primary_key: false) do
      add :user_id, :bigint, primary_key: true, null: false
      add :commission_balance, :decimal, precision: 38, scale: 18, null: false, default: 0
      add :total_earned, :decimal, precision: 38, scale: 18, null: false, default: 0

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    execute "CREATE TYPE commission_log_type AS ENUM('referral_reward', 'milestone_reward', 'transfer_to_balance', 'withdraw_payout', 'withdraw_reject_refund');"

    create table(:commission_logs, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :action_type, :commission_log_type, null: false
      add :before_amount, :decimal, precision: 38, scale: 18, null: false
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :after_amount, :decimal, precision: 38, scale: 18, null: false
      add :settlement_id, :bigint
      add :withdrawal_id, :bigint
      add :remark, :string, size: 255

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create index(:commission_logs, [:user_id, "created_at DESC"], name: :idx_commission_logs_user)

    create table(:payout_methods, primary_key: false) do
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
      add :sort_order, :integer, null: false, default: 0

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:payout_methods, [:code], name: :uk_payout_methods_code)

    create table(:payout_accounts, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :payout_method_id, :bigint, null: false
      add :name, :string, size: 64, null: false
      add :driver, :string, size: 32, null: false
      add :config, :jsonb, null: false, default: fragment("'{}'::jsonb")
      add :weight, :integer, null: false, default: 10
      add :balance, :decimal, precision: 38, scale: 18
      add :is_enable, :boolean, null: false, default: true
      add :sort_order, :integer, null: false, default: 0

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    execute "CREATE TYPE withdrawal_status AS ENUM('pending', 'approved', 'completed', 'rejected');"

    create table(:withdrawal_records, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :sn, :string, size: 64, null: false
      add :user_id, :bigint, null: false
      add :payout_channel_id, :bigint
      add :payout_method, :string, size: 32, null: false
      add :payout_driver, :string, size: 32, null: false
      add :currency, :string, size: 16, null: false, default: "USD"
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :handling_fee, :decimal, precision: 38, scale: 18, null: false, default: 0
      add :actual_amount, :decimal, precision: 38, scale: 18, null: false
      add :payout_account, :decimal, precision: 38, scale: 18, null: false
      add :payout_identity, :jsonb, default: fragment("'{}'::jsonb")
      add :status, :withdrawal_status, null: false, default: "pending"
      add :reject_reason, :string, size: 255
      add :payout_trade_no, :string, size: 255
      add :handled_at, :timestamptz

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:withdrawal_records, [:sn], name: :uk_withdrawal_records_sn)

    create index(:withdrawal_records, [:user_id, :status], name: :idx_withdrawals_user)

    create index(:withdrawal_records, [:created_at], name: :idx_withdrawals_created_at)
  end

  def down do
    drop_if_exists index(:withdrawal_records, name: :idx_withdrawals_created_at)
    drop_if_exists index(:withdrawal_records, name: :idx_withdrawals_user)
    drop_if_exists index(:withdrawal_records, name: :uk_withdrawal_records_sn)
    drop_if_exists index(:payout_methods, name: :uk_payout_methods_code)
    drop_if_exists index(:commission_logs, name: :idx_commission_logs_user)
    drop_if_exists index(:commission_settlements, name: :idx_commission_settlements_order)
    drop_if_exists index(:commission_settlements, name: :idx_commission_settlements_unlock)

    drop_if_exists table(:withdrawal_records)
    drop_if_exists table(:payout_accounts)
    drop_if_exists table(:payout_methods)
    drop_if_exists table(:commission_logs)
    drop_if_exists table(:user_commissions)
    drop_if_exists table(:commission_settlements)
    drop_if_exists table(:commission_rules)

    execute "DROP TYPE IF EXISTS withdrawal_status;"
    execute "DROP TYPE IF EXISTS commission_log_type;"
    execute "DROP TYPE IF EXISTS settlement_status;"
    execute "DROP TYPE IF EXISTS rule_type;"
  end
end
