defmodule HakkawineWeb.PlanController do
  use HakkawineWeb, :controller

  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.Subscription

  def index(conn, _params) do
    user = conn.assigns[:current_user]

    plans = Catalog.list_active_plans() |> Repo.preload(:prices)

    recurring_plans = Enum.filter(plans, &(&1.charge_type == :recurring))
    one_time_plans = Enum.filter(plans, &(&1.charge_type == :one_time))

    subscription =
      Subscription.get_recurring_subscription_by_user_id(user.id) |> Repo.preload(:product)

    conn
    |> render(
      :index,
      recurring_plans: recurring_plans,
      one_time_plans: one_time_plans,
      subscription: subscription
    )
  end
end
