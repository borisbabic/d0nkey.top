defmodule Backend.Infrastructure.HSReplayLatestCache do
  use GenServer
  alias Backend.FifoSet
  @name :hsreplay_latest_cache

  # Client
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def get(key) do
    GenServer.call(@name, {:get, key})
  end

  def list() do
    GenServer.call(@name, {:list})
  end

  @spec add(any, any) :: :ok
  def add(key, value) do
    GenServer.cast(@name, {:add, key, value})
  end

  @spec add_multiple([{String.t(), any}]) :: :ok
  def add_multiple(key_value_list) do
    GenServer.cast(@name, {:add_multiple, key_value_list})
  end

  # Server
  def init(args \\ [max_length: 10000]) do
    fs = %FifoSet{max_length: args[:max_length]}
    {:ok, %{fs: fs}}
  end

  def create(server, name) do
    GenServer.cast(server, {:create, name})
  end

  def handle_call({:get, key}, _from, state = %{fs: fs}) do
    value = fs |> FifoSet.get(key)
    {:reply, value, state}
  end

  def handle_call({:list}, _from, state = %{fs: fs}) do
    value = fs |> FifoSet.to_list()
    {:reply, value, state}
  end

  def handle_cast({:add_multiple, key_value_list}, %{fs: fs}) do
    new_fs =
      key_value_list
      |> Enum.reduce(fs, fn {key, value}, acc -> acc |> FifoSet.add(key, value) end)

    {:noreply, %{fs: new_fs}}
  end

  def handle_cast({:add, key, value}, %{fs: fs}) do
    new_fs = fs |> FifoSet.add(key, value)
    {:noreply, %{fs: new_fs}}
  end
end
