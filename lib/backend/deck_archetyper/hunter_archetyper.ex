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

      zerg?(card_info, 5) and zoo_hunter?(card_info) ->
        :"Zerg Zoo Hunter"

      zoo_hunter?(card_info) ->
        :"Zoo Hunter"

      beast_hunter?(card_info) ->
        :"Beast Hunter"

      murloc?(card_info) ->
        :"Murloc Hunter"

      menagerie?(card_info) ->
        :"Menagerie Hunter"

      mystery_egg_hunter?(card_info) ->
        :"Mystery Egg Hunter"

      starship?(card_info) ->
        :"Starship Hunter"

      zerg?(card_info, 5) and egg_hunter?(card_info) ->
        :"Zerg Egg Hunter"

      egg_hunter?(card_info) ->
        :"Egg Hunter"

      zerg?(card_info, 5) and discover?(card_info) ->
        :"Zerg Discover Hunter"

      "Mantle Shaper" in card_info.card_names and discover?(card_info) ->
        :"Shaper Discover Hunter"

      discover?(card_info) ->
        :"Discover Hunter"

      shaffar?(card_info) ->
        :"Shaffar Hunter"

      "Floppy Hydra" in card_info.card_names ->
        :"Floppy Hunter"

      bad?(card_info) ->
        :"Bad Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  defp shaffar?(ci) do
    min_count?(ci, 1, [
      "Nexus Prince Shaffar",
      "Nexus-Prince Shaffar"
    ]) and
      min_count?(ci, 1, [
        "Zergling",
        "Spawning Pool"
      ])
  end

  defp bad?(ci) do
    min_count?(ci, 5, [
      "Dire Wolf Alpha",
      "Lifedrinker",
      "Siamat",
      "Savannah Highmane",
      "Ball of Spiders",
      "Dragonbane"
    ])
  end

  defp discover?(ci) do
    min_count?(ci, 2, ["Rangari Scout", "Parallax Cannon", "Alien Encounters"])
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
      "Reserved Spot",
      "Warsong Grunt",
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
      "Gorgonzormu",
      "Jungle Gym"
    ])
  end

  defp egg_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "Foul Egg",
        "Nerubian Egg",
        "Ravenous Kraken",
        "Yelling Yodeler",
        "Extraterrestrial Egg",
        "Terrible Chef",
        "Cubicle"
      ])

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
        :"Floppy Hunter"

      "Adaptive Amalgam" in card_info.card_names ->
        :"Amalgam Hunter"

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
