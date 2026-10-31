defmodule HakkawineWeb.OrderController do
  use HakkawineWeb, :controller

  alias Hakkawine.Billing

  def create(conn, params) do
    fallback_url = Map.get(params, "fallback_url", ~p"/")
    safe_url = if String.starts_with?(fallback_url, "/"), do: fallback_url, else: ~p"/"

    user_id = conn.assigns.user_id

    case Billing.create_order(user_id, params) do
      {:ok, _order} ->
        conn
        |> put_flash(:info, "Order created successfully!")
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        error_msg =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
              opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
            end)
          end)
          |> Enum.map(fn {field, errs} -> "#{field} #{Enum.join(errs, ", ")}" end)
          |> Enum.join("; ")

        conn
        |> put_flash(:error, error_msg)
        |> redirect(to: safe_url)

      {:error, reason} ->
        conn
        |> put_flash(:error, to_string(reason))
        |> redirect(to: safe_url)
    end
  end

  def status(_conn, _params) do
  end

  def success(_conn, _params) do
  end

  def cancel(_conn, _params) do
  end
end
