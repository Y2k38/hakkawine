defmodule Hakkawine.Repo.Migrations.CreateContentTables do
  use Ecto.Migration

  def up do
    create table(:media_assets, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :user_id, :bigint, null: false
      add :file_key, :string, size: 512, null: false
      add :bucket_name, :string, size: 100, null: false
      add :original_filename, :string, size: 255, null: false
      add :file_size, :bigint, null: false
      add :mime_type, :string, size: 100, null: false
      add :associated_type, :string, size: 50
      add :associated_id, :bigint

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:media_assets, :chk_media_polymorphic,
             check:
               "(associated_type IS NULL AND associated_id IS NULL) OR (associated_type IS NOT NULL AND associated_id IS NOT NULL)"
           )

    create unique_index(:media_assets, [:file_key], name: :uk_media_assets_file)

    create index(:media_assets, [:user_id], name: :idx_media_assets_user)

    create index(:media_assets, [:associated_type, :associated_id],
             name: :idx_media_assets_associated,
             where: "associated_id IS NOT NULL"
           )

    create table(:announcements, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :title, :string, size: 255, null: false
      add :content, :string, null: false
      add :is_pinned, :boolean, null: false, default: false
      add :status, :string, size: 20, null: false, default: "draft"
      add :published_at, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:announcements, :status_must_be_valid,
             check: "status IN ('draft', 'scheduled', 'published', 'offline', 'archived')"
           )

    create index(:announcements, ["is_pinned DESC", "published_at DESC"],
             name: :idx_announcements_front
           )

    create table(:articles, primary_key: false) do
      add :id, :bigint, primary_key: true, generated: "BY DEFAULT AS IDENTITY"
      add :title, :string, size: 255, null: false
      add :slug, :string, size: 255, null: false
      add :summary, :string, size: 500, null: false, default: ""
      add :content, :string, null: false
      add :status, :string, size: 20, null: false, default: "draft"
      add :published_at, :timestamptz

      timestamps(
        type: :timestamptz,
        default: fragment("NOW()")
      )
    end

    create constraint(:articles, :status_must_be_valid,
             check: "status IN ('draft', 'scheduled', 'published', 'offline', 'archived')"
           )

    create unique_index(:articles, [:slug],
             name: :uk_articles_slug_published,
             where: "status = 'published'"
           )

    create index(:articles, ["published_at DESC"],
             name: :idx_articles_front,
             where: "status = 'published'"
           )
  end

  def down do
    drop_if_exists table(:articles)
    drop_if_exists table(:announcements)
    drop_if_exists table(:media_assets)
  end
end
