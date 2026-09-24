defmodule HakkawineWeb.FormatHelpers do
  alias Hakkawine.System

  def currency_symbol do
    case System.get_setting("symbol") do
      [{"symbol", value}] -> value
      _ -> "$"
    end
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
      :erlang.float_to_binary(amount, [decimals: 2])
    end
  end

  def format_amount(amount) when is_integer(amount), do: Integer.to_string(amount)

  def format_amount(amount) when is_binary(amount) do
    case Decimal.parse(amount) do
      {decimal, _} -> format_amount(decimal)
      :error -> amount
    end
  end

  def format_traffic(bytes) when is_integer(bytes) and bytes > 0 do
    gb = div(bytes, 1024 * 1024 * 1024)

    if gb >= 1024 do
      tb = div(gb, 1024)
      "#{tb} TB"
    else
      "#{gb} GB"
    end
  end

  def format_traffic(_), do: "0 GB"
end
