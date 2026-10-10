defmodule HakkawineWeb.ServiceController do
  use HakkawineWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index)
  end

  def details(conn, _params) do
    conn
    |> render(:details)
  end
end
