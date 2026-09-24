defmodule Hakkawine.Marketing.UserCheckin do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_checkin" do
    field :user_id, :integer
    field :traffic_in_mb, :integer
    field :check_in_date, :date
    field :subscription_id, :integer
    field :applied_at, :utc_datetime_usec

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at,
      updated_at: false
    )
  end

  @doc false
  def changeset(user_checkin, attrs) do
    user_checkin
    |> cast(attrs, [:user_id, :traffic_in_mb, :check_in_date, :subscription_id, :applied_at])
    |> validate_required([:user_id, :traffic_in_mb, :check_in_date])
  end
end
