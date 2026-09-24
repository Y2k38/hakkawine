defmodule Hakkawine.CheckoutFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Checkout` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        string: "some string"
      })
      |> Hakkawine.Checkout.create_order()

    order
  end
end
