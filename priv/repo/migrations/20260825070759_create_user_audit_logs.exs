defmodule Hakkawine.Repo.Migrations.CreateUserAuditLogs do
  use Ecto.Migration

  def change do
    create table(:user_audit_actions, primary_key: false) do
      add :code, :string, size: 50, primary_key: true
      add :domain, :string, size: 20, null: false
      add :category, :string, size: 50, null: false
      add :description, :text, null: false

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create table(:user_audit_logs, primary_key: false) do
      add :user_id, :bigint, null: false
      add :action_code, :string, size: 50, null: false
      add :ip_address, :inet
      add :user_agent, :text
      add :metadata, :map, default: "{}"

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create index(:user_audit_logs, [:user_id, {:desc, :created_at}], name: :idx_ual_user_time)
    create index(:user_audit_logs, [:action_code, {:desc, :created_at}], name: :idx_ual_action_time)
    create index(:user_audit_logs, [:ip_address, {:desc, :created_at}], name: :idx_ual_ip_time, where: "ip_address IS NOT NULL")

    create table(:admin_audit_logs, primary_key: false) do
      add :operator_id, :bigint, null: false
      add :action_code, :string, size: 50, null: false
      add :target_type, :string, size: 50
      add :target_id, :bigint
      add :ip_address, :inet
      add :user_agent, :text
      add :metadata, :map, default: "{}"

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        updated_at: false,
        default: fragment("NOW()")
      )
    end

    create index(:admin_audit_logs, [:operator_id, {:desc, :created_at}], name: :idx_aal_operator_time)
    create index(:admin_audit_logs, [:target_type, :target_id], name: :idx_aal_target, where: "target_id IS NOT NULL")
    create index(:admin_audit_logs, [:action_code, {:desc, :created_at}], name: :idx_aal_action_time)
  end
end
