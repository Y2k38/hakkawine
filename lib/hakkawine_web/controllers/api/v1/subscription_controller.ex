defmodule HakkawineWeb.Api.V1.SubscriptionController do
  alias Hakkawine.Subscription
  use HakkawineWeb, :controller

  def index(conn, %{"uuid" => uuid}) do
    ua = get_req_header(conn, "user-agent") |> List.first() || ""

    with {:ok, subscription} <- Subscription.get_by_uuid(uuid),
         {:ok, profile} <- Subscription.build_profile(subscription, ua) do
      conn
      |> put_status(200)
      |> put_resp_content_type(profile.type)
      |> put_resp_header("profile-title", profile.title)
      |> put_resp_header("profile-update-interval", to_string(profile.interval))
      |> put_resp_header("subscription-userinfo", build_userinfo(subscription))
      |> put_resp_header("content-disposition", ~s(attachment; filename="#{profile.filename}"))
      |> text(profile.content)
    else
      {:error, :subscription_not_found} ->
        conn |> put_status(404) |> json(%{error: "Subscription not found"})
    end
  end

  def index(conn, _params) do
    conn
    |> put_status(404)
    |> json(%{error: "Invalid request"})
  end
end
