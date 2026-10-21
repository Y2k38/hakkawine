defmodule HakkawineWeb.UserAccountLive.Components.BillingComponent do
  use HakkawineWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)

    {:ok, socket}
  end
end
