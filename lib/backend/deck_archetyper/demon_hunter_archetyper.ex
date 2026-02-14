# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DemonHunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.DeckArchetyper.PriestArchetyper
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest DH"

      murloc?(card_info) ->
        :"Murloc Demon Hunter"

      no_minion?(card_info) ->
        :"No Minion DH"

      "Arkonite Defense Crystal" in card_info.card_names and deathrattle?(card_info) ->
        :"Armor DH"

      menagerie?(card_info) ->
        :"Menagerie DH"

      pirate?(card_info) ->
        :"Pirate Demon Hunter"

      ravenous_cliff_dive?(card_info) ->
        :"Ravenous Cliff Dive DH"

      aggro?(card_info) ->
        :"Aggro Demon Hunter"

      octosari?(card_info) ->
        :"Octosari DH"

      "Spirit Peddler" in card_info.card_names ->
        :"Peddler DH"

      blobxigar?(card_info) ->
        :"Blobxigar DH"

      "Entomologist Toru" in card_info.card_names ->
        :"Toru DH"

      "Elise the Navigator" in card_info.card_names ->
        :"Elise DH"

      deathrattle?(card_info) ->
        :"Deathrattle DH"

      pain?(card_info) ->
        :"Pain Demon Hunter"

      broxigar?(card_info) ->
        :"Broxigar DH"

      shopper_dh?(card_info) ->
        :"Shopper DH"

      zerg?(card_info, 4) ->
        :"Zerg DH"

      crewmate?(card_info, 2) ->
        :"Among Us DH"

      cliff_dive?(card_info) ->
        :"Cliff Dive DH"

      kj?(card_info) ->
        :"Kil'jaeden DH"

      "Broxigar" in card_info.card_names ->
        :"Broxigar DH"

      "Alara'shi" in card_info.card_names ->
        :"Alara'shi DH"

      true ->
        fallbacks(card_info, "Demon Hunter")
    end
  end

  defp broxigar?(card_info) do
    min_count?(card_info, 2, ["Broxigar", "Youthful Brewmaster"])
  end

  defp blobxigar?(card_info) do
    broxigar?(card_info) and min_count?(card_info, 2, ["Blob of Tar", "Ravenous Felhunter"])
  end

  defp no_minion?(card_info) do
    min_count?(card_info, 2, [
      "Solitude",
      "Lasting Legacy",
      "Hounds of Fury",
      "The Eternal Hold"
    ])
  end

  defp aggro?(card_info) do
    min_count?(card_info, 4, [
      "Battlefiend",
      "Slumbering Sprite",
      "Sock Puppet Slitherspear",
      "Patches the Pilot",
      "King Mukla",
      "Brain Masseuse",
      "Kayn Sunfury",
      "Observer of Mysteries",
      "Spirity of the Team",
      "Acupuncture"
    ])
  end

  @dh_pain_cards ["Infernal Stapler"]
  defp pain?(card_info) do
    PriestArchetyper.pain?(card_info, @dh_pain_cards)
  end

  defp ravenous_cliff_dive?(card_info) do
    cliff_dive?(card_info) and
      min_count?(card_info, 1, ["Ravenous Felhunter"])
  end

  defp cliff_dive?(card_info) do
    "Cliff Dive" in card_info.card_names
  end

  defp deathrattle?(card_info) do
    min_count?(card_info, 3, [
      "Ravenous Felhunter",
      "Ferocious Felbat",
      "Endbringer Umbra",
      "Carnivorous Cubicle",
      "Tuskpiercer",
      "Return Policy"
    ])
  end

  # @dreadseeds ["Grim Harvest", "Wyvern's Slumber", "Dreadsoul Corrupter"]
  # defp dreadseed?(card_info, count \\ 3) do
  #   min_count?(card_info, count, @dreadseeds)
  # end

  defp kj?(ci) do
    "Kil'jaeden" in ci.card_names
  end

  defp crewmate?(ci, min_count) do
    min_count?(ci, min_count, [
      "Voronei Recruiter",
      "Emergency Meeting",
      "Headhunt",
      "Dirdra, Rebel Captain"
    ])
  end

  defp octosari?(ci) do
    min_count?(ci, 2, ["Aranna, Thrill Seeker", "Octosari"])
  end

  defp shopper_dh?(ci) do
    min_count?(ci, 2, ["Window Shopper", "Umpire's Grasp"])
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

  defp fel_dh?(ci) do
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

      fel_dh?(card_info) and relic_dh?(card_info) ->
        :"Fel Relic DH"

      fel_dh?(card_info) ->
        :"Fel DH"

      relic_dh?(card_info) ->
        :"Relic DH"

      "Blindeye Sharpshooter" in card_info.card_names and questline?(card_info) ->
        :"Naga DH"

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
