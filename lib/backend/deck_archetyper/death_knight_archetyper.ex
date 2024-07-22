# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DeathKnightArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander DK"

      burn_dk?(card_info) ->
        :"Burn DK"

      handbuff_dk?(card_info) ->
        :"Handbuff DK"

      rainbow_dk?(card_info) && plague_dk?(card_info) ->
        :"Rainbow Plague DK"

      rainbow_dk?(card_info) && excavate_dk?(card_info) ->
        :"Rainbow Excavate DK"

      rainbow_dk?(card_info) ->
        :"Rainbow DK"

      plague_dk?(card_info) ->
        :"Plague DK"

      excavate_dk?(card_info) ->
        :"Excavate DK"

      aggro_dk?(card_info) ->
        :"Aggro DK"

      menagerie?(card_info) ->
        :"Menagerie DK"

      boar?(card_info) ->
        :"Boar DK"

      quest?(card_info) || questline?(card_info) ->
        :"Quest DK"

      murloc?(card_info) ->
        :"Murloc DK"

      control_dk?(card_info) ->
        :"Control DK"

      true ->
        fallbacks(card_info, "DK", ignore_types: ["Undead", "undead", "UNDEAD"])
    end
  end

  def rainbow_dk?(ci) do
    case Deck.rune_cost(ci.cards) do
      %{blood: b, frost: f, unholy: u} when b > 0 and f > 0 and u > 0 -> true
      _ -> false
    end
  end

  def excavate_dk?(ci) do
    min_count?(ci, 4, [
      "Pile of Bones",
      "Reap What You Sow",
      "Skeleton Crew",
      "Harrowing Ox" | neutral_excavate()
    ])
  end

  def plague_dk?(ci),
    do:
      min_count?(ci, 3, [
        "Staff of the Primus",
        "Distressed Kvaldir",
        "Down with the Ship",
        "Helya",
        "Tomb Traitor",
        "Chained Guardian"
      ])

  def burn_dk?(c),
    do: min_count?(c, 2, ["Bloodmage Thalnos", "Talented Arcanist", "Guild Trader"])

  def aggro_dk?(c),
    do:
      min_count?(c, 4, [
        "Body Bagger",
        "Hawkstrider Rancher",
        "Irondeep Trogg",
        "Incorporeal Corporal",
        "Peasant"
      ])

  def control_dk?(c) do
    min_count?(c, 2, ["Corpse Explosion", "Soulstealer"])
  end

  def handbuff_dk?(c),
    do:
      min_count?(c, 3, [
        "Lesser Spinel Spellstone",
        "Amateur Puppeteer",
        "Blood Tap",
        "Toysnatching Geist",
        "Darkfallen Neophyte",
        "Vicious Bloodworm",
        "Overlord Runthak",
        "Ram Commander",
        "Encumbered Pack Mule",
        "Saloon Brewmaster"
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

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      true ->
        fallbacks(card_info, class_name)
    end
  end
end
