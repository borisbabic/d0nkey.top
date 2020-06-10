defmodule Backend.Infrastructure.PlayerStatsCache do
  @moduledoc false
  use GenServer
  @name :player_stats_cache

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def get(period) do
    GenServer.call(@name, {:get, period})
  end

  def set(period, stats) do
    GenServer.cast(@name, {:set, period, stats})
  end

  def delete(period) do
    GenServer.cast(@name, {:delete, period})
  end

  # Server
  def init(_args \\ nil) do
    {:ok, %{}}
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def handle_call({:get, period}, _from, state) do
    {:reply, state[period], state}
  end

  def handle_cast({:set, period, stats}, state) do
    {:noreply, Map.put(state, period, stats)}
  end

  def handle_cast({:delete, period}, state) do
    {:noreply, Map.delete(state, period)}
  end
end
