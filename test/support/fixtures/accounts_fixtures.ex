defmodule Hakkawine.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Accounts` context.
  """

  @doc """
  Generate a user_account.
  """
  def user_account_fixture(attrs \\ %{}) do
    {:ok, user_account} =
      attrs
      |> Enum.into(%{
        email: "some email"
      })
      |> Hakkawine.Accounts.create_customer()

    user_account
  end

  @doc """
  Generate a dashboard_mock.
  """
  def dashboard_mock_fixture(attrs \\ %{}) do
    {:ok, dashboard_mock} =
      attrs
      |> Enum.into(%{
        title: "some title",
        value: 42
      })
      |> Hakkawine.Accounts.create_dashboard_mock()

    dashboard_mock
  end
end
