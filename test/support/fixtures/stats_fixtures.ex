defmodule Hakkawine.StatsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Stats` context.
  """

  @doc """
  Generate a traffic_log.
  """
  def traffic_log_fixture(attrs \\ %{}) do
    {:ok, traffic_log} =
      attrs
      |> Enum.into(%{
        node_id: 42
      })
      |> Hakkawine.Stats.create_traffic_log()

    traffic_log
  end
end
