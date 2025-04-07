# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DeathKnightArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      handbuff_dk?(card_info) ->
        :"Handbuff DK"

      menagerie?(card_info) and leech?(card_info, 3) ->
        :"Menagerie Succ DK"

      starship?(card_info) and leech?(card_info, 3) ->
        :"Starship Succ DK"

      leech?(card_info, 3) ->
        :"Succ DK"

      buttons?(card_info) && rainbow_runes?(card_info) ->
        :"Buttons Rainbow DK"

      starship?(card_info) and rainbow_runes?(card_info) ->
        :"Rainbow Starship DK"

      rainbow_runes?(card_info) && zerg?(card_info, 5) ->
        :"Zerg Rainbow DK"

      rainbow_runes?(card_info) ->
        :"Rainbow DK"

      starship?(card_info) ->
        :"Starship DK"

      leech?(card_info, 2) ->
        :"Succ DK"

      menagerie?(card_info) ->
        :"Menagerie DK"

      murloc?(card_info) ->
        :"Murloc DK"

      buttons?(card_info) ->
        :"Buttons DK"

      "Frostbitten Freebooter" in card_info.card_names and deathrattle?(card_info, 2) ->
        :"Frostbitten DK"

      zerg?(card_info, 6) and only_runes?(card_info, :blood) ->
        :"Zerg Blood DK"

      only_runes?(card_info, :blood) ->
        :"Blood DK"

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

      deathrattle?(card_info) ->
        :"Deathrattle DK"

      true ->
        fallbacks(card_info, "DK", ignore_types: ["Undead", "undead", "UNDEAD"])
    end
  end

  defp leech?(ci, min_count) do
    min_count?(ci, min_count, ["Infested Breath", "Sanguine Infestation", "Hideous Husk"])
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

  defp only_runes?(ci, rune, min \\ 1) do
    rune_cost = Deck.rune_cost(ci.cards) |> Map.from_struct()
    {rune_count, others} = Map.pop(rune_cost, rune, 0)
    others_zero? = Enum.all?(others, fn {_key, val} -> val == 0 end)
    rune_count >= min and others_zero?
  end

  defp rainbow_runes?(ci) do
    case Deck.rune_cost(ci.cards) do
      %{blood: b, frost: f, unholy: u} when b > 0 and f > 0 and u > 0 -> true
      _ -> false
    end
  end

  defp handbuff_dk?(c),
    do:
      min_count?(c, 3, [
        "Lesser Spinel Spellstone",
        "Amateur Puppeteer",
        "Blood Tap",
        "Toysnatching Geist",
        "Darkfallen Neophyte",
        "Helm of Humiliation",
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
