defmodule HakkawineWeb.PlansLive do
  use HakkawineWeb, :live_view

  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.Subscription

  @impl true
  def mount(_params, session, socket) do
    user_id = session["user_id"]
    session_id = session["session_id"]

    plans = Catalog.list_active_plans() |> Repo.preload(:prices)

    recurring_plans = Enum.filter(plans, &(&1.charge_type == :recurring))
    one_time_plans = Enum.filter(plans, &(&1.charge_type == :one_time))

    current_sub =
      Subscription.get_active_recurring_subscription(user_id) |> Repo.preload(:product)

    socket =
      socket
      |> assign(
        user_id: user_id,
        session_id: session_id,
        recurring_plans: recurring_plans,
        one_time_plans: one_time_plans,
        current_sub: current_sub
      )

    {:ok, socket}
  end
end
