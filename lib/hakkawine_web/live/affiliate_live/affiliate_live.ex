defmodule HakkawineWeb.AffiliateLive do
  use HakkawineWeb, :live_view

  alias Hakkawine.Repo
  alias Hakkawine.Affiliate
  alias Hakkawine.Accounts

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]

    user = Accounts.get_user(user_id)

    user_commissions = Affiliate.get_user_commissions(user_id)

    affiliate_count = Accounts.count_affiliate_users(user_id)

    commission_rules = Affiliate.fetch_all_active_commission_rules() |> Repo.preload(:product)

    socket =
      socket
      |> assign(
        user: user,
        user_commissions: user_commissions,
        affiliate_count: affiliate_count,
        commission_rules: commission_rules,
        show_rules: false
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("toggle_commission_rules", _, socket) do
    {:noreply, assign(socket, :show_rules, !socket.assigns.show_rules)}
  end
end
