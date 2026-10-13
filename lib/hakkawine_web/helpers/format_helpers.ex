defmodule HakkawineWeb.FormatHelpers do
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

  def format_traffic(bytes, precision \\ 2) when is_integer(bytes) and bytes > 0 do
    gb = bytes / (1024 * 1024 * 1024)

    if gb >= 1024 do
      tb = gb / 1024
      "#{:erlang.float_to_binary(tb, decimals: precision)} TB"
    else
      "#{:erlang.float_to_binary(gb, decimals: precision)} GB"
    end
  end

  def format_traffic(_, _precision), do: "0 GB"

  def format_speed(nil), do: "Unlimited"
  def format_speed(0), do: "Unlimited"

  def format_speed(mbps) when is_integer(mbps) do
    "#{mbps} Mbps"
  end

  def remaining_days(nil), do: nil

  def remaining_days(%DateTime{} = target_at) do
    Date.diff(DateTime.to_date(target_at), Date.utc_today())
  end

  def remaining_days_count(%DateTime{} = expired_at) do
    case remaining_days(expired_at) do
      d when d >= 0 -> d
      _ -> 0
    end
  end

  def remaining_days_text(%DateTime{} = expired_at) do
    case remaining_days(expired_at) do
      d when d > 1 -> "#{d} days remaining"
      1 -> "1 day remaining"
      _ -> nil
    end
  end

  def in_days_text(%DateTime{} = target_at) do
    case remaining_days(target_at) do
      d when d > 1 -> "In #{d} days"
      1 -> "In 1 day"
      0 -> "Today"
      _ -> "Past"
    end
  end
end
