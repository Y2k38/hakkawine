defmodule HakkawineWeb.ServiceController do
  use HakkawineWeb, :controller

  alias Hakkawine.Repo
  alias Hakkawine.Catalog
  alias Hakkawine.System
  alias Hakkawine.Subscription
  alias Hakkawine.Subscription.UrlBuilder
  alias Hakkawine.Utils.TimeUtils

  def index(conn, _params) do
    user_id = conn.assigns.user_id

    subs = Subscription.list_history_subscriptions(user_id) |> Repo.preload(:product)

    billing_summaries =
      Map.new(subs, fn sub ->
        if sub.status == :active do
          {sub.id, Subscription.billing_summary(sub)}
        else
          nil
        end
      end)

    conn
    |> render(:index, subs: subs, billing_summaries: billing_summaries)
  end

  def details(conn, %{"sub_id" => sub_id}) do
    user_id = conn.assigns.user_id

    sub = Subscription.get_for_user(user_id, sub_id) |> Repo.preload([:product])

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

    addon_list =
      if sub.product.charge_type == :recurring and
           sub.status in [:active, :exhausted] do
        Catalog.list_active_addons() |> Repo.preload(:prices)
      else
        []
      end

    conn
    |> render(:details,
      sub: sub,
      sub_urls: sub_urls,
      expires_in_one_month: TimeUtils.expires_in_one_month?(sub.expired_at),
      billing_summary: billing_summary,
      online_device_count: online_device_count,
      addon_list: addon_list
    )
  end
end
