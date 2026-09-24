defmodule Hakkawine.InfraFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Infra` context.
  """

  @doc """
  Generate a node.
  """
  def node_fixture(attrs \\ %{}) do
    {:ok, node} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Hakkawine.Infra.create_node()

    node
  end
end
