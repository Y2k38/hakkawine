defmodule Hakkawine.AccountsTest do
  use Hakkawine.DataCase

  alias Hakkawine.Accounts

  describe "user_accounts" do
    alias Hakkawine.Accounts.UserAccount

    import Hakkawine.AccountsFixtures

    @invalid_attrs %{email: nil}

    test "list_user_accounts/0 returns all user_accounts" do
      user_account = user_account_fixture()
      assert Accounts.list_user_accounts() == [user_account]
    end

    test "get_user_account!/1 returns the user_account with given id" do
      user_account = user_account_fixture()
      assert Accounts.get_user_account!(user_account.id) == user_account
    end

    test "create_user_account/1 with valid data creates a user_account" do
      valid_attrs = %{email: "some email"}

      assert {:ok, %UserAccount{} = user_account} = Accounts.create_user_account(valid_attrs)
      assert user_account.email == "some email"
    end

    test "create_user_account/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user_account(@invalid_attrs)
    end

    test "update_user_account/2 with valid data updates the user_account" do
      user_account = user_account_fixture()
      update_attrs = %{email: "some updated email"}

      assert {:ok, %UserAccount{} = user_account} = Accounts.update_user_account(user_account, update_attrs)
      assert user_account.email == "some updated email"
    end

    test "update_user_account/2 with invalid data returns error changeset" do
      user_account = user_account_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user_account(user_account, @invalid_attrs)
      assert user_account == Accounts.get_user_account!(user_account.id)
    end

    test "delete_user_account/1 deletes the user_account" do
      user_account = user_account_fixture()
      assert {:ok, %UserAccount{}} = Accounts.delete_user_account(user_account)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user_account!(user_account.id) end
    end

    test "change_user_account/1 returns a user_account changeset" do
      user_account = user_account_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user_account(user_account)
    end
  end
end
