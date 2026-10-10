defmodule HakkawineWeb.PageController do
  use HakkawineWeb, :controller

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/home")
    else
      redirect(conn, to: ~p"/auth/log_in")
    end
  end

  def home(conn, _params) do
    render(conn, :home)
  end
end
