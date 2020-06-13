defmodule Backend.Infrastructure.ApiCache do
  @moduledoc """
  Holds, in memory, a cache of various results from various api's
  """
  use GenServer

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: :api_cache)
  end

  def get(key) do
    GenServer.call(:api_cache, {:get, key})
  end

  def set(key, value) do
    GenServer.cast(:api_cache, {:set, key, value})
  end

  def delete(key) do
    GenServer.cast(:api_cache, {:delete, key})
  end

  # Server
  def init(_args) do
    table = :ets.new(:api_cache, [:set, :private])
    {:ok, %{table: table}}
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def handle_call({:get, key}, _from, state) do
    %{table: table} = state

    value =
      case :ets.lookup(table, key) do
        [{found_key, value}] when found_key == key -> value
        [] -> nil
        other -> other
      end

    {:reply, value, state}
  end

  def handle_cast({:set, key, value}, state) do
    %{table: table} = state
    true = :ets.insert(table, {key, value})
    {:noreply, state}
  end

  def handle_cast({:delete, key}, state) do
    %{table: table} = state
    true = :ets.delete(table, key)
    {:noreply, state}
  end
end
