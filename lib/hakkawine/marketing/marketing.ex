defmodule Hakkawine.Marketing do
  import Ecto.Query
  import Hakkawine.Repo.Query
  alias Hakkawine.Repo
  alias Hakkawine.Marketing.Coupon

  def get_active_coupon(code, opts \\ []) do
    case String.trim(code) do
      "" ->
        nil

      clean_code ->
        now = DateTime.utc_now()

        Coupon
        |> where(code: ^clean_code)
        |> where(is_active: true)
        |> where([c], is_nil(c.start_at) or c.start_at <= ^now)
        |> where([c], is_nil(c.end_at) or c.end_at >= ^now)
        |> where([c], is_nil(c.limit_use_count) or c.used_count < c.limit_use_count)
        |> apply_opts(opts)
        |> Repo.one()
    end
  end

  def generate_traffic_bonus() do
    # {min, max, weight}
    ranges_with_weights = [
      {1, 50, 60},
      {51, 150, 25},
      {151, 300, 10},
      {301, 500, 5}
    ]

    total_weight = Enum.sum(for {_, _, w} <- ranges_with_weights, do: w)

    random_point = :rand.uniform(total_weight)

    {min_mb, max_mb} = pick_range(ranges_with_weights, random_point)

    :rand.uniform(max_mb - min_mb + 1) + min_mb - 1
  end

  defp pick_range([{min, max, weight} | _rest], current_point) when current_point <= weight do
    {min, max}
  end

  defp pick_range([{_min, _max, weight} | rest], current_point) do
    pick_range(rest, current_point - weight)
  end
end
