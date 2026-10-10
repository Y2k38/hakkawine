defmodule Hakkawine.Billing.Drivers.Epay do
  @behaviour Hakkawine.Billing.Driver

  @impl true
  def pay(config, payment_record) do
    amount =
      payment_record.amount
      |> Decimal.round(2, :half_up)
      |> Decimal.to_string(:normal)

    base = %{
      "money" => amount,
      "name" => payment_record.trade_no,
      "notify_url" => config["notify_url"],
      "return_url" => config["return_url"],
      "out_trade_no" => payment_record.trade_no,
      "pid" => config["pid"]
    }

    sign = build_pay_sign(base, config["key"])

    final =
      base
      |> Map.put("sign", sign)
      |> Map.put("sign_type", "MD5")

    {:ok, "#{config["url"]}/submit.php?#{URI.encode_query(final)}"}
  end

  defp build_pay_sign(params, secret_key) do
    query_string =
      params
      |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
      |> Enum.sort_by(fn {k, _v} -> k end)
      |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)

    raw_str = query_string <> secret_key

    :crypto.hash(:md5, raw_str)
    |> Base.encode16(case: :lower)
  end

  @impl true
  def notify(config, params) do
    with {:ok, expected_sign} <- Map.fetch(params, "sign"),
         calculated_sign <- build_notify_sign(params, config["key"]),
         true <- Plug.Crypto.secure_compare(String.downcase(expected_sign), calculated_sign) do
      {:ok,
       %{
         trade_no: params["out_trade_no"],
         gateway_trade_no: params["trade_no"]
       }}
    else
      _ -> {:error, :invalid_signature}
    end
  end

  defp build_notify_sign(params, secret_key) do
    params
    |> Map.drop(["sign", "sign_type"])
    |> Enum.reject(fn {_k, v} -> is_nil(v) or v == "" end)
    |> Enum.sort_by(fn {k, _v} -> k end)
    |> Enum.map_join("&", fn {k, v} -> "#{k}=#{v}" end)
    |> Kernel.<>(secret_key)
    |> then(&:crypto.hash(:md5, &1))
    |> Base.encode16(case: :lower)
  end
end
