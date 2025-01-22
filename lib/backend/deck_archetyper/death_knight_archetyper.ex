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

      rainbow_runes?(card_info) && plague_dk?(card_info) ->
        :"Rainbow Plague DK"

      rainbow_runes?(card_info) && excavate_dk?(card_info) ->
        :"Rainbow Excavate DK"

      buttons?(card_info) && rainbow_runes?(card_info) ->
        :"Buttons Rainbow DK"

      starship?(card_info) and rainbow_runes?(card_info) ->
        :"Rainbow Starship DK"

      rainbow_runes?(card_info) && zerg?(card_info, 5) ->
        :"Zerg Rainbow DK"

      rainbow_runes?(card_info) ->
        :"Rainbow DK"

      starship?(card_info) and plague_dk?(card_info) ->
        :"Starship Plague DK"

      plague_dk?(card_info) ->
        :"Plague DK"

      excavate_dk?(card_info) ->
        :"Excavate DK"

      starship?(card_info) ->
        :"Starship DK"

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

      buttons?(card_info) ->
        :"Buttons DK"

      "Frostbitten Freebooter" in card_info.card_names and deathrattle?(card_info, 2) ->
        :"Frostbitten DK"

      deathrattle?(card_info) ->
        :"Deathrattle DK"

      zerg?(card_info, 6) and only_runes?(card_info, :blood) ->
        :"Zerg Blood DK"

      only_runes?(card_info, :blood) ->
        :"Blood DK"

      zerg?(card_info, 6) and only_runes?(card_info, :frost) ->
        :"Zerg Frost DK"

      zerg?(card_info, 6) and only_runes?(card_info, :frost) ->
        :"Zerg Frost DK"

      only_runes?(card_info, :frost) ->
        :"Frost DK"

      zerg?(card_info, 6) and only_runes?(card_info, :unholy) ->
        :"Zerg Unholy DK"

      only_runes?(card_info, :unholy) ->
        :"Unholy DK"

      zerg?(card_info, 6) and "Stitched Giant" in card_info.card_names ->
        :"Zerg Corpse DK"

      "Stitched Giant" in card_info.card_names ->
        :"Corpse DK"

      zerg?(card_info, 6) and fake_frost?(card_info) ->
        :"Zerg \"Frost\" DK"

      fake_frost?(card_info) ->
        :"\"Frost\" DK"

      true ->
        fallbacks(card_info, "DK", ignore_types: ["Undead", "undead", "UNDEAD"])
    end
  end

  defp fake_frost?(ci) do
    case Deck.rune_cost(ci.cards) do
      %{frost: 2} -> true
      _ -> false
    end
  end

  defp buttons?(ci) do
    "Buttons" in ci.card_names and
      min_count?(ci, 2, [
        "Razzle-Dazzler",
        "Natural Talent",
        "Malted Magma",
        "Cabaret Headliner",
        "Siren Song",
        "Carress, Cabaret Star"
      ])
  end

  defp deathrattle?(ci, min_count \\ 3) do
    min_count?(ci, min_count, [
      "Death Growl",
      "Brittlebone Buccaneer",
      "Dead Air",
      "Eternal Layover",
      "Yelling Yodeler"
    ])
  end

  def only_runes?(ci, rune, min \\ 1) do
    rune_cost = Deck.rune_cost(ci.cards) |> Map.from_struct()
    {rune_count, others} = Map.pop(rune_cost, rune, 0)
    others_zero? = Enum.all?(others, fn {_key, val} -> val == 0 end)
    rune_count >= min and others_zero?
  end

  def rainbow_runes?(ci) do
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
