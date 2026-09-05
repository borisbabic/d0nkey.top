defmodule Backend.PlayedCardsArchetyper.ArchetyperHelper do
  @moduledoc false

  defdelegate quest?(card_info), to: Backend.DeckArchetyper.ArchetyperHelpers

  def any?(card_info_or_names, targets) do
    matches?(card_info_or_names, targets)
  end

  def all?(card_info_or_names, {:all, targets}) when is_list(targets) do
    Enum.all?(targets, &matches?(card_info_or_names, &1))
  end

  def all?(card_info_or_names, targets) when is_list(targets) do
    Enum.all?(targets, &matches?(card_info_or_names, &1))
  end

  def all?(card_info_or_names, target) do
    matches?(card_info_or_names, target)
  end

  def matches?(card_info_or_names, {:all, targets}) when is_list(targets) do
    Enum.all?(targets, &matches?(card_info_or_names, &1))
  end

  def matches?(card_info_or_names, {:all, target}) do
    matches?(card_info_or_names, target)
  end

  def matches?(card_info_or_names, {:any, targets}) when is_list(targets) do
    Enum.any?(targets, &matches?(card_info_or_names, &1))
  end

  def matches?(card_info_or_names, {:any, target}) do
    matches?(card_info_or_names, target)
  end

  def matches?(card_info_or_names, targets) when is_list(targets) do
    Enum.any?(targets, &matches?(card_info_or_names, &1))
  end

  def matches?(card_info_or_names, {:start_of_game, cards}) do
    sog_cards = start_of_game_card_names(card_info_or_names)
    Enum.any?(List.wrap(cards), &(&1 in sog_cards))
  end

  def matches?(card_info_or_names, {:played, cards}) do
    played = played_card_names(card_info_or_names)
    Enum.any?(List.wrap(cards), &(&1 in played))
  end

  def matches?(card_info_or_names, card_name) when is_binary(card_name) do
    card_name in played_card_names(card_info_or_names)
  end

  def matches?(_card_info_or_names, _), do: false

  defp played_card_names(%{card_names: names}) when is_list(names), do: names
  defp played_card_names(names) when is_list(names), do: names
  defp played_card_names(name) when is_binary(name), do: [name]
  defp played_card_names(_), do: []

  defp start_of_game_card_names(%{start_of_game_card_names: names}) when is_list(names), do: names
  defp start_of_game_card_names(%{start_of_game: names}) when is_list(names), do: names
  defp start_of_game_card_names(_), do: []

  @spec extract_card_names(any()) :: [String.t()]
  def extract_card_names(cards) when is_list(cards) do
    Enum.flat_map(cards, &extract_card_names/1)
  end

  def extract_card_names({:all, cards}), do: extract_card_names(cards)
  def extract_card_names({:any, cards}), do: extract_card_names(cards)
  def extract_card_names({:start_of_game, cards}), do: extract_card_names(cards)
  def extract_card_names({:played, cards}), do: extract_card_names(cards)

  def extract_card_names({cards, exclude}) when is_list(cards) or is_tuple(cards) do
    extract_card_names(cards) ++ extract_card_names(exclude)
  end

  def extract_card_names(name) when is_binary(name), do: [name]
  def extract_card_names(_), do: []

  @spec process_config(list(), any(), atom() | nil) :: atom() | nil
  def process_config(config, card_info, fallback \\ nil) do
    config
    |> Enum.with_index(1)
    |> Enum.find_value(fallback, fn
      {{archetype, {cards, exclude}}, level} ->
        if matches?(card_info, cards) and not matches?(card_info, exclude) do
          if card_info.debug do
            IO.puts("Matching #{archetype} at level #{level}")
          end

          archetype
        else
          nil
        end

      {{archetype, cards}, level} ->
        if matches?(card_info, cards) do
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
        extra = Map.get(excludes_map, archetype) || Map.get(excludes_map, to_string(archetype)) || []
        new_excludes = List.wrap(excludes) ++ List.wrap(extra)
        {archetype, {cards, new_excludes}}

      {archetype, cards} ->
        excludes = Map.get(excludes_map, archetype) || Map.get(excludes_map, to_string(archetype)) || []
        {archetype, {cards, List.wrap(excludes)}}
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

  def archetype_game_player(game, debug \\ true)

  def archetype_game_player(
        %{played_cards: %{player_cards: pc} = played_cards, player_class: player_class, format: format},
        debug
      )
      when is_list(pc) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    Backend.PlayedCardsArchetyper.archetype(pc, sog, player_class, format, debug)
  end

  def archetype_game_player(
        %{played_cards: %{"player_cards" => pc} = played_cards, player_class: player_class, format: format},
        debug
      )
      when is_list(pc) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    Backend.PlayedCardsArchetyper.archetype(pc, sog, player_class, format, debug)
  end

  def example_archetyping(played_card_archetype, deck_archetype, limit \\ 10) do
    for g <- example_games(played_card_archetype, deck_archetype, limit) do
      archetype_game_player(g)

      IO.puts(
        "Deck Archetype: #{g.player_deck.archetype} Deck Id: #{g.player_deck.id} Deck: #{Backend.Hearthstone.Deck.link(g.player_deck)}"
      )
    end
  end
end
