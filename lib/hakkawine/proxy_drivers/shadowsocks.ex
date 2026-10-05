defmodule Hakkawine.ProxyDrivers.Shadowsocks do
  @cipher_key_lens %{
    aes_128_gcm: 16,
    aes_256_gcm: 32,
    chacha20_poly1305: 32,
    blake3_aes_128_gcm: 16,
    blake3_aes_256_gcm: 32,
    blake3_chacha20_poly1305: 32
  }

  def ss_ciphers do
    [
      aes_128_gcm: "aes-128-gcm",
      aes_256_gcm: "aes-256-gcm",
      chacha20_poly1305: "chacha20-poly1305",
      blake3_aes_128_gcm: "blake3-aes-128-gcm",
      blake3_aes_256_gcm: "blake3-aes-256-gcm",
      blake3_chacha20_poly1305: "blake3-chacha20-poly1305"
    ]
  end

  def ss_plugins do
    [
      none: "none",
      simple_obfs: "simple-obfs"
    ]
  end

  def ss_plugin_modes, do: [:http, :tls]

  def generate_key(cipher_name) do
    case Map.fetch(@cipher_key_lens, cipher_name) do
      {:ok, len} -> {:ok, :crypto.strong_rand_bytes(len) |> Base.encode64()}
      :error -> {:error, :unknown_cipher}
    end
  end

  def to_clash_map(:client, config) do
    base = %{
      "name" => config.name,
      "type" => "ss",
      "server" => config.host,
      "port" => config.port,
      "cipher" => to_string(config.ss_cipher),
      "password" => config.password,
      "udp" => Map.get(config, :enable_udp, true),
      "tfo" => false
    }

    if config.ss_plugin == :simple_obfs do
      Map.merge(base, %{
        "plugin" => "obfs",
        "plugin-opts" => %{
          "mode" => to_string(config.ss_plugin_mode),
          "host" => config.obfs_host
        }
      })
    else
      base
    end
  end

  def to_clash_map(:server, config) do
    base = %{
      "name" => "ss-in",
      "type" => "shadowsocks",
      "server" => "0.0.0.0",
      "port" => config.port,
      "cipher" => to_string(config.ss_cipher),
      "password" => config.password
    }

    if config.ss_plugin == :simple_obfs do
      Map.put(base, "simple-obfs", %{
        "enable" => true,
        "mode" => to_string(config.ss_plugin_mode)
      })
    else
      base
    end
  end

  def to_uri(config) do
    userinfo = Base.encode64("#{config.ss_cipher}:#{config.password}")
    query = build_query_params(config) |> URI.encode_query()
    query_str = if query != "", do: "?#{query}", else: ""

    "ss://#{userinfo}@#{config.host}:#{config.port}#{query_str}##{URI.encode_www_form(config.name)}"
  end

  defp build_query_params(%{ss_plugin: :simple_obfs} = config) do
    %{
      "plugin" =>
        "obfs-local;obfs=#{config.ss_plugin_mode};obfs-host=#{config.obfs_host};obfs-uri=#{config.obfs_uri}"
    }
  end

  defp build_query_params(_config), do: %{}
end
