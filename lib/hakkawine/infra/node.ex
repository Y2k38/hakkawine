defmodule Hakkawine.Infra.Node do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "nodes" do
    field :name, :string
    field :secret_hash, :string
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

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(node, attrs) do
    node
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
