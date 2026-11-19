defmodule HakkawineWeb.Plugs.IpBan do
  use Phoenix.Component

  import Plug.Conn
  import Phoenix.Controller

  alias Hakkawine.Utils.RedisExt
  alias Hakkawine.Utils.RequestHelpers

  @window_seconds 60
  @max_404_count 10
  @ban_ttl_seconds 3600

  def block_banned(conn, _opts) do
    ip = RequestHelpers.get_client_ip(conn)

    commands = [
      ["EXISTS", "ban:ip:#{ip}"],
      ["EXISTS", "blacklist:ip:#{ip}"]
    ]

    case RedisExt.execute_pipeline(commands) do
      {:ok, [1, _]} ->
        conn |> put_status(403) |> render_banned(ip, :auto_banned) |> halt()

      {:ok, [_, 1]} ->
        conn |> put_status(403) |> render_banned(ip, :blacklisted) |> halt()

      {:ok, [0, 0]} ->
        conn

      {:error, _reason} ->
        conn
    end
  end

  def track_404(conn, _opts) do
    ip = RequestHelpers.get_client_ip(conn)
    counter_key = "counter:404:ip:#{ip}"

    commands = [
      ["INCR", counter_key],
      ["EXPIRE", counter_key, @window_seconds, "NX"]
    ]

    case RedisExt.execute_pipeline(commands) do
      {:ok, [count_reply, _]} ->
        if parse_count(count_reply) >= @max_404_count do
          ban_commands = [
            ["SET", "ban:ip:#{ip}", "1", "EX", @ban_ttl_seconds],
            ["DEL", counter_key]
          ]

          case RedisExt.execute_pipeline(ban_commands) do
            {:ok, _} -> :ok
            {:error, reason} -> {:error, reason}
          end
        else
          :ok
        end

      {:error, reason} ->
        {:error, reason}
    end

    conn
  end

  defp parse_count(count) when is_integer(count), do: count

  defp parse_count(count) when is_binary(count) do
    case Integer.parse(count) do
      {int, _} -> int
      :error -> 0
    end
  end

  defp parse_count(_), do: 0

  defp render_banned(conn, ip, type) do
    message =
      case type do
        :blacklisted -> "Your IP has been blacklisted by the administrator."
        :auto_banned -> "Your IP has been temporarily banned due to unusual activity."
      end

    case get_format(conn) do
      "json" ->
        json(conn, %{error: "Access Denied", message: message, ip: ip})

      _html ->
        conn
        |> put_root_layout(html: {HakkawineWeb.Layouts, :root})
        |> html(
          Phoenix.HTML.Safe.to_iodata(ban_page(%{ip: ip, message: message}))
          |> IO.iodata_to_binary()
        )
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
        <p class="text-gray-600 dark:text-gray-300 text-sm mb-4">{@message}</p>
        <div class="inline-block bg-gray-100 dark:bg-zinc-700/50 px-3 py-1 rounded text-xs font-mono text-gray-500 dark:text-gray-400">
          IP: {@ip}
        </div>
      </div>
    </div>
    """
  end
end
