defmodule HakkawineWeb.CheckoutController do
  use HakkawineWeb, :controller
  alias Hakkawine.Catalog
  # alias Hakkawine.Order

  def plan_page(conn, params) do
    %{"code" => code} = params

    plan = Catalog.get_product_by_plan_code(code)

    conn
    |> render(:plan,
      plan: plan,
      brand_name: "Hakkawine",
      user_balance: 0
    )
  end
end
