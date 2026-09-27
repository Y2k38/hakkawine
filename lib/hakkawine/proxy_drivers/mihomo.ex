defmodule Hakkawine.ProxyDrivers.Mihomo do
  alias Hakkawine.ProxyDrivers.Endpoint
  alias Hakkawine.ProxyDrivers.Config
  alias Hakkawine.ProxyDrivers.Shadowsocks

  defp to_yaml_block(map) do
    content = Ymlr.document!(map)

    content
    |> String.replace(~r/^---\n/, "")
    |> String.split("\n")
    |> Enum.reject(&(&1 == ""))
    |> case do
      [first | rest] ->
        "- " <> first <> "\n" <> Enum.join(rest, "\n")

      _ ->
        "- "
    end
  end

  def format(endpoint, opts) do
    case {endpoint.role, endpoint.config.protocol} do
      {:client, :ss} ->
        {:ok, EEx.eval_string(Shadowsocks.get_template(:client), endpoint: endpoint)}

      _ ->
        {:error, :unsupported_role_or_protocol}
    end
  end
end
