defmodule Hearthstone.DeckTracker.GameInsertBatcher do
  @moduledoc "Batches enqueueing game inserts"

  use GenServer
  alias Hearthstone.DeckTracker.GameInserter

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  @impl true
  def init(_args) do
    send_loop()
    {:ok, []}
  end

  @impl true
  def handle_info(:loop, []) do
    send_loop()
    {:noreply, []}
  end

  def handle_info(:loop, args) do
    Task.start(fn ->
      GameInserter.enqueue_all(args)
    end)

    send_loop()
    {:noreply, []}
  end

  def enqueue(params, api_user_or_id),
    do: GenServer.cast(__MODULE__, {:enqueue, {params, api_user_or_id}})

  @impl true
  def handle_cast({:enqueue, args}, state) do
    {:noreply, [args | state]}
  end

  defp send_loop(), do: Process.send_after(self(), :loop, 1000 * 2)
end
