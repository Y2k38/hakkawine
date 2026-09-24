defmodule Hakkawine.SubscriptionTest do
  use Hakkawine.DataCase

  alias Hakkawine.Subscription

  describe "user_subscriptions" do
    alias Hakkawine.Subscription.UserSubscription

    import Hakkawine.SubscriptionFixtures

    @invalid_attrs %{user_id: nil}

    test "list_user_subscriptions/0 returns all user_subscriptions" do
      user_subscription = user_subscription_fixture()
      assert Subscription.list_user_subscriptions() == [user_subscription]
    end

    test "get_user_subscription!/1 returns the user_subscription with given id" do
      user_subscription = user_subscription_fixture()
      assert Subscription.get_user_subscription!(user_subscription.id) == user_subscription
    end

    test "create_user_subscription/1 with valid data creates a user_subscription" do
      valid_attrs = %{user_id: 42}

      assert {:ok, %UserSubscription{} = user_subscription} = Subscription.create_user_subscription(valid_attrs)
      assert user_subscription.user_id == 42
    end

    test "create_user_subscription/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscription.create_user_subscription(@invalid_attrs)
    end

    test "update_user_subscription/2 with valid data updates the user_subscription" do
      user_subscription = user_subscription_fixture()
      update_attrs = %{user_id: 43}

      assert {:ok, %UserSubscription{} = user_subscription} = Subscription.update_user_subscription(user_subscription, update_attrs)
      assert user_subscription.user_id == 43
    end

    test "update_user_subscription/2 with invalid data returns error changeset" do
      user_subscription = user_subscription_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscription.update_user_subscription(user_subscription, @invalid_attrs)
      assert user_subscription == Subscription.get_user_subscription!(user_subscription.id)
    end

    test "delete_user_subscription/1 deletes the user_subscription" do
      user_subscription = user_subscription_fixture()
      assert {:ok, %UserSubscription{}} = Subscription.delete_user_subscription(user_subscription)
      assert_raise Ecto.NoResultsError, fn -> Subscription.get_user_subscription!(user_subscription.id) end
    end

    test "change_user_subscription/1 returns a user_subscription changeset" do
      user_subscription = user_subscription_fixture()
      assert %Ecto.Changeset{} = Subscription.change_user_subscription(user_subscription)
    end
  end
end
