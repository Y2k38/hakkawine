defmodule Hakkawine.ProxyDrivers.Shadowsocks do
  @ciphers %{
    "2022-blake3-aes-128-gcm" => %{key_len: 16, is_2022: true, name: "2022-BLAKE3-AES-128-GCM"},
    "2022-blake3-aes-256-gcm" => %{key_len: 32, is_2022: true, name: "2022-BLAKE3-AES-256-GCM"},
    "2022-blake3-chacha20-poly1305" => %{key_len: 32, is_2022: true, name: "2022-BLAKE3-ChaCha20-Poly1305"},
    "aes-128-gcm" => %{key_len: 16, is_2022: false, name: "AES-128-GCM"},
    "aes-256-gcm" => %{key_len: 32, is_2022: false, name: "AES-256-GCM"},
    "chacha20-ietf-poly1305" => %{key_len: 32, is_2022: false, name: "ChaCha20-IETF-Poly1305"}
  }

  @obfs_plugins %{
    "plain" => %{type: :none},
    "http" => %{type: :simple_obfs, mode: "http"},
    "tls" => %{type: :simple_obfs, mode: "tls"},
    "v2ray-plugin" => %{type: :v2ray_plugin}
  }

  defp available_methods, do: Map.keys(@ciphers)

  defp available_obfs, do: Map.keys(@obfs_plugins)

  defp get_cipher_info(cipher_name), do: Map.get(@ciphers, cipher_name)

  defp get_obfs_info(obfs), do: Map.get(@obfs_plugins, obfs)

  defp valid_cipher?(cipher_name), do: Map.has_key?(@ciphers, cipher_name)

  defp valid_obfs?(obfs_name), do: Map.has_key?(@obfs_plugins, obfs_name)

  defp key_length(cipher_name) do
    case get_cipher_info(cipher_name) do
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
end
