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
  end
end
