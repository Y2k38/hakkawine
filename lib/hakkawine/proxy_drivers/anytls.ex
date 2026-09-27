defmodule Hakkawine.ProxyDrivers.AnyTLS do
  alias Hakkawine.ProxyDrivers.Config

  @clash_server_template """
  - name: anytls-in
    type: anytls
    listen: 0.0.0.0
    port: <%= endpoint.port %>
    users:
      user_<%= endpoint.config.user_id %>: <%= endpoint.config.user_uuid %>
    certificate: <%= endpoint.config.certificate %>
    private-key: <%= endpoint.config.private_key %>
    udp: <%= endpoint.config.enable_udp %>
  """

  @clash_client_template """
  - name: <%= endpoint.name %>
    type: anytls
    server: <%= endpoint.host %>
    port: <%= endpoint.port %>
    password: <%= endpoint.config.user_uuid %>
    client-fingerprint: <%= fp %>
    udp: <%= endpoint.config.enable_udp %>
    sni: <%= endpoint.obfs_host %>
    skip-cert-verify: <%= endpoint.config.skip_cert_verify %>
  """

  def build_client_uri(endpoint) do
    userinfo = endpoint.config.user_uuid
    query = build_query_params(endpoint) |> URI.encode_query()

    "anytls://#{userinfo}@#{endpoint.host}:#{endpoint.port}?#{query}##{URI.encode_www_form(endpoint.name)}"
  end

  defp build_query_params(endpoint) do
    %{
      "peer" => endpoint.config.obfs_host,
      "insecure" => Config.bool_to_flag(endpoint.config.skip_cert_verify),
      "fingerprint" => Config.get_random_fingerprint()
    }
  end
end
