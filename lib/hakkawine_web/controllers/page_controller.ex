defmodule HakkawineWeb.PageController do
  use HakkawineWeb, :controller

  alias Hakkawine.Billing
  alias Hakkawine.Repo
  alias Hakkawine.Subscription

  def index(conn, _params) do
    if conn.assigns[:current_user] do
      redirect(conn, to: ~p"/home")
    else
      redirect(conn, to: ~p"/auth/log_in")
    end
  end

  def home(conn, _params) do
    user = conn.assigns[:current_user]

    subscriptions = Subscription.list_active_subscriptions(user.id) |> Repo.preload(:product)

    billing_summaries =
      Map.new(subscriptions, fn sub ->
        {sub.id, Subscription.billing_summary(sub)}
      end)

    total_remaining = Enum.sum_by(billing_summaries, fn {_, data} -> data.remaining end)

    user_balance = Billing.get_user_balance(user.id)

    render(conn, :home,
      subscriptions: subscriptions,
      billing_summaries: billing_summaries,
      total_remaining: total_remaining,
      user_balance: user_balance,
      commission_balance: 0
    )
  end
end
