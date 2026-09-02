defmodule Hakkawine.Accounts.Services.Login do
  import Ecto.Query, warn: false
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Utils.RateLimiter

  def login(attrs) do
    email = attrs["email"] || attrs[:email]
    password = attrs["password"] || attrs[:password]

    email_5m_key = "rate_limit:auth:login:email_5m:#{email}"
    email_24h_key = "rate_limit:auth:login:email_24h:#{email}"

    with :allow <- RateLimiter.check_only(email_5m_key, 5, 300_000),
         :allow <- RateLimiter.check_only(email_24h_key, 30, 86_400_000) do

      case authenticate_user(email, password) do
        {:ok, user_account} ->
          RateLimiter.delete_keys([email_5m_key, email_24h_key])
          {:ok, user_account}

        {:error, :invalid_credentials} ->
          RateLimiter.hit(email_5m_key, 300_000)
          RateLimiter.hit(email_24h_key, 86_400_000)
          {:error, :invalid_credentials}
      end
    else
      :deny ->
        {:error, :too_many_attempts}
    end
  end

  defp authenticate_user(email, password) do
    case Accounts.ensure_user_exists(email) do
      {:ok, %UserAccount{} = user_account} ->
        if Argon2.verify_pass(password, user_account.password_hash) do
          {:ok, user_account}
        else
          {:error, :invalid_credentials}
        end

      {:error, :user_not_exists} ->
        Argon2.no_user_verify(password)
        {:error, :invalid_credentials}
    end
  end
end
