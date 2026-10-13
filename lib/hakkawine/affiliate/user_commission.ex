defmodule Hakkawine.Affiliate.UserCommission do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:user_id, :integer, autogenerate: false}
  schema "user_commissions" do
    field :commission_balance, :decimal
    field :total_earned, :decimal

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(user_commission, attrs) do
    user_commission
    |> cast(attrs, [:commission_balance, :total_earned])
    |> validate_required([:commission_balance, :total_earned])
  end
end
