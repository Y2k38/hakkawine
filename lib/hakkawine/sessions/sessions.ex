defmodule Hakkawine.Sessions do
  # - Min Age (Sliding Window): 7 days
  # - Max Age (Hard Limit): 30 days
  # - Refresh Strategy: Lazy refresh on requests, with background cleanup every 1-4 hours.
  # 7 Days
  defp min_age_seconds, do: 7 * 24 * 60 * 60
  # 30 Days
  defp max_age_seconds, do: 30 * 24 * 60 * 60
  # 5 Minutes
  defp activity_throttle, do: 5 * 60

  defp calculate_ttl(inserted_at, now) do
    remaining_max_age = inserted_at + max_age_seconds() - now
    min(min_age_seconds(), max(remaining_max_age, 0))
  end

  def create_session(user_id, session_id, log_id, now) do
    session_key = session_key(session_id)
    user_sessions_key = user_sessions_key(user_id)

    initial_ttl = calculate_ttl(now, now)

    commands = [
      ["MULTI"],
      [
        "HSET",
        session_key,
        "user_id",
        user_id,
        "log_id",
        log_id,
        "inserted_at",
        now,
        "last_active_at",
        now
      ],
      ["EXPIRE", session_key, initial_ttl],
      ["ZADD", user_sessions_key, now, session_id],
      ["EXPIRE", user_sessions_key, initial_ttl],
      ["EXEC"]
    ]

    execute_transaction(commands)
  end

  def valid_session?(user_id, session_id) when not is_nil(user_id) and not is_nil(session_id) do
    case get_session(user_id, session_id) do
      {:ok, _session} -> true
      _ -> false
    end
  end

  def valid_session?(_, _), do: false

  def get_session(user_id, session_id) do
    session_key = session_key(session_id)

    with {:ok, [_ | _] = result} <- Redix.command(:redix, ["HGETALL", session_key]),
         session = Map.new(Enum.chunk_every(result, 2), fn [k, v] -> {k, v} end),
         true <- session["user_id"] == to_string(user_id) do
      {:ok, session}
    else
      {:ok, []} ->
        {:error, :session_not_found}

      false ->
        {:error, :unauthorized}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def list_user_sessions(user_id) do
    user_sessions_key = user_sessions_key(user_id)

    with {:ok, [_ | _] = session_ids} <-
           Redix.command(:redix, ["ZREVRANGE", user_sessions_key, 0, -1]) do
      commands =
        Enum.map(session_ids, fn session_id ->
          ["HGETALL", session_key(session_id)]
        end)

      case Redix.pipeline(:redix, commands) do
        {:ok, responses} ->
          sessions =
            Enum.zip(session_ids, responses)
            |> Enum.reduce([], fn {session_id, resp}, acc ->
              case resp do
                result when is_list(result) and result != [] ->
                  session_map =
                    Map.new(Enum.chunk_every(result, 2), fn [k, v] -> {k, v} end)
                    |> Map.put("session_id", session_id)

                  [session_map | acc]

                _ ->
                  acc
              end
            end)
            |> Enum.reverse()

          {:ok, sessions}

        {:error, reason} ->
          {:error, {:network_error, reason}}
      end
    else
      {:ok, []} ->
        {:ok, []}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def touch_session(user_id, session_id, inserted_at, last_active_at, now) do
    if should_touch?(last_active_at, now) do
      do_touch_session(user_id, session_id, inserted_at, now)
    else
      :ok
    end
  end

  defp should_touch?(last_active_at, now) when is_integer(last_active_at) do
    now - last_active_at > activity_throttle()
  end

  defp should_touch?(_, _), do: true

  defp do_touch_session(user_id, session_id, inserted_at, now) do
    session_key = session_key(session_id)
    user_sessions_key = user_sessions_key(user_id)

    ttl = calculate_ttl(inserted_at, now)

    commands = [
      ["MULTI"],
      ["HSET", session_key, "last_active_at", now],
      ["EXPIRE", session_key, ttl],
      ["ZADD", user_sessions_key, now, session_id],
      ["EXPIRE", user_sessions_key, ttl],
      ["EXEC"]
    ]

    execute_transaction(commands)
  end

  def delete_session(user_id, session_id) do
    session_key = session_key(session_id)
    user_sessions_key = user_sessions_key(user_id)

    commands = [
      ["MULTI"],
      ["DEL", session_key],
      ["ZREM", user_sessions_key, session_id],
      ["EXEC"]
    ]

    execute_transaction(commands)
  end

  def delete_other_sessions(user_id, current_session_id) do
    case list_user_sessions(user_id) do
      {:ok, session_list} ->
        other_sessions =
          Enum.reject(session_list, fn s -> s["session_id"] == current_session_id end)

        if Enum.empty?(other_sessions) do
          {:ok, []}
        else
          other_session_ids = Enum.map(other_sessions, & &1["session_id"])
          other_session_keys = Enum.map(other_session_ids, &session_key/1)
          user_sessions_key = user_sessions_key(user_id)

          commands = [
            ["MULTI"],
            ["DEL" | other_session_keys],
            ["ZREM", user_sessions_key | other_session_ids],
            ["EXEC"]
          ]

          case execute_transaction(commands) do
            :ok ->
              {:ok, other_sessions}

            error ->
              error
          end
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp session_key(session_id), do: "auth:session:#{session_id}"
  defp user_sessions_key(user_id), do: "auth:user:sessions:#{user_id}"

  defp execute_transaction(commands) do
    case Redix.pipeline(:redix, commands) do
      {:ok, responses} ->
        case List.last(responses) do
          nil ->
            {:error, :transaction_aborted}

          exec_results when is_list(exec_results) ->
            if Enum.any?(exec_results, &match?(%Redix.Error{}, &1)) do
              {:error, {:redis_error, exec_results}}
            else
              :ok
            end

          other ->
            {:error, {:unexpected_response, other}}
        end

      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end
end
