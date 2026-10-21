defmodule Hakkawine.Utils.TimeUtils do
  @spec within_next?(DateTime.t(), integer(), atom()) :: boolean()
  def within_next?(%DateTime{} = target_at, count, unit) do
    now = DateTime.utc_now()
    future_limit = DateTime.shift(now, [{unit, count}])

    DateTime.after?(target_at, now) and DateTime.before?(target_at, future_limit)
  end

  @spec within_past?(DateTime.t(), integer(), atom()) :: boolean()
  def within_past?(%DateTime{} = target_at, count, unit) do
    now = DateTime.utc_now()
    past_limit = DateTime.shift(now, [{unit, -count}])

    DateTime.before?(target_at, now) and DateTime.after?(target_at, past_limit)
  end

  def expires_in_one_month?(%DateTime{} = expired_at, months \\ 1) do
    within_next?(expired_at, months, :month)
  end
end
