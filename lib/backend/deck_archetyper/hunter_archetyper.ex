# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.HunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Hunter"

      secret_hunter?(card_info) ->
        :"Secret Hunter"

      big_beast_hunter?(card_info) ->
        :"Big Beast Hunter"

      handbuff_hunter?(card_info) ->
        :"Handbuff Hunter"

      amalgam?(card_info) ->
        :"Amalgam Hunter"

      zoo_hunter?(card_info) ->
        :"Zoo Hunter"

      beast_hunter?(card_info) ->
        :"Beast Hunter"

      murloc?(card_info) ->
        :"Murloc Hunter"

      menagerie?(card_info) ->
        :"Menagerie Hunter"

      egg_hunter?(card_info) ->
        :"Egg Hunter"

      mystery_egg_hunter?(card_info) ->
        :"Mystery Egg Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  defp amalgam?(ci) do
    "Adaptive Amalgam" in ci.card_names and
      min_count?(ci, 3, [
        "Cup o' Muscle",
        "Bronze Gatekeeper",
        "Sailboat Captain",
        "Trusty Fishing Rod",
        "Absorbent Parasite",
        "Always a Bigger Jormungar",
        "Birdwatching"
      ])
  end

  defp handbuff_hunter?(ci) do
    min_count?(ci, 3, [
      "Bestial Madness",
      "Messenger Buzzard",
      "Char",
      "Cup o' Muscle",
      "Ranger Gilly",
      "Overlord Runthak"
    ])
  end

  defp beast_hunter?(ci) do
    min_count?(ci, 4, [
      "Fetch!",
      "Bunny Stomper",
      "Jungle Gym",
      "Painted Canvasaur",
      "Master's Call",
      "Ball of Spiders",
      "Kill Command"
    ])
  end

  defp zoo_hunter?(ci) do
    min_count?(ci, 4, [
      "Observer of Myths",
      "Saddle Up!",
      "R.C. Rampage",
      "Remote Control",
      "Jungle Gym"
    ])
  end

  defp egg_hunter?(ci),
    do: min_count?(ci, 3, ["Foul Egg", "Nerubian Egg", "Ravenous Kraken", "Yelling Yodeler"])

  defp secret_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "Lesser Emerald Spellstone",
        "Costumed Singer",
        "Anonymous Informant",
        "Titanforged Traps",
        "Product 9",
        "Starstrung Bow"
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

      lion_hunter?(card_info) ->
        :"Lion Hunter"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      "Floppy Hydra" in card_info.card_names ->
        :"Floppy Hydra Hunter"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp lion_hunter?(card_info) do
    min_count?(card_info, 2, ["Mok'Nathal Lion", "Mystery Egg"])
  end

  defp mystery_egg_hunter?(card_info) do
    min_count?(card_info, 1, ["Mystery Egg"])
  end

  defp big_beast_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "King Krush",
        "Stranglethorn Heart",
        "Faithful Companions",
        "Banjosaur",
        "Beached Whale",
        "Thunderbringer",
        "Mister Mukla"
      ])
end
