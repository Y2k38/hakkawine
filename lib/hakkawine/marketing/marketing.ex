defmodule Hakkawine.Marketing do
  import Ecto.Query

  alias Hakkawine.Repo
  alias Hakkawine.Marketing.Coupon
  alias Hakkawine.Marketing.CheckinRule
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

  def validate_checkin_rules(rules) when is_list(rules) do
    sorted = Enum.sort_by(rules, & &1.min_bytes)

    cond do
      Enum.reduce(sorted, 0, fn rule, acc -> acc + rule.weight end) != 100 ->
        {:error, :total_weight_not_equal_100}

      Enum.chunk_every(sorted, 2, 1, :discard)
      |> Enum.any?(fn [prev, curr] -> curr.min_bytes <= prev.max_bytes end) ->
        {:error, :min_bytes_overlap}

      true ->
        :ok
    end
  end

  def fetch_all_checkin_rules() do
    from(r in CheckinRule,
      select: {r.min_bytes, r.max_bytes, r.weight}
    )
    |> Repo.all()
  end

  def generate_traffic_bonus() do
    case fetch_all_checkin_rules() do
      [] ->
        {:error, :no_checkin_rules_configured}

      ranges_with_weights ->
        total_weight = Enum.sum(for {_, _, w} <- ranges_with_weights, do: w)
        random_point = :rand.uniform(total_weight)

        {min_bytes, max_bytes} = pick_range(ranges_with_weights, random_point)
        awarded_bytes = :rand.uniform(max_bytes - min_bytes) + min_bytes - 1

        {:ok, awarded_bytes}
    end
  end

  defp pick_range([{min, max, weight} | _rest], current_point) when current_point <= weight do
    {min, max}
  end

  defp pick_range([{_min, _max, weight} | rest], current_point) do
    pick_range(rest, current_point - weight)
  end

  defp insert_user_checkin_attrs(user_id, sub_id, traffic_amount) do
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
    with %UserSubscription{} = sub <- Subscription.get_active_recurring_subscription(user_id),
         {:ok, awarded_bytes} = generate_traffic_bonus() do
      Repo.transaction(fn ->
        case insert_user_checkin_attrs(user_id, sub.id, awarded_bytes) do
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
      nil ->
        {:error, :no_active_subscription}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
