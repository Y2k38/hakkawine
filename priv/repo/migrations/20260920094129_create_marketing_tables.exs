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
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:coupons, [:code], name: :uk_coupons_code)

    create table(:user_checkins, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :traffic_in_mb, :int, null: false
      add :check_in_date, :date, null: false
      add :subscription_id, :bigint, null: false
      add :applied_at, :timestamptz

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create unique_index(:user_checkins, [:user_id, :check_in_date], name: :uk_user_checkin_date)
  end

  def down do
    drop_if_exists index(:user_checkins, name: :uk_user_checkin_date)
    drop_if_exists index(:coupons, name: :uk_coupons_code)

    drop_if_exists table(:user_checkins)
    drop_if_exists table(:coupons)

    execute "DROP TYPE IF EXISTS coupon_type;"
  end
end
