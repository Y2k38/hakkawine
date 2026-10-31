defmodule HakkawineWeb.PageController do
  use HakkawineWeb, :controller

  alias Hakkawine.Marketing
  alias Hakkawine.Billing
  alias Hakkawine.Repo
  alias Hakkawine.Subscription

  def index(conn, _params) do
    if conn.assigns.user_id do
      redirect(conn, to: ~p"/home")
    else
      redirect(conn, to: ~p"/auth/log_in")
    end
  end

  def home(conn, _params) do
    user_id = conn.assigns.user_id
    subs = Subscription.list_valid_subscriptions(user_id) |> Repo.preload(:product)

    billing_summaries =
      Map.new(subs, fn sub ->
        {sub.id, Subscription.billing_summary(sub)}
      end)

    total_remaining = Enum.sum_by(billing_summaries, fn {_, data} -> data.remaining end)

    user_balance = Billing.get_user_balance(user_id)

    checkin_today = Marketing.get_today_user_checkin(user_id)
    checkin_today_count = Marketing.count_today_checkins()

    render(conn, :home,
      subs: subs,
      billing_summaries: billing_summaries,
      total_remaining: total_remaining,
      user_balance: user_balance,
      commission_balance: 0,
      checkin_today: checkin_today,
      checkin_today_count: checkin_today_count
    )
  end
end
