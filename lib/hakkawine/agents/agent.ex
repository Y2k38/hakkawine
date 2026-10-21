defmodule Hakkawine.Agents.Agent do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "agents" do
    field :name, :string
    field :client_id, :string
    field :client_secret_hash, :string
    field :status, Ecto.Enum, values: [:pending, :active, :offline, :disabled]
    field :address, :string
    field :protocol, :string
    field :port_base, :integer
    field :stat_base, :integer
    field :port_capacity, :integer
    field :max_sub_count, :integer
    field :rate, :decimal
    field :weight, :integer
    field :monthly_traffic_bytes, :integer
    field :traffic_reset_day, :integer
    field :labels, :map

    timestamps(type: :utc_datetime_usec)
  end

  def generate_client_id do
    random_part =
      :crypto.strong_rand_bytes(9)
      |> Base.url_encode64(padding: false)
      |> String.replace(~r/[-_]/, "")

    "agent_" <> String.downcase(random_part)
  end

  def generate_client_secret do
    random_bytes = :crypto.strong_rand_bytes(32)

    secret_body = Base.url_encode64(random_bytes, padding: false)

    "sec_" <> secret_body
  end

  @doc false
  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end

  def parse(host) when is_binary(host) do
    charlist = String.to_charlist(host)

    case :inet.parse_address(charlist) do
      {:ok, {_, _, _, _} = ipv4} ->
        {:ok, :ipv4, ipv4}

      {:ok, {_, _, _, _, _, _, _, _} = ipv6} ->
        {:ok, :ipv6, ipv6}

      {:error, :einval} ->
        if valid_domain?(host) do
          {:ok, :domain, host}
        else
          {:error, :invalid_host}
        end
    end
  end

  defp valid_domain?(host) do
    case URI.parse("//" <> host) do
      %URI{host: nil} -> false
      %URI{host: ^host} -> String.contains?(host, ".") and not String.ends_with?(host, ".")
      _ -> false
    end
  end
end
