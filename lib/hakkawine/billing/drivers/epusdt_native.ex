defmodule Hakkawine.Billing.Drivers.EpusdtNative do
  @behaviour Hakkawine.Billing.Driver

  @impl true
  def pay(config, payment_record) do
    base_url = String.trim_trailing(config["url"], "/")
    endpoint = "#{base_url}/api/v1/order/create-transaction"
    api_token = config["token"]

    amount =
      payment_record.amount
      |> Decimal.round(2, :half_up)
      |> Decimal.to_float()

    params = %{
      "order_id" => payment_record.trade_no,
      "amount" => amount,
      "redirect_url" => config["return_url"],
      "notify_url" => config["notify_url"]
    }

    signature = calc_signature(params, api_token)
    body = Map.put(params, "signature", signature)

    case Req.post(endpoint, json: body) do
      {:ok, %{status: 200, body: %{"code" => 200, "data" => %{"payment_url" => payment_url}}}} ->
        {:ok, payment_url}

      {:ok, %{body: %{"msg" => msg}}} ->
        {:error, msg}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def notify(config, params) do
    api_token = config["token"]
    received_sign = Map.get(params, "signature", "")

    payload_without_sign = Map.drop(params, ["signature", "_raw_body", "_sig_header"])
    expected_sign = calc_signature(payload_without_sign, api_token)

    if Plug.Crypto.secure_compare(received_sign, expected_sign) do
      status = Map.get(params, "status")

      if status == 2 do
        {:ok,
         %{
           trade_no: Map.get(params, "order_id"),
           gateway_trade_no: Map.get(params, "trade_id")
         }}
      else
        {:error, :payment_not_successful}
      end
    else
      {:error, :invalid_signature}
    end
  end

  defp calc_signature(params, api_token) do
    query_string =
      params

    :Enum.reject(fn {_k, v} -> is_nil(v) or to_string(v) == "" end)
    |> Enum.sort_by(fn {k, _v} -> to_string(k) end)
    |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)

    full_string = "#{query_string}&key=#{api_token}"

    :crypto.hash(:md5, full_string)
    |> Base.encode16(case: :lower)
  end

  defp parse_decimal(nil), do: nil

  defp parse_decimal(val) do
    case Decimal.parse(to_string(val)) do
      {dec, _} -> dec
      :error -> nil
    end
  end
end
