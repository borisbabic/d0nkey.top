# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DemonHunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest DH"

      no_minion?(card_info) ->
        :"No Minion DH"

      fel_dh?(card_info) ->
        :"Fel DH"

      herald?(card_info) ->
        :"Harold DH"

      "Entomologist Toru" in card_info.card_names ->
        :"Toru DH"

      "Elise the Navigator" in card_info.card_names ->
        :"Elise DH"

      broxigar?(card_info) ->
        :"Broxigar DH"

      zerg?(card_info, 4) ->
        :"Zerg DH"

      "Broxigar" in card_info.card_names ->
        :"Broxigar DH"

      "Alara'shi" in card_info.card_names ->
        :"Alara'shi DH"

      true ->
        fallbacks(card_info, "DH")
    end
  end

  defp fel_dh?(card_info) do
    min_count?(card_info, 2, [
      "Nespirah, Enthralled",
      "Ravenous Felfisher",
      "Malevolent Mutant",
      "Scorchreaver"
    ])
  end

  defp broxigar?(card_info) do
    min_count?(card_info, 2, ["Broxigar", "Youthful Brewmaster"])
  end

  defp no_minion?(card_info) do
    min_count?(card_info, 2, [
      "Solitude",
      "Lasting Legacy",
      "Hounds of Fury",
      "The Eternal Hold"
    ])
  end

  defp relic_dh?(ci) do
    min_count?(ci, 4, [
      "Relic of Extinction",
      "Relic Vault",
      "Relic of Phantasms",
      "Relic of Dimensions",
      "Artificer Xy'mox"
    ])
  end

  defp wild_fel_dh?(ci) do
    min_spell_school_count?(ci, 5, "fel") and
      min_count?(ci, 1, [
        "Fossil Fanatic",
        "Jace Darkweaver",
        "Felgorger"
      ])
  end

  def wild(card_info) do
    class_name = Deck.class_name(card_info.deck)

    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline DH"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest DH")

      highlander?(card_info) ->
        :"Highlander DH"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest DH")

      baku?(card_info) ->
        :"Odd DH"

      genn?(card_info) ->
        :"Even DH"

      "King Togwaggle" in card_info.card_names ->
        :"Tog DH"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun DH"

      boar?(card_info) ->
        :"Boar DH"

      "Il'gynoth" in card_info.card_names ->
        :"Il'gynoth DH"

      wild_fel_dh?(card_info) and relic_dh?(card_info) ->
        :"Fel Relic DH"

      wild_fel_dh?(card_info) ->
        :"Fel DH"

      relic_dh?(card_info) ->
        :"Relic DH"

      "Blindeye Sharpshooter" in card_info.card_names and questline?(card_info) ->
        :"Naga DH"

      wild_token_brox?(card_info) and questline?(card_info) ->
        :"Token Broxigar DH"

      "Broxigar" in card_info.card_names and questline?(card_info) ->
        :"Broxigar DH"

      wild_fatigue?(card_info) and questline?(card_info) ->
        :"Fatigue DH"

      questline?(card_info) ->
        :"Questline DH"

      pirate?(card_info) ->
        :"Pirate DH"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp wild_token_brox?(card_info) do
    min_count?(card_info, 2, [
      "Broxigar",
      "Broxigar's Last Stand"
    ])
  end

  def pirate?(card_info) do
    min_count?(card_info, 4, [
      "Patches the Pilot",
      "Patches the Pirate",
      "Space Pirate",
      "Treasure Distributor",
      "Adrenaline Fiend",
      "Sigil of Skydiving",
      "Ship's Cannon",
      "Parachute Brigand",
      "Hozen Roughhouser",
      "Dangerous Cliffside"
    ])
  end

  def wild_fatigue?(card_info) do
    min_count?(card_info, 2, [
      "Aranna, Thrill Seeker",
      "Glaivetar"
    ])
  end
end
