defmodule HakkawineWeb.Plugs.FetchCurrentUser do
  import Plug.Conn

  alias Hakkawine.Sessions
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    session_id = get_session(conn, :session_id) || 0

    case fetch_and_validate_user(user_id, session_id) do
      {:ok, %UserAccount{} = user} ->
        assign(conn, :current_user, user)

      _ ->
        conn
        |> delete_session(:user_id)
        |> delete_session(:session_id)
        |> assign(:current_user, nil)
    end
  end

  def on_mount(:fetch_current_user, _params, session, socket) do
    user_id = session["user_id"]
    session_id = session["session_id"] || 0

    user =
      case fetch_and_validate_user(user_id, session_id) do
        {:ok, %UserAccount{} = user} -> user
        _ -> nil
      end

    socket =
      socket
      |> Phoenix.Component.assign(:user_id, user_id)
      |> Phoenix.Component.assign(:session_id, session_id)
      |> Phoenix.Component.assign(:current_user, user)

    {:cont, socket}
  end

  defp fetch_and_validate_user(nil, _session_id), do: {:error, :unauthorized}
  defp fetch_and_validate_user(_user_id, nil), do: {:error, :unauthorized}

  defp fetch_and_validate_user(user_id, session_id) do
    with {:ok, _session} <- Sessions.get_session(user_id, session_id),
         %UserAccount{} = user <- Accounts.get_user(user_id) do
      {:ok, user}
    else
      _ -> {:error, :invalid_session}
    end
  end
end
