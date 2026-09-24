defmodule Hakkawine.Marketing.Coupon do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "coupon" do
    field :code, :string
    field :name, :string
    field :type, Ecto.Enum, values: [:fixed_amount, :percentage]
    field :value, :decimal
    field :limit_use_count, :integer
    field :used_count, :integer
    field :limit_user_use_count, :integer
    field :start_at, :utc_datetime_usec
    field :end_at, :utc_datetime_usec
    field :is_active, :boolean

    timestamps(
      type: :utc_datetime_usec,
      inserted_at: :created_at
    )
  end

  @doc false
  def changeset(coupon, attrs) do
    coupon
    |> cast(attrs, [:code, :name, :type, :value, :limit_use_count, :used_count, :limit_user_use_count, :start_at, :end_at, :is_active])
    |> validate_required([:code, :name, :type, :value, :limit_use_count, :used_count, :limit_user_use_count, :is_active])
  end

  def to_snapshot(%__MODULE__{} = coupon) do
    %{
      id: coupon.id,
      code: coupon.code,
      name: coupon.name,
      type: coupon.type,
      value: Decimal.to_string(coupon.value),
      limit_use_count: coupon.limit_use_count,
      used_count: coupon.used_count,
      limit_user_use_count: coupon.limit_user_use_count,
      start_at: coupon.start_at,
      end_at: coupon.end_at,
      is_active: coupon.is_active
    }
  end

  def to_snapshot(nil), do: nil
end
