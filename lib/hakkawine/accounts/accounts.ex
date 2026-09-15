defmodule Hakkawine.Accounts do
  import Ecto.Query
  import Hakkawine.Repo.Query

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
  defdelegate login(attrs \\ %{}), to: Login

  # forgot password
  defdelegate forgot_password_changeset(user_account, attrs \\ %{}), to: UserAccount
  defdelegate send_reset_link(attrs), to: ResetPassword
  # reset password
  defdelegate change_reset_password(user_account, attrs \\ %{}), to: UserAccount
  defdelegate reset_password_changeset(user_account, attrs \\ %{}), to: UserAccount
  defdelegate verify_reset_token(token), to: ResetPassword
  defdelegate reset_password(attrs \\ %{}), to: ResetPassword

  def get_user(user_id, opts \\ []) do
    UserAccount
    |> where(id: ^user_id)
    |> apply_opts(opts)
    |> Repo.one()
  end

  def get_user_by_email(email, opts \\ []) do
    UserAccount
    |> where(email: ^email)
    |> apply_opts(opts)
    |> Repo.one()
  end
end
