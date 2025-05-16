# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.DruidArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers
  alias Backend.Hearthstone.Deck

  def standard(card_info) do
    cond do
      imbue_druid?(card_info) ->
        :"Imbue Druid"

      menagerie?(card_info) ->
        :"Menagerie Druid"

      murloc?(card_info) ->
        :"Murloc Druid"

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

  @wide_buff ["Power of the Wild", "Overheat", "Cosmic Phenomenon", "A. F. Kay"]
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

      wild_mill_OTK?(card_info) ->
        :"Mill OTK Druid"

      old_aggro?(card_info) ->
        :"Old Aggro Druid"

      imbue_druid?(card_info) ->
        :"Imbue Druid"

      "Astral Communion" in card_info.card_names ->
        :"Astral Communion Druid"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Druid"

      "Travelmaster Dungar" in card_info.card_names ->
        :"Dungar Druid"

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
        fallbacks(card_info, class_name)
    end
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

  defp wild_mill_OTK?(card_info) do
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
