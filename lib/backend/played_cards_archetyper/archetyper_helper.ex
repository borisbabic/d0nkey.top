defmodule Backend.PlayedCardsArchetyper.ArchetyperHelper do
  @moduledoc false

  defdelegate quest?(card_info), to: Backend.DeckArchetyper.ArchetyperHelpers

  def any?(%{card_names: search_card_names}, target_card_names),
    do: any?(search_card_names, target_card_names)

  def any?(search_card_names, target_card_names) do
    Enum.any?(search_card_names, &(&1 in target_card_names))
  end

  @spec process_config(list(), any(), atom() | nil) :: atom() | nil
  def process_config(config, card_info, fallback \\ nil) do
    config
    |> Enum.with_index(1)
    |> Enum.find_value(fallback, fn
      {{archetype, {cards, exclude}}, level} when is_list(cards) and is_list(exclude) ->
        if any?(card_info, cards) and not any?(card_info, exclude) do
          if card_info.debug do
            IO.puts("Matching #{archetype} at level #{level}")
          end
          archetype
        else
          nil
        end

      {{archetype, cards}, level} ->
        if any?(card_info, cards) do
          if card_info.debug do
            IO.puts("Matching #{archetype} at level #{level}")
          end
          archetype
        else
          nil
        end
    end)
  end

  @spec add_excludes(list(), map()) :: list()
  def add_excludes(config, excludes_map) do
    Enum.map(config, fn
      {archetype, {cards, excludes}} ->
        new_excludes = excludes ++ Map.get(excludes_map, archetype, [])
        {archetype, {cards, new_excludes}}

      {archetype, cards} ->
        excludes = Map.get(excludes_map, archetype, [])
        {archetype, {cards, excludes}}
    end)
  end

  def example_games(played_card_archetype, deck_archetype, limit \\ 10) do
    criteria = [
      {"player_archetype", Util.to_list(played_card_archetype)},
      {"archetype", deck_archetype},
      {"limit", limit}
    ]

    Hearthstone.DeckTracker.games_with_played_cards(criteria)
  end

  def archetype_game_player(
        %{played_cards: %{player_cards: pc}, player_class: player_class, format: format},
        debug \\ true
      )
      when is_list(pc) do
    Backend.PlayedCardsArchetyper.archetype(pc, player_class, format, debug)
  end

  def example_archetyping(played_card_archetype, deck_archetype, limit \\ 10) do
    for g <- example_games(played_card_archetype, deck_archetype, limit) do
      archetype_game_player(g)

      IO.puts(
        "Deck Archetype: #{g.player_deck.archetype} Deck Id: #{g.player_deck.id} Deck: https://www.hsguru.com/deck/#{g.player_deck.id}"
      )
    end
  end
end
