defmodule Hakkawine.ProxyDrivers do
  alias Hakkawine.ProxyDrivers.Endpoint
  alias Hakkawine.ProxyDrivers.Mihomo
  alias Hakkawine.ProxyDrivers.Shadowrocket

  @formatters %{
    mihomo: Mihomo,
    clash: Mihomo,
    stash: Mihomo,
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

  defp parse_ua(nil), do: :mihomo

  defp parse_ua(ua) when is_binary(ua) do
    cond do
      String.contains?(ua, "Mihomo") -> :mihomo
      String.contains?(ua, "Clash") -> :clash
      String.contains?(ua, "Stash") -> :stash
      String.contains?(ua, "Shadowrocket") -> :shadowrocket
      true -> :mihomo
    end
  end
end
