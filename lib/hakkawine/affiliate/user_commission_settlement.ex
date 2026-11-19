defmodule Hakkawine.Affiliate.UserCommissionSettlement do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_commission_settlements" do
    field :rule_id, :integer
    field :beneficiary_user_id, :integer
    field :buyer_id, :integer
    field :order_id, :integer
    field :order_amount, :decimal
    field :commission_rate, :decimal
    field :commission_amount, :decimal
    field :status, Ecto.Enum, values: [:pending, :unlocked, :cancelled]
    field :freeze_days, :integer
    field :expected_unlock_at, :utc_datetime_usec
    field :actual_unlocked_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end
end
