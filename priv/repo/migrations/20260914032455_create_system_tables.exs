defmodule Hakkawine.Repo.Migrations.CreateSystemTables do
  use Ecto.Migration

  def change do
    create table(:settings, primary_key: false) do
      add :section, :string, null: false, size: 32
      add :key, :string, primary_key: true, size: 64
      add :value, :jsonb, null: false
      add :description, :string, null: false, size: 255

      timestamps(
        type: :timestamptz,
        inserted_at: :created_at,
        default: fragment("NOW()")
      )
    end

    create index(:settings, [:section])
  end
end
