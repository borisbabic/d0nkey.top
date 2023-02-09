defmodule Command.DeduplicateDecks do
  @moduledoc "One time command to deduplicate decks"
  import Ecto.Query, warn: false
  alias Hearthstone.DeckTracker.Game
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone.Deck

  def duplicated_deckcodes(limit \\ 1000) do
    query =
      from d in Deck,
        select: d.deckcode,
        group_by: d.deckcode,
        having: count(d.id) > 1,
        limit: ^limit

    Repo.all(query)
  end

  def run(limit \\ 1000) do
    duplicated_deckcodes(limit)
    |> same_deck_groups()
    |> Enum.each(&deduplicate_group/1)
  end

  def deduplicate_group(group) do
    [actual | rest] = Enum.sort_by(group, & &1.inserted_at, :asc)
    ids = Enum.map(rest, & &1.id)
    IO.puts("Changing #{inspect(ids)} to #{actual.id}")

    Multi.new()
    |> update_streamer_decks(ids, actual)
    |> update_deck_interactions(ids, actual)
    |> update_lineup_decks(ids, actual)
    |> update_games(ids, actual)
    |> update_hsr_map(ids, actual)
    |> delete_rest(rest)
    |> Repo.transaction()
  end

  def delete_rest(multi, rest) do
    Enum.reduce(rest, multi, fn d, m ->
      Multi.delete(m, "delete_#{d.id}", d)
    end)
  end

  def update_streamer_decks(multi, ids, %{id: new_id}) when is_integer(new_id) do
    query = from sd in Backend.Streaming.StreamerDeck, where: sd.deck_id in ^ids
    Multi.update_all(multi, :streamer_decks, query, set: [deck_id: new_id])
  end

  def update_deck_interactions(multi, ids, %{id: new_id}) when is_integer(new_id) do
    query = from sd in Backend.Feed.DeckInteraction, where: sd.deck_id in ^ids
    Multi.update_all(multi, :deck_interactions, query, set: [deck_id: new_id])
  end

  def update_lineup_decks(multi, ids, %{id: new_id}) when is_integer(new_id) do
    query = from sd in Backend.Hearthstone.LineupDeck, where: sd.deck_id in ^ids
    Multi.update_all(multi, :lineup_deck, query, set: [deck_id: new_id])
  end

  def update_games(multi, ids, %{id: new_id}) when is_integer(new_id) do
    player_query = from g in Game, where: g.player_deck_id in ^ids
    opponent_query = from g in Game, where: g.opponent_deck_id in ^ids

    multi
    |> Multi.update_all(:game_player_deck, player_query, set: [player_deck_id: new_id])
    |> Multi.update_all(:game_opponent_deck, opponent_query, set: [opponent_deck_id: new_id])
  end

  def update_hsr_map(multi, ids, %{id: new_id}) when is_integer(new_id) do
    query = from sd in Backend.HSReplay.DeckMap, where: sd.deck_id in ^ids
    Multi.update_all(multi, :deck_map, query, set: [deck_id: new_id])
  end

  def same_deck_groups(deckcodes) do
    Enum.flat_map(deckcodes, fn d ->
      d
      |> deckcode_decks()
      |> group_by_cards()
    end)
  end

  defp deckcode_decks(d) when is_binary(d) do
    query =
      from d in Deck,
        where: d.deckcode == ^d

    Repo.all(query)
  end

  defp group_by_cards(decks) do
    decks
    |> Enum.group_by(&Enum.sort(&1.cards))
    |> Enum.map(&elem(&1, 1))
  end
end
