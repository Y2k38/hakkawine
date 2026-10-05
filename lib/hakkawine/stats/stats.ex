defmodule Hakkawine.Stats do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Stats.NodeTrafficLogsDaily

  def get_subscription_traffic(sub_id, period_start) do
    from(t in NodeTrafficLogsDaily,
      where: t.subscription_id == ^sub_id and t.bucket_day >= ^period_start,
      select: %{
        up: coalesce(sum(t.rated_upload_bytes), 0),
        down: coalesce(sum(t.rated_download_bytes), 0)
      }
    )
    |> Repo.one()
  end
end
