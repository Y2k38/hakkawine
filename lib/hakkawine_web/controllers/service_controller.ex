defmodule HakkawineWeb.ServiceController do
  use HakkawineWeb, :controller

  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.System
  alias Hakkawine.Subscription
  alias Hakkawine.Subscription.UrlBuilder

  def index(conn, _params) do
    user = conn.assigns[:current_user]

    subscriptions = Subscription.list_history_subscriptions(user.id) |> Repo.preload(:product)

    billing_summaries =
      Map.new(subscriptions, fn sub ->
        if sub.status in [:active, :exhausted, :suspended] do
          {sub.id, Subscription.billing_summary(sub)}
        else
          nil
        end
      end)

    conn
    |> render(:index, subscriptions: subscriptions, billing_summaries: billing_summaries)
  end

  def details(conn, %{"sub_id" => sub_id}) do
    subscription = Subscription.get_by_id(sub_id) |> Repo.preload([:product])

    billing_summary = Subscription.billing_summary(subscription)

    online_device_count = 0

    subscription_urls =
      if subscription.status in [:active, :exhausted, :suspended] do
        UrlBuilder.generate_all(
          subscription,
          System.get_setting("site_name") <> "-" <> subscription.product.name
        )
      else
        %{}
      end

    addon_list =
      if subscription.product.charge_type == :recurring and
           subscription.status in [:active, :exhausted, :suspended] do
        Catalog.list_active_addons() |> Repo.preload(:prices)
      else
        []
      end

    conn
    |> render(:details,
      subscription: subscription,
      billing_summary: billing_summary,
      online_device_count: online_device_count,
      subscription_urls: subscription_urls,
      addon_list: addon_list
    )
  end
end
