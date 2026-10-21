defmodule HakkawineWeb.UserAccountLive.Index do
  use HakkawineWeb, :live_view

  alias Hakkawine.Billing

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign(:user_id, session["user_id"])
      |> assign(:session_id, session["session_id"])

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    current_tab = params["tab"] || "main"

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

  def handle_event("switch_tab", %{"tab" => "main"}, socket) do
    {:noreply, push_patch(socket, to: ~p"/account")}
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, push_patch(socket, to: ~p"/account?tab=#{tab}")}
  end

  def load_tab_data(socket, "main", _page) do
    user = socket.assigns.current_user

    user_balance = Billing.get_user_balance(user.id)

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
end
