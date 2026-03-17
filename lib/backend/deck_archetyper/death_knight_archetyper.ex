# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DeathKnightArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest DK"

      bot?(card_info) ->
        :"Bot? DK"

      handbuff_dk?(card_info) ->
        :"Handbuff DK"

      stego_herenn?(card_info) ->
        :"Stego Herenn DK"

      herenn?(card_info) ->
        :"Herenn DK"

      imbue?(card_info, 7) ->
        :"Imbue DK"

      herald?(card_info) ->
        :"Harold DK"

      rainbow_runes?(card_info) ->
        :"Rainbow DK"

      talanji?(card_info) ->
        :"Talanji DK"

      imbue?(card_info, 4) ->
        :"Imbue DK"

      only_runes?(card_info, :blood) ->
        :"Blood DK"

      only_runes?(card_info, :frost) ->
        :"Frost DK"

      only_runes?(card_info, :unholy) ->
        :"Unholy DK"

      frost?(card_info) ->
        :"\"Frost\" DK"

      dark_gift?(card_info) ->
        :"Dark Gift DK"

      true ->
        fallbacks(card_info, "DK", ignore_types: ["Undead", "undead", "UNDEAD"])
    end
  end

  defp stego_herenn?(card_info) do
    min_count?(card_info, 2, [
      "High Cultist Herenn",
      "Bonechill Stegodon"
    ])
  end

  defp herenn?(card_info) do
    min_count?(card_info, 1, [
      "High Cultist Herenn"
    ])
  end

  defp talanji?(card_info) do
    "Talanji of the Graves" in card_info.card_names and
      min_count?(card_info, 2, [
        "Memoriam Manifest",
        "Wakener of Souls",
        "Endbringer Umbra"
      ])
  end

  defp bot?(card_info) do
    min_count?(card_info, 2, [
      "Stormwind Champion",
      "Life Drinker",
      "Sen'jin Shieldmasta",
      "Dire Wolf Alpha",
      "Annoy-o-Tron",
      "Murloc Tidehunter",
      "Mo'arg Forgefiend"
    ])
  end

  defp dark_gift?(ci) do
    "Frostburn Matriarch" in ci.card_names
  end

  defp frost?(ci) do
    min_count?(ci, 2, ["Horn of Winter", "Marrow Manipulator"])
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
        "City Chief Esho",
        "Amateur Puppeteer",
        "Blood Tap",
        "Toysnatching Geist",
        "Darkfallen Neophyte",
        "Helm of Humiliation",
        "Vicious Bloodworm",
        "Hourglass Attendant",
        "Overlord Runthak",
        "Ram Commander",
        "Encumbered Pack Mule",
        "Saloon Brewmaster"
      ])

  def wild(card_info) do
    class_name = Deck.class_name(card_info.deck)

    cond do
      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest #{class_name}")

      only_runes?(card_info, :blood) and highlander?(card_info) ->
        :"HL Blood DK"

      rainbow_runes?(card_info) and highlander?(card_info) ->
        :"HL Rainbow DK"

      plague?(card_info) and highlander?(card_info) ->
        :"HL Plague DK"

      highlander?(card_info) ->
        String.to_atom("Highlander #{class_name}")

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

      starship?(card_info) ->
        :"Starship DK"

      buttons?(card_info) ->
        :"Buttons DK"

      wild_aggro_dk?(card_info) and plague?(card_info) ->
        :"Aggro Plague DK"

      plague?(card_info) ->
        :"Plague DK"

      wild_aggro_dk?(card_info) ->
        :"Aggro DK"

      only_runes?(card_info, :blood) ->
        :"Blood DK"

      rainbow_runes?(card_info) ->
        :"Rainbow DK"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp plague?(card_info) do
    "Helya" in card_info.card_names and
      min_count?(card_info, 2, [
        "Staff of the Primus",
        "Down with the Ship",
        "Distressed Kvaldir",
        "Tomb Traitor",
        "Chained Guardian"
      ])
  end

  defp wild_aggro_dk?(card_info) do
    min_count?(card_info, 1, [
      "Grave Strength",
      "Anti-Magic Shell",
      "Monstrous Mosquito"
    ])
  end
end
