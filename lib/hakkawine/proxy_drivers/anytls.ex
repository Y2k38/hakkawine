defmodule Hakkawine.ProxyDrivers.AnyTLS do
  alias Hakkawine.ProxyDrivers.Config

  def to_clash_map(:client, config) do
    %{
      "name" => config.name,
      "type" => "anytls",
      "server" => config.host,
      "port" => config.port,
      "password" => config.sub_uuid,
      "client-fingerprint" => config.fingerprint,
      "udp" => config.enable_udp,
      "sni" => config.obfs_host,
      "skip-cert-verify" => config.skip_cert_verify
    }
  end

  def to_clash_map(:server, config) do
    %{
      "name" => "anytls-in",
      "type" => "anytls",
      "listen" => "0.0.0.0",
      "port" => config.port,
      "users" => %{
        "user_#{config.sub_id}" => config.sub_uuid,
      },
      "certificate" => config.certificate,
      "private-key" => config.private_key,
      "udp" => config.enable_udp,
    }
  end

  def to_uri(config) do
    userinfo = config.sub_uuid
    query = build_query_params(config) |> URI.encode_query()

    "anytls://#{userinfo}@#{config.host}:#{config.port}?#{query}##{URI.encode_www_form(config.name)}"
  end

  defp build_query_params(config) do
    %{
      "peer" => config.obfs_host,
      "insecure" => Config.bool_to_flag(config.skip_cert_verify),
      "fingerprint" => config.fingerprint,
    }
  end
end
