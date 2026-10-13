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
  end

  def get_plan_by_code(code) do
    Product
    |> where(code: ^code)
    |> where(type: :plan)
    |> where(status: :active)
    |> Repo.one()
  end

  def list_active_addons do
    Product
    |> where(type: :addon)
    |> where(status: :active)
    |> order_by(asc: :sort_order)
    |> Repo.all()
  end
end
