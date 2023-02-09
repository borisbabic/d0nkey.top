defmodule Command.DeduplicateDecks do
  @moduledoc "One time command to deduplicate decks"
  import Ecto.Query, warn: false
  alias Hearthstone.DeckTracker.Game
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Hearthstone.Deck
  alias Backend.Streaming.StreamerDeck

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
    |> Repo.transaction(timeout: 360_000)
  end

  def delete_rest(multi, rest) do
    Enum.reduce(rest, multi, fn d, m ->
      Multi.delete(m, "delete_#{d.id}", d)
    end)
  end

  def update_streamer_decks(multi, ids, actual = %{id: new_id}) when is_integer(new_id) do
    change_ids_query = from sd in StreamerDeck, where: sd.deck_id in ^ids

    from(sd in StreamerDeck, where: sd.deck_id in ^ids, preload: [:deck, :streamer])
    |> Repo.all()
    |> Enum.group_by(&{&1.streamer_id, &1.deck.deckcode})
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce(multi, fn sds, m ->
      merge_streamer_decks(sds, m, actual)
    end)
    |> Multi.update_all(:streamer_decks, change_ids_query, set: [deck_id: new_id])
  end

  # no previous streamer decks from the decks we want to delete
  def merge_streamer_decks([], m, _actual), do: m

  def merge_streamer_decks(sds = [%{streamer: streamer} | _], m, actual) do
    case {Backend.Streaming.get_streamer_deck(actual, streamer), Enum.count(sds)} do
      # only one, so we can just change the id later
      {nil, c} when c < 2 ->
        m

      {nil, _} ->
        {:ok, sd} =
          Backend.Streaming.get_or_create_streamer_deck(
            actual,
            streamer,
            %Hearthstone.DeckTracker.Game{player_rank: 0, player_legend_rank: 0}
          )

        merge_streamer_decks([sd | sds], m)

      {sd, _} ->
        merge_streamer_decks([sd | sds], m)
    end
  end

  def merge_streamer_decks(all = [keep | delete], m) do
    latest = Enum.max_by(all, & &1.last_played)

    attrs = %{
      wins: all |> Enum.map(& &1.wins) |> Enum.sum(),
      losses: all |> Enum.map(& &1.losses) |> Enum.sum(),
      minutes_played: all |> Enum.map(& &1.minutes_played) |> Enum.sum(),
      best_rank: all |> Enum.map(& &1.best_rank) |> Enum.max(),
      worst_legend_rank: all |> Enum.map(& &1.worst_legend_rank) |> Enum.max(),
      best_legend_rank: all |> Enum.map(& &1.best_legend_rank) |> Enum.min(),
      latest_legend_rank: latest.latest_legend_rank
    }

    cs = Ecto.Changeset.cast(keep, attrs, Map.keys(attrs))
    multi = Multi.update(m, "streamer_deck_#{keep.streamer_id}#{keep.deck_id}", cs)

    Enum.reduce(delete, multi, fn to_delete, mul ->
      Multi.delete(
        mul,
        "pruning_streamer_decks_#{to_delete.streamer_id}#{to_delete.deck_id}",
        to_delete
      )
    end)
  end

  def update_deck_interactions(multi, ids, %{id: new_id}) when is_integer(new_id) do
    query = from sd in Backend.Feed.DeckInteraction, where: sd.deck_id in ^ids
    Multi.delete_all(multi, :deck_interactions, query)
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
    |> Enum.filter(&(Enum.count(&1) > 1))
  end

  def generate_test_data() do
    d =
      "AAECAfHhBATE9gSpgAXLpQXMpQUN7bEElrcE7eME9eME/uMEguQEk+QEueYEh/YEtIAFtYAFk4EFopkFAA=="
      |> Deck.decode!()

    {:ok, first} = Backend.Hearthstone.create_deck(d.cards, d.hero, d.format)
    {:ok, second} = Backend.Hearthstone.create_deck(d.cards, d.hero, d.format)
    add_interactions(first)
    add_streamer_deck(first, 50)
    add_interactions(second)
    add_streamer_deck(second, 5000)
    :ok
  end

  def add_interactions(deck) do
    Backend.DeckInteractionTracker.inc_copied(deck)
    Backend.DeckInteractionTracker.inc_expanded(deck)
  end

  def add_streamer_deck(deck, legend_rank) do
    Backend.Streaming.log_streamer_game(0, %Game{
      player_deck: deck,
      player_rank: 51,
      player_legend_rank: legend_rank
    })
  end
end
