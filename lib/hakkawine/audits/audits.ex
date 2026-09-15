defmodule Hakkawine.Audits do
  @moduledoc """
  The Audits context.
  """

  import Ecto.Query, warn: false
  alias Hakkawine.Repo

  alias Hakkawine.Audits.UserAuditLog

  @doc """
  Returns the list of user_audit_logs.

  ## Examples

      iex> list_user_audit_logs()
      [%UserAuditLog{}, ...]

  """
  def list_user_audit_logs do
    Repo.all(UserAuditLog)
  end

  @doc """
  Gets a single user_audit_log.

  Raises `Ecto.NoResultsError` if the User audit log does not exist.

  ## Examples

      iex> get_user_audit_log!(123)
      %UserAuditLog{}

      iex> get_user_audit_log!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_audit_log!(id), do: Repo.get!(UserAuditLog, id)

  @doc """
  Creates a user_audit_log.

  ## Examples

      iex> create_user_audit_log(%{field: value})
      {:ok, %UserAuditLog{}}

      iex> create_user_audit_log(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_audit_log(attrs) do
    %UserAuditLog{}
    |> UserAuditLog.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_audit_log.

  ## Examples

      iex> update_user_audit_log(user_audit_log, %{field: new_value})
      {:ok, %UserAuditLog{}}

      iex> update_user_audit_log(user_audit_log, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_audit_log(%UserAuditLog{} = user_audit_log, attrs) do
    user_audit_log
    |> UserAuditLog.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_audit_log.

  ## Examples

      iex> delete_user_audit_log(user_audit_log)
      {:ok, %UserAuditLog{}}

      iex> delete_user_audit_log(user_audit_log)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_audit_log(%UserAuditLog{} = user_audit_log) do
    Repo.delete(user_audit_log)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_audit_log changes.

  ## Examples

      iex> change_user_audit_log(user_audit_log)
      %Ecto.Changeset{data: %UserAuditLog{}}

  """
  def change_user_audit_log(%UserAuditLog{} = user_audit_log, attrs \\ %{}) do
    UserAuditLog.changeset(user_audit_log, attrs)
  end
end
