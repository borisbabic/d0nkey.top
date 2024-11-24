# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.MageArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper.PaladinArchetyper
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    lightshow? = "Lightshow" in card_info.card_names

    cond do
      highlander?(card_info) ->
        :"Highlander Mage"

      menagerie?(card_info) ->
        :"Menagerie Mage"

      rainbow_mage?(card_info) ->
        :"Rainbow Mage"

      PaladinArchetyper.drunk?(card_info) ->
        :"Drunk Mage"

      excavate_mage?(card_info) ->
        :"Excavate Mage"

      no_minion?(card_info, 2) ->
        :"Spell Mage"

      orb_bsm?(card_info) ->
        :"Orb Big Spell Mage"

      big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      murloc?(card_info) ->
        :"Murloc Mage"

      lightshow? ->
        :"Lightshow Mage"

      "Arkwing Pilot" in card_info.card_names ->
        :"Arkwing Mage"

      "The Galactic Projection Orb" in card_info.card_names ->
        :"Orb Mage"

      bad?(card_info) ->
        :"Bad Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp bad?(card_info) do
    min_count?(card_info, 4, [
      "Firelands Portal",
      "Fireball",
      "Kobold Geomancer",
      "Malygos the Spellweaver",
      "Arcanologist"
    ])
  end

  defp orb_bsm?(card_info) do
    orb = "The Galactic Projection Orb"

    (orb in card_info.card_names or orb in card_info.etc_sideboard_names) and
      big_spell_mage?(card_info)
  end

  defp excavate_mage?(ci) do
    min_count?(ci, 3, [
      "Cryopreservation",
      "Reliquary Researcher",
      "Blastmage Miner" | neutral_excavate()
    ])
  end

  @non_sif_rainbow [
    "Discovery of Magic",
    "Inquisitive Creation",
    "Wisdom of Norgannon",
    "Elemental Inspiration"
  ]
  def rainbow_mage?(ci) do
    min_count?(ci, 3, @non_sif_rainbow) or
      ("Sif" in ci.card_names and min_count?(ci, 1, @non_sif_rainbow))
  end

  defp big_spell_mage?(ci) do
    min_count?(ci, 2, ["Surfalopod", "King Tide", "Portalmancer Skyla"])
  end

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

      hostage_mage?(card_info) ->
        :"Hostage Mage"

      ping_mage?(card_info) ->
        :"Ping Mage"

      no_minion?(card_info, 2) ->
        :"Spell Mage"

      "Sif" in card_info.card_names ->
        :"Sif Mage"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      wild_bsm_mage?(card_info) ->
        :"Big Spell Mage"

      wild_orb_mage?(card_info) ->
        :"Orb Mage"

      wild_flow?(card_info) ->
        :"Flow Mage"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp wild_flow?(card_info) do
    min_count?(card_info, 2, ["Go with the Flow", "Sorcerer's Apprentice"])
  end

  defp no_minion?(card_info, min_count) do
    min_count?(card_info, min_count, [
      # wild
      "Font of Power",
      "Apexis Blast",
      # standard
      "Malfunction",
      "Spot the Difference",
      "Yogg in the Box",
      "Manufacturing Error"
    ])
  end

  defp hostage_mage?(card_info) do
    min_count?(card_info, 2, ["Solid Alibi", "Ice Block"]) and
      min_count?(card_info, 2, [
        "Rewind",
        "Tidepool Pupil",
        "Commander Sivara",
        "Grand Magister Rommath"
      ])
  end

  defp ping_mage?(card_info) do
    min_count?(card_info, 4, [
      "Wildfire",
      "Reckless Apprentice",
      "Sing-Along Buddy",
      "Magister Dawngrasp",
      "Mordresh Fire Eye"
    ])
  end

  defp wild_orb_mage?(card_info) do
    min_count?(card_info, 3, [
      "The Galactic Projection Orb",
      "Potion of Illusion",
      "Grey Sage Parrot"
    ])
  end

  defp wild_bsm_mage?(card_info) do
    min_count?(card_info, 3, [
      "King Tide",
      "Portalmancer Skyla",
      "Naga Sand Witch",
      "Balinda Stonehearth",
      "Barbaric Sorceress",
      "Grey Sage Parrot",
      "The Galactic Projection Orb",
      "Iceblood Tower"
    ])
  end
end
