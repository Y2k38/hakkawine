defmodule Hakkawine.Accounts.Services.ResetPassword do
  import Ecto.Query, warn: false
  alias Hakkawine.Repo
  alias Hakkawine.Mailer
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Utils.RateLimiter
  alias Hakkawine.Utils.CodeGenerator

  def send_reset_link(attrs) do
    email = attrs["email"] || attrs[:email]

    email_3m_key = "rate_limit:auth:forget_password:link:email_3m:#{email}"
    email_24h_key = "rate_limit:auth:forget_password:link:email_24h:#{email}"

    token = CodeGenerator.generate_reset_password_token(24)

    with :allow <- RateLimiter.allow?(email_3m_key, 1, 120_000),
         :allow <- RateLimiter.allow?(email_24h_key, 5, 86_400_000),
         %UserAccount{} <- Accounts.get_user_by_email(email),
         {:ok, _} <- cache_reset_password_token(email, token),
         {:ok, _} <- deliver_reset_password_email(email, token) do
      {:ok, :sent}
    else
      nil -> {:error, :user_not_exists}
      error -> error
    end
  end

  defp cache_reset_password_token(email, token) do
    ttl_seconds = 1800
    key = "auth:reset_password:token:#{token}"

    case Redix.command(:redix, ["SET", key, email, "EX", ttl_seconds]) do
      {:ok, "OK"} -> {:ok, token}
      {:error, reason} -> {:error, {:cache_failed, reason}}
    end
  end

  defp deliver_reset_password_email(email, token) do
    case Mailer.send_reset_password_email(email, token) do
      {:ok, _} = res -> res
      {:error, _} -> {:error, :mail_delivery_failed}
    end
  end

  def verify_reset_token(token) do
    key = "auth:reset_password:token:#{token}"

    case Redix.command(:redix, ["GET", key]) do
      {:ok, nil} ->
        {:error, :invalid_or_expired_token}

      {:ok, email} when is_binary(email) ->
        {:ok, email}

      {:error, reason} ->
        {:error, {:redis_error, reason}}
    end
  end

  def reset_password(attrs) do
    token = attrs["token"] || attrs[:token]

    token_15m_key = "rate_limit:auth:forget_password:link:token_15m:#{token}"
    token_24h_key = "rate_limit:auth:forget_password:link:token_24h:#{token}"

    with :allow <- RateLimiter.allow?(token_15m_key, 3, 900_000),
         :allow <- RateLimiter.allow?(token_24h_key, 10, 86_400_000),
         {:ok, email} <- verify_and_consume_reset_token(token),
         %UserAccount{} = user_account <- Accounts.get_user_by_email(email) do
      user_account
      |> UserAccount.reset_password_changeset(attrs)
      |> Repo.update()
    else
      nil -> {:error, :user_not_exists}
      error -> error
    end
  end

  defp verify_and_consume_reset_token(token) do
    key = "auth:reset_password:token:#{token}"

    case Redix.command(:redix, ["GETDEL", key]) do
      {:ok, nil} ->
        {:error, :invalid_or_expired_token}

      {:ok, email} when is_binary(email) ->
        {:ok, email}

      {:error, reason} ->
        {:error, {:redis_error, reason}}
    end
  end
end
