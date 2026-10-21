defmodule HakkawineWeb.Plugs.RedisRateLimiter do
  require Logger

  import Plug.Conn
  import Phoenix.Controller, only: [json: 2, put_flash: 3, redirect: 2]

  alias Hakkawine.Utils.RequestHelpers

  def init(opts) do
    %{
      action_name: Keyword.fetch!(opts, :action_name),
      time_window: Keyword.fetch!(opts, :time_window),
      max_attempts: Keyword.fetch!(opts, :max_attempts)
    }
  end

  def call(conn, opts) do
    if Application.get_env(:hakkawine, :rate_limiter)[:enabled] do
      do_rate_limit(conn, opts)
    else
      conn
    end
  end

  defp do_rate_limit(conn, opts) do
    client_identifier = get_client_identifier(conn)
    key = "rate_limit:#{opts.action_name}:#{client_identifier}"

    case check_rate_limit(key, opts.time_window, opts.max_attempts) do
      :ok ->
        conn

      {:error, :rate_limited} ->
        conn
        |> push_flash_message()
        |> halt()

      {:error, {error_type, reason}} ->
        Logger.error("Rate limiter failed [#{error_type}]: #{inspect(reason)}")

        conn
        |> handle_server_error()
        |> halt()
    end
  end

  defp push_flash_message(conn) do
    handle_error_response(conn, :too_many_requests, "Too many requests. Please try again later.")
  end

  defp handle_server_error(conn) do
    handle_error_response(conn, :internal_server_error, "Something went wrong. Please try again.")
  end

  defp handle_error_response(conn, status, message) do
    http_status = Plug.Exception.status(status) || status

    cond do
      json_request?(conn) ->
        conn
        |> put_status(http_status)
        |> json(%{error: message})

      Map.has_key?(conn.private, :plug_session) ->
        conn
        |> put_flash(:error, message)
        |> redirect(to: safe_referer_path(conn))

      true ->
        conn
        |> put_status(http_status)
        |> send_resp(http_status, message)
    end
  end

  defp json_request?(conn) do
    accept = get_req_header(conn, "accept") |> List.first() || ""
    content_type = get_req_header(conn, "content-type") |> List.first() || ""

    String.contains?(accept, "application/json") or
      String.contains?(content_type, "application/json") or
      String.starts_with?(conn.request_path, "/api")
  end

  defp safe_referer_path(conn) do
    with [referer | _] <- get_req_header(conn, "referer"),
         %URI{path: path} when is_binary(path) and path != "" <- URI.parse(referer) do
      if String.starts_with?(path, "/"), do: path, else: "/"
    else
      _ -> "/"
    end
  end

  defp get_client_identifier(conn) do
    ip_str = RequestHelpers.get_client_ip(conn)
    ua = get_req_header(conn, "user-agent") |> List.first() || "unknown"

    :crypto.hash(:sha256, "#{ip_str}:#{ua}")
    |> Base.encode16(case: :lower)
  end

  defp check_rate_limit(key, time_window, max_attempts) do
    commands = [
      ["INCR", key],
      ["EXPIRE", key, time_window, "NX"]
    ]

    case Redix.pipeline(:redix, commands) do
      {:ok, [%Redix.Error{} = error, _]} ->
        {:error, {:redis_error, error}}

      {:ok, [current_count, _expire_res]} when is_integer(current_count) ->
        if current_count <= max_attempts, do: :ok, else: {:error, :rate_limited}

      {:ok, [unexpected, _]} ->
        {:error, {:unexpected_response, unexpected}}

      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end
end
