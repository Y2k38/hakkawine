defmodule Hakkawine.AffiliateTest do
  use Hakkawine.DataCase

  alias Hakkawine.Affiliate

  describe "user_commissions" do
    alias Hakkawine.Affiliate.UserCommission

    import Hakkawine.AffiliateFixtures

    @invalid_attrs %{user_id: nil}

    test "list_user_commissions/0 returns all user_commissions" do
      user_commission = user_commission_fixture()
      assert Affiliate.list_user_commissions() == [user_commission]
    end

    test "get_user_commission!/1 returns the user_commission with given id" do
      user_commission = user_commission_fixture()
      assert Affiliate.get_user_commission!(user_commission.id) == user_commission
    end

    test "create_user_commission/1 with valid data creates a user_commission" do
      valid_attrs = %{user_id: 42}

      assert {:ok, %UserCommission{} = user_commission} =
               Affiliate.create_user_commission(valid_attrs)

      assert user_commission.user_id == 42
    end

    test "create_user_commission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Affiliate.create_user_commission(@invalid_attrs)
    end

    test "update_user_commission/2 with valid data updates the user_commission" do
      user_commission = user_commission_fixture()
      update_attrs = %{user_id: 43}

      assert {:ok, %UserCommission{} = user_commission} =
               Affiliate.update_user_commission(user_commission, update_attrs)

      assert user_commission.user_id == 43
    end

    test "update_user_commission/2 with invalid data returns error changeset" do
      user_commission = user_commission_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Affiliate.update_user_commission(user_commission, @invalid_attrs)

      assert user_commission == Affiliate.get_user_commission!(user_commission.id)
    end

    test "delete_user_commission/1 deletes the user_commission" do
      user_commission = user_commission_fixture()
      assert {:ok, %UserCommission{}} = Affiliate.delete_user_commission(user_commission)

      assert_raise Ecto.NoResultsError, fn ->
        Affiliate.get_user_commission!(user_commission.id)
      end
    end

    test "change_user_commission/1 returns a user_commission changeset" do
      user_commission = user_commission_fixture()
      assert %Ecto.Changeset{} = Affiliate.change_user_commission(user_commission)
    end
  end
end
