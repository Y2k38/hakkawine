defmodule HakkawineWeb.Plugs.RedirectIfAuthenticated do
  import Phoenix.Controller

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> redirect(to: "/")
    else
      conn
    end
  end
end
