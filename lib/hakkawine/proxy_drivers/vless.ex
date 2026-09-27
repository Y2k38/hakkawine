defmodule Hakkawine.ProxyDrivers.Vless do
  alias Hakkawine.ProxyDrivers.Config

  @networks [:tcp, :ws, :grpc, :xhttp, :quic]

  def networks, do: @networks

  def generate_keypair do
    {pub_key_bytes, priv_key_bytes} = :crypto.generate_key(:eddsa, :x25519)

    private_key = Base.url_encode64(priv_key_bytes, padding: false)
    public_key = Base.url_encode64(pub_key_bytes, padding: false)

    %{
      private_key: private_key,
      public_key: public_key
    }
  end

  defp random_short_id(short_ids) when is_list(short_ids) and short_ids != [],
    do: Enum.random(short_ids)

  defp random_short_id(_), do: ""

  @clash_server_template """
  - name: "vless-reality-in"
    type: vless
    server: 0.0.0.0
    port: <%= endpoint.port %>
    users:
      - user_<%= endpoint.config.user_id %>: 1
        uuid: <%= endpoint.config.user_uuid %>
    reality-config:
      dest: <%= endpoint.config.obfs_host %>:<%= endpoint.config.obfs_port %>
      private-key: <%= endpoint.config.vless_private_key %>
      short-id:
        - <%= endpoint.config.vless_short_ids %>
      server-names:
      <% for id <- endpoint.config.vless_short_ids do %>
        - <%= id %>
      <% end %>
    <% if endpoint.config.vless_network == :xhttp %>
    xhttp-config:
      path: "<%= endpoint.config.obfs_uri %>"
      host: "<%= endpoint.config.obfs_host %>"
      mode: <%= endpoint.config.obfs_mode %>
    <% end %>
  """

  @clash_client_template """
  - name: <%= endpoint.name %>
    type: vless
    server: <%= endpoint.server %>
    port: <%= endpoint.port %>
    uuid: <%= endpoint.config.user_uuid %>
    reality-opts:
      public-key: "<%= endpoint.config.vless_public_key %>"
      short-id: "<%= short_id %>"
    network: <%= endpoint.config.vless_network %>
    <% if endpoint.config.vless_network == :xhttp %>
    xhttp-opts:
      path: <%= endpoint.config.obfs_uri %>
      host: <%= endpoint.config.obfs_host %>
      mode: "stream-one"
    <% end %>
    udp: <%= endpoint.config.enable_udp %>
    tls: true
    servername: <%= endpoint.config.obfs_host %>
    alpn: <%= endpoint.config.alpn %>
    client-fingerprint: <%= fp %>
  """

  def build_client_uri(endpoint) do
    userinfo =
      Base.encode64(":#{endpoint.config.user_uuid}:#{endpoint.host}:#{endpoint.config.port}")

    query = build_query_params(endpoint) |> URI.encode_query()

    "vless://#{userinfo}?#{query}"
  end

  defp build_query_params(endpoint) do
    obfs_host = "{\"Host\":\"#{endpoint.config.obfs_host}\"}"

    %{
      "obfs" => "xhttp",
      "obfsParam" => obfs_host,
      "path" => endpoint.config.obfs_uri,
      "mode" => "auto",
      "alpn" => endpoint.config.alpn || "http/1.1"
    }
    |> merge_common_params(endpoint)
  end

  defp merge_common_params(params, endpoint) do
    base = %{
      "tls" => "1",
      "udp" => if(endpoint.config.enable_udp, do: "1", else: "0"),
      "fingerprint" => Config.get_random_fingerprint(),
      "remarks" => endpoint.name
    }

    base =
      if is_binary(endpoint.config.vless_public_key) and endpoint.config.vless_public_key != "" do
        Map.merge(base, %{
          "pbk" => endpoint.config.vless_public_key,
          "sid" => random_short_id(endpoint.config.vless_short_ids)
        })
      else
        base
      end

    Map.merge(params, base)
  end
end
