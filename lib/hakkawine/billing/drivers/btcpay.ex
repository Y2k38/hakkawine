defmodule Hakkawine.Billing.Drivers.Btcpay do
  @behaviour Hakkawine.Billing.Driver

  @impl true
  def pay(config, payment_record) do
    base_url = String.trim_trailing(config["url"], "/")
    store_id = config["store_id"]
    api_key = config["api_key"]

    endpoint = "#{base_url}/api/v1/stores/#{store_id}/invoices"

    amount =
      payment_record.amount
      |> Decimal.round(2, :half_up)
      |> Decimal.to_string(:normal)

    body = %{
      "amount" => amount,
      "currency" => config["currency"],
      "metadata" => %{
        "orderId" => payment_record.trade_no
      },
      "checkout" => %{
        "redirectURL" => config["return_url"]
      }
    }

    headers = [
      {"Authorization", "token #{api_key}"},
      {"Content-Type", "application/json"}
    ]

    case Req.post(endpoint, json: body, headers: headers) do
      {:ok, %{status: 200, body: %{"checkoutLink" => checkout_url}}} ->
        {:ok, checkout_url}

      {:ok, %{body: %{"message" => msg}}} ->
        {:error, msg}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def notify(config, params) do
    secret = config["secret"]
    raw_body = Map.get(params, "_raw_body", "")
    sig_header = Map.get(params, "_sig_header", "")

    expected_sig = "sha256=" <> calc_hmac_sha256(raw_body, secret)

    if Plug.Crypto.secure_compare(sig_header, expected_sig) do
      event_type = Map.get(params, "type")
      invoice_id = Map.get(params, "invoiceId")
      trade_no = get_in(params, ["metadata", "orderId"])

      case event_type do
        "InvoiceSettled" ->
          {:ok,
           %{
             trade_no: trade_no,
             gateway_trade_no: invoice_id
           }}

        _ ->
          {:error, :ignored_event}
      end
    else
      {:error, :invalid_signature}
    end
  end

  defp calc_hmac_sha256(raw_body, secret) do
    :crypto.mac(:hmac, :sha256, secret, raw_body)
    |> Base.encode16(case: :lower)
  end
end
