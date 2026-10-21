defmodule Hakkawine.Marketing.CheckinRule do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "checkin_rules" do
    field :min_bytes, :integer
    field :max_bytes, :integer
    field :weight, :integer

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(rule, attrs) do
    rule
    |> cast(attrs, [:min_bytes, :max_bytes, :weight])
    |> validate_required([:min_bytes, :max_bytes, :weight])
    |> validate_number(:weight, greater_than: 0)
    |> validate_number(:min_bytes, greater_than_or_equal_to: 0)
    |> validate_max_greater_than_min()
  end

  defp validate_max_greater_than_min(changeset) do
    min_bytes = get_field(changeset, :min_bytes)
    max_bytes = get_field(changeset, :max_bytes)

    if min_bytes && max_bytes && max_bytes <= min_bytes do
      add_error(changeset, :max_bytes, "must be greater than min_bytes")
    else
      changeset
    end
  end
end
