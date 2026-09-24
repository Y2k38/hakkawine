defmodule Hakkawine.Billing.SequenceNo do
  def generate do
    now = DateTime.utc_now()
    time_str = Calendar.strftime(now, "%Y%m%d%H%M%S")
    ms = div(elem(now.microsecond, 0), 1000) |> Integer.to_string() |> String.pad_leading(3, "0")

    raw_num = :crypto.strong_rand_bytes(2) |> :binary.decode_unsigned()
    rand = rem(raw_num, 9000) + 1000

    "#{time_str}#{ms}#{rand}"
  end
end
