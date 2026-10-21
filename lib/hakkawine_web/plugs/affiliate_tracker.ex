defmodule HakkawineWeb.Plugs.AffiliateTracker do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn = fetch_query_params(conn)

    case conn.query_params["affid"] do
      nil ->
        conn

      affid ->
        # Last-Touch Attribution
        if conn.cookies["affid"] == affid do
          conn
        else
          # Set a 30-day attribution window as the industry standard, balancing user decision time with browser cookie lifespan limits.
          put_resp_cookie(conn, "affid", affid,
            max_age: 30 * 24 * 60 * 60,
            http_only: true,
            secure: true,
            same_site: "Lax"
          )
        end
    end
  end
end
