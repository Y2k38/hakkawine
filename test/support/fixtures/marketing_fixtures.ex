defmodule Hakkawine.MarketingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Marketing` context.
  """

  @doc """
  Generate a coupon.
  """
  def coupon_fixture(attrs \\ %{}) do
    {:ok, coupon} =
      attrs
      |> Enum.into(%{
        code: "some code",
        string: "some string"
      })
      |> Hakkawine.Marketing.create_coupon()

    coupon
  end
end
