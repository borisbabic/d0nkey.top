# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.MageArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Mage"

      menagerie?(card_info) ->
        :"Menagerie Mage"

      type_count(card_info, "Elemental") > 6 ->
        :"Elemental Mage"

      imbue?(card_info, 4) ->
        :"Imbue Mage"

      burn_mage?(card_info) ->
        :"Burn Mage"

      arcane_mage?(card_info) ->
        :"Arcane Mage"

      "Timelooper Toki" in card_info.card_names ->
        :"Toki Mage"

      bad?(card_info) ->
        :"Bad Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp burn_mage?(card_info) do
    min_count?(card_info, 4, [
      "Archmage Kalec",
      "Unstable Spellcaster",
      "Sleet Storm",
      "Arcane Flow",
      "Spellweaver's Brilliance",
      "Arcane Barrage"
    ])
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

      wild_big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      orb_hostage_mage?(card_info) ->
        :"Orb Hostage Mage"

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

  defp orb_hostage_mage?(card_info) do
    min_count?(card_info, 3, [
      "Ice Block",
      "Grey Sage Parrot",
      "The Galactic Projection Orb"
    ]) and
      ("Potion of Illusion" in card_info.card_names or
         "Potion of Illusion" in card_info.etc_sideboard_names)
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
