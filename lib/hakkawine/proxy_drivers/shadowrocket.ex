defmodule Hakkawine.ProxyDrivers.Shadowrocket do
  alias Hakkawine.ProxyDrivers.Endpoint
  alias Hakkawine.ProxyDrivers.Config
  alias Hakkawine.ProxyDrivers.Shadowsocks

  def format(endpoint, opts) do
    case {endpoint.role, endpoint.config.protocol} do
      {:client, :ss} ->
        {:ok, Shadowsocks.build_client_uri(endpoint)}

      _ ->
        {:error, :unsupported_role_or_protocol}
    end
  end
end
