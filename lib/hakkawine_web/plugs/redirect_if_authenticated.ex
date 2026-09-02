defmodule HakkawineWeb.Plugs.RedirectIfAuthenticated do
  import Plug.Conn
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: "/")
      |> halt()
    else 
      conn
    end
  end
end