defmodule Hakkawine.Infra do
  import Ecto.Query
  alias Hakkawine.Repo
  alias Hakkawine.Infra.OBFSDomain

  defp get_random_obfs_domain() do
    OBFSDomain
    |> order_by(fragment("random()"))
    |> limit(1)
    |> Repo.one()
  end
end
