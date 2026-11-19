defmodule HakkawineWeb.UserSubscriptionLive do
  use HakkawineWeb, :live_view

  require Logger

  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.System
  alias Hakkawine.Subscription
  alias Hakkawine.Subscription.UrlBuilder
  alias Hakkawine.Utils.TimeUtils
  alias Hakkawine.Stats
  alias Hakkawine.Stats.TrafficForm

  @impl true
  def mount(%{"sub_id" => sub_id}, session, socket) do
    user_id = session["user_id"]
    session_id = session["session_id"]

    sub = Subscription.get_for_user(user_id, sub_id) |> Repo.preload(:product)

    billing_summary = Subscription.billing_summary(sub)

    online_device_count = 0

    sub_urls =
      if sub.status in [:active, :exhausted] do
        UrlBuilder.generate_all(
          sub,
          System.get_setting("site_name") <> "-" <> sub.product.name
        )
      else
        %{}
      end

    form =
      %TrafficForm{}
      |> TrafficForm.changeset(%{})
      |> Ecto.Changeset.apply_action!(:cast)

    socket =
      socket
      |> assign(
        user_id: user_id,
        session_id: session_id,
        sub: sub,
        sub_urls: sub_urls,
        expires_in_one_month: TimeUtils.expires_in_one_month?(sub.expired_at),
        billing_summary: billing_summary,
        online_device_count: online_device_count,
        show_addon_list: false,
        addon_list: [],
        active_period: form.active_period,
        custom_start_time: form.custom_start_time,
        custom_end_time: form.custom_end_time
      )
      |> assign_async(:traffic_usage, fn ->
        {aligned_start, aligned_end, interval_minutes, summary, list} =
          Stats.get_subscription_traffic_chart(sub, form)

        {:ok,
         %{
           traffic_usage: %{
             aligned_start: aligned_start,
             aligned_end: aligned_end,
             interval_minutes: interval_minutes,
             summary: summary,
             list: list
           }
         }}
      end)

    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_addon_list", _params, socket) do
    sub = socket.assigns.sub
    current_state = socket.assigns.show_addon_list

    addon_list =
      if !current_state and sub.product.charge_type == :recurring and
           sub.status in [:active, :exhausted] do
        Catalog.list_active_addons() |> Repo.preload(:prices)
      else
        []
      end

    socket =
      socket
      |> assign(
        show_addon_list: !current_state,
        addon_list: addon_list
      )

    {:noreply, socket}
  end

  def handle_event("toggle_auto_renewal", _params, socket) do
    sub = socket.assigns.sub

    case Subscription.toggle_auto_renewal(sub.user_id, sub.id) do
      {:ok, updated_sub} ->
        updated_sub = %{updated_sub | product: socket.assigns.sub.product}

        socket =
          socket
          |> assign(sub: updated_sub)

        {:noreply, socket}

      {:error, :not_found} ->
        socket =
          socket
          |> put_flash(:error, "Subscription not found.")
          |> push_navigate(to: ~p"/plans")

        {:noreply, socket}

      {:error, reason} ->
        Logger.error(
          "Failed to update subscription for user_id: #{sub.user_id}, reason: #{inspect(reason)}"
        )

        socket =
          socket
          |> put_flash(:error, "Failed to update preferences. Please try again.")

        {:noreply, socket}
    end
  end

  def handle_event("toggle_quota_auto_reset", _params, socket) do
    sub = socket.assigns.sub

    case Subscription.toggle_quota_auto_reset(sub.user_id, sub.id) do
      {:ok, updated_sub} ->
        updated_sub = %{updated_sub | product: socket.assigns.sub.product}

        socket =
          socket
          |> assign(sub: updated_sub)

        {:noreply, socket}

      {:error, :not_found} ->
        socket =
          socket
          |> put_flash(:error, "Subscription not found.")
          |> push_navigate(to: ~p"/plans")

        {:noreply, socket}

      {:error, reason} ->
        Logger.error(
          "Failed to update subscription for user_id: #{sub.user_id}, reason: #{inspect(reason)}"
        )

        socket =
          socket
          |> put_flash(:error, "Failed to update preferences. Please try again.")

        {:noreply, socket}
    end
  end

  def handle_event("change_sub_traffic_period", params, socket) do
    sub_traffic_update(params, socket)
  end

  def handle_event("change_sub_traffic_time_range", params, socket) do
    sub_traffic_update(params, socket)
  end

  def handle_event("show_node_traffic_usage", _params, socket) do
    {:noreply, socket}
  end

  defp sub_traffic_update(params, socket) do
    changeset = TrafficForm.changeset(%TrafficForm{}, params)

    case Ecto.Changeset.apply_action(changeset, :cast) do
      {:ok, form} ->
        sub = socket.assigns.sub

        socket =
          socket
          |> assign(
            active_period: form.active_period,
            custom_start_time: form.custom_start_time,
            custom_end_time: form.custom_end_time
          )
          |> assign_async(:traffic_usage, fn ->
            {aligned_start, aligned_end, interval_minutes, summary, list} =
              Stats.get_subscription_traffic_chart(sub, form)

            IO.inspect({aligned_start, aligned_end, interval_minutes, summary})

            {:ok,
             %{
               traffic_usage: %{
                 aligned_start: aligned_start,
                 aligned_end: aligned_end,
                 interval_minutes: interval_minutes,
                 summary: summary,
                 list: list
               }
             }}
          end)

        {:noreply, socket}

      {:error, changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        error_msg =
          Enum.map_join(errors, ", ", fn {field, msgs} ->
            "#{field} #{Enum.join(msgs, ", ")}"
          end)

        {:noreply, put_flash(socket, :error, "Validation failed: #{error_msg}")}
    end
  end
end
