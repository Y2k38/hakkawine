defmodule Hakkawine.AuditsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hakkawine.Audit` context.
  """

  @doc """
  Generate a user_audit_log.
  """
  def user_audit_log_fixture(attrs \\ %{}) do
    {:ok, user_audit_log} =
      attrs
      |> Enum.into(%{
        user_id: 42
      })
      |> Hakkawine.Audits.create_user_audit_log()

    user_audit_log
  end
end
