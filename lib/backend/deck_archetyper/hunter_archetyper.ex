# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.HunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Hunter"

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
    min_count?(ci, 5, [
      "Fetch!",
      "Bunny Stomper",
      "Jungle Gym",
      "Painted Canvasaur",
      "Dinositter",
      "Supreme Dinomancy",
      "Cower in Fear",
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
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Hunter"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Hunter")

      highlander?(card_info) ->
        :"Highlander Hunter"

      questline?(card_info) ->
        :"Questline Hunter"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Hunter")

      boar?(card_info) ->
        :"Boar Hunter"

      baku?(card_info) ->
        :"Odd Hunter"

      genn?(card_info) ->
        :"Even Hunter"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Hunter"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Hunter"

      midrange?(card_info) ->
        :"Midrange Hunter"

      "Floppy Hydra" in card_info.card_names ->
        :"Floppy Hunter"

      "Adaptive Amalgam" in card_info.card_names ->
        :"Amalgam Hunter"

      true ->
        fallbacks(card_info, "Hunter")
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

  defp mystery_egg_hunter?(card_info) do
    min_count?(card_info, 1, ["Mystery Egg"])
  end
end
