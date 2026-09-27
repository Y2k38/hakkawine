defmodule Hakkawine.ProxyDrivers.Hysteria2 do
  alias Hakkawine.ProxyDrivers.Config

  @clash_server_template """
  - name: "hysteria2-in"
    type: hysteria2
    server: 0.0.0.0
    port: <%= endpoint.port %>
    users:
      <%= endpoint.config.user_uuid %>: <%= endpoint.config.password %>
    certificate: <%= endpoint.config.certificate %>
    private-key: <%= endpoint.config.private_key %>
    <% if endpoint.config.hy2_obfs == :salamander %>
    obfs: salamander
    obfs-password: <%= endpoint.config.obfs_pass %>
    <% end %>
    up: <%= endpoint.config.bandwidth_up_mbps %>
    down: <%= endpoint.config.bandwidth_down_mbps %>
  """

  @clash_client_template """
  - name: <%= endpoint.name %>
    type: hysteria2
    server: <%= endpoint.host %>
    port: <%= endpoint.port %>
    password: <%= endpoint.config.password %>
    <% if endpoint.config.hy2_obfs == :salamander %>
    obfs: salamander
    obfs-password: <%= endpoint.config.obfs_pass %>
    <% end %>
    sni: <%= endpoint.config.obfs_host %>
    skip-cert-verify: <%= endpoint.config.skip_cert_verify %>
    udp: <%= endpoint.config.enable_udp %>
    alpn:
      - h3
    fingerprint: <%= fp %>
  """

  def build_client_uri(endpoint) do
    userinfo = Base.encode64("user_#{endpoint.config.user_id}:#{endpoint.config.password}")
    query = build_query_params(endpoint.config) |> URI.encode_query()

    "hysteria2://#{userinfo}@#{endpoint.host}:#{endpoint.port}/?#{query}##{URI.encode_www_form(endpoint.name)}"
  end

  defp build_query_params(endpoint) do
    base_params = %{
      "sni" => endpoint.config.obfs_host,
      "insecure" => Config.bool_to_flag(endpoint.config.skip_cert_verify),
      "alpn" => "h3",
      "udp" => Config.bool_to_flag(endpoint.config.enable_udp)
    }

    if endpoint.config.hy2_obfs == :salamander do
      Map.merge(base_params, %{
        "obfs" => "salamander",
        "obfs-password" => endpoint.config.obfs_pass
      })
    else
      base_params
    end
  end
end
