defmodule Hakkawine.Utils.RateLimiter do

  @lua_path Path.join([:code.priv_dir(:hakkawine), "lua", "rate_limiter.lua"])
  @external_resource @lua_path
  @lua_script File.read!(@lua_path)
  @script_sha :crypto.hash(:sha, @lua_script) |> Base.encode16(case: :lower)

  def check_only(key, limit, window_ms) do
    eval_script(key, limit, window_ms, "check_only")
  end

  def allow?(key, limit, window_ms) do
    eval_script(key, limit, window_ms, "hit")
  end

  def hit(key, window_ms) do
    eval_script(key, 999_999, window_ms, "hit")
    :ok
  end

  def delete_keys(keys) when is_list(keys) and keys != [] do
    case Redix.command(:redix, ["DEL" | keys]) do
      {:ok, _count} -> :ok
      {:error, _reason} -> :ok
    end
  end

  defp eval_script(key, limit, window_ms, mode) do
    now_ms = System.system_time(:millisecond)
    args = ["EVALSHA", @script_sha, 1, key, now_ms, window_ms, limit, mode]

    case Redix.command(:redix, args) do
      {:ok, 1} -> :allow
      {:ok, 0} -> :deny
      {:error, %Redix.Error{message: "NOSCRIPT " <> _}} ->
        fallback_args = ["EVAL", @lua_script, 1, key, now_ms, window_ms, limit, mode]
        case Redix.command(:redix, fallback_args) do
          {:ok, 1} -> :allow
          {:ok, 0} -> :deny
          _ -> :allow
        end
      _other ->
        :allow
    end
  end
end
