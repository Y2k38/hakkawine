defmodule Hakkawine.Repo.Migrations.EnableTimescaledb do
  use Ecto.Migration

  @disable_ddl_transaction true

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;"
  end

  def down do
    execute "DROP EXTENSION IF EXISTS timescaledb CASCADE;"
  end
end
