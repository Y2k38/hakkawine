defmodule HakkawineWeb.Plugs.BlockQqWechat do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    user_agent =
      conn
      |> get_req_header("user-agent")
      |> List.first() || ""

    if qq_or_wechat?(user_agent) do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(200, "")
      |> halt()
    else
      conn
    end
  end

  defp qq_or_wechat?(ua) do
    String.contains?(ua, "MicroMessenger") or String.contains?(ua, "QQ/")
  end
end
