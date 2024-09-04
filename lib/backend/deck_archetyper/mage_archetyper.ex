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

      big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      no_minion?(card_info, 2) ->
        :"Spell Mage"

      murloc?(card_info) ->
        :"Murloc Mage"

      lightshow? ->
        :"Lightshow Mage"

      "The Galactic Projection Orb" in card_info.card_names ->
        :"Orb Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp excavate_mage?(ci) do
    min_count?(ci, 3, [
      "Cryopreservation",
      "Reliquary Researcher",
      "Blastmage Miner" | neutral_excavate()
    ])
  end

  def rainbow_mage?(ci),
    do:
      min_count?(ci, 3, [
        "Discovery of Magic",
        "Inquisitive Creation",
        "Wisdom of Norgannon",
        "Sif",
        "Elemental Inspiration"
      ])

  defp big_spell_mage?(ci) do
    min_count?(ci, 2, ["Surfalopod", "King Tide"])
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
end
