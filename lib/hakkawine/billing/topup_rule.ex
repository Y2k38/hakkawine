defmodule Hakkawine.Billing.TopupRule do
  use Ecto.Schema

  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "topup_rules" do
    field :min_amount, :decimal
    field :max_amount, :decimal
    field :bonus_type, Ecto.Enum, values: [:fixed_amount, :percentage]
    field :bonus_value, :decimal

    timestamps(type: :utc_datetime_usec)
  end

  def changeset(rule, attrs) do
    rule
    |> cast(attrs, [:min_amount, :max_amount, :bonus_type, :bonus_value])
    |> validate_required([:min_amount])
    |> validate_number(:min_amount, greater_than: 0)
    |> validate_max_greater_than_min()
    |> validate_bonus()
  end

  defp validate_max_greater_than_min(changeset) do
    min_amount = get_field(changeset, :min_amount)
    max_amount = get_field(changeset, :max_amount)

    cond do
      is_nil(max_amount) ->
        changeset

      Decimal.compare(max_amount, Decimal.new(0)) != :gt ->
        add_error(changeset, :max_amount, "must be greater than 0")

      Decimal.compare(max_amount, min_amount) != :gt ->
        add_error(changeset, :max_amount, "must be greater than min_amount")

      true ->
        changeset
    end
  end

  defp validate_bonus(changeset) do
    bonus_type = get_field(changeset, :bonus_type)
    bonus_value = get_field(changeset, :bonus_value)

    cond do
      is_nil(bonus_type) && is_nil(bonus_value) ->
        changeset

      is_nil(bonus_type) || is_nil(bonus_value) ->
        changeset
        |> add_error(:bonus_type, "must be present together with bonus_value")
        |> add_error(:bonus_value, "must be present together with bonus_type")

      Decimal.compare(bonus_value, Decimal.new(0)) != :gt ->
        add_error(changeset, :bonus_value, "must be greater than 0")

      true ->
        changeset
    end
  end
end
