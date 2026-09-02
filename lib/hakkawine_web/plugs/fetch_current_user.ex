defmodule HakkawineWeb.Plugs.FetchCurrentUser do
  import Plug.Conn
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    case user_id && Accounts.get_user(user_id) do
      %UserAccount{} = user ->
        session_ts = get_session(conn, :password_updated_at) || 0
        db_ts = (user.password_updated_at && DateTime.to_unix(user.password_updated_at)) || 0

        if session_ts >= db_ts do
          assign(conn, :current_user, user)
        else
          conn
          |> delete_session(:user_id)
          |> delete_session(:password_updated_at)
          |> assign(:current_user, nil)
        end

      _ ->
        assign(conn, :current_user, nil)
    end
  end
end
