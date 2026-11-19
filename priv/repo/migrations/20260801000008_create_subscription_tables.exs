defmodule Hakkawine.Repo.Migrations.CreateSubscriptionTables do
  use Ecto.Migration

  def up do
    create table(:user_subscriptions, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :product_id, :bigint, null: false
      add :product_price_id, :bigint, null: false
      add :uuid, :uuid, null: false, default: fragment("gen_random_uuid()")
      add :status, :string, size: 20, null: false, default: "active"
      add :billing_cycle, :string, size: 20, null: false
      add :billing_day, :integer, null: false
      add :is_auto_renew, :boolean, null: false, default: false
      add :is_auto_reset_quota, :boolean, null: false, default: false
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
        default: fragment("NOW()")
      )
    end

    create constraint(:user_subscriptions, :status_must_be_valid,
             check: "status IN ('active', 'expired', 'exhausted', 'suspended', 'cancelled')"
           )

    create constraint(:user_subscriptions, :billing_cycle_must_be_valid,
             check:
               "billing_cycle IN ('monthly', 'quarterly', 'half_yearly', 'yearly', 'one_time')"
           )

    create unique_index(:user_subscriptions, [:uuid], name: :uk_user_subscriptions_uuid)

    create index(:user_subscriptions, [:user_id, :status],
             name: :idx_user_subscriptions_user_status
           )

    create index(:user_subscriptions, [:expired_at],
             name: :idx_user_subscriptions_expired_at,
             where: "status = 'active'"
           )

    create table(:proxy_templates, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :name, :string, size: 64
      add :code, :string, size: 64
      add :scope, :string, size: 32
      add :target, :string, size: 32
      add :format, :string, size: 16
      add :content, :text
      add :is_active, :boolean, default: false

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create index(:proxy_templates, [:code], name: :uk_proxy_templates_code)

    create index(:proxy_templates, [:scope, :target],
             name: :uk_proxy_templates_single_active,
             where: "is_active = TRUE"
           )
  end

  def down do
    drop_if_exists table(:proxy_templates)
    drop_if_exists table(:user_subscriptions)
  end
end
