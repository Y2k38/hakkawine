defmodule HakkawineWeb.Agent.V1.AgentSocket do
  use Phoenix.Socket

  alias Hakkawine.Agents

  channel "agent:*", HakkawineWeb.Agent.V1.AgentChannel

  @impl true
  def connect(
        %{"client_id" => client_id, "client_secret" => client_secret} = _params,
        socket,
        _connect_info
      ) do
    agent = Agents.get_agent_by_client_id(client_id)

    if Argon2.verify_pass(client_secret, agent.client_secret_hash) do
      {:ok, assign(socket, :client_id, client_id)}
    else
      :error
    end
  end

  @impl true
  def connect(_params, _socket, _connect_info) do
    :error
  end

  @impl true
  def id(socket), do: "agent_socket:#{socket.assigns.client_id}"
end
