defmodule HakkawineWeb.Plugs.IpBan do
  use Phoenix.Component

  import Plug.Conn
  import Phoenix.Controller

  @window_seconds 60
  @max_404_count 10
  @ban_ttl_seconds 3600

  def block_banned(conn, _opts) do
    ip = get_client_ip(conn)

    case Redix.command(:redix, ["EXISTS", "ban:ip:#{ip}"]) do
      {:ok, 1} ->
        conn
        |> put_status(403)
        |> render_banned(ip)
        |> halt()

      _ ->
        conn
    end
  end

  def track_404(conn, _opts) do
    ip = get_client_ip(conn)
    counter_key = "counter:404:ip:#{ip}"

    case Redix.transaction(:redix, [
           ["INCR", counter_key],
           ["EXPIRE", counter_key, @window_seconds, "NX"]
         ]) do
      {:ok, [count, _]} when count >= @max_404_count ->
        Redix.command(:redix, ["SET", "ban:ip:#{ip}", "1", "EX", @ban_ttl_seconds])
        Redix.command(:redix, ["DEL", counter_key])

      _ ->
        :ok
    end

    conn
  end

  defp get_client_ip(conn) do
    case get_req_header(conn, "x-forwarded-for") do
      [ip_list | _] ->
        ip_list |> String.split(",") |> List.first() |> String.trim()

      [] ->
        conn.remote_ip |> :inet.ntoa() |> to_string()
    end
  end

  defp render_banned(conn, ip) do
    case get_format(conn) do
      "json" ->
        json(conn, %{
          error: "Access Denied",
          message: "Your IP has been temporarily banned.",
          ip: ip
        })

      _html ->
        conn
        |> put_root_layout({HakkawineWeb.Layouts, :root})
        |> html(ban_page(%{ip: ip}))
    end
  end

  defp ban_page(assigns) do
    ~H"""
    <div class="min-h-[60vh] flex items-center justify-center p-4">
      <div class="max-w-md w-full bg-white dark:bg-zinc-800 rounded-xl shadow-lg p-6 text-center border border-gray-100 dark:border-zinc-700">
        <div class="w-12 h-12 bg-red-100 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-full flex items-center justify-center mx-auto mb-4 font-bold text-xl">
          ✕
        </div>
        <h1 class="text-xl font-bold text-gray-900 dark:text-white mb-2">403 Access Denied</h1>
        <p class="text-gray-600 dark:text-gray-300 text-sm mb-4">
          Your IP address has been temporarily banned due to unusual activity.
        </p>
        <div class="inline-block bg-gray-100 dark:bg-zinc-700/50 px-3 py-1 rounded text-xs font-mono text-gray-500 dark:text-gray-400">
          IP: {@ip}
        </div>
      </div>
    </div>
    """
  end
end
