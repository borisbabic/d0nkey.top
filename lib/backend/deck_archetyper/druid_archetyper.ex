# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DruidArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Druid"

      imbue_druid?(card_info) ->
        :"Imbue Druid"

      menagerie?(card_info) ->
        :"Menagerie Druid"

      murloc?(card_info) ->
        :"Murloc Druid"

      starship?(card_info) and spell_damage_druid?(card_info) ->
        :"SD Starship Druid"

      spell_damage_druid?(card_info) ->
        :"Spell Damage Druid"

      owlonius_druid?(card_info) ->
        :"Owlonius Druid"

      treant_druid?(card_info) ->
        :"Treant Druid"

      protoss?(card_info, 4) ->
        :"Protoss Druid"

      "Travelmaster Dungar" in card_info.card_names ->
        :"Dungar Druid"

      token?(card_info) ->
        :"Token Druid"

      starship?(card_info) ->
        :"Starship Druid"

      "Hydration Station" in card_info.card_names ->
        :"Hydration Druid"

      greybough?(card_info) ->
        :"Greybough Druid"

      bad?(card_info) ->
        :"Bad Druid"

      "Sky Mother Aviana" in card_info.card_names ->
        :"Aviana Druid"

      true ->
        fallbacks(card_info, "Druid")
    end
  end

  @wide_buff [
    "Power of the Wild",
    "Overheat",
    "Cosmic Phenomenon",
    "A. F. Kay",
    "Hatchery Helper"
  ]
  defp token?(card_info) do
    min_count?(card_info, 2, @wide_buff)
  end

  defp bad?(card_info) do
    min_count?(card_info, 4, [
      "Ysera",
      "Cenarius",
      "Ancient of Lore",
      "Druid of the Claw",
      "Thickhide Kodo",
      "Feral Rage"
    ])
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

  defp spell_damage_druid?(ci) do
    min_count?(ci, 4, @non_owlonius_druid_sd_cards)
  end

  defp treant_druid?(ci),
    do:
      min_count?(ci, 2, [
        "Witchwood Apple",
        "Conservator Nymph",
        "Blood Treant",
        "Grove Shaper",
        "Cultivation",
        "Overgrown Beanstalk"
      ])

  defp imbue_druid?(card_info) do
    "Hamuul Runetotem" in card_info.card_names
  end

  defp aviana_druid?(card_info) do
    "Aviana" in card_info.card_names
  end

  def wild(card_info) do
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Druid"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation(card_info)} Quest Druid")

      wild_dragon_druid?(card_info) and highlander?(card_info) ->
        :"HL Dragon Druid"

      highlander?(card_info) ->
        :"Highlander Druid"

      questline?(card_info) ->
        :"Questline Druid"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation(card_info)} Quest Druid")

      boar?(card_info) ->
        :"Boar Druid"

      baku?(card_info) ->
        :"Odd Druid"

      genn?(card_info) ->
        :"Even Druid"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Druid"

      "Linecracker" in card_info.card_names ->
        :"Linecracker Druid"

      imbue_druid?(card_info) ->
        :"Imbue Druid"

      wild_treant_druid?(card_info) ->
        :"Treant Druid"

      wild_mill_druid?(card_info) ->
        :"Mill Druid"

      wild_mill_otk?(card_info) ->
        :"Mill OTK Druid"

      old_aggro?(card_info) ->
        :"Old Aggro Druid"

      "Astral Communion" in card_info.card_names ->
        :"Astral Communion Druid"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Druid"

      "Celestial Alignment" in card_info.card_names ->
        :"Alignment Druid"

      "Travelmaster Dungar" in card_info.card_names ->
        :"Dungar Druid"

      "Malygos" in card_info.card_names ->
        :"Malygos Druid"

      wild_dragon_druid?(card_info) ->
        :"Dragon Druid"

      aviana_druid?(card_info) ->
        :"Aviana Druid"

      wild_miracle_druid?(card_info) ->
        :"Miracle Druid"

      min_keyword_count?(card_info, 4, "spell-damage") ->
        :"Spell Damage Druid"

      jade_golem?(card_info) ->
        :"Jade Druid"

      wild_taunt_druid?(card_info) ->
        :"Taunt Druid"

      "Star Grazer" in card_info.card_names ->
        :"Star Grazer Druid"

      bad?(card_info) ->
        :"Bad Druid"

      true ->
        fallbacks(card_info, "Druid")
    end
  end

  defp wild_dragon_druid?(card_info) do
    min_count?(card_info, 2, [
      "Breath of Dreams",
      "Splish-Splash Whelp",
      "Desert Nestmatron",
      "Fye, the Setting Sun"
    ])
  end

  defp jade_golem?(card_info) do
    min_count?(card_info, 3, [
      "Jade Idol",
      "Jade Blossom",
      "Jade Spirit",
      "Jade Behemoth",
      "Aya Blackpaw"
    ])
  end

  defp wild_mill_druid?(card_info) do
    min_count?(card_info, 2, ["Dew Process", "Coldlight Oracle", "Naturalize"])
  end

  defp wild_mill_otk?(card_info) do
    min_count?(card_info, 2, ["Grove Shaper", "Naturalize"])
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

  defp wild_miracle_druid?(card_info) do
    min_count?(card_info, 1, [
      "Gadgetzan Auctioneer",
      "Ysiel Windsinger"
    ])
  end

  defp wild_taunt_druid?(card_info) do
    min_count?(card_info, 2, ["Hadronox", "Hydration Station"])
  end
end
