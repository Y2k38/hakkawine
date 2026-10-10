defmodule HakkawineWeb.AccountController do
  use HakkawineWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index)
  end
end
