defmodule Hakkawine.CheckoutTest do
  use Hakkawine.DataCase

  alias Hakkawine.Checkout

  describe "order_no" do
    alias Hakkawine.Checkout.Order

    import Hakkawine.CheckoutFixtures

    @invalid_attrs %{string: nil}

    test "list_order_no/0 returns all order_no" do
      order = order_fixture()
      assert Checkout.list_order_no() == [order]
    end

    test "get_order!/1 returns the order with given id" do
      order = order_fixture()
      assert Checkout.get_order!(order.id) == order
    end

    test "create_order/1 with valid data creates a order" do
      valid_attrs = %{string: "some string"}

      assert {:ok, %Order{} = order} = Checkout.create_order(valid_attrs)
      assert order.string == "some string"
    end

    test "create_order/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Checkout.create_order(@invalid_attrs)
    end

    test "update_order/2 with valid data updates the order" do
      order = order_fixture()
      update_attrs = %{string: "some updated string"}

      assert {:ok, %Order{} = order} = Checkout.update_order(order, update_attrs)
      assert order.string == "some updated string"
    end

    test "update_order/2 with invalid data returns error changeset" do
      order = order_fixture()
      assert {:error, %Ecto.Changeset{}} = Checkout.update_order(order, @invalid_attrs)
      assert order == Checkout.get_order!(order.id)
    end

    test "delete_order/1 deletes the order" do
      order = order_fixture()
      assert {:ok, %Order{}} = Checkout.delete_order(order)
      assert_raise Ecto.NoResultsError, fn -> Checkout.get_order!(order.id) end
    end

    test "change_order/1 returns a order changeset" do
      order = order_fixture()
      assert %Ecto.Changeset{} = Checkout.change_order(order)
    end
  end
end
