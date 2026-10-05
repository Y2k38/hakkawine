defmodule Hakkawine.ProxyDrivers.Hysteria2 do
  alias Hakkawine.ProxyDrivers.Config

  def to_clash_map(:client, config) do
    base = %{
      "name" => config.name,
      "type" => "hysteria2",
      "server" => config.host,
      "port" => config.port,
      "password" => config.password,
      "sni" => config.obfs_host,
      "skip-cert-verify" => config.skip_cert_verify,
      "udp" => config.enable_udp,
      "alpn" => config.alpn,
      "fingerprint" => config.fingerprint
    }

    if config.hy2_obfs == :salamander do
      Map.merge(base, %{
        "obfs" => "salamander",
        "obfs-password" => config.obfs_pass
      })
    else
      base
    end
  end

  def to_clash_map(:server, config) do
    base = %{
      "name" => "hysteria2-in",
      "type" => "hysteria2",
      "server" => "0.0.0.0",
      "port" => config.port,
      "users" => %{
        "user_#{config.sub_uuid}" => config.password,
      },
      "certificate" => config.certificate,
      "private-key" => config.private_key
    }

    if config.hy2_obfs == :salamander do
      Map.merge(base, %{
        "obfs" => "salamander",
        "obfs-password" => config.obfs_pass
      })
    else
      base
    end
  end

  def to_uri(config) do
    userinfo = Base.encode64("user_#{config.sub_id}:#{config.password}")
    query = build_query_params(config) |> URI.encode_query()

    "hysteria2://#{userinfo}@#{config.host}:#{config.port}/?#{query}##{URI.encode_www_form(config.name)}"
  end

  defp build_query_params(config) do
    base = %{
      "sni" => config.obfs_host,
      "insecure" => Config.bool_to_flag(config.skip_cert_verify),
      "alpn" => config.alpn,
      "udp" => Config.bool_to_flag(config.enable_udp)
    }

    if config.hy2_obfs == :salamander do
      Map.merge(base, %{
        "obfs" => "salamander",
        "obfs-password" => config.obfs_pass
      })
    else
      base
    end
  end
end
