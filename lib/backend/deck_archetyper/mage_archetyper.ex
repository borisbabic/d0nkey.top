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

      arcane_mage?(card_info) ->
        :"Arcane Mage"

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

      "Timelooper Toki" in card_info.card_names ->
        :"Toki Mage"

      "Treasure Hunter Eudora" in card_info.card_names ->
        :"Eudora Mage"

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

      wild_big_spell_mage?(card_info) and highlander?(card_info) ->
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

      imbue?(card_info, 4) ->
        :"Imbue Mage"

      no_minion?(card_info, 2) ->
        :"Spell Mage"

      "Sif" in card_info.card_names ->
        :"Sif Mage"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Mage"

      wild_big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      wild_small_spell_mage?(card_info) ->
        :"Small Spell Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp arcane_mage?(card_info) do
    "Azure Queen Sindragosa" in card_info.card_names and
      min_count?(card_info, 2, [
        "Alter Time",
        "Arcane Barrage",
        "Semi-Stable Portal",
        "Primordial Glyph",
        "Stellar Balance",
        "Anomalize",
        "Arcane Intellect"
      ])
  end

  defp wild_exodia_mage?(card_info) do
    "The Forbidden Sequence" in card_info.card_names and
      "Archmage Antonidas" in card_info.etc_sideboard_names
  end

  defp wild_big_spell_mage?(card_info) do
    "Arcane Brilliance" in card_info.card_names
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
    min_count?(card_info, 2, [
      "Ice Block",
      "Grand Magister Rommath"
    ]) and
      ("Potion of Illusion" in card_info.card_names or
         "Potion of Illusion" in card_info.etc_sideboard_names)
  end
end
