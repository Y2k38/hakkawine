defmodule Hakkawine.SubscriptionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Subscription` context.
  """

  @doc """
  Generate a user_subscription.
  """
  def user_subscription_fixture(attrs \\ %{}) do
    {:ok, user_subscription} =
      attrs
      |> Enum.into(%{
        user_id: 42
      })
      |> Hakkawine.Subscription.create_user_subscription()

    user_subscription
  end
end
