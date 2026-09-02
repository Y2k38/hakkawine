defmodule Hakkawine.Accounts.Services.Registration do
  import Ecto.Query, warn: false
  alias Hakkawine.Repo
  alias Hakkawine.Mailer
  alias Hakkawine.Accounts
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Utils.RateLimiter
  alias Hakkawine.Utils.CodeGenerator

  def send_verification_code(email) do
    email_60s_key = "rate_limit:auth:register:code:email_60s:#{email}"
    email_24h_key = "rate_limit:auth:register:code:email_24h:#{email}"

    code = CodeGenerator.generate_verification_code(6)

    with :allow <- RateLimiter.allow?(email_60s_key, 1, 60_000),
         :allow <- RateLimiter.allow?(email_24h_key, 5, 86_400_000),
         :ok <- Accounts.ensure_user_not_exists(email),
         {:ok, _} <- cache_verification_code(email, code),
         {:ok, _} <- deliver_verification_email(email, code) do
      {:ok, :sent}
    end
  end

  def create_customer(attrs) do
    email = attrs["email"] || attrs[:email]
    code = attrs["verification_code"] || attrs[:verification_code]

    email_60s_key = "rate_limit:auth:register:new:email_60s:#{email}"
    email_24h_key = "rate_limit:auth:register:new:email_24h:#{email}"

    with :allow <- RateLimiter.allow?(email_60s_key, 2, 60_000),
         :allow <- RateLimiter.allow?(email_24h_key, 10, 86_400_000),
         {:ok} <- verify_otp_code(email, code),
         {:ok, user} <- do_create_customer(attrs, 3) do
      {:ok, user}
    end
  end

  defp cache_verification_code(email, code) do
    ttl_seconds = 300
    key = "auth:register:otp:#{email}"

    case Redix.command(:redix, ["SET", key, code, "EX", ttl_seconds]) do
      {:ok, "OK"} -> {:ok, code}
      {:error, reason} -> {:error, {:cache_failed, reason}}
    end
  end

  defp deliver_verification_email(email, code) do
    case Mailer.send_verification_email(email, code) do
      {:ok, _} = res -> res
      {:error, _} -> {:error, :mail_delivery_failed}
    end
  end

  defp verify_otp_code(email, code) do
    otp_key = "auth:register:otp:#{email}"

    case Redix.command(:redix, ["GET", otp_key]) do
      {:ok, ^code} ->
        Redix.command(:redix, ["DEL", otp_key])
        {:ok}

      _other ->
        {:error, :invalid_code}
    end
  end

  defp do_create_customer(attrs, attempts_left) when attempts_left > 0 do
    result =
      %UserAccount{}
      |> UserAccount.registration_changeset(attrs)
      |> Ecto.Changeset.put_change(:account_type, :customer)
      |> Ecto.Changeset.put_change(:status, :active)
      |> Ecto.Changeset.put_change(:email_verified_at, DateTime.utc_now())
      |> Repo.insert()

    case result do
      {:ok, user} ->
        {:ok, user}

      {:error, %Ecto.Changeset{errors: [invite_code: {_, [constraint: :unique, constraint_name: _]}]}} ->
        do_create_customer(attrs, attempts_left - 1)

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
