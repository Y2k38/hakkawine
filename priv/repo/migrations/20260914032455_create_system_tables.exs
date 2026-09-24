defmodule Hakkawine.Repo.Migrations.CreateSystemTables do
  use Ecto.Migration

  def up do
    create table(:settings, primary_key: false) do
      add :section, :string, size: 32, null: false
      add :key, :string, size: 64, primary_key: true
      add :value, :jsonb, null: false
      add :description, :string, size: 255, null: false

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create index(:settings, [:section], name: :idx_settings_section)

    create table(:node_labels, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :category, :string, size: 32, null: false
      add :key, :string, size: 64, null: false
      add :name, :string, size: 64, null: false
      add :is_enabled, :boolean, null: false, default: true

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create unique_index(:node_labels, [:category, :key], name: :uk_node_labels_category_key)

    execute "CREATE TYPE template_type AS ENUM('client', 'server');"

    create table(:templates, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :name, :string, size: 64, null: false
      add :type, :template_type, null: false
      add :file_ext, :string, size: 16, null: false, default: "yaml"
      add :match_rules, :jsonb, null: false, default: "{}"
      add :content, :string, null: false

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create index(:templates, [:type], name: :idx_templates_type)
  end

  def down do
    drop_if_exists index(:templates, name: :idx_templates_type)
    drop_if_exists index(:node_labels, name: :uk_node_labels_category_key)
    drop_if_exists index(:settings, name: :idx_settings_section)

    drop_if_exists table(:templates)
    drop_if_exists table(:node_labels)
    drop_if_exists table(:settings)

    execute "DROP TYPE template_type;"
  end
end
