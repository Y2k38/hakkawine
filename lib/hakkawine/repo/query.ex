defmodule Hakkawine.Repo.Query do
  import Ecto.Query

  def with_lock(query, nil), do: query
  def with_lock(query, false), do: query

  def with_lock(query, :for_update), do: lock(query, "FOR UPDATE")
  def with_lock(query, :for_update_nowait), do: lock(query, "FOR UPDATE NOWAIT")
  def with_lock(query, :for_update_skip_locked), do: lock(query, "FOR UPDATE SKIP LOCKED")
  def with_lock(query, :shared), do: lock(query, "FOR SHARE")

  def with_lock(query, lock_str) when is_binary(lock_str) do
    lock(query, fragment(^lock_str))
  end

  def apply_opts(query, opts) when is_list(opts) do
    query
    |> with_lock(Keyword.get(opts, :lock))
  end
end
