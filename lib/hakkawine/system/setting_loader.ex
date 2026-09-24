defmodule Hakkawine.System.SettingLoader do
  use GenServer

  alias Hakkawine.Repo
  alias Hakkawine.System.Setting

  @ets_table :app_settings

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def reload do
    GenServer.call(__MODULE__, :reload_settings)
  end

  @impl true
  def init(_opts) do
    if :ets.info(@ets_table) == :undefined do
      :ets.new(@ets_table, [
        :named_table,
        :public,
        read_concurrency: true,
        write_concurrency: true
      ])
    end

    load_all_settings()
    {:ok, %{}}
  end

  @impl true
  def handle_call(:reload_settings, _from, state) do
    load_all_settings()
    {:reply, :ok, state}
  end

  defp load_all_settings do
    Repo.all(Setting)
    |> Enum.each(fn setting ->
      :ets.insert(@ets_table, {setting.key, setting.value})
    end)
  end
end
