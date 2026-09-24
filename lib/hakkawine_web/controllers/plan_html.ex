defmodule HakkawineWeb.PlanHTML do
  use HakkawineWeb, :html

  embed_templates "plan_html/*"

  def get_default_price(prices) when is_list(prices) do
    Enum.find(prices, fn price ->
      price.is_default == true
    end)
  end

  def get_default_price(_, _), do: nil

  def get_reset_price(prices) when is_list(prices) do
    Enum.find(prices, &(&1.type == :reset))
  end
  def get_reset_price(_), do: nil

  def format_speed(nil), do: "Unlimited"
  def format_speed(0), do: "Unlimited"
  def format_speed(mbps), do: "#{mbps} Mbps"
end
