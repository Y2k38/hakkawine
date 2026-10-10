defmodule Hakkawine.Billing.PaymentAccount do
  use Ecto.Schema

  import Ecto.Changeset

  alias Hakkawine.Repo.Types.JSONValue

  @primary_key {:id, :id, autogenerate: true}
  schema "payment_accounts" do
    field :payment_method_id, :integer
    field :name, :string
    field :is_enable, :boolean
    field :weight, :integer
    field :config, :map
    field :min_tx_amount, :decimal
    field :max_tx_amount, :decimal
    field :daily_limit_amount, :decimal
    field :daily_accumulated_amount, :decimal
    field :daily_limit_count, :integer
    field :yearly_limit_amount, :decimal
    field :yearly_accumulated_amount, :decimal
    field :last_daily_reset_at, :integer
    field :last_yearly_reset_at, :integer

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  def changeset(payment_account, attrs) do
    payment_account
    |> cast(attrs, [
      :payment_method_id,
      :name,
      :is_enable,
      :weight,
      :config,
      :min_tx_amount,
      :max_tx_amount,
      :daily_limit_amount,
      :daily_accumulated_amount,
      :daily_limit_count,
      :yearly_limit_amount,
      :yearly_accumulated_amount,
      :last_daily_reset_at,
      :last_yearly_reset_at
    ])
  end
end
