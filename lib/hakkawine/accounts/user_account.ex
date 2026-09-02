defmodule Hakkawine.Accounts.UserAccount do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "user_accounts" do
    field :account_type, Ecto.Enum, values: [:customer, :staff, :system_admin], default: :customer
    field :status, Ecto.Enum, values: [:unverified, :active, :suspended, :deactivating], default: :unverified
    field :email, :string
    field :password_hash, :string
    field :email_verified_at, :utc_datetime_usec
    field :password_updated_at, :utc_datetime_usec
    field :telegram_id, :integer
    field :invited_by, :integer
    field :invite_code, :string
    field :invite_count, :integer, default: 0
    field :suspended_until, :utc_datetime_usec

    field :password, :string, virtual: true
    field :verification_code, :string, virtual: :true
    field :captcha_token, :string, virtual: true
    field :token, :string, virtual: true
    field :phone_number, :string, virtual: true # Honeypot field

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at,
      updated_at: :updated_at
    )
  end

  def admin_registration_changeset(user_account, attrs) do
    user_account
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> normalize_email()
    |> validate_email()
    |> validate_length(:password, min: 8, max: 72, message: "must be between 8 and 72 characters long")
    |> validate_password_complexity()
    |> put_password_hash()
    |> ensure_invite_code()
    |> unique_constraint(:email, name: :idx_user_accounts_active_email)
    |> unique_constraint(:invite_code, name: :idx_user_accounts_invite_code)
  end

  def registration_changeset(user_account, attrs) do
    user_account
    |> cast(attrs, [:email, :password, :verification_code, :phone_number])
    |> validate_required([:email, :password, :verification_code])
    |> validate_honeypot()
    |> normalize_email()
    |> validate_email()
    |> validate_length(:password, min: 8, max: 72, message: "must be between 8 and 72 characters long")
    |> validate_password_complexity()
    |> put_password_hash()
    |> ensure_invite_code()
    |> unique_constraint(:email, name: :idx_user_accounts_active_email)
    |> unique_constraint(:invite_code, name: :idx_user_accounts_invite_code)
  end

  def login_changeset(user_account, attrs) do
    user_account
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> normalize_email()
  end

  def forgot_password_changeset(user_account, attrs) do
    user_account
    |> cast(attrs, [:email])
    |> validate_required([:email])
    |> normalize_email()
  end

  def change_reset_password(user_account, attrs \\ %{}) do
    user_account
    |> cast(attrs, [:token, :password])
  end

  def reset_password_changeset(user_account, attrs) do
    user_account
    |> cast(attrs, [:token, :password])
    |> validate_required([:token, :password])
    |> validate_length(:password, min: 8, max: 72, message: "must be between 8 and 72 characters long")
    |> validate_password_complexity()
    |> put_password_hash()
    |> change(password_updated_at: DateTime.utc_now() |> DateTime.truncate(:second))
  end

  defp validate_honeypot(changeset) do
    case get_change(changeset, :phone_number) do
      nil -> changeset
      "" -> changeset
      _bot_input -> add_error(changeset, :phone_number, "Bot detected")
    end
  end

  defp normalize_email(changeset) do
    case get_change(changeset, :email) do
      email when is_binary(email) ->
        put_change(changeset, :email, String.downcase(email))

      _ ->
        changeset
    end
  end

  defp validate_email(changeset) do
    email_regex = ~r/^[^\s]+@[^\s]+$/

    changeset
    |> validate_format(:email, email_regex, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 254, message: "must not exceed 254 characters")
  end

  defp validate_password_complexity(changeset) do
    validate_change(changeset, :password, fn :password, password ->
      errors = []

      errors =
        if String.match?(password, ~r/[a-z]/), do: errors, else: ["must contain at least one lowercase letter" | errors]

      errors =
        if String.match?(password, ~r/[A-Z]/), do: errors, else: ["must contain at least one uppercase letter" | errors]

      errors =
        if String.match?(password, ~r/[0-9]/), do: errors, else: ["must contain at least one digit" | errors]

      errors =
        if String.match?(password, ~r/[^a-zA-Z0-9]/), do: errors, else: ["must contain at least one special character" | errors]

      Enum.map(errors, fn error_msg -> {:password, error_msg} end)
    end)
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

  defp ensure_invite_code(changeset) do
    case get_field(changeset, :invite_code) do
      code when code in [nil, ""] ->
        put_change(changeset, :invite_code, Hakkawine.Utils.CodeGenerator.generate_invite_code(8))

      _ ->
        changeset
    end
  end
end
