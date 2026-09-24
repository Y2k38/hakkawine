defmodule Hakkawine.Billing.UserBalance do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:user_id, :integer, autogenerate: false}
  schema "user_balances" do
    field :balance, :decimal

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(user_balance, attrs) do
    user_balance
    |> cast(attrs, [:balance])
    |> validate_required([:balance])
  end
end
