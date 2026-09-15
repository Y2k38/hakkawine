defmodule Hakkawine.System do

  alias Hakkawine.Repo
  alias Hakkawine.System.Setting

  @ets_table :settings

  def load_settings! do
    if :ets.info(@ets_table) == :undefined do
      :ets.new(@ets_table, [
        :named_table,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])
    end

    Repo.all(Setting)
    |> Enum.each(fn setting ->
      :ets.insert(@ets_table, {setting.key, setting.value})
    end)

    :ok
  end

  def get_setting(key, default \\ nil) when is_binary(key) do
    case :ets.lookup(@ets_table, key) do
      [{^key, value}] -> value
      [] -> default
    end
  end

  def update_setting(%Setting{} = setting, attrs) do
    setting
    |> Setting.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, updated} ->
        :ets.insert(@ets_table, {updated.key, updated.value})
        {:ok, updated}

      error ->
        error
    end
  end
end
