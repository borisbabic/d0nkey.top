# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DruidArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      highlander?(card_info) ->
        :"Highlander Druid"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Druid"

      boar?(card_info) ->
        :"Boar Druid"

      vanndar?(card_info) ->
        :"Vanndar Druid"

      fire_druid?(card_info) ->
        :"Fire Druid"

      chad_druid?(card_info) ->
        :"Chad Druid"

      big_druid?(card_info) ->
        :"Big Druid"

      celestial_druid?(card_info) ->
        :"Celestial Druid"

      menagerie?(card_info) ->
        :"Menagerie Druid"

      moonbeam_druid?(card_info) ->
        :"Moonbeam Druid"

      murloc?(card_info) ->
        :"Murloc Druid"

      "Lady Prestor" in card_info.card_names ->
        :"Prestor Druid"

      "Gadgetzan Auctioneer" in card_info.card_names ->
        :"Miracle Druid"

      ignis_druid?(card_info) ->
        :"Ignis Druid"

      "Tony, King of Piracy" in card_info.card_names ->
        :"Tony Druid"

      zok_druid?(card_info) ->
        :"Zok Druid"

      hero_power_druid?(card_info) ->
        :"Hero Power Druid"

      choose_one?(card_info) ->
        :"Choose Druid"

      afk_druid?(card_info) ->
        :"AFK Druid"

      mill_druid?(card_info) ->
        :"Mill Druid"

      owlonius_druid?(card_info) ->
        :"Owlonius Druid"

      tempo_druid?(card_info) ->
        :"Tempo Druid"

      spell_damage_druid?(card_info) ->
        :"Spell Damage Druid"

      ramp_druid?(card_info) && "Death Beetle" in card_info.card_names ->
        :"Beetle Druid"

      "Topior the Shrubbagazzor" in card_info.card_names ->
        :"Topior Druid"

      treant_druid?(card_info) ->
        :"Treant Druid"

      aggro_druid?(card_info) ->
        :"Aggro Druid"

      "Therazane" in card_info.card_names and deathrattle_druid?(card_info) ->
        :"Therazane Druid"

      deathrattle_druid?(card_info) ->
        :"Deathrattle Druid"

      "Drum Circle" in card_info.card_names ->
        :"Drum Druid"

      ramp_druid?(card_info) ->
        :"Ramp Druid"

      greybough?(card_info) ->
        :"Greybough Druid"

      true ->
        fallbacks(card_info, "Druid")
    end
  end

  defp greybough?(card_info) do
    "Greybough" in card_info.card_names and
      match?({_, ["Hydration Station"]}, lowest_highest_cost_cards(card_info))
  end

  @non_owlonius_druid_sd_cards [
    "Magical Dollhouse",
    "Bottomless Toy Chest",
    "Woodland Wonders",
    "Chia Drake",
    "Sparkling Phial" | neutral_spell_damage()
  ]
  defp owlonius_druid?(ci) do
    "Owlonius" in ci.card_names and min_count?(ci, 2, @non_owlonius_druid_sd_cards)
  end

  defp tempo_druid?(ci) do
    min_count?(ci, 4, [
      "Trogg Gemtosser",
      "Marin The Manager",
      "Swipe",
      "Splish-Splash Whelp",
      "Magical Dollhouse",
      "Giftwrapped Whelp",
      "Desert Nestmatron",
      "Doomkin"
    ])
  end

  defp spell_damage_druid?(ci) do
    min_count?(ci, 4, @non_owlonius_druid_sd_cards)
  end

  defp mill_druid?(ci) do
    min_count?(ci, 2, ["Dew Process", "Prince Renathal", "Selfish Shellfish"])
  end

  defp ignis_druid?(ci) do
    min_count?(ci, 2, ["Forbidden Fruit", "Ignis, the Eternal Flame"])
  end

  defp deathrattle_druid?(ci) do
    min_count?(ci, 2, ["Hedge Maze", "Death Blossom Whomper"])
  end

  defp moonbeam_druid?(ci) do
    "Moonbeam" in ci.card_names &&
      min_count?(ci, 2, ["Bloodmage Thalnos", "Kobold Geomancer", "Rainbow Glowscale"])
  end

  defp treant_druid?(ci),
    do:
      min_count?(ci, 2, [
        "Witchwood Apple",
        "Conservator Nymph",
        "Blood Treant",
        "Cultivation",
        "Overgrown Beanstalk"
      ])

  defp afk_druid?(ci),
    do: min_count?(ci, 2, ["Rhythm and Roots", "Timber Tambourine"])

  defp choose_one?(ci),
    do: min_count?(ci, 3, ["Embrace Nature", "Disciple of Eonar"])

  defp zok_druid?(ci),
    do: min_count?(ci, 2, ["Zok Fogsnout", "Anub'Rekhan"])

  defp celestial_druid?(%{card_names: card_names}), do: "Celestial Alignment" in card_names

  defp fire_druid?(ci) do
    min_count?(ci, 2, [
      "Pyrotechnician",
      "Thaddius, Monstrosity"
    ])
  end

  defp chad_druid?(ci) do
    min_count?(ci, 2, [
      "Flesh Behemoth",
      "Thaddius, Monstrosity"
    ])
  end

  defp big_druid?(ci),
    do:
      min_count?(ci, 3, [
        "Sessellie of the Fae Court",
        "Neptulon the Tidehunter",
        "Masked Reveler",
        "Stoneborn General"
      ])

  defp ramp_druid?(ci),
    do:
      min_count?(ci, 1, ["Nourish", "Crystal Cluster"]) or
        min_count?(ci, 2, ["New Heights", "Malfurion's Gift"])

  defp hero_power_druid?(ci),
    do: min_count?(ci, 2, ["Free Spirit", "Groovy Cat", "Sing-Along Buddy"])

  defp aggro_druid?(ci),
    do:
      min_count?(ci, 3, [
        "Herald of Nature",
        "Lingering Zombie",
        "Vicious Slitherspear",
        "Mark of the Wild",
        "Soul of the Forest",
        "Blood Treant",
        "Elder Nadox"
      ])

  defp aviana_druid?(card_info) do
    "Aviana" in card_info.card_names
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

      "Linecracker" in card_info.card_names ->
        :"Linecracker Druid"

      wild_treant_druid?(card_info) ->
        :"Treant Druid"

      wild_mill_druid?(card_info) ->
        :"Mill Druid"

      old_aggro?(card_info) ->
        :"Old Aggro Druid"

      "Mecha'thun" in card_info.card_names ->
        "Mecha'thun #{class_name}"

      aviana_druid?(card_info) ->
        :"Aviana Druid"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp wild_mill_druid?(card_info) do
    min_count?(card_info, 2, ["Dew Process", "Coldlight Oracle", "Naturalize"])
  end

  defp old_aggro?(card_info) do
    min_count?(card_info, 5, [
      "Herald of Nature",
      "Pride's Fury",
      "Irondeep Trogg",
      "Druid of the Reef",
      "Thorngrowth Sentries",
      "Peasant"
    ])
  end

  defp wild_treant_druid?(card_info) do
    min_count?(card_info, 5, [
      "Cultivation",
      "Blood Treant",
      "Aeuroponics",
      "Overgrown Beanstalk",
      "Aerosoilizer",
      "Witchwood Apple",
      "Forest Seedlings",
      "Treenforcements",
      "Sow the Soil",
      "Soul of the Forest",
      "Plot of Sin"
    ])
  end
end
