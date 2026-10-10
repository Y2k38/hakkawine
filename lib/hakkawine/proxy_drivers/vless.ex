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

  def to_clash_map(:client, config) do
    base = %{
      "name" => config.name,
      "type" => "vless",
      "server" => config.server,
      "port" => config.port,
      "uuid" => config.sub_uuid,
      "reality-opts" => %{
        "public-key" => config.vless_public_key,
        "short-id" => ""
      },
      "network" => config.vless_network,
      "udp" => config.enable_udp,
      "tls" => true,
      "servername" => config.obfs_host,
      "alpn" => config.alpn,
      "client-fingerprint" => config.fingerprint
    }

    if config.vless_network == :xhttp do
      Map.put(base, "xhttp-opts", %{
        "path" => config.obfs_uri,
        "host" => config.obfs_host,
        "mode" => "stream-one"
      })
    else
      base
    end
  end

  def to_clash_map(:server, config) do
    base = %{
      "name" => "vless-reality-in",
      "type" => "vless",
      "server" => "0.0.0.0",
      "port" => config.port,
      "users" => [
        %{
          "user_#{config.sub_id}" => 1,
          "uuid" => config.sub_uuid
        }
      ],
      "reality-config" => %{
        "dest" => "#{config.obfs_host}:#{config.obfs_port}",
        "private-key" => config.vless_private_key,
        "short-id" => config.vless_short_ids
      }
    }

    if config.vless_network == :xhttp do
      Map.put(base, "xhttp-config", %{
        "path" => config.obfs_uri,
        "host" => config.obfs_host,
        "mode" => "auto"
      })
    else
      base
    end
  end

  def to_uri(config) do
    userinfo =
      Base.encode64(":#{config.sub_uuid}:#{config.host}:#{config.port}")

    query = build_query_params(config) |> URI.encode_query()

    "vless://#{userinfo}?#{query}"
  end

  defp build_query_params(config) do
    %{
      "obfs" => "xhttp",
      "obfsParam" => "{\"Host\":\"#{config.obfs_host}\"}",
      "path" => config.obfs_uri,
      "mode" => "auto",
      "alpn" => config.alpn
    }
    |> merge_common_params(config)
  end

  defp merge_common_params(params, config) do
    base = %{
      "tls" => "1",
      "udp" => Config.bool_to_flag(config.enable_udp),
      "fingerprint" => config.fingerprint,
      "remarks" => config.name
    }

    base =
      if is_binary(config.vless_public_key) and config.vless_public_key != "" do
        Map.merge(base, %{
          "pbk" => config.vless_public_key,
          "sid" => random_short_id(config.vless_short_ids)
        })
      else
        base
      end

    Map.merge(params, base)
  end
end
