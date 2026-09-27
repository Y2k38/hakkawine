defmodule Hakkawine.ProxyDrivers.Shadowsocks do
  @ciphers [
    :blake3_aes_128_gcm,
    :blake3_aes_256_gcm,
    :blake3_chacha20_poly1305,
    :aes_128_gcm,
    :aes_256_gcm,
    :chacha20_poly1305
  ]

  def ciphers, do: @ciphers

  @cipher_key_lens %{
    blake3_aes_128_gcm: 16,
    blake3_aes_256_gcm: 32,
    blake3_chacha20_poly1305: 32,
    aes_128_gcm: 16,
    aes_256_gcm: 32,
    chacha20_poly1305: 32
  }

  @obfs_plugins [:none, :simple_obfs]

  def obfs_plugins, do: @obfs_plugins

  @ss_plugin_modes [:http, :tls]

  def ss_plugin_modes, do: @ss_plugin_modes

  defp key_length(cipher_name) do
    case Map.get(@cipher_key_lens, cipher_name) do
      %{key_len: len} -> {:ok, len}
      nil -> {:error, :unknown_cipher}
    end
  end

  defp generate_key(cipher_name) do
    with {:ok, len} <- key_length(cipher_name) do
      key = :crypto.strong_rand_bytes(len) |> Base.encode64()
      {:ok, key}
    end
  end

  @clash_server_template """
  - name: "ss-in"
    type: shadowsocks
    server: 0.0.0.0
    port: <%= endpoint.port %>
    cipher: <%= endpoint.config.ss_cipher %>
    password: '<%= endpoint.config.password %>'
    <% if endpoint.config.ss_plugin == :simple_obfs do %>
    simple-obfs:
      enable: true
      mode: <%= config.obfs_mode %>
    <% end %>
  """

  @clash_client_template """
  - name: <%= endpoint.name %>
    type: ss
    server: <%= endpoint.host %>
    port: <%= endpoint.port %>
    cipher: <%= endpoint.config.ss_cipher %>
    password: '<%= endpoint.config.password %>'
    <% if endpoint.config.ss_plugin == :simple_obfs do %>
    plugin: obfs
    plugin-opts:
      mode: <%= endpoint.config.obfs_mode %>
      host: <%= endpoint.config.obfs_host %>
    <% end %>
    udp: <%= endpoint.config.enable_udp %>
    tfo: false
  """

  def get_template(role) do
    case role do
      :client -> @clash_client_template
      :server -> @clash_server_template
    end
  end

  def build_client_uri(endpoint) do
    userinfo = Base.encode64("#{endpoint.config.ss_cipher}:#{endpoint.config.password}")

    query = build_query_params(endpoint.config) |> URI.encode_query()
    query_str = if query != "", do: "?#{query}", else: ""

    "ss://#{userinfo}@#{endpoint.host}:#{endpoint.port}#{query_str}##{URI.encode_www_form(endpoint.name)}"
  end

  defp build_query_params(%{ss_plugin: :simple_obfs} = config) do
    %{
      "plugin" =>
        "obfs-local;obfs=#{config.ss_plugin_mode};obfs-host=#{config.obfs_host};obfs-uri=#{config.obfs_uri}"
    }
  end

  defp build_query_params(_config), do: %{}
end
