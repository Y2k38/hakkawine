defmodule HakkawineWeb.PageController do
  use HakkawineWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
