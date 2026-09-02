defmodule HakkawineWeb.Plugs.RedisRateLimiter do
  import Plug.Conn
  import Phoenix.Controller, only: [json: 2, put_flash: 3, redirect: 2]

  def init(opts) do
    %{
      action_name: Keyword.fetch!(opts, :action_name),
      time_window: Keyword.fetch!(opts, :time_window),
      max_attempts: Keyword.fetch!(opts, :max_attempts)
    }
  end

  def call(conn, opts) do
    client_identifier = get_client_identifier(conn)
    key = "rate_limit:#{opts.action_name}:#{client_identifier}"

    case check_rate_limit(key, opts.time_window, opts.max_attempts) do
      :ok ->
        conn

      {:error, :rate_limited} ->
        conn
        |> render_rate_limited_response()
        |> halt()
    end
  end

  defp render_rate_limited_response(conn) do
    cond do
      json_request?(conn) ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Too many requests. Please try again later."})

      Map.has_key?(conn.private, :plug_session) ->
        conn
        |> put_flash(:error, "Too many requests. Please try again later.")
        |> redirect(to: safe_referer_path(conn))

      true ->
        conn
        |> put_status(:too_many_requests)
        |> send_resp(429, "Too many requests. Please try again later.")
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
    ip_str = conn.remote_ip |> :inet.ntoa() |> to_string()
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
      {:ok, [current_count, _expire_res]} ->
        if current_count <= max_attempts, do: :ok, else: {:error, :rate_limited}

      {:error, _reason} ->
        :ok
    end
  end
end