# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.WarriorArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      menagerie_warrior?(card_info) ->
        :"Menagerie Warrior"

      food_fight?(card_info) ->
        :"Food Fight Warrior"

      terran?(card_info, 4) ->
        :"Terran Warrior"

      draenei?(card_info) ->
        :"Draenei Warrior"

      mech_warrior?(card_info) ->
        :"Mech Warrior"

      bomb_warrior?(card_info) ->
        :"Bomb Warrior"

      "The Ryecleaver" in card_info.card_names ->
        :"Sandwich Warrior"

      murloc?(card_info) ->
        :"Murloc Warrior"

      "Safety Expert" in card_info.card_names ->
        :"Safety Warrior"

      type_count(card_info, "dragon") > 5 ->
        :"Dragon Warrior"

      "Hydration Station" in card_info.card_names ->
        :"Hydration Warrior"

      "Ysondre" in card_info.card_names ->
        :"Ysondre Warrior"

      warrior_aoe?(card_info) ->
        :"Control Warrior"

      type_count(card_info, "Pirate") >= 5 ->
        :"Pirate Warrior"

      true ->
        fallbacks(card_info, "Warrior")
    end
  end

  defp food_fight?(card_info) do
    num_minions = Enum.count(card_info.full_cards, &Backend.Hearthstone.Card.minion?/1)
    "Food Fight" in card_info.card_names and num_minions <= 5
  end

  defp bomb_warrior?(card_info) do
    min_count?(card_info, 2, ["Explodineer", "Safety Expert"])
  end

  defp mech_warrior?(card_info) do
    min_count?(card_info, 2, ["Boom Wrench", "Testing Dummy"])
  end

  defp draenei?(card_info) do
    type_count(card_info, "Draenei") > 5
  end

  defp menagerie_warrior?(card_info) do
    min_count?(card_info, 3, [
      "Roaring Applause",
      "Party Animal",
      "The One-Amalgam Band",
      "All You Can Eat",
      "Rock Master Voone",
      "Power Slider"
    ])
  end

  defp warrior_aoe?(ci, min_count \\ 4),
    do:
      min_count?(ci, min_count, [
        "Brawl",
        "Aftershocks",
        "Sanitize",
        "Garrosh's Gift",
        "Bladestorm",
        "Hostile Invader"
      ])

  def wild(card_info) do
    class_name = Deck.class_name(card_info.deck)

    cond do
      highlander?(card_info) ->
        String.to_atom("Highlander #{class_name}")

      questline?(card_info) ->
        String.to_atom("Questline #{class_name}")

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest #{class_name}")

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      baku?(card_info) ->
        String.to_atom("Odd #{class_name}")

      genn?(card_info) ->
        String.to_atom("Even #{class_name}")

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      wild_handbuff_warrior?(card_info) ->
        :"Handbuff Warrior"

      n_roll?(card_info) ->
        :"Rock 'n' Roll Warrior"

      "Odyn, Prime Designate" in card_info.card_names ->
        :"Odyn Warrior"

      "Warsong Commander" in card_info.card_names ->
        :"Warsong Warrior"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      wild_dmh_warrior?(card_info) ->
        :"DMH Warrior"

      raider?(card_info) ->
        :"Raider Warrior"

      "Thaddius, Monstrosity" in card_info.card_names ->
        :"Chad Warrior"

      sulthraze?(card_info) ->
        :"Sul'thraze Warrior"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp sulthraze?(card_info), do: min_count?(card_info, 1, ["Sul'thraze"])
  defp n_roll?(card_info), do: "Blackrock 'n' Roll" in card_info.card_names

  defp raider?(card_info) do
    min_count?(card_info, 2, ["Bladed Gauntlet", "Bloodsail Raider"])
  end

  defp wild_handbuff_warrior?(card_info) do
    min_count?(card_info, 1, ["Anima Extractor"])
  end

  defp wild_dmh_warrior?(card_info) do
    min_count?(card_info, 2, [
      "Dead Man's Hand",
      "Marin the Manager"
    ])
  end
end
