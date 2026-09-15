defmodule Hakkawine.SystemFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.System` context.
  """

  @doc """
  Generate a setting.
  """
  def setting_fixture(attrs \\ %{}) do
    {:ok, setting} =
      attrs
      |> Enum.into(%{
        description: "some description",
        key: "some key",
        section: "some section",
        value: %{}
      })
      |> Hakkawine.System.create_setting()

    setting
  end
end
