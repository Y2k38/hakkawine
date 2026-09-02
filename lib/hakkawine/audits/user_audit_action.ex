defmodule Hakkawine.Audits.UserAuditAction do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:code, :string, autogenerate: false}
  schema "user_audit_actions" do
    field :domain, :string
    field :category, :string
    field :description, :string

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at,
      updated_at: false
    )
  end

  @doc false
  def changeset(user_audit_actions, attrs) do
    user_audit_actions
    |> cast(attrs, [:code, :domain, :category, :description])
    |> validate_required([:code, :domain, :category, :description])
    |> validate_length(:code, max: 50)
    |> validate_length(:domain, max: 20)
    |> validate_length(:category, max: 50)
  end
end
