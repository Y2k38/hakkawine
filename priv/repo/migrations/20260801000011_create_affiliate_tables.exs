defmodule Hakkawine.Repo.Migrations.CreateAffiliateTables do
  use Ecto.Migration

  def up do
    create table(:commission_rules, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :product_id, :bigint, null: false
      add :name, :string, size: 100, null: false
      add :reward_cycle, :string, size: 20, null: false
      add :reward_type, :string, size: 20, null: false
      add :reward_value, :decimal, precision: 38, scale: 18, null: false, default: 0
      add :is_active, :boolean, null: false, default: true
      add :sort_order, :integer, null: false, default: 0

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:commission_rules, :reward_cycle_must_be_valid,
             check: "reward_cycle IN ('first_order', 'recurring')"
           )

    create constraint(:commission_rules, :reward_type_must_be_valid,
             check: "reward_type IN ('percentage', 'fixed')"
           )

    create unique_index(:commission_rules, [:product_id], name: :uk_commission_rules_product)

    create table(:user_commission_settlements, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :rule_id, :bigint, null: false
      add :beneficiary_user_id, :bigint, null: false
      add :buyer_id, :bigint, null: false
      add :order_id, :bigint, null: false
      add :order_amount, :decimal, precision: 38, scale: 18, null: false
      add :commission_rate, :decimal, precision: 5, scale: 4, null: false
      add :commission_amount, :decimal, precision: 38, scale: 18, null: false
      add :status, :string, size: 20, null: false, default: "pending"
      add :freeze_days, :integer, null: false, default: 30
      add :expected_unlock_at, :timestamptz, null: false
      add :actual_unlocked_at, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:user_commission_settlements, :status_must_be_valid,
             check: "status IN ('pending', 'unlocked', 'cancelled')"
           )

    create index(:user_commission_settlements, [:status, :expected_unlock_at],
             name: :idx_commission_settlements_unlock,
             where: "status = 'pending'"
           )

    create index(:user_commission_settlements, [:order_id],
             name: :idx_commission_settlements_order
           )

    create index(:user_commission_settlements, [:beneficiary_user_id, :status],
             name: :idx_commission_settlements_beneficiary
           )

    create table(:user_commissions, primary_key: false) do
      add :user_id, :bigint, primary_key: true, null: false
      add :commission_balance, :decimal, precision: 38, scale: 18, null: false, default: 0
      add :total_earned, :decimal, precision: 38, scale: 18, null: false, default: 0

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create table(:user_commission_logs, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :action_type, :string, size: 20, null: false
      add :before_amount, :decimal, precision: 38, scale: 18, null: false
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :after_amount, :decimal, precision: 38, scale: 18, null: false
      add :settlement_id, :bigint
      add :withdrawal_id, :bigint
      add :remark, :string, size: 255

      timestamps(
        type: :timestamptz,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create constraint(:user_commission_logs, :action_type_must_be_valid,
             check:
               "action_type IN ('referral_reward', 'milestone_reward', 'transfer_to_balance', 'withdraw_payout', 'withdraw_reject_refund')"
           )

    create index(:user_commission_logs, [:user_id, "inserted_at DESC"],
             name: :idx_user_commission_logs_user
           )

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
        default: fragment("NOW()")
      )
    end

    create table(:user_withdrawal_accounts, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :payout_method_id, :bigint, null: false
      add :account_name, :string, size: 64, null: false
      add :account_no, :string, size: 128, null: false
      add :config, :jsonb, default: fragment("'{}'::jsonb")
      add :is_default, :boolean, null: false, default: false
      add :is_enable, :boolean, null: false, default: true

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create index(:user_withdrawal_accounts, [:user_id], name: :idx_user_withdrawal_accounts_user)

    create table(:user_withdrawal_records, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :tx_no, :string, size: 64, null: false
      add :gateway_tx_no, :string, size: 255
      add :user_id, :bigint, null: false
      add :user_withdrawal_account_id, :bigint
      add :payout_channel_id, :bigint
      add :payout_method, :string, size: 32, null: false
      add :payout_driver, :string, size: 32, null: false
      add :currency, :string, size: 16, null: false, default: "USD"
      add :amount, :decimal, precision: 38, scale: 18, null: false
      add :handling_fee, :decimal, precision: 38, scale: 18, null: false, default: 0
      add :actual_amount, :decimal, precision: 38, scale: 18, null: false
      add :payout_account, :decimal, precision: 38, scale: 18, null: false
      add :payout_identity, :jsonb, default: fragment("'{}'::jsonb")
      add :status, :string, size: 20, null: false, default: "pending"
      add :reject_reason, :string, size: 255
      add :handled_at, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:user_withdrawal_records, :status_must_be_valid,
             check: "status IN ('pending', 'approved', 'completed', 'rejected')"
           )

    create unique_index(:user_withdrawal_records, [:tx_no],
             name: :uk_user_withdrawal_records_tx_no
           )

    create index(:user_withdrawal_records, [:user_id, :status],
             name: :idx_user_withdrawal_records_user
           )

    create index(:user_withdrawal_records, [:inserted_at],
             name: :idx_user_withdrawal_records_inserted_at
           )
  end

  def down do
    drop_if_exists table(:user_withdrawal_records)
    drop_if_exists table(:user_withdrawal_accounts)
    drop_if_exists table(:payout_accounts)
    drop_if_exists table(:payout_methods)
    drop_if_exists table(:user_commission_logs)
    drop_if_exists table(:user_commissions)
    drop_if_exists table(:user_commission_settlements)
    drop_if_exists table(:commission_rules)
  end
end
