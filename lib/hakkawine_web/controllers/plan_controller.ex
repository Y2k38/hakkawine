defmodule HakkawineWeb.PlanController do
  use HakkawineWeb, :controller

  alias Hakkawine.Catalog

  def index(conn, _params) do
    plans = Catalog.list_active_plans()

    recurring_plans = Enum.filter(plans, &(&1.charge_type == :recurring))
    one_time_plans = Enum.filter(plans, &(&1.charge_type == :one_time))

    conn
    |> render(
      :index,
      recurring_plans: recurring_plans,
      one_time_plans: one_time_plans
    )
  end
end
