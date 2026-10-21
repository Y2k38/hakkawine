defmodule HakkawineWeb.UserAccountLive.Components.TopupComponent do
  use HakkawineWeb, :live_component

  def update(assigns, socket) do
    topup_rules = assigns.topup_rules

    lowest_amount =
      case List.first(topup_rules) do
        %{min_amount: min_val} -> min_val
        _ -> Decimal.new(0)
      end

    custom_amount = socket.assigns[:custom_amount] || lowest_amount
    topup_details = calculate_topup_details(lowest_amount, topup_rules)

    socket =
      socket
      |> assign(assigns)
      |> assign(:lowest_amount, lowest_amount)
      |> assign(:custom_amount, custom_amount)
      |> assign(:bonus_amount, topup_details.bonus_amount)
      |> assign(:total_arrived, topup_details.total_arrived)

    {:ok, socket}
  end

  defp calculate_topup_details(amount, rules) do
    matched_rule =
      Enum.find(rules, fn rule ->
        in_min? = Decimal.compare(amount, rule.min_amount) in [:gt, :eq]
        in_max? = is_nil(rule.max_amount) || Decimal.compare(amount, rule.max_amount) == :lt
        in_min? && in_max?
      end)

    bonus_amount =
      cond do
        is_nil(matched_rule) || is_nil(matched_rule.bonus_type) ->
          Decimal.new("0.00")

        matched_rule.bonus_type == :fixed_amount ->
          matched_rule.bonus_value

        matched_rule.bonus_type == :percentage ->
          Decimal.mult(amount, matched_rule.bonus_value)
          |> Decimal.div(Decimal.new(100))
          |> Decimal.round(2)

        true ->
          Decimal.new("0.00")
      end

    total_arrived = Decimal.add(amount, bonus_amount)

    %{
      amount: amount,
      bonus_amount: bonus_amount,
      total_arrived: total_arrived,
      matched_rule: matched_rule
    }
  end

  def handle_event("select_preset_amount", %{"amount" => amount}, socket) do
    amount_dec = Decimal.new(amount)
    topup_details = calculate_topup_details(amount_dec, socket.assigns.topup_rules)

    socket =
      socket
      |> assign(:custom_amount, topup_details.amount)
      |> assign(:bonus_amount, topup_details.bonus_amount)
      |> assign(:total_arrived, topup_details.total_arrived)

    {:noreply, socket}
  end

  def handle_event("update_custom_amount", %{"value" => val}, socket) do
    amount =
      case Decimal.parse(val) do
        {dec, _} -> dec
        :error -> Decimal.new(0)
      end

    topup_details = calculate_topup_details(amount, socket.assigns.topup_rules)

    socket =
      socket
      |> assign(:custom_amount, topup_details.amount)
      |> assign(:bonus_amount, topup_details.bonus_amount)
      |> assign(:total_arrived, topup_details.total_arrived)

    {:noreply, socket}
  end
end
