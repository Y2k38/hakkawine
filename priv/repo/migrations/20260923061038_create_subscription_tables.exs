defmodule Hakkawine.Repo.Migrations.CreateSubscriptionTables do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE subscription_status AS ENUM('active', 'expired', 'exhausted', 'suspended', 'cancelled');"

    create table(:user_subscriptions, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :status, :subscription_status, null: false, default: "active"
      add :user_id, :bigint, null: false
      add :product_id, :bigint, null: false
      add :product_price_id, :bigint, null: false
      add :billing_cycle, :billing_cycle, null: false
      add :snap_limit_device_count, :integer
      add :snap_limit_speed_mbps, :integer
      add :snap_limit_speed_up_mbps, :integer
      add :snap_limit_speed_down_mbps, :integer
      add :snap_base_quota_bytes, :bigint, null: false
      add :extra_quota_bytes, :bigint, null: false, default: 0
      add :started_at, :timestamptz, null: false, default: fragment("NOW()")
      add :expired_at, :timestamptz, null: false

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:user_subscriptions, [:uuid], name: :uk_user_subscriptions_uuid)
    create index(:user_subscriptions, [:user_id, :status], name: :idx_user_subscriptions_user_status)
    create index(:user_subscriptions, [:expired_at], name: :idx_user_subscriptions_expired_at, where: "status = 'active'")
  end

  def down do
    drop_if_exists index(:user_subscriptions, name: :idx_user_subscriptions_expired_at)
    drop_if_exists index(:user_subscriptions, name: :idx_user_subscriptions_user_status)
    drop_if_exists index(:user_subscriptions, name: :uk_user_subscriptions_uuid)

    drop_if_exists table(:user_subscriptions)

    execute "DROP TYPE IF EXISTS subscription_status;"
  end
end
