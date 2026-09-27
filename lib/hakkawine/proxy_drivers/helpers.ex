defmodule Hakkawine.ProxyDrivers.Helpers do
  def generate_hex(bytes_count) when is_integer(bytes_count) and bytes_count > 0 do
    bytes_count
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end
end
