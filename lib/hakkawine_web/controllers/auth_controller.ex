defmodule HakkawineWeb.AuthController do
  use HakkawineWeb, :controller

  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount
  alias HakkawineWeb.Plugs.RedisRateLimiter

  plug RedisRateLimiter,
    [action_name: "ip_send_code_min", time_window: 60, max_attempts: 5]
    when action in [:send_code]
  plug RedisRateLimiter,
    [action_name: "ip_send_code_daily", time_window: 86_400, max_attempts: 50]
    when action in [:send_code]

  plug RedisRateLimiter,
    [action_name: "ip_register_min", time_window: 60, max_attempts: 5]
    when action in [:register]
  plug RedisRateLimiter,
    [action_name: "ip_register_daily", time_window: 86_400, max_attempts: 30]
    when action in [:register]

  plug RedisRateLimiter,
    [action_name: "ip_log_in_min", time_window: 300, max_attempts: 20]
    when action in [:log_in]
  plug RedisRateLimiter,
    [action_name: "ip_log_in_daily", time_window: 86_400, max_attempts: 200]
    when action in [:log_in]

  plug RedisRateLimiter,
    [action_name: "ip_forgot_password_min", time_window: 60, max_attempts: 3]
    when action in [:forgot_password]
  plug RedisRateLimiter,
    [action_name: "ip_forgot_password_daily", time_window: 86_400, max_attempts: 20]
    when action in [:forgot_password]

  plug RedisRateLimiter,
    [action_name: "ip_reset_password_min", time_window: 60, max_attempts: 3]
    when action in [:reset_password]
  plug RedisRateLimiter,
    [action_name: "ip_reset_password_daily", time_window: 86_400, max_attempts: 20]
    when action in [:reset_password]

  def register_page(conn, _params) do
    conn
    |> render(:register_new, changeset: Accounts.registration_changeset(%UserAccount{}))
  end

  def send_code(conn, %{"email" => email}) do
    case Accounts.send_verification_code(email) do
      res when res in [{:ok, :sent}, {:error, :user_already_exists}] ->
        conn
        |> put_status(:ok)
        |> json(%{
          message: "The verification code has been sent, please check your email."
        })

      :deny ->
        conn
        |> put_status(:too_many_requests)
        |> json(%{error: "Too many requests. Please try again later."})

      {:error, :mail_delivery_failed} ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to send email. Please try again later."})

      _other ->
        conn
        |> put_status(:internal_server_error)
        |> json(%{error: "Failed to process request."})
    end
  end

  def register(conn, %{"user_account" => user_account_params}) do
    case Accounts.create_customer(user_account_params) do
      {:ok, _user_account} ->
        conn
        |> put_status(:created)
        |> render(:register_success)

      :deny ->
        changeset =
          %UserAccount{}
          |> Accounts.registration_changeset(user_account_params)
          |> Map.put(:action, :insert)

        conn
        |> put_status(:too_many_requests)
        |> put_flash(:error, "Too many requests. Please try again later.")
        |> render(:register_new, changeset: changeset)

      {:error, :invalid_code} ->
        changeset =
          %UserAccount{}
          |> Accounts.registration_changeset(user_account_params)
          |> Ecto.Changeset.add_error(:verification_code, "is invalid or has expired")
          |> Map.put(:action, :insert)

        conn
        |> put_status(:bad_request)
        |> render(:register_new, changeset: changeset)

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:register_new, changeset: changeset)

      _other ->
        changeset =
          %UserAccount{}
          |> Accounts.registration_changeset(user_account_params)
          |> Map.put(:action, :insert)

        conn
        |> put_status(:internal_server_error)
        |> put_flash(:error, "Failed to create customer due to a system error.")
        |> render(:register_new, changeset: changeset)
    end
  end

  def log_in_page(conn, _params) do
    conn
    |> render(:log_in, changeset: Accounts.login_changeset(%UserAccount{}))
  end

  def log_in(conn, %{"user_account" => user_account_params}) do
    case Accounts.login(user_account_params) do
      {:ok, user} ->
        ts = if user.password_updated_at, do: DateTime.to_unix(user.password_updated_at), else: 0

        conn
        |> put_flash(:info, "Welcome back!")
        |> configure_session(renew: true)
        |> put_session(:user_id, user.id)
        |> put_session(:password_updated_at, ts)
        |> redirect(to: ~p"/")

      {:error, :invalid_credentials} ->
        changeset = %UserAccount{}
          |> Accounts.login_changeset(user_account_params)
          |> Ecto.Changeset.add_error(:email, "Invalid email or password")
          |> Map.put(:action, :insert)

        changeset = update_in(changeset.params, &Map.delete(&1, "password"))

        conn
        |> put_status(:unauthorized)
        |> render(:log_in, changeset: changeset)
    end
  end

  def log_out(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> configure_session(drop: true)
    |> redirect(to: ~p"/")
  end

  def forgot_password_page(conn, _params) do
    changeset = Accounts.forgot_password_changeset(%UserAccount{})
    conn
    |> render(:forgot_password, changeset: changeset)
  end

  def send_reset_link(conn, %{"user_account" => user_account_params}) do
    case Accounts.send_reset_link(user_account_params) do
      res when res in [{:ok, :sent}, {:error, :user_not_exists}] ->
        conn
        |> put_flash(:info, "If this email address is registered, a reset email has been sent; please check your inbox.")
        |> redirect(to: ~p"/auth/forgot_password")

      :deny ->
        conn
        |> put_flash(:error, "Too many requests. Please try again later.")
        |> redirect(to: ~p"/auth/forgot_password")

      {:error, :mail_delivery_failed} ->
        conn
        |> put_flash(:error, "Failed to send email. Please try again later.")
        |> redirect(to: ~p"/auth/forgot_password")

      _other ->
        conn
        |> put_flash(:error, "Failed to process request.")
        |> redirect(to: ~p"/auth/forgot_password")
    end
  end

  def reset_password_page(conn, %{"token" => token}) do
    case Accounts.verify_reset_token(token) do
      {:ok, _email} ->
        changeset = Accounts.change_reset_password(%UserAccount{}, %{"token" => token})
        conn
        |> render(:reset_password, changeset: changeset, token: token)

      {:error, _reason} ->
        conn
        |> put_flash(:error, "The password reset link has expired or does not exist; please request a new one.")
        |> redirect(to: ~p"/auth/forgot_password")
    end
  end

  def reset_password(conn, %{"user_account" => user_account_params}) do
    case Accounts.reset_password(user_account_params) do
      {:ok, _user_account} ->
        conn
        |> put_flash(:info, "Password reset successful. Please log in again.")
        |> redirect(to: ~p"/auth/log_in")

      {:error, :user_not_exists} ->
        conn
        |> put_flash(:error, "User account not found.")
        |> redirect(to: ~p"/auth/forgot_password")

      {:error, :invalid_or_expired_token} ->
        conn
        |> put_flash(:error, "The reset link is invalid or expired; please request a new one.")
        |> redirect(to: ~p"/auth/forgot_password")

      {:error, %Ecto.Changeset{}} ->
        conn
        |> put_flash(:error, "Please enter a valid password.")
        |> redirect(to: ~p"/auth/forgot_password")

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Failed to process request.")
        |> redirect(to: ~p"/auth/forgot_password")
    end
  end
end
