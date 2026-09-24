defmodule HakkawineWeb.CheckoutController do
  use HakkawineWeb, :controller
  alias Hakkawine.Catalog

  def new_sub(conn, params) do
    case params do
      %{"code" => code} when is_binary(code) and code != "" ->
        plan = Catalog.get_product_by_plan_code(code)

        render(conn, :new_sub,
          plan: plan,
          brand_name: "Hakkawine",
          user_balance: 0,
          idempotency_key: Ecto.UUID.generate()
        )

      _ ->
        referer = get_req_header(conn, "referer") |> List.first() || "/plan/list"

        conn
        |> put_flash(:error, "Please select a valid plan.")
        |> redirect(to: referer)
        |> halt()
    end
  end

  def renew_sub(_conn, _params) do
    # subscription_id
    # target_product_code
    # billing_cycle
  end

  def upgrade_sub(_conn, _params) do
    # subscription_id
    # current_product_code
    # target_product_code
  end

  def reset_quota(_conn, _params) do
    # subscription_id
    # target_product_code
  end

  def addon(_conn, _params) do
    # subscription_id
    # target_product_code
  end

  def topup(_conn, _params) do
    # recharge_amount
  end
end
