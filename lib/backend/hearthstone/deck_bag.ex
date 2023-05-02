defmodule Backend.Hearthstone.DeckBag do
  @moduledoc false
  use GenServer
  alias Backend.Hearthstone
  alias Backend.Hearthstone.DeckArchetyper

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    {:ok, %{table: table}}
  end

  def get(id) do
    with nil <- get_fresh(id) do
      update(id)
    end
    |> tap(&check_archetype/1)
  end

  defp check_archetype(deck) do
    Task.start(fn ->
      if needs_archetype_update?(deck) do
        Hearthstone.recalculate_decks_archetypes([deck])
        update(deck.id)
      end
    end)
  end

  defp needs_archetype_update?(%{archetype: archetype} = deck)
       when is_binary(archetype) or is_atom(archetype) do
    to_string(archetype) != to_string(DeckArchetyper.archetype(deck))
  end

  defp needs_archetype_update?(_), do: true

  def update(id) do
    with deck = %{id: ^id} <- Backend.Hearthstone.get_deck(id) do
      set_deck(deck)
    end
  end

  def get_fresh(id) do
    with {cached, deck} <- table() |> Util.ets_lookup(id),
         true <- fresh?(cached) do
      deck
    else
      _ -> nil
    end
  end

  def set_deck(deck) do
    GenServer.call(__MODULE__, {:set_deck, deck})
  end

  def handle_call({:set_deck, deck = %{id: id}}, _, state = %{table: table}) do
    now = NaiveDateTime.utc_now()
    :ets.insert(table, {id, {now, deck}})
    {:reply, deck, state}
  end

  def fresh?(date) do
    cutoff =
      NaiveDateTime.utc_now()
      |> NaiveDateTime.add(-1 * 60 * 60)

    :gt == NaiveDateTime.compare(date, cutoff)
  end

  def table(), do: :ets.whereis(__MODULE__)
end
