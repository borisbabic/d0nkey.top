defmodule Backend.DeckInteractionTracker do
  @moduledoc false
  use GenServer
  @name :deck_interaction
  alias Backend.Hearthstone
  alias Backend.Feed

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: @name)
  end

  def init(_args) do
    {:ok, nil}
  end

  def inc_copied(deck_or_code), do: GenServer.cast(@name, {:inc_copied, deck_or_code})
  def inc_expanded(deck_or_code), do: GenServer.cast(@name, {:inc_expanded, deck_or_code})

  def handle_cast({:inc_copied, deck_or_code}, state) do
    deck_or_code
    |> Feed.inc_deck_copied()

    {:noreply, state}
  end

  def handle_cast({:inc_expanded, deck_or_code}, state) do
    deck_or_code
    |> Feed.inc_deck_expanded()

    {:noreply, state}
  end
end
