defmodule HakkawineWeb.Agent.V1.AgentChannel do
  use Phoenix.Channel

  @impl true
  def join("agent:" <> client_id, _payload, socket) do
    if socket.assigns.client_id == client_id do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("agent:message", packet, socket) do
    {:reply, {:ok, %{status: "success"}}, socket}
  end
end
