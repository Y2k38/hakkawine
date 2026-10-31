defmodule HakkawineWeb.Plugs.InitSessionAssigns do
  import Plug.Conn

  alias Hakkawine.Sessions

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    session_id = get_session(conn, :session_id)
    email = get_session(conn, :email)

    if Sessions.valid_session?(user_id, session_id) do
      conn
      |> assign(:user_id, user_id)
      |> assign(:session_id, session_id)
      |> assign(:email, email)
    else
      conn
      |> clear_session_data()
      |> assign(:user_id, nil)
      |> assign(:session_id, nil)
      |> assign(:email, nil)
    end
  end

  defp clear_session_data(conn) do
    conn
    |> delete_session(:user_id)
    |> delete_session(:email)
    |> delete_session(:session_id)
  end
end
