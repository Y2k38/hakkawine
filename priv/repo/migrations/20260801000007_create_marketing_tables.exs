defmodule Hakkawine.Repo.Migrations.CreateMarketingTables do
  use Ecto.Migration

  def up do
    execute "CREATE TYPE coupon_type AS ENUM('fixed_amount', 'percentage');"

    create table(:coupons, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :code, :string, size: 32, null: false
      add :name, :string, size: 64, null: false
      add :type, :coupon_type, null: false
      add :value, :decimal, precision: 38, scale: 18, null: false
      add :limit_use_count, :integer, null: false, default: 0
      add :used_count, :integer, null: false, default: 0
      add :limit_user_use_count, :integer, null: false, default: 1
      add :start_at, :timestamptz
      add :end_at, :timestamptz
      add :is_active, :boolean, null: false, default: true

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create unique_index(:coupons, [:code], name: :uk_coupons_code)

    create table(:checkin_rules, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :min_bytes, :bigint, null: false
      add :max_bytes, :bigint, null: false
      add :weight, :int, null: false

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create table(:user_checkins, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :traffic_amount, :bigint, null: false
      add :check_in_date, :date, null: false
      add :subscription_id, :bigint
      add :applied_at, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create unique_index(:user_checkins, [:user_id, :check_in_date],
             name: :uq_user_checkins_user_date
           )

    create index(:user_checkins, [:check_in_date], name: :idx_user_checkins_date_today)
  end

  def down do
    drop_if_exists index(:user_checkins, name: :idx_user_checkins_date_today)
    drop_if_exists index(:user_checkins, name: :uq_user_checkins_user_date)
    drop_if_exists index(:coupons, name: :uk_coupons_code)

    drop_if_exists table(:user_checkins)
    drop_if_exists table(:checkin_rules)
    drop_if_exists table(:coupons)

    execute "DROP TYPE IF EXISTS coupon_type;"
  end
end
