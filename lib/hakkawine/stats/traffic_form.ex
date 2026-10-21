defmodule Hakkawine.Stats.TrafficForm do
  use Ecto.Schema

  import Ecto.Changeset

  embedded_schema do
    field :period, Ecto.Enum, values: [:current, :last_31d], default: :current
    field :start_time, :utc_datetime_usec
    field :end_time, :utc_datetime_usec
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:period, :start_time, :end_time])
    |> validate_time_range()
  end

  defp validate_time_range(changeset) do
    start_t = get_field(changeset, :start_time)
    end_t = get_field(changeset, :end_time)

    cond do
      (start_t && !end_t) || (!start_t && end_t) ->
        msg = "start_time and end_time must be provided together"

        changeset
        |> add_error(:start_time, msg)
        |> add_error(:end_time, msg)

      start_t && end_t && DateTime.compare(start_t, end_t) == :gt ->
        now = DateTime.utc_now()
        thirty_one_days_ago = DateTime.add(now, -31, :day)

        cond do
          DateTime.compare(start_t, end_t) != :lt ->
            add_error(changeset, :end_time, "must be greater than start_time")

          DateTime.compare(start_t, thirty_one_days_ago) == :lt ->
            add_error(changeset, :start_time, "start_time cannot be older than 31 days")

          DateTime.diff(end_t, start_t, :day) > 31 ->
            add_error(changeset, :end_time, "time range cannot exceed 31 days")

          true ->
            changeset
        end

      true ->
        changeset
    end
  end
end
