defmodule Hakkawine.Affiliate do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Affiliate.UserCommission
  alias Hakkawine.Affiliate.CommissionRule
  alias Hakkawine.Affiliate.UserCommissionSettlement
  alias Hakkawine.Affiliate.UserWithdrawalRecord

  def get_user_commissions(user_id) do
    UserCommission
    |> where(user_id: ^user_id)
    |> Repo.one()
  end

  def fetch_all_active_commission_rules() do
    CommissionRule
    |> where(is_active: true)
    |> Repo.all()
  end

  def list_user_commission_settlements() do
    UserCommissionSettlement
    |> Repo.all()
  end

  def list_user_withdrawal_records() do
    UserWithdrawalRecord
    |> Repo.all()
  end
end
