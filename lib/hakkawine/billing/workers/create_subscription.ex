defmodule Hakkawine.Billing.Workers.CreateSubscription do
  use Oban.Worker,
    queue: :realtime,
    max_attempts: 3

  require Logger

  alias Hakkawine.Repo
  alias Hakkawine.Billing
  alias Hakkawine.Billing.Order
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"order_id" => order_id, "user_id" => user_id}}) do
    with order <- Billing.get_order(order_id),
         user <- Accounts.get_user(user_id),
         :ok <- process_subscription(order, user) do
      :ok
    else
      {:error, reason} = error ->
        Logger.error("process_subscription fail, error: #{inspect(reason)}",
          params: %{"order_id" => order_id, "user_id" => user_id}
        )
    end
  end

  defp process_subscription(nil, _user), do: {:error, :order_not_found}
  defp process_subscription(_order, nil), do: {:error, :user_not_found}

  defp process_subscription(%Order{status: "paid"} = order, %UserAccount{} = user) do
    if Subscriptions.has_subscription_for_order?(order.id) do
      :ok
    else
      case Subscriptions.create_subscription_for_user(user, order) do
        {:ok, _subscription} ->
          :ok

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  # defp process_subscription(%Order{status: status}, _user) do
  #   # Logger.info("Skip CreateSubscription for order in status: #{status}")
  #   :ok
  # end
end
