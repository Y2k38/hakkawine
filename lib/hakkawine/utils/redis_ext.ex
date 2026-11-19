defmodule Hakkawine.Utils.RedisExt do
  def execute_transaction(conn \\ :redix, commands) do
    case Redix.pipeline(conn, commands) do
      {:ok, responses} ->
        case List.last(responses) do
          nil ->
            {:error, :transaction_aborted}

          exec_results when is_list(exec_results) ->
            if Enum.any?(exec_results, &match?(%Redix.Error{}, &1)) do
              {:error, {:redis_error, exec_results}}
            else
              {:ok, exec_results}
            end

          other ->
            {:error, {:unexpected_response, other}}
        end

      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end

  def execute_pipeline(conn \\ :redix, commands) do
    case Redix.pipeline(conn, commands) do
      {:ok, responses} ->
        if Enum.any?(responses, &match?(%Redix.Error{}, &1)) do
          {:error, {:redis_error, responses}}
        else
          {:ok, responses}
        end

      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end
end
