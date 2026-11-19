defmodule HakkawineWeb.UserAccountLive do
  use HakkawineWeb, :live_view

  alias Hakkawine.Billing
  alias Hakkawine.Audits
  alias Hakkawine.Sessions

  @impl true
  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(
        user_id: session["user_id"],
        session_id: session["session_id"],
        email: session["email"],
        show_modal: false,
        active_modal: nil,
        modal_title: ""
      )

    {:ok, socket}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    current_tab = params["tab"] || "account"

    page =
      case Integer.parse(params["page"] || "1") do
        {p, _} -> p
        :error -> 1
      end

    socket =
      socket
      |> assign(:current_tab, current_tab)
      |> assign(:page, page)
      |> load_tab_data(current_tab, page)

    {:noreply, socket}
  end

  def load_tab_data(socket, "account", _page) do
    user_id = socket.assigns.user_id

    user_balance = Billing.get_user_balance(user_id)

    topup_rules = Billing.fetch_all_topup_rules()

    socket =
      socket
      |> assign(:user_balance, user_balance)
      |> assign(:topup_rules, topup_rules)

    socket
  end

  def load_tab_data(socket, "billing", _page) do
    socket
  end

  defp load_modal_data(socket, "balance_logs") do
    socket
  end

  defp load_modal_data(socket, "change_email") do
    socket
  end

  defp load_modal_data(socket, "change_pass") do
    socket
  end

  defp load_modal_data(socket, "session_list") do
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

  @impl true
  def handle_event("switch_tab", %{"tab" => "account"}, socket) do
    {:noreply, push_patch(socket, to: ~p"/account")}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, push_patch(socket, to: ~p"/account?tab=#{tab}")}
  end

  def handle_event("open_modal", %{"modal" => modal_type, "title" => modal_title}, socket) do
    socket = load_modal_data(socket, modal_type)

    {:noreply,
     assign(socket, show_modal: true, active_modal: modal_type, modal_title: modal_title)}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, show_modal: false, active_modal: nil, modal_title: "")}
  end

  def handle_event("logout_session", %{"session_id" => session_id}, socket) do
    user_id = socket.assigns[:user_id]

    case Sessions.delete_session(user_id, session_id) do
      {:ok, _responses} ->
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
    user_id = socket.assigns[:user_id]
    session_id = socket.assigns[:session_id]

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
end
