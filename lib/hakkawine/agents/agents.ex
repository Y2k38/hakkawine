defmodule Hakkawine.Agents do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Agents.Agent
  alias Hakkawine.Agents.OBFSDomain

  def get_random_obfs_domain() do
    OBFSDomain
    |> order_by(fragment("random()"))
    |> limit(1)
    |> Repo.one()
  end

  def get_agent_by_client_id(client_id) do
    Agent
    |> where(:client_id, ^client_id)
    |> Repo.one()
  end
end
