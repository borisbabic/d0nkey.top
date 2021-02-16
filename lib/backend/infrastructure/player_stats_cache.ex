defmodule Backend.Infrastructure.PlayerStatsCache do
  @moduledoc false
  use GenServer
  @name :player_stats_cache

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def get(period), do: table() |> Util.ets_lookup(period)

  def set(period, stats) do
    GenServer.cast(@name, {:set, period, stats})
  end

  def delete(period) do
    GenServer.cast(@name, {:delete, period})
  end

  # Server
  def init(_args \\ nil) do
    table = :ets.new(@name, [:named_table])
    {:ok, %{table: table}}
  end

  def handle_call({:get, period}, _from, state) do
    {:reply, state[period], state}
  end

  def handle_cast({:set, period, stats}, state = %{table: table}) do
    :ets.insert(table, {period, stats})
    {:noreply, state}
  end

  def handle_cast({:delete, period}, state = %{table: table}) do
    :ets.delete(table, period)
    {:noreply, state}
  end

  def table(), do: :ets.whereis(@name)
end
