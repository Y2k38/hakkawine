defmodule Hakkawine.Billing.Workers.ExpireOrder do
  use Oban.Worker,
    queue: :scheduled,
    max_attempts: 3

  alias Hakkawine.Repo
  alias Hakkawine.Billing.Order

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"order_id" => order_id}}) do
    case Repo.get(Order, order_id) do
      nil ->
        :ok

      %Order{status: "pending"} = order ->
        order
        |> Order.changeset(%{status: "cancelled", note: "payment_timeout"})
        |> Repo.update()
        |> case do
          {:ok, _updated_order} ->
            :ok

          {:error, changeset} ->
            {:error, changeset}
        end

      %Order{status: _other_status} ->
        :ok
    end
  end
end
