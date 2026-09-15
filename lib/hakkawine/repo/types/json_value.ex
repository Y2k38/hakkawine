defmodule Hakkawine.Repo.Types.JSONValue do
  use Ecto.Type

  @impl true
  def type, do: :jsonb

  @impl true
  def cast(value), do: {:ok, value}

  @impl true
  def load(value), do: {:ok, value}

  @impl true
  def dump(value), do: {:ok, value}
end
