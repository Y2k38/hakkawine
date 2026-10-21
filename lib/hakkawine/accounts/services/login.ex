defmodule Hakkawine.Accounts.Services.Login do
  import Ecto.Query, warn: false

  alias Hakkawine.Audits
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Utils.RateLimiter
  alias Hakkawine.Sessions

  def do_login(attrs, ip, ua) do
    email = attrs["email"] || attrs[:email]
    password = attrs["password"] || attrs[:password]

    email_5m_key = "rate_limit:auth:login:email_5m:#{email}"
    email_24h_key = "rate_limit:auth:login:email_24h:#{email}"

    now = System.system_time(:millisecond)
    # session_id = Ecto.UUID.generate()
    session_id = :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)

    with :allow <- RateLimiter.check_only(email_5m_key, 5, 300_000),
         :allow <- RateLimiter.check_only(email_24h_key, 30, 86_400_000),
         {:ok, user_account} <- authenticate_user(email, password),
         :ok <- RateLimiter.delete_keys([email_5m_key, email_24h_key]),
         {:ok, audit_log} <- Audits.insert_user_login_log(user_account, ip, ua),
         :ok <- Sessions.create_session(user_account.id, session_id, audit_log.id, now) do
      {:ok, user_account, session_id}
    else
      :deny ->
        {:error, :too_many_attempts}

      {:error, :invalid_credentials} ->
        RateLimiter.hit(email_5m_key, 300_000)
        RateLimiter.hit(email_24h_key, 86_400_000)
        {:error, :invalid_credentials}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp authenticate_user(email, password) do
    case Accounts.get_user_by_email(email) do
      %UserAccount{} = user_account ->
        if Argon2.verify_pass(password, user_account.password_hash) do
          {:ok, user_account}
        else
          {:error, :invalid_credentials}
        end

      nil ->
        Argon2.no_user_verify()
        {:error, :invalid_credentials}
    end
  end
end
