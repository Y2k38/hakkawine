defmodule Hakkawine.Audits.AdminAuditLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "admin_audit_logs" do
    field :operator_id, :integer
    field :action_code, :string
    field :target_type, :string
    field :target_id, :integer
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string
    field :metadata, :map, default: %{}

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at,
      updated_at: false
    )
  end

  def changeset(admin_audit_log, attrs) do
    admin_audit_log
    |> cast(attrs, [:operator_id, :action_code, :target_type, :target_id, :ip_address, :user_agent, :metadata])
    |> validate_required([:operator_id, :action_code])
  end
end
