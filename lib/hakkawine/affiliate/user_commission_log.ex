defmodule Hakkawine.Affiliate.UserCommissionLog do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_commission_logs" do
    field :user_id, :integer

    field :action_type, Ecto.Enum,
      values: [
        :referral_reward,
        :milestone_reward,
        :transfer_to_balance,
        :withdraw_payout,
        :withdraw_reject_refund
      ]

    field :before_amount, :decimal
    field :amount, :decimal
    field :after_amount, :decimal
    field :settlement_id, :integer
    field :withdrawal_id, :integer
    field :remark, :string

    timestamps(
      type: :utc_datetime_usec,
      updated_at: false
    )
  end
end
