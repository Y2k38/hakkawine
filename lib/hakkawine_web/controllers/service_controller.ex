defmodule HakkawineWeb.ServiceController do
  use HakkawineWeb, :controller

  alias Hakkawine.Repo
  alias Hakkawine.Subscription

  def index(conn, _params) do
    user_id = conn.assigns.user_id

    subs = Subscription.list_history_subscriptions(user_id) |> Repo.preload(:product)

    billing_summaries =
      Map.new(subs, fn sub ->
        if sub.status == :active do
          {sub.id, Subscription.billing_summary(sub)}
        else
          nil
        end
      end)

    conn
    |> render(:index, subs: subs, billing_summaries: billing_summaries)
  end
end
