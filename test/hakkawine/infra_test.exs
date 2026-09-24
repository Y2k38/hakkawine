defmodule Hakkawine.InfraTest do
  use Hakkawine.DataCase

  alias Hakkawine.Infra

  describe "nodes" do
    alias Hakkawine.Infra.Node

    import Hakkawine.InfraFixtures

    @invalid_attrs %{name: nil}

    test "list_nodes/0 returns all nodes" do
      node = node_fixture()
      assert Infra.list_nodes() == [node]
    end

    test "get_node!/1 returns the node with given id" do
      node = node_fixture()
      assert Infra.get_node!(node.id) == node
    end

    test "create_node/1 with valid data creates a node" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Node{} = node} = Infra.create_node(valid_attrs)
      assert node.name == "some name"
    end

    test "create_node/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Infra.create_node(@invalid_attrs)
    end

    test "update_node/2 with valid data updates the node" do
      node = node_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Node{} = node} = Infra.update_node(node, update_attrs)
      assert node.name == "some updated name"
    end

    test "update_node/2 with invalid data returns error changeset" do
      node = node_fixture()
      assert {:error, %Ecto.Changeset{}} = Infra.update_node(node, @invalid_attrs)
      assert node == Infra.get_node!(node.id)
    end

    test "delete_node/1 deletes the node" do
      node = node_fixture()
      assert {:ok, %Node{}} = Infra.delete_node(node)
      assert_raise Ecto.NoResultsError, fn -> Infra.get_node!(node.id) end
    end

    test "change_node/1 returns a node changeset" do
      node = node_fixture()
      assert %Ecto.Changeset{} = Infra.change_node(node)
    end
  end
end
