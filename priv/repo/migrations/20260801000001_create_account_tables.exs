defmodule Hakkawine.Repo.Migrations.CreateAccountTables do
  use Ecto.Migration

  def up do
    create table(:user_accounts, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"

      add :account_type, :string, size: 20, null: false, default: "customer"
      add :status, :string, size: 20, null: false, default: "unverified"
      add :email, :string, size: 255, null: false
      add :password_hash, :string, size: 255, null: false
      add :language, :string, size: 10, null: false, default: "en"
      add :email_verified_at, :timestamptz
      add :password_updated_at, :timestamptz

      add :telegram_chat_id, :bigint
      add :invited_by, :bigint
      add :invite_code, :string, size: 16
      add :suspended_until, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:user_accounts, :account_type_must_be_valid,
             check: "account_type IN ('customer', 'staff', 'system_admin')"
           )

    create constraint(:user_accounts, :status_must_be_valid,
             check: "status IN ('unverified', 'active', 'suspended', 'deactivating')"
           )

    create unique_index(:user_accounts, [:email], name: :uk_user_accounts_active_email)

    create unique_index(:user_accounts, [:account_type],
             where: "account_type = 'system_admin'",
             name: :idx_single_system_admin
           )

    create unique_index(:user_accounts, [:invite_code], name: :uk_user_accounts_invite_code)
    create index(:user_accounts, [:invited_by], name: :idx_user_accounts_invited_by)
  end

  def down do
    drop_if_exists table(:user_accounts)
  end
end
