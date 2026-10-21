defmodule Hakkawine.Audits do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Audits.UserAuditLog
  alias Hakkawine.Utils.GeoIP
  alias Hakkawine.Utils.UserAgent

  def get_user_log(id) do
    UserAuditLog
    |> where(id: ^id)
    |> Repo.one()
  end

  def list_user_logs_by_ids([]), do: []

  def list_user_logs_by_ids(ids) do
    UserAuditLog
    |> where([log], log.id in ^ids)
    |> Repo.all()
  end

  def insert_user_login_log(user, ip, ua) do
    params = %{
      user_id: user.id,
      action_code: "user_login_success",
      ip_address: ip,
      user_agent: ua,
      metadata: %{
        ip: GeoIP.lookup(ip),
        ua: UserAgent.parse(ua)
      }
    }

    %UserAuditLog{}
    |> UserAuditLog.changeset(params)
    |> Repo.insert()
  end

  def update_user_log_metadata(user_log, metadata) do
    user_log
    |> UserAuditLog.changeset(%{metadata: metadata})
    |> Repo.update()
  end
end
