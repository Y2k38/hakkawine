defmodule HakkawineWeb.PlanController do
  use HakkawineWeb, :controller

  alias Hakkawine.Catalog

  def list(conn, _params) do
    plans = Catalog.list_active_plans()

    recurring_plans = Enum.filter(plans, &(&1.reset_policy == :recurring_cycle))
    one_time_plans = Enum.filter(plans, &(&1.reset_policy == :never))

    conn
    |> render(
      :list,
      recurring_plans: recurring_plans,
      one_time_plans: one_time_plans
    )
  end
end
