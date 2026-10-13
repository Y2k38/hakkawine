defmodule Hakkawine.Checkout do
  alias Hakkawine.Checkout.CheckoutForm

  defdelegate changeset(checkout_form, attrs \\ %{}), to: CheckoutForm
end
