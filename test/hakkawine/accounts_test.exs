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

      assert {:ok, %UserAccount{} = user_account} =
               Accounts.update_user_account(user_account, update_attrs)

      assert user_account.email == "some updated email"
    end

    test "update_user_account/2 with invalid data returns error changeset" do
      user_account = user_account_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_user_account(user_account, @invalid_attrs)

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

  describe "mock_tables" do
    alias Hakkawine.Accounts.DashboardMock

    import Hakkawine.AccountsFixtures

    @invalid_attrs %{value: nil, title: nil}

    test "list_mock_tables/0 returns all mock_tables" do
      dashboard_mock = dashboard_mock_fixture()
      assert Accounts.list_mock_tables() == [dashboard_mock]
    end

    test "get_dashboard_mock!/1 returns the dashboard_mock with given id" do
      dashboard_mock = dashboard_mock_fixture()
      assert Accounts.get_dashboard_mock!(dashboard_mock.id) == dashboard_mock
    end

    test "create_dashboard_mock/1 with valid data creates a dashboard_mock" do
      valid_attrs = %{value: 42, title: "some title"}

      assert {:ok, %DashboardMock{} = dashboard_mock} =
               Accounts.create_dashboard_mock(valid_attrs)

      assert dashboard_mock.value == 42
      assert dashboard_mock.title == "some title"
    end

    test "create_dashboard_mock/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_dashboard_mock(@invalid_attrs)
    end

    test "update_dashboard_mock/2 with valid data updates the dashboard_mock" do
      dashboard_mock = dashboard_mock_fixture()
      update_attrs = %{value: 43, title: "some updated title"}

      assert {:ok, %DashboardMock{} = dashboard_mock} =
               Accounts.update_dashboard_mock(dashboard_mock, update_attrs)

      assert dashboard_mock.value == 43
      assert dashboard_mock.title == "some updated title"
    end

    test "update_dashboard_mock/2 with invalid data returns error changeset" do
      dashboard_mock = dashboard_mock_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Accounts.update_dashboard_mock(dashboard_mock, @invalid_attrs)

      assert dashboard_mock == Accounts.get_dashboard_mock!(dashboard_mock.id)
    end

    test "delete_dashboard_mock/1 deletes the dashboard_mock" do
      dashboard_mock = dashboard_mock_fixture()
      assert {:ok, %DashboardMock{}} = Accounts.delete_dashboard_mock(dashboard_mock)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_dashboard_mock!(dashboard_mock.id) end
    end

    test "change_dashboard_mock/1 returns a dashboard_mock changeset" do
      dashboard_mock = dashboard_mock_fixture()
      assert %Ecto.Changeset{} = Accounts.change_dashboard_mock(dashboard_mock)
    end
  end
end
