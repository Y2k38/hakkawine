defmodule HakkawineWeb.Helpers.NumberHelper do
  alias Hakkawine.System

  def currency_symbol do
    System.get_setting("symbol")
  end

  def format_amount(amount, scale \\ 2)

  def format_amount(nil, _scale), do: "0.00"

  def format_amount(%Decimal{} = decimal, scale) do
    decimal
    |> Decimal.to_float()
    |> format_amount(scale)
  end

  def format_amount(amount, scale) when is_integer(amount) do
    :erlang.float_to_binary(amount * 1.0, decimals: scale)
  end

  def format_amount(amount, scale) when is_float(amount) do
    :erlang.float_to_binary(amount, decimals: scale)
  end

  def to_percentage(nil), do: "0%"

  def to_percentage(decimal_value) do
    percentage =
      decimal_value
      |> Decimal.mult(Decimal.new(100))
      |> Decimal.round(0)
      |> Decimal.to_integer()

    "#{percentage}%"
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
