defmodule Hakkawine.Repo.Migrations.CreateAuditTables do
  use Ecto.Migration

  def change do
    create table(:user_audit_actions, primary_key: false) do
      add :code, :string, size: 50, primary_key: true
      add :domain, :string, size: 20, null: false
      add :category, :string, size: 50, null: false
      add :description, :text, null: false

      timestamps(
        type: :timestamptz,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create table(:user_audit_logs, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :action_code, :string, size: 50, null: false
      add :ip_address, :inet
      add :user_agent, :text
      add :metadata, :map, default: "{}"

      timestamps(
        type: :timestamptz,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create index(:user_audit_logs, [:user_id, {:desc, :inserted_at}], name: :idx_ual_user_time)

    create table(:admin_audit_logs, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :operator_id, :bigint, null: false
      add :action_code, :string, size: 50, null: false
      add :target_type, :string, size: 50
      add :target_id, :bigint
      add :ip_address, :inet
      add :user_agent, :text
      add :metadata, :map, default: "{}"

      timestamps(
        type: :timestamptz,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create index(:admin_audit_logs, [:operator_id, {:desc, :inserted_at}],
             name: :idx_aal_operator_time
           )
  end
end
