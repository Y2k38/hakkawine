defmodule Hakkawine.Billing.Workers.CreateSubscription do
  use Oban.Worker,
    queue: :realtime,
    max_attempts: 3

  alias Hakkawine.Repo
  alias Hakkawine.Billing.Order
  alias Hakkawine.Accounts.UserAccount

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"order_id" => order_id, "user_id" => user_id}}) do
    with order <- Repo.get(Order, order_id),
         user <- Repo.get(UserAccount, user_id) do
      process_subscription(order, user)
    end
  end

  defp process_subscription(nil, _user), do: {:error, :order_not_found}
  defp process_subscription(_order, nil), do: {:error, :user_not_found}

  defp process_subscription(%Order{status: "paid"} = order, %UserAccount{} = user) do
    if Subscriptions.has_subscription_for_order?(order.id) do
      :ok
    else
      # 执行真正的创建/开通订阅逻辑
      case Subscriptions.create_subscription_for_user(user, order) do
        {:ok, _subscription} ->
          :ok

        {:error, reason} ->
          # 返回 error 触发 Oban 的指数退避自动重试
          {:error, reason}
      end
    end
  end

  defp process_subscription(%Order{status: status}, _user) do
    # Logger.info("Skip CreateSubscription for order in status: #{status}")
    :ok
  end
end
