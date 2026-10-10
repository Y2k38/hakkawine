defmodule HakkawineWeb.Plugs.EnsureAdminRewritten do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.private[:admin_path_rewritten] == true do
      conn
    else
      %{conn | request_path: "/__invalid_404_path__", path_info: ["__invalid_404_path__"]}
    end
  end
end
