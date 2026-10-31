defmodule HakkawineWeb.UserAccountLive.Components.AccountComponent do
  use HakkawineWeb, :live_component

  alias Hakkawine.Audits
  alias Hakkawine.Sessions

  def mount(socket) do
    {:ok, assign(socket, show_modal: false, active_modal: nil, modal_title: "", items: [])}
  end

  def handle_event("open_modal", %{"modal" => modal_type, "title" => modal_title}, socket) do
    socket = load_data_by_type(socket, modal_type)

    {:noreply,
     assign(socket, show_modal: true, active_modal: modal_type, modal_title: modal_title)}
  end

  def handle_event("logout_session", %{"session_id" => session_id}, socket) do
    user_id = socket.assigns[:user_id]

    case Sessions.delete_session(user_id, session_id) do
      :ok ->
        HakkawineWeb.Endpoint.broadcast(
          "user_session:#{user_id}:#{session_id}",
          "disconnect",
          %{}
        )

        updated_list =
          Enum.reject(socket.assigns.session_list, fn s -> s["session_id"] == session_id end)

        socket =
          socket
          |> put_flash(:info, "Session terminated successfully.")
          |> assign(:session_list, updated_list)

        {:noreply, socket}

      {:error, _reason} ->
        socket = put_flash(socket, :error, "Failed to log out of device. Please try again.")

        {:noreply, socket}
    end
  end

  def handle_event("logout_session", _, socket) do
    {:noreply, socket}
  end

  def handle_event("logout_other_sessions", _params, socket) do
    user_id = socket.assigns.user_id
    session_id = socket.assigns.session_id

    case Sessions.delete_other_sessions(user_id, session_id) do
      {:ok, deleted_sessions} ->
        Enum.each(deleted_sessions, fn other_session ->
          other_session_id = other_session["session_id"]
          HakkawineWeb.Endpoint.broadcast(
            "user_session:#{user_id}:#{other_session_id}",
            "disconnect",
            %{}
          )
        end)

        current_session =
          Enum.find(socket.assigns.session_list, fn s -> s["session_id"] == session_id end)

        updated_list = if current_session, do: [current_session], else: []

        socket =
          socket
          |> put_flash(:info, "All other sessions terminated successfully.")
          |> assign(:session_list, updated_list)

        {:noreply, socket}

      {:error, _reason} ->
        socket =
          put_flash(socket, :error, "Failed to log out of other devices. Please try again.")

        {:noreply, socket}
    end
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, active_modal: nil, modal_title: "")}
  end

  defp load_data_by_type(socket, "balance_logs") do
    socket
  end

  defp load_data_by_type(socket, "change_email") do
    socket
  end

  defp load_data_by_type(socket, "change_pass") do
    socket
  end

  defp load_data_by_type(socket, "session_list") do
    user_id = socket.assigns.user_id

    with {:ok, session_list} <- Sessions.list_user_sessions(user_id) do
      log_ids = Enum.map(session_list, & &1["log_id"])

      logs_map =
        Audits.list_user_logs_by_ids(log_ids)
        |> Map.new(fn log -> {to_string(log.id), log} end)

      final_session_list =
        Enum.map(session_list, fn session ->
          log = Map.get(logs_map, session["log_id"])

          Map.merge(session, %{
            "ip_address" => log && log.ip_address,
            "user_agent" => log && log.user_agent,
            "metadata" => log && log.metadata
          })
        end)

      socket
      |> assign(:session_list, final_session_list)
    else
      {:error, _reason} ->
        socket
        |> put_flash(:error, "Failed to load data, please try again later.")
        |> assign(:session_list, [])
    end
  end
end
