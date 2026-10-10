defmodule Hakkawine.Billing.Driver do
  @type config :: map()
  @type payment_record :: %Hakkawine.Billing.PaymentRecord{}

  @callback pay(config(), payment_record()) ::
              {:ok, url :: String.t()} | {:error, term()}

  @callback notify(config(), params :: map()) ::
              {:ok, %{trade_no: String.t(), gateway_trade_no: String.t()}} | {:error, term()}
end
