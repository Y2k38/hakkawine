defmodule Hakkawine.System do
  def get_setting(key, default \\ nil) when is_binary(key) do
    case :ets.lookup(:app_settings, key) do
      [{^key, value}] -> value
      [] -> default
    end
  end
end
