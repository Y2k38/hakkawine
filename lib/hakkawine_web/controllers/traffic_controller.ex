defmodule HakkawineWeb.TrafficController do
  use HakkawineWeb, :controller

  alias Hakkawine.Subscription
  alias Hakkawine.Stats
  alias Hakkawine.Stats.TrafficForm

  def sub_usage(conn, %{"sub_id" => sub_id} = params) do
    user_id = conn.assigns.user_id

    changeset = TrafficForm.changeset(%TrafficForm{}, params)

    case Ecto.Changeset.apply_action(changeset, :cast) do
      {:ok, form} ->
        subscription = Subscription.get_for_user(user_id, sub_id)

        {aligned_start, aligned_end, interval_minutes, summary, traffic_data} =
          Stats.get_subscription_traffic_chart(subscription, form)

        json(conn, %{
          period: form.period,
          start_time: form.start_time,
          end_time: form.end_time,
          aligned_start: aligned_start,
          aligned_end: aligned_end,
          interval_minutes: interval_minutes,
          summary: summary,
          traffic_data: traffic_data
        })

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:bad_request)
        |> json(%{errors: errors})
    end
  end

  def sub_node_stats(_conn, _params) do
  end

  def sub_export(_conn, _params) do
  end
end
