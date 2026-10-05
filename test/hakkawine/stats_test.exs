defmodule Hakkawine.StatsTest do
  use Hakkawine.DataCase

  alias Hakkawine.Stats

  describe "node_traffic_logs" do
    alias Hakkawine.Stats.TrafficLog

    import Hakkawine.StatsFixtures

    @invalid_attrs %{node_id: nil}

    test "list_node_traffic_logs/0 returns all node_traffic_logs" do
      traffic_log = traffic_log_fixture()
      assert Stats.list_node_traffic_logs() == [traffic_log]
    end

    test "get_traffic_log!/1 returns the traffic_log with given id" do
      traffic_log = traffic_log_fixture()
      assert Stats.get_traffic_log!(traffic_log.id) == traffic_log
    end

    test "create_traffic_log/1 with valid data creates a traffic_log" do
      valid_attrs = %{node_id: 42}

      assert {:ok, %TrafficLog{} = traffic_log} = Stats.create_traffic_log(valid_attrs)
      assert traffic_log.node_id == 42
    end

    test "create_traffic_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Stats.create_traffic_log(@invalid_attrs)
    end

    test "update_traffic_log/2 with valid data updates the traffic_log" do
      traffic_log = traffic_log_fixture()
      update_attrs = %{node_id: 43}

      assert {:ok, %TrafficLog{} = traffic_log} =
               Stats.update_traffic_log(traffic_log, update_attrs)

      assert traffic_log.node_id == 43
    end

    test "update_traffic_log/2 with invalid data returns error changeset" do
      traffic_log = traffic_log_fixture()
      assert {:error, %Ecto.Changeset{}} = Stats.update_traffic_log(traffic_log, @invalid_attrs)
      assert traffic_log == Stats.get_traffic_log!(traffic_log.id)
    end

    test "delete_traffic_log/1 deletes the traffic_log" do
      traffic_log = traffic_log_fixture()
      assert {:ok, %TrafficLog{}} = Stats.delete_traffic_log(traffic_log)
      assert_raise Ecto.NoResultsError, fn -> Stats.get_traffic_log!(traffic_log.id) end
    end

    test "change_traffic_log/1 returns a traffic_log changeset" do
      traffic_log = traffic_log_fixture()
      assert %Ecto.Changeset{} = Stats.change_traffic_log(traffic_log)
    end
  end
end
