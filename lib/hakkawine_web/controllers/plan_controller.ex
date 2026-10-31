defmodule HakkawineWeb.PlanController do
  use HakkawineWeb, :controller

  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.Subscription

  def index(conn, _params) do
    user_id = conn.assigns.user_id

    plans = Catalog.list_active_plans() |> Repo.preload(:prices)

    recurring_plans = Enum.filter(plans, &(&1.charge_type == :recurring))
    one_time_plans = Enum.filter(plans, &(&1.charge_type == :one_time))

    current_sub =
      Subscription.get_active_recurring_subscription(user_id) |> Repo.preload(:product)

    conn
    |> render(
      :index,
      recurring_plans: recurring_plans,
      one_time_plans: one_time_plans,
      current_sub: current_sub
    )
  end
end
