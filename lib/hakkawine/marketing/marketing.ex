defmodule Hakkawine.Marketing do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Marketing.Coupon
  alias Hakkawine.Marketing.UserCheckin
  alias Hakkawine.Subscription
  alias Hakkawine.Subscription.UserSubscription

  def get_active_coupon(code) do
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
        |> Repo.one()
    end
  end

  defp get_today_user_checkin_base(user_id) do
    UserCheckin
    |> where(user_id: ^user_id)
    |> where(check_in_date: ^Date.utc_today())
  end

  def get_today_user_checkin(user_id) do
    get_today_user_checkin_base(user_id)
    |> Repo.one()
  end

  def get_locked_today_user_checkin(user_id) do
    get_today_user_checkin_base(user_id)
    |> lock("FOR UPDATE")
    |> Repo.one()
  end

  def count_today_checkins() do
    UserCheckin
    |> where(check_in_date: ^Date.utc_today())
    |> Repo.aggregate(:count, :id)
  end

  def generate_traffic_bonus() do
    # {min_mb, max_mb, weight}
    ranges_with_weights = [
      {1, 50, 60},
      {51, 150, 25},
      {151, 300, 10},
      {301, 500, 5}
    ]

    total_weight = Enum.sum(for {_, _, w} <- ranges_with_weights, do: w)
    random_point = :rand.uniform(total_weight)

    {min_mb, max_mb} = pick_range(ranges_with_weights, random_point)

    min_bytes = (min_mb - 1) * 1_048_576 + 1
    max_bytes = max_mb * 1_048_576

    :rand.uniform(max_bytes - min_bytes + 1) + min_bytes - 1
  end

  defp pick_range([{min, max, weight} | _rest], current_point) when current_point <= weight do
    {min, max}
  end

  defp pick_range([{_min, _max, weight} | rest], current_point) do
    pick_range(rest, current_point - weight)
  end

  defp insert_user_checkin_attrs(user_id, sub_id) do
    traffic_amount = generate_traffic_bonus()

    attrs = %{
      user_id: user_id,
      traffic_amount: traffic_amount,
      check_in_date: Date.utc_today(),
      subscription_id: sub_id,
      applied_at: DateTime.utc_now()
    }

    case get_locked_today_user_checkin(user_id) do
      nil ->
        case %UserCheckin{} |> UserCheckin.changeset(attrs) |> Repo.insert() do
          {:ok, record} ->
            {:ok, %{checkin: record, is_new: true}}

          {:error, changeset} ->
            case Keyword.get(changeset.errors, :user_id) do
              {_, [constraint: :unique, constraint_name: "uq_user_checkins_user_date"]} ->
                record = get_today_user_checkin(user_id)
                {:ok, %{checkin: record, is_new: false}}

              _ ->
                {:error, changeset}
            end
        end

      record ->
        {:ok, %{checkin: record, is_new: false}}
    end
  end

  def do_user_checkin(user_id) do
    with %UserSubscription{} = sub <- Subscription.get_active_recurring_subscription(user_id) do
      Repo.transaction(fn ->
        case insert_user_checkin_attrs(user_id, sub.id) do
          {:ok, %{checkin: checkin, is_new: true}} ->
            case Subscription.assign_extra_traffic(sub, checkin.traffic_amount) do
              {:ok, _} ->
                %{checkin: checkin, is_new: true}

              {:error, reason} ->
                Repo.rollback(reason)
            end

          {:ok, %{checkin: checkin, is_new: false}} ->
            %{checkin: checkin, is_new: false}

          {:error, changeset} ->
            Repo.rollback(changeset)
        end
      end)
    else
      nil -> {:error, :no_active_subscription}
    end
  end
end
