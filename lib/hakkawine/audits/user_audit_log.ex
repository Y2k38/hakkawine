defmodule Hakkawine.Audits.UserAuditLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "user_audit_logs" do
    field :user_id, :integer
    field :action_code, :string
    field :ip_address, EctoNetwork.INET
    field :user_agent, :string
    field :metadata, :map, default: %{}

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at,
      updated_at: false
    )
  end

  @doc false
  def changeset(user_audit_log, attrs) do
    user_audit_log
    |> cast(attrs, [:user_id, :action_code, :ip_address, :user_agent, :metadata])
    |> validate_required([:user_id, :action_code])
  end
end
