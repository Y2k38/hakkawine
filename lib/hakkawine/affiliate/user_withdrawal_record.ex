defmodule Hakkawine.Affiliate.UserWithdrawalRecord do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_withdrawal_records" do
    field :tx_no, :string
    field :gateway_tx_no, :string
    field :user_id, :integer
    field :user_withdrawal_account_id, :integer
    field :payout_method_id, :integer
    field :payout_method, :string
    field :payout_driver, :string
    field :currency, :string
    field :amount, :decimal
    field :handling_fee, :decimal
    field :actual_amount, :decimal
    field :payout_account, :decimal
    field :payout_identity, :map
    field :status, Ecto.Enum, values: [:pending, :approved, :completed, :rejected]
    field :reject_reason, :string
    field :handled_at, :utc_datetime_usec

    timestamps(type: :utc_datetime_usec)
  end
end
