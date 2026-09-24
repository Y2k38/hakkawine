defmodule Hakkawine.MarketingTest do
  use Hakkawine.DataCase

  alias Hakkawine.Marketing

  describe "coupon" do
    alias Hakkawine.Marketing.Coupon

    import Hakkawine.MarketingFixtures

    @invalid_attrs %{code: nil, string: nil}

    test "list_coupon/0 returns all coupon" do
      coupon = coupon_fixture()
      assert Marketing.list_coupon() == [coupon]
    end

    test "get_coupon!/1 returns the coupon with given id" do
      coupon = coupon_fixture()
      assert Marketing.get_coupon!(coupon.id) == coupon
    end

    test "create_coupon/1 with valid data creates a coupon" do
      valid_attrs = %{code: "some code", string: "some string"}

      assert {:ok, %Coupon{} = coupon} = Marketing.create_coupon(valid_attrs)
      assert coupon.code == "some code"
      assert coupon.string == "some string"
    end

    test "create_coupon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Marketing.create_coupon(@invalid_attrs)
    end

    test "update_coupon/2 with valid data updates the coupon" do
      coupon = coupon_fixture()
      update_attrs = %{code: "some updated code", string: "some updated string"}

      assert {:ok, %Coupon{} = coupon} = Marketing.update_coupon(coupon, update_attrs)
      assert coupon.code == "some updated code"
      assert coupon.string == "some updated string"
    end

    test "update_coupon/2 with invalid data returns error changeset" do
      coupon = coupon_fixture()
      assert {:error, %Ecto.Changeset{}} = Marketing.update_coupon(coupon, @invalid_attrs)
      assert coupon == Marketing.get_coupon!(coupon.id)
    end

    test "delete_coupon/1 deletes the coupon" do
      coupon = coupon_fixture()
      assert {:ok, %Coupon{}} = Marketing.delete_coupon(coupon)
      assert_raise Ecto.NoResultsError, fn -> Marketing.get_coupon!(coupon.id) end
    end

    test "change_coupon/1 returns a coupon changeset" do
      coupon = coupon_fixture()
      assert %Ecto.Changeset{} = Marketing.change_coupon(coupon)
    end
  end
end
