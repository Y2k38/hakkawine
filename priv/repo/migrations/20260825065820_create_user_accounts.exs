defmodule Hakkawine.Repo.Migrations.CreateUserAccounts do
  use Ecto.Migration

  def up do
     execute "CREATE TYPE user_account_type AS ENUM ('customer', 'staff', 'system_admin');"
    execute "CREATE TYPE user_status AS ENUM ('unverified', 'active', 'suspended', 'deactivating');"

    create table(:user_accounts, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"

      add :account_type, :user_account_type, null: false
      add :status, :user_status, null: false, default: "unverified"
      add :email, :string, size: 255, null: false
      add :password_hash, :string, size: 255, null: false
      add :email_verified_at, :timestamptz
      add :password_updated_at, :timestamptz

      add :telegram_id, :bigint
      add :invited_by, :bigint
      add :invite_code, :string, size: 16, null: false
      add :invite_count, :integer, null: false, default: 0
      add :suspended_until, :timestamptz

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: :updated_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:user_accounts, [:email], name: :idx_user_accounts_active_email)
    create unique_index(:user_accounts, [:invite_code], name: :idx_user_accounts_invite_code)
  end

  def down do
    drop_if_exists index(:user_accounts, [], name: :idx_user_accounts_invite_code)
    drop_if_exists index(:user_accounts, [], name: :idx_user_accounts_active_email)

    drop table(:user_accounts)

    execute "DROP TYPE user_status;"
    execute "DROP TYPE user_account_type;"
  end
end
