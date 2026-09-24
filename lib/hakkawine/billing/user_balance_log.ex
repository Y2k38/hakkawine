defmodule Hakkawine.Billing.UserBalanceLog do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_balance_logs" do
    field :user_id, :integer
    field :action_type, Ecto.Enum, values: [:recharge, :recharge_bonus, :order_payment, :order_refund, :commission_transfer, :system_bonus, :system_deduct]
    field :before_balance, :decimal
    field :amount, :decimal
    field :after_balance, :decimal
    field :ref_type, :string
    field :ref_id, :integer
    field :operator_id, :integer
    field :remark, :string

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at,
      updated_at: false
    )
  end

  def changeset(user_balance_log, attrs) do
    user_balance_log
    |> cast(attrs, [:user_id, :action_type, :before_balance, :amount, :after_balance, :ref_type, :ref_id, :operator_id, :remark])
    |> validate_required([:user_id, :action_type, :before_balance, :amount, :after_balance, :ref_type, :ref_id, :operator_id, :remark])
    |> validate_number(:before_balance, greater_than_or_equal_to: 0)
    |> validate_number(:amount, greater_than_or_equal_to: 0)
    |> validate_number(:after_balance, greater_than_or_equal_to: 0)
    |> validate_length(:ref_type, min: 1, max: 32, message: "must be between 1 and 32 characters long")
    |> validate_length(:remark, min: 1, max: 255, message: "must be between 1 and 255 characters long")
  end
end
