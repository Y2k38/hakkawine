defmodule HakkawineWeb.Helpers.DateHelper do
  def remaining_days(nil), do: nil

  def remaining_days(%DateTime{} = target_at) do
    Date.diff(DateTime.to_date(target_at), Date.utc_today())
  end

  def remaining_days_count(%DateTime{} = expired_at) do
    case remaining_days(expired_at) do
      d when d >= 0 -> d
      _ -> 0
    end
  end

  def remaining_days_text(%DateTime{} = expired_at) do
    case remaining_days(expired_at) do
      d when d > 1 -> "#{d} days remaining"
      1 -> "1 day remaining"
      _ -> nil
    end
  end

  def in_days_text(%DateTime{} = target_at) do
    case remaining_days(target_at) do
      d when d > 1 -> "In #{d} days"
      1 -> "In 1 day"
      0 -> "Today"
      _ -> "Past"
    end
  end
end
