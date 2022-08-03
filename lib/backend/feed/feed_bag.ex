defmodule Backend.Feed.FeedBag do
  use GenServer
  alias Backend.Feed

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    {:ok, %{table: table}, {:continue, :update}}
  end

  def handle_continue(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  def table(), do: :ets.whereis(__MODULE__)

  def update(), do: GenServer.cast(__MODULE__, :update)

  def handle_cast(:update, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  defp update_table(table) do
    Feed.get_current_items()
    |> set_current_items(table)
  end

  defp set_current_items(current_items, table) do
    :ets.insert(table, {:current_items, current_items})
  end

  def get_current_items() do
    table()
    |> Util.ets_lookup(:current_items, [])
  end
end
