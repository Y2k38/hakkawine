defmodule Hakkawine.Checkout do
  import Ecto.Query
  alias Ecto.Multi
  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.Marketing
  alias Hakkawine.Marketing.Coupon
  alias Hakkawine.Catalog.ProductPrice
  alias Hakkawine.Checkout.CheckoutForm
  alias Hakkawine.Billing.Order
  alias Hakkawine.Billing.UserBalance
  alias Hakkawine.Billing.PaymentRecord
  alias Hakkawine.Billing.PaymentGateway
  alias Hakkawine.Billing.Workers.ExpireOrder
  alias Hakkawine.Billing.Workers.CreateSubscription

  defdelegate changeset(attrs \\ %{}), to: CheckoutForm

  def create_order(user, params \\ %{}) do
    with {:ok, form} <- CheckoutForm.parse(params),
        {:ok, order_attrs} <- build_order_attrs(user, form) do

      changeset = Order.changeset(%Order{}, order_attrs)

      multi =
        Multi.new()
        |> Multi.insert(:order, changeset)
        |> Multi.insert(:expire_job, fn %{order: order} ->
          ExpireOrder.new(%{"order_id" => order.id}, schedule_in: {30, :minutes})
        end)
        |> Multi.run(:payment_record, fn _repo, %{order: order} ->
          process_internal_payment(order)
        end)

      with {:ok, %{order: order, payment_record: payment}} <- Repo.transaction(multi),
           {:ok, payment_info} <- initiate_gateway_payment(order, payment) do
        {:ok, %{order: order, payment: payment, payment_info: payment_info}}
      else
        {:error, :order, %Ecto.Changeset{} = changeset, _changes} ->
          {:error, changeset}

        {:error, _failed_step, reason, _changes} ->
          {:error, reason}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  defp build_order_attrs(user, %{order_type: "plan_purchase"} = form) do
    plan = Catalog.get_product_by_plan_code(form.target_product_code)

    case Enum.find(plan.prices, &(to_string(&1.type) == form.billing_cycle)) do
      nil ->
        {:error, :invalid_billing_cycle}
      price ->
        subtotal = price.amount

        coupon = Marketing.get_active_coupon(form.coupon_code)
        discount = calculate_discount(coupon, price.amount)

        after_discount = Decimal.sub(subtotal, discount) |> Decimal.max(Decimal.new(0))

        balance_deduct = calculate_balance_deduct(user, form.use_balance, after_discount)

        payable_base = Decimal.sub(after_discount, balance_deduct) |> Decimal.max(Decimal.new(0))

        gateway = get_gateway(form.payment_driver)
        payment_fee = PaymentGateway.get_handle_fee(gateway, payable_base)

        total_amount = Decimal.add(payable_base, payment_fee)

        if PaymentGateway.exceeds_max_limit?(gateway, total_amount) do
          {:error, :exceeds_max_limit}
        else
          {:ok, %{
            user_id: user.id,
            type: "plan_purchase",
            status: "pending",
            product_id: plan.id,
            product_price_id: price.id,
            billing_cycle: form.billing_cycle,

            subtotal_amount: subtotal,
            discount_amount: discount,
            balance_amount: balance_deduct,
            payment_fee: payment_fee,
            total_amount: total_amount,

            coupon_code: form.coupon_code,
            coupon_snapshot: Coupon.to_snapshot(coupon),
            price_snapshot: ProductPrice.to_snapshot(price),

            payment_gateway_id: gateway.id,
            payment_driver: form.payment_driver,
            idempotency_key: form.idempotency_key
          }}
        end
    end
  end

  defp calculate_discount(nil, _amount), do: Decimal.new(0)
  defp calculate_discount(coupon, amount) do
    case coupon do
      %{type: :fixed_amount, value: val} -> Decimal.min(val, amount)
      %{type: :percentage, value: val} ->
        discount_val = Decimal.mult(amount, val)
        Decimal.min(discount_val, amount)
      _ -> Decimal.new(0)
    end
  end

  defp calculate_balance_deduct(user, use_balance, amount) do
    case use_balance do
      val when val in [true, "true"] ->
        balance = get_user_balance(user.id)
        Decimal.min(amount, balance)
      _ ->
        Decimal.new(0)
    end
  end

  defp get_user_balance(user_id) do
    UserBalance
    |> where(user_id: ^user_id)
    |> select([b], b.balance)
    |> Repo.one() || Decimal.new(0)
  end

  defp get_gateway(payment_driver) do
    PaymentGateway
    |> where(payment_driver: ^payment_driver)
    |> where(is_enable: true)
    |> Repo.one()
  end

  def process_internal_payment(order) do
    with {:ok, payment_record} <- create_payment_record(order) do
      case order.payment_driver do
        "balance" ->
          process_balance_payment(order, payment_record)

        _all_other_drivers ->
          {:ok, payment_record}
      end
    end
  end

  defp create_payment_record(order) do
    PaymentRecord.changeset(%PaymentRecord{}, %{
      status: "pending",
      order_id: order.id,
      user_id: order.user_id,
      payment_gateway_id: order.payment_gateway_id,
      payment_driver: order.payment_driver,
      amount: order.total_amount,
      gateway_currency: "USD",
      gateway_amount: order.total_amount
    })
    |> Repo.insert()
  end

  def process_balance_payment(_order, _payment_record) do
    {:ok}
  end

  defp initiate_gateway_payment(_order, payment) do
    if payment.status == "paid" do
      {:ok, %{action_type: :none, payload: %{status: "paid"}}}
    else
      {:ok, %{action_type: :none, payload: %{status: "paid"}}}
      # case order.payment_driver do
      #   "epay" ->
      #     case EpayService.create_pay_url(order, payment) do
      #       {:ok, url} ->
      #         {:ok, %{action_type: :redirect, payload: %{url: url}}}

      #       {:error, reason} ->
      #         {:error, {:payment_gateway_error, reason}}
      #     end

      #   "alipay_private" ->
      #     case AlipayService.generate_pay_params(order, payment) do
      #       {:ok, params} ->
      #         {:ok, %{action_type: :sdk, payload: params}}

      #       {:error, reason} ->
      #         {:error, {:payment_gateway_error, reason}}
      #     end

      #   unknown ->
      #     {:error, {:unsupported_driver, unknown}}
      # end
    end
  end

  defp mark_order_as_paid(%Multi{} = multi, %Order{} = order, %PaymentRecord{} = payment) do
    multi
      |> Multi.update(:order, Order.changeset(order, %{status: "paid", paid_at: DateTime.utc_now()}))
      |> Multi.update(:payment_record, PaymentRecord.changeset(payment, %{status: "paid", paid_at: DateTime.utc_now()}))
      |> Oban.insert(:provision_job, fn %{order: order} ->
        CreateSubscription.new(%{
          "order_id" => order.id,
          "user_id" => order.user_id
        })
      end)
  end
end
