defmodule Hakkawine.Catalog do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Catalog.Product

  def list_active_plans do
    Product
    |> where(type: :plan)
    |> where(status: :active)
    |> order_by(asc: :sort_order)
    |> Repo.all()
    |> Repo.preload(:prices)
  end

  def get_product_by_plan_code(code) do
    Product
    |> where(code: ^code)
    |> where(type: :plan)
    |> where(status: :active)
    |> Repo.one()
    |> Repo.preload(:prices)
  end
end
