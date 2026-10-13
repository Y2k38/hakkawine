defmodule Hakkawine.AffiliateFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Affiliate` context.
  """

  @doc """
  Generate a user_commission.
  """
  def user_commission_fixture(attrs \\ %{}) do
    {:ok, user_commission} =
      attrs
      |> Enum.into(%{
        user_id: 42
      })
      |> Hakkawine.Affiliate.create_user_commission()

    user_commission
  end
end
