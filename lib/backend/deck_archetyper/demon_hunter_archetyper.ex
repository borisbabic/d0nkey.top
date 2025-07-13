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

      "Arkonite Defense Crystal" in card_info.card_names and deathrattle?(card_info) ->
        :"Armor DH"

      menagerie?(card_info) ->
        :"Menagerie DH"

      pirate?(card_info) ->
        :"Pirate Demon Hunter"

      ravenous_cliff_dive?(card_info) ->
        :"Ravenous Cliff Dive DH"

      "Ball Hog" in card_info.card_names and deathrattle?(card_info) ->
        :"Hog Demon Hunter"

      "Entomologist Toru" in card_info.card_names ->
        :"Toru DH"

      deathrattle?(card_info) ->
        :"Deathrattle DH"

      pain?(card_info) ->
        :"Pain Demon Hunter"

      aggro?(card_info) ->
        :"Aggro Demon Hunter"

      fatigue?(card_info) ->
        :"Fatigue Demon Hunter"

      shopper_dh?(card_info) ->
        :"Shopper DH"

      zerg?(card_info, 4) and attack_dh?(card_info) ->
        :"Zerg Attack DH"

      zerg?(card_info, 4) ->
        :"Zerg DH"

      attack_dh?(card_info) ->
        :"Attack DH"

      menagerie?(card_info) ->
        :"Menagerie DH"

      crewmate?(card_info, 2) ->
        :"Among Us DH"

      cliff_dive?(card_info) ->
        :"Cliff Dive DH"

      dreadseed?(card_info) ->
        :"Dreadseed DH"

      kj?(card_info) ->
        :"Kil'jaeden DH"

      outcast_dh?(card_info) ->
        :"Outcast DH"

      "Alara'shi" in card_info.card_names ->
        :"Alara'shi DH"

      true ->
        fallbacks(card_info, "Demon Hunter")
    end
  end

  defp aggro?(card_info) do
    min_count?(card_info, 3, [
      "Battlefiend",
      "Sock Puppet Slitherspear",
      "Kayn Sunfury",
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
      "Tuskpiercer",
      "Return Policy"
    ])
  end

  @dreadseeds ["Grim Harvest", "Wyvern's Slumber", "Dreadsoul Corrupter"]
  defp dreadseed?(card_info, count \\ 3) do
    min_count?(card_info, count, @dreadseeds)
  end

  defp attack_dh?(ci) do
    min_count?(ci, 5, [
      "Illidari Inquisitor",
      "Sock Puppet Slitherspear",
      "Burning Heart",
      "Battlefiend",
      "Parched Desperado",
      "Spirit of the Team",
      "Going Down Swinging",
      "Chaos Strike",
      "Sing-Along Buddy",
      "Lesser Opal Spellstone",
      "Saronite Shambler",
      "Gan'arg Glaivesmith",
      "Gibbering Reject",
      "Pocket Sand",
      "Rhythmdancer Risa"
    ])
  end

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

  defp fatigue?(ci) do
    "Aranna, Thrill Seeker" in ci.card_names and
      min_count?(ci, 3, [
        "Quick Pick",
        "Paraglide",
        "Sigil of Time",
        "Weight of the World",
        "Rest in Peace"
      ])
  end

  defp shopper_dh?(ci) do
    min_count?(ci, 2, ["Window Shopper", "Umpire's Grasp"])
  end

  defp outcast_dh?(c), do: min_keyword_count?(c, 4, "outcast")

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
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest #{class_name}")

      highlander?(card_info) ->
        :"Highlander DH"

      "Il'gynoth" in card_info.card_names ->
        :"Il'gynoth DH"

      fel_dh?(card_info) && relic_dh?(card_info) ->
        :"Fel Relic DH"

      fel_dh?(card_info) ->
        :"Fel DH"

      wild_fatigue?(card_info) && questline?(card_info) ->
        :"Fatigue Demon Hunter"

      questline?(card_info) ->
        :"Questline DH"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest #{class_name}")

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      baku?(card_info) ->
        String.to_atom("Odd #{class_name}")

      genn?(card_info) ->
        String.to_atom("Even #{class_name}")

      pirate?(card_info) ->
        :"Pirate Demon Hunter"

      outcast_dh?(card_info) ->
        :"Outcast DH"

      relic_dh?(card_info) ->
        :"Relic Demon Hunter"

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      attack_dh?(card_info) ->
        :"Attack DH"

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
