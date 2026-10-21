defmodule HakkawineWeb.Helpers.NumberHelper do
  alias Hakkawine.System

  def currency_symbol do
    System.get_setting("symbol")
  end

  def format_amount(nil), do: "0"

  def format_amount(%Decimal{} = decimal) do
    decimal
    |> Decimal.to_float()
    |> format_amount()
  end

  def format_amount(amount) when is_float(amount) do
    if amount == Float.floor(amount) do
      trunc(amount) |> Integer.to_string()
    else
      :erlang.float_to_binary(amount, decimals: 2)
    end
  end

  def format_amount(amount) when is_integer(amount), do: Integer.to_string(amount)

  def format_amount(amount) when is_binary(amount) do
    case Decimal.parse(amount) do
      {decimal, _} -> format_amount(decimal)
      :error -> amount
    end
  end

  def format_traffic(bytes, precision \\ 2)

  def format_traffic(bytes, precision) when is_integer(bytes) and bytes > 0 do
    cond do
      # 1024^4 (TB)
      bytes >= 1_099_511_627_776 ->
        tb = bytes / 1_099_511_627_776
        "#{:erlang.float_to_binary(tb, decimals: precision)} TB"

      # 1024^3 (GB)
      bytes >= 1_073_741_824 ->
        gb = bytes / 1_073_741_824
        "#{:erlang.float_to_binary(gb, decimals: precision)} GB"

      # 1024^2 (MB)
      bytes >= 1_048_576 ->
        mb = bytes / 1_048_576
        "#{:erlang.float_to_binary(mb, decimals: precision)} MB"

      # 1024^1 (KB)
      bytes >= 1024 ->
        kb = bytes / 1024
        "#{:erlang.float_to_binary(kb, decimals: precision)} KB"

      true ->
        "#{bytes} B"
    end
  end

  def format_traffic(_bytes, _precision), do: "0 B"

  def format_speed(nil), do: "Unlimited"
  def format_speed(0), do: "Unlimited"

  def format_speed(mbps) when is_integer(mbps) do
    "#{mbps} Mbps"
  end
end
