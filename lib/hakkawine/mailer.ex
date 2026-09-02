defmodule Hakkawine.Mailer do
  use Swoosh.Mailer, otp_app: :hakkawine

  alias Hakkawine.Emails.UserEmailVerificationCode
  alias Hakkawine.Emails.UserEmailResetPassword

  def send_verification_email(email, code) do
    email
    |> UserEmailVerificationCode.call(code)
    |> deliver()
  end

  def send_reset_password_email(email, token) do
    email
    |> UserEmailResetPassword.call(token)
    |> deliver()
  end
end
