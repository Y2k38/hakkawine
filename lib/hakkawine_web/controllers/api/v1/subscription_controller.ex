defmodule HakkawineWeb.Api.V1.SubscriptionController do
  use HakkawineWeb, :controller

  require Logger

  alias Hakkawine.Subscription
  alias HakkawineWeb.Plugs.RedisRateLimiter

  plug RedisRateLimiter,
       [action_name: "ip_sub_req_min", time_window: 60, max_attempts: 10]
       when action in [:index]

  plug RedisRateLimiter,
       [action_name: "ip_sub_req_daily", time_window: 3_600, max_attempts: 20]
       when action in [:index]

  def index(conn, %{"uuid" => uuid}) do
    user_agent = get_req_header(conn, "user-agent") |> List.first() || ""
    target = Subscription.parse_user_agent(user_agent)

    with subscription <- Subscription.get_by_uuid(uuid),
         profile <- Subscription.build_profile(:client, target, subscription),
         userinfo <- Subscription.build_userinfo(subscription) do
      conn
      |> put_status(200)
      |> put_resp_content_type(profile.type)
      |> put_resp_header("profile-title", profile.title)
      |> put_resp_header("profile-update-interval", to_string(profile.update_interval))
      |> put_resp_header("subscription-userinfo", userinfo)
      |> put_resp_header("content-disposition", ~s(attachment; filename="#{profile.filename}"))
      |> text(profile.content)
    else
      {:error, :subscription_not_found} ->
        Logger.error("Subscription not found",
          params: %{"uuid" => uuid, "user_agent" => user_agent}
        )

        conn |> put_status(404) |> json(%{error: "Subscription not found"})
    end
  end
end
