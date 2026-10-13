defmodule Hakkawine.AgentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Agents` context.
  """

  @doc """
  Generate a agent.
  """
  def agent_fixture(attrs \\ %{}) do
    {:ok, agent} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Hakkawine.Agents.create_agent()

    agent
  end
end
