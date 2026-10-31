defmodule HakkawineWeb.Live.Hooks.InitSessionAssigns do
  use HakkawineWeb, :verified_routes

  import Phoenix.Component
  import Phoenix.LiveView

  alias Hakkawine.Sessions

  def on_mount(_initial_arg, _params, session, socket) do
    user_id = session["user_id"]
    session_id = session["session_id"]
    email = session["email"] || ""

    if Sessions.valid_session?(user_id, session_id) do
      socket =
        socket
        |> assign(:user_id, user_id)
        |> assign(:session_id, session_id)
        |> assign(:email, email)

      # {:cont, socket}
      {:cont, attach_hook(socket, :verify_session_on_event, :handle_event, &check_session/3)}
    else
      halt_with_error(socket)
    end
  end

  defp check_session(_event, _params, socket) do
    user_id = socket.assigns[:user_id]
    session_id = socket.assigns[:session_id]

    if user_id && session_id && Hakkawine.Sessions.valid_session?(user_id, session_id) do
      {:cont, socket}
    else
      halt_with_error(socket)
    end
  end

  defp halt_with_error(socket) do
    {:halt,
     socket
     |> put_flash(:error, "Your session has expired or been terminated.")
     |> push_navigate(to: ~p"/auth/log_in")}
  end
end
