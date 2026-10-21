defmodule HakkawineWeb.CheckinController do
  use HakkawineWeb, :controller

  alias Hakkawine.Marketing

  def create(conn, _params) do
    user = conn.assigns.current_user

    case Marketing.do_user_checkin(user.id) do
      {:ok, checkin} ->
        conn
        |> put_status(:created)
        |> json(checkin)

      {:error, :no_active_subscription} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: %{detail: "No active subscription found"}})

      {:error, %Ecto.Changeset{} = changeset} ->
        errors =
          Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)

        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: errors})

      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(%{errors: %{detail: to_string(reason)}})
    end
  end
end
