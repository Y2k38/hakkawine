defmodule HakkawineWeb.TicketController do
  use HakkawineWeb, :controller

  def index(conn, _params) do
    conn
    |> render(:index)
  end

  def new(conn, _params) do
    conn
    |> render(:new)
  end
end
