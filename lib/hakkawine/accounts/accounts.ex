defmodule Hakkawine.Accounts do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Accounts.UserAccount
  alias Hakkawine.Accounts.Services.Registration
  alias Hakkawine.Accounts.Services.ResetPassword
  alias Hakkawine.Accounts.Services.Login

  # CMD
  defdelegate admin_registration_changeset(user_account, attrs \\ %{}), to: UserAccount

  # Registration
  defdelegate registration_changeset(user_account, attrs \\ %{}), to: UserAccount
  defdelegate send_verification_code(email), to: Registration
  defdelegate create_customer(attrs), to: Registration

  # Login
  defdelegate login_changeset(user_account, attrs \\ %{}), to: UserAccount
  defdelegate do_login(attrs, ip, ua), to: Login

  # forgot password
  defdelegate forgot_password_changeset(user_account, attrs \\ %{}), to: UserAccount
  defdelegate send_reset_link(attrs), to: ResetPassword
  # reset password
  defdelegate change_reset_password(user_account, attrs \\ %{}), to: UserAccount
  defdelegate reset_password_changeset(user_account, attrs \\ %{}), to: UserAccount
  defdelegate verify_reset_token(token), to: ResetPassword
  defdelegate reset_password(attrs \\ %{}), to: ResetPassword

  defp get_user_base(user_id) do
    UserAccount
    |> where(id: ^user_id)
  end

  def get_user(user_id) do
    get_user_base(user_id)
    |> Repo.one()
  end

  def get_locked_user(user_id) do
    get_user_base(user_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end

  defp get_user_by_email_base(email) do
    UserAccount
    |> where(email: ^email)
  end

  def get_user_by_email(email) do
    get_user_by_email_base(email)
    |> Repo.one()
  end

  def get_locked_user_by_email(email) do
    get_user_by_email_base(email)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end
end
