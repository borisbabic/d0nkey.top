# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper do
  @moduledoc false

  alias Backend.PlayedCardsArchetyper.DeathKnightArchetyper
  alias Backend.PlayedCardsArchetyper.DemonHunterArchetyper
  alias Backend.PlayedCardsArchetyper.DruidArchetyper
  alias Backend.PlayedCardsArchetyper.HunterArchetyper
  alias Backend.PlayedCardsArchetyper.MageArchetyper
  alias Backend.PlayedCardsArchetyper.PaladinArchetyper
  alias Backend.PlayedCardsArchetyper.PriestArchetyper
  alias Backend.PlayedCardsArchetyper.RogueArchetyper
  alias Backend.PlayedCardsArchetyper.ShamanArchetyper
  alias Backend.PlayedCardsArchetyper.WarlockArchetyper
  alias Backend.PlayedCardsArchetyper.WarriorArchetyper

  @type card_info :: %{
          card_names: [String.t()],
          full_cards: [Card.t()],
          cards: [integer()],
          start_of_game_card_names: [String.t()],
          start_of_game_full_cards: [Card.t()],
          start_of_game_cards: [integer()],
          start_of_game: [String.t()],
          debug: boolean
        }

  defdelegate extract_card_names(cards), to: Backend.PlayedCardsArchetyper.ArchetyperHelper

  def archetype(cards, class) when is_list(cards) and is_binary(class) do
    archetype(cards, [], class, 2, false)
  end

  def archetype(%{player_cards: pc} = played_cards, class) when is_list(pc) and is_binary(class) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    archetype(pc, sog, class, 2, false)
  end

  def archetype(%{"player_cards" => pc} = played_cards, class) when is_list(pc) and is_binary(class) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    archetype(pc, sog, class, 2, false)
  end

  def archetype(_cards, _class), do: nil

  def archetype(cards, class, format) when is_list(cards) and is_binary(class) do
    archetype(cards, [], class, format, false)
  end

  def archetype(%{player_cards: pc} = played_cards, class, format) when is_list(pc) and is_binary(class) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    archetype(pc, sog, class, format, false)
  end

  def archetype(%{"player_cards" => pc} = played_cards, class, format) when is_list(pc) and is_binary(class) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    archetype(pc, sog, class, format, false)
  end

  def archetype(cards, start_of_game, class) when is_list(cards) and is_list(start_of_game) and is_binary(class) do
    archetype(cards, start_of_game, class, 2, false)
  end

  def archetype(_cards, _b, _c), do: nil

  def archetype(cards, class, format, debug) when is_list(cards) and is_binary(class) do
    archetype(cards, [], class, format, debug)
  end

  def archetype(cards, start_of_game, class, format)
      when is_list(cards) and is_list(start_of_game) and is_binary(class) do
    archetype(cards, start_of_game, class, format, false)
  end

  def archetype(%{player_cards: pc} = played_cards, class, format, debug)
      when is_list(pc) and is_binary(class) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    archetype(pc, sog, class, format, debug)
  end

  def archetype(%{"player_cards" => pc} = played_cards, class, format, debug)
      when is_list(pc) and is_binary(class) do
    sog = Map.get(played_cards, :player_start_of_game) || Map.get(played_cards, "player_start_of_game") || []
    archetype(pc, sog, class, format, debug)
  end

  def archetype(_cards, _b, _c, _d), do: nil

  def archetype(cards, start_of_game, class, format, debug)
      when is_binary(class) and is_list(cards) and is_list(start_of_game) do
    card_info = card_info(cards, start_of_game, debug)

    archetype =
      case {Util.to_int_or_orig(format), class} do
        {2, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard(card_info)
        {1, "DEATHKNIGHT"} -> DeathKnightArchetyper.wild(card_info)
        {2, "DEMONHUNTER"} -> DemonHunterArchetyper.standard(card_info)
        {1, "DEMONHUNTER"} -> DemonHunterArchetyper.wild(card_info)
        {2, "DRUID"} -> DruidArchetyper.standard(card_info)
        {1, "DRUID"} -> DruidArchetyper.wild(card_info)
        {2, "HUNTER"} -> HunterArchetyper.standard(card_info)
        {1, "HUNTER"} -> HunterArchetyper.wild(card_info)
        {2, "MAGE"} -> MageArchetyper.standard(card_info)
        {1, "MAGE"} -> MageArchetyper.wild(card_info)
        {2, "PALADIN"} -> PaladinArchetyper.standard(card_info)
        {1, "PALADIN"} -> PaladinArchetyper.wild(card_info)
        {2, "PRIEST"} -> PriestArchetyper.standard(card_info)
        {1, "PRIEST"} -> PriestArchetyper.wild(card_info)
        {2, "ROGUE"} -> RogueArchetyper.standard(card_info)
        {1, "ROGUE"} -> RogueArchetyper.wild(card_info)
        {2, "SHAMAN"} -> ShamanArchetyper.standard(card_info)
        {1, "SHAMAN"} -> ShamanArchetyper.wild(card_info)
        {2, "WARLOCK"} -> WarlockArchetyper.standard(card_info)
        {1, "WARLOCK"} -> WarlockArchetyper.wild(card_info)
        {2, "WARRIOR"} -> WarriorArchetyper.standard(card_info)
        {1, "WARRIOR"} -> WarriorArchetyper.wild(card_info)
        _ -> nil
      end

    if debug do
      card_names_part = Enum.join(card_info.card_names, "\n")

      sog_part =
        if Enum.any?(card_info.start_of_game_card_names) do
          "\nStart of game:\n" <> Enum.join(card_info.start_of_game_card_names, "\n")
        else
          ""
        end

      IO.puts("--------------------------------\nGot #{archetype} for:\n\n#{card_names_part}#{sog_part}\n")
    end

    archetype
  end

  def archetype(_cards, _b, _c, _d, _e), do: nil

  def all_archetypes(format) do
    Backend.Hearthstone.Deck.classes()
    |> Enum.flat_map(fn class ->
      config(format, class)
      |> Enum.map(fn {archetype, _} ->
        archetype
      end)
    end)
    |> Enum.uniq()
  end

  def full_config(format) do
    Backend.Hearthstone.Deck.classes()
    |> Map.new(fn class ->
      {class, config(format, class)}
    end)
  end

  def excludes(format, class) do
    case {Util.to_int_or_orig(format), class} do
      {2, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard_excludes()
      {1, "DEATHKNIGHT"} -> DeathKnightArchetyper.wild_excludes()
      {2, "DEMONHUNTER"} -> DemonHunterArchetyper.standard_excludes()
      {1, "DEMONHUNTER"} -> DemonHunterArchetyper.wild_excludes()
      {2, "DRUID"} -> DruidArchetyper.standard_excludes()
      {1, "DRUID"} -> DruidArchetyper.wild_excludes()
      {2, "HUNTER"} -> HunterArchetyper.standard_excludes()
      {1, "HUNTER"} -> HunterArchetyper.wild_excludes()
      {2, "MAGE"} -> MageArchetyper.standard_excludes()
      {1, "MAGE"} -> MageArchetyper.wild_excludes()
      {2, "PALADIN"} -> PaladinArchetyper.standard_excludes()
      {1, "PALADIN"} -> PaladinArchetyper.wild_excludes()
      {2, "PRIEST"} -> PriestArchetyper.standard_excludes()
      {1, "PRIEST"} -> PriestArchetyper.wild_excludes()
      {2, "ROGUE"} -> RogueArchetyper.standard_excludes()
      {1, "ROGUE"} -> RogueArchetyper.wild_excludes()
      {2, "SHAMAN"} -> ShamanArchetyper.standard_excludes()
      {1, "SHAMAN"} -> ShamanArchetyper.wild_excludes()
      {2, "WARLOCK"} -> WarlockArchetyper.standard_excludes()
      {1, "WARLOCK"} -> WarlockArchetyper.wild_excludes()
      {2, "WARRIOR"} -> WarriorArchetyper.standard_excludes()
      {1, "WARRIOR"} -> WarriorArchetyper.wild_excludes()
      _ -> %{}
    end
  end

  def config(format, class) do
    case {format, class} do
      {2, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard_config()
      {1, "DEATHKNIGHT"} -> DeathKnightArchetyper.wild_config()
      {2, "DEMONHUNTER"} -> DemonHunterArchetyper.standard_config()
      {1, "DEMONHUNTER"} -> DemonHunterArchetyper.wild_config()
      {2, "DRUID"} -> DruidArchetyper.standard_config()
      {1, "DRUID"} -> DruidArchetyper.wild_config()
      {2, "HUNTER"} -> HunterArchetyper.standard_config()
      {1, "HUNTER"} -> HunterArchetyper.wild_config()
      {2, "MAGE"} -> MageArchetyper.standard_config()
      {1, "MAGE"} -> MageArchetyper.wild_config()
      {2, "PALADIN"} -> PaladinArchetyper.standard_config()
      {1, "PALADIN"} -> PaladinArchetyper.wild_config()
      {2, "PRIEST"} -> PriestArchetyper.standard_config()
      {1, "PRIEST"} -> PriestArchetyper.wild_config()
      {2, "ROGUE"} -> RogueArchetyper.standard_config()
      {1, "ROGUE"} -> RogueArchetyper.wild_config()
      {2, "SHAMAN"} -> ShamanArchetyper.standard_config()
      {1, "SHAMAN"} -> ShamanArchetyper.wild_config()
      {2, "WARLOCK"} -> WarlockArchetyper.standard_config()
      {1, "WARLOCK"} -> WarlockArchetyper.wild_config()
      {2, "WARRIOR"} -> WarriorArchetyper.standard_config()
      {1, "WARRIOR"} -> WarriorArchetyper.wild_config()
      _ -> []
    end
  end

  def card_info(cards) when is_list(cards), do: card_info(cards, [], false)

  def card_info(cards, debug) when is_list(cards) and is_boolean(debug) do
    card_info(cards, [], debug)
  end

  def card_info(cards, start_of_game) when is_list(cards) and is_list(start_of_game) do
    card_info(cards, start_of_game, false)
  end

  def card_info(cards, start_of_game, debug) when is_list(cards) and is_list(start_of_game) do
    {card_names, full_cards, card_ids} = extract_card_info(cards)
    {sog_names, sog_full_cards, sog_ids} = extract_card_info(start_of_game)

    %{
      card_names: card_names,
      full_cards: full_cards,
      cards: card_ids,
      start_of_game_card_names: sog_names,
      start_of_game_full_cards: sog_full_cards,
      start_of_game_cards: sog_ids,
      start_of_game: sog_names,
      debug: debug
    }
  end

  def card_info(_, _, debug) do
    %{
      card_names: [],
      full_cards: [],
      cards: [],
      start_of_game_card_names: [],
      start_of_game_full_cards: [],
      start_of_game_cards: [],
      start_of_game: [],
      debug: debug
    }
  end

  defp extract_card_info(cards) when is_list(cards) do
    cards
    |> Enum.uniq()
    |> Enum.reduce(
      {[], [], []},
      fn item, {names, full_cards, ids} ->
        case resolve_card(item) do
          {id, %{name: name} = full_card} ->
            {[name | names], [full_card | full_cards], (id && [id | ids]) || ids}

          _ ->
            {names, full_cards, ids}
        end
      end
    )
  end

  defp extract_card_info(_), do: {[], [], []}

  defp resolve_card(id) when is_integer(id) do
    case Backend.Hearthstone.get_deckcode_card(id) do
      %{name: _} = full_card -> {id, full_card}
      _ -> nil
    end
  end

  defp resolve_card(%{name: _} = full_card) do
    id = Map.get(full_card, :id) || Map.get(full_card, :dbf_id)
    {id, full_card}
  end

  defp resolve_card(name) when is_binary(name) do
    {nil, %{name: name}}
  end

  defp resolve_card(_), do: nil
end
