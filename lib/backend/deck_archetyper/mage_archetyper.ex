# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.MageArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper.PaladinArchetyper

  def standard(card_info) do
    cond do
      no_minion?(card_info, 2) and quest?(card_info) ->
        :"Quest Spell Mage"

      quest?(card_info) ->
        :"Quest Mage"

      menagerie?(card_info) ->
        :"Menagerie Mage"

      PaladinArchetyper.drunk?(card_info) ->
        :"Drunk Mage"

      protoss?(card_info, 4) and imbue?(card_info, 4) ->
        :"Protoss Imbue Mage"

      imbue?(card_info, 4) and "Portalmancer Skyla" in card_info.card_names ->
        :"Skyla Imbue Mage"

      imbue?(card_info, 4) and "Raylla, Sand Sculptor" in card_info.card_names ->
        :"Raylla Imbue Mage"

      imbue?(card_info, 4) ->
        :"Imbue Mage"

      protoss?(card_info, 4) ->
        :"Protoss Mage"

      no_minion?(card_info, 2) ->
        :"Spell Mage"

      orb_bsm?(card_info) ->
        :"Orb Big Spell Mage"

      big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      murloc?(card_info) ->
        :"Murloc Mage"

      type_count(card_info, "Elemental") > 6 ->
        :"Elemental Mage"

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
    cond do
      "Luna's Pocket Galaxy" in card_info.card_names and highlander?(card_info) ->
        :"HL LPG Mage"

      wild_exodia_mage?(card_info) and highlander?(card_info) ->
        :"HL Exodia Mage"

      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Mage"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Mage")

      hostage_mage?(card_info) and highlander?(card_info) ->
        :"HL Hostage Mage"

      big_spell_mage?(card_info) and highlander?(card_info) ->
        :"HL Big Spell Mage"

      highlander?(card_info) ->
        :"Highlander Mage"

      "Luna's Pocket Galaxy" in card_info.card_names ->
        :"LPG Mage"

      wild_exodia_mage?(card_info) ->
        :"Exodia Mage"

      questline?(card_info) ->
        :"Questline Mage"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Mage")

      boar?(card_info) ->
        :"Boar Mage"

      baku?(card_info) ->
        :"Odd Mage"

      genn?(card_info) ->
        :"Even Mage"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Mage"

      protoss?(card_info, 4) ->
        :"Protoss Mage"

      hostage_mage?(card_info) ->
        :"Hostage Mage"

      xl?(card_info) and imbue?(card_info, 4) ->
        :"XL Imbue Mage"

      imbue?(card_info, 4) ->
        :"Imbue Mage"

      no_minion?(card_info, 2) ->
        :"Spell Mage"

      "Sif" in card_info.card_names ->
        :"Sif Mage"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Mage"

      wild_bsm_mage?(card_info) ->
        :"Big Spell Mage"

      wild_orb_mage?(card_info) ->
        :"Orb Mage"

      wild_flow?(card_info) ->
        :"Flow Mage"

      wild_fire_mage?(card_info) ->
        :"Fire Mage"

      wild_small_spell_mage?(card_info) ->
        :"Small Spell Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp wild_exodia_mage?(card_info) do
    "The Forbidden Sequence" in card_info.card_names and
      "Archmage Antonidas" in card_info.etc_sideboard_names
  end

  defp wild_small_spell_mage?(card_info) do
    min_count?(card_info, 3, [
      "Mana Wyrm",
      "Flamewaker",
      "Raylla, Sand Sculptor",
      "Vicious Slitherspear",
      "Mantle Shaper"
    ])
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
      "Kalecgos",
      "Deepwater Evoker",
      "Arcane Brilliance",
      "The Galactic Projection Orb",
      "Iceblood Tower"
    ])
  end

  defp wild_fire_mage?(card_info) do
    min_count?(card_info, 3, [
      "Blazing Accretion",
      "Hot Streak",
      "Blasteroid",
      "Supernova",
      "Scorching Winds",
      "Sanctum Chandler"
    ])
  end
end
