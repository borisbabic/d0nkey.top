# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.HunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      handbuff_hunter?(card_info) ->
        :"Handbuff Hunter"

      amalgam?(card_info) ->
        :"Amalgam Hunter"

      imbue?(card_info) ->
        :"Imbue Hunter"

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

      zerg?(card_info, 4) and egg_hunter?(card_info) ->
        :"Zerg Egg Hunter"

      egg_hunter?(card_info) ->
        :"Egg Hunter"

      zerg?(card_info, 4) and discover?(card_info) ->
        :"Zerg Discover Hunter"

      zerg?(card_info, 4) ->
        :"Zerg Hunter"

      discover?(card_info) ->
        :"Discover Hunter"

      "Floppy Hydra" in card_info.card_names ->
        :"Floppy Hunter"

      bad?(card_info) ->
        :"Bad Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
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

  defp egg_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "Foul Egg",
        "Nerubian Egg",
        "Ravenous Kraken",
        "Yelling Yodeler",
        "Extraterrestrial Egg",
        "Terrorscale Stalker",
        "Terrible Chef",
        "Cubicle"
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

      midrange?(card_info) ->
        :"Midrange Hunter"

      porcupine?(card_info) ->
        :"Porcupine Hunter"

      "Floppy Hydra" in card_info.card_names ->
        :"Floppy Hunter"

      "Adaptive Amalgam" in card_info.card_names ->
        :"Amalgam Hunter"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp midrange?(card_info) do
    min_count?(card_info.card_names, 4, [
      "Exarch Naielle",
      "Acidmaw",
      "Dreadscale",
      "Razorscale",
      "Loatheb",
      "Blademaster Okani",
      "Dirty Rat"
    ])
  end

  defp porcupine?(card_info) do
    min_count?(card_info.card_names, 2, ["Augmented Porcupine", "Mystery Egg"])
  end

  defp lion_hunter?(card_info) do
    min_count?(card_info, 2, ["Mok'Nathal Lion", "Mystery Egg"])
  end

  defp mystery_egg_hunter?(card_info) do
    min_count?(card_info, 1, ["Mystery Egg"])
  end
end
