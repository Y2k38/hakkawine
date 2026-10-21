defmodule Hakkawine.Marketing.UserCheckin do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_checkins" do
    field :user_id, :integer
    field :traffic_amount, :integer
    field :check_in_date, :date
    field :subscription_id, :integer
    field :applied_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end

  @doc false
  def changeset(user_checkin, attrs) do
    user_checkin
    |> cast(attrs, [:user_id, :traffic_amount, :check_in_date, :subscription_id, :applied_at])
    |> validate_required([:user_id, :traffic_amount, :check_in_date])
    |> unique_constraint(:user_id,
      name: "uq_user_checkins_user_date",
      message: "You've already checked in today."
    )
  end
end
