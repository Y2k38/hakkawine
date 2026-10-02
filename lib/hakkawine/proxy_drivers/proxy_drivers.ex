defmodule Hakkawine.ProxyDrivers do
  alias Hakkawine.ProxyDrivers.Endpoint
  alias Hakkawine.ProxyDrivers.Mihomo
  alias Hakkawine.ProxyDrivers.Shadowrocket

  @formatters %{
    clash: Mihomo,
    shadowrocket: Shadowrocket
  }

  def generate(endpoint, opts \\ []) do
    target = opts[:target] || parse_ua(opts[:ua])

    case Map.fetch(@formatters, target) do
      {:ok, formatter_module} ->
        formatter_module.format(endpoint, opts)

      :error ->
        {:error, "Unknown target or missing formatter for: #{inspect(target)}"}
    end
  end
end
