# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.DeckArchetyper.HunterArchetyper do
  @moduledoc false
  import Backend.DeckArchetyper.ArchetyperHelpers

  def standard(card_info) do
    cond do
      "The Food Chain" in card_info.card_names ->
        :"Quest Hunter"

      "Battle at the End Time" in card_info.card_names ->
        :"Tick Tock Hunter"

      quest?(card_info) ->
        :"Quest Hunter"

      imbue?(card_info) ->
        :"Imbue Hunter"

      dragon_hunter?(card_info) ->
        :"Dragon Hunter"

      companion?(card_info) ->
        :"Companion Hunter"

      face?(card_info) ->
        :"Face Hunter"

      huffer?(card_info) ->
        :"Huffer Hunter"

      rat_trap?(card_info) ->
        :"Rat Trap Hunter"

      deathrattle?(card_info) ->
        :"Deathrattle Hunter"

      "The Egg of Khelos" in card_info.card_names ->
        :"Egg Hunter"

      bad?(card_info) ->
        :"Bad Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  @face_cards [
    "Precise Shot",
    "Sylvanas's Triumph",
    "Sizzling Cinder",
    "Arcane Shot",
    "Quel'dorei Fletcher",
    "Reinforcement Rallier",
    "Quick Shot",
    "Arrow Retriever",
    "Slumbering Sprite",
    "Rockskipper",
    "Arcane Tripwire"
  ]
  defp face?(card_info) do
    confront_without_caretaker? =
      "Confront the Tol'vir" in card_info.card_names and "Critter Caretaker" not in card_info.card_names

    confront_highest? = "Confront the Tol'vir" in (lowest_highest_cost_cards(card_info, :name) |> elem(1))

    min_count?(card_info.card_names, 6, @face_cards) or
      (confront_without_caretaker? and (min_count?(card_info, 3, @face_cards) or confront_highest?))
  end

  defp rat_trap?(card_info) do
    min_count?(card_info, 3, ["Arcane Tripwire", "R4T-C4TCH3R", "Warmaster Blackhorn"])
  end

  @deathrattle_synergy ["Sewer Swimmer", "Black Market Overseer", "Chrono-Lord Deios", "Endbringer Umbra"]
  defp deathrattle?(card_info) do
    min_keyword_count?(card_info, 6, "deathrattle") and
      min_count?(card_info, 2, @deathrattle_synergy)
  end

  defp huffer?(card_info) do
    min_count?(card_info, 3, [
      "Tayla Earthstrider",
      "Spiritspeaker",
      "Chrono-Lord Deios"
    ])
  end

  defp companion?(card_info) do
    min_count?(card_info, 4, [
      "Tame Pet",
      "Spiritspeaker",
      "Migrating Elekk",
      "Roam Free",
      "Tayla Earthstrider",
      "Animal Companion",
      "Broll Bearmantle",
      "Call of the Wild"
    ])
  end

  defp dragon_hunter?(card_info) do
    min_count?(
      card_info,
      4,
      [
        "Earthen Roar",
        "Stonetalon Striker",
        "Ebonscale Scout",
        "Ebyssian"
      ] ++ neutral_dragon_synergy()
    )
  end

  # defp no_hand?(card_info) do
  #   min_count?(card_info, 2, [
  #     "Arrow Retriever",
  #     "Quel'dorei Fletcher",
  #     "Quick Shot",
  #     "Precise Shot",
  #     "King Maluk"
  #   ])
  # end

  defp bad?(ci) do
    min_count?(ci, 5, [
      "Dire Wolf Alpha",
      "Lifedrinker",
      "Siamat",
      "Savannah Highmane",
      "Ball of Spiders",
      "Dragonbane"
    ])
  end

  def wild(card_info) do
    cond do
      questline?(card_info) and highlander?(card_info) ->
        :"HL Questline Hunter"

      quest?(card_info) and highlander?(card_info) ->
        String.to_atom("HL #{quest_abbreviation_part(card_info)}Quest Hunter")

      "Beastmaster Leoroxx" in card_info.card_names and highlander?(card_info) ->
        :"HL Leoroxx Hunter"

      "Elise the Navigator" in card_info.card_names and highlander?(card_info) ->
        :"HL Elise Hunter"

      highlander?(card_info) ->
        :"Highlander Hunter"

      baku?(card_info) and questline?(card_info) ->
        :"Odd Questline Hunter"

      questline?(card_info) ->
        :"Questline Hunter"

      quest?(card_info) ->
        String.to_atom("#{quest_abbreviation_part(card_info)}Quest Hunter")

      boar?(card_info) ->
        :"Boar Hunter"

      baku?(card_info) ->
        :"Odd Hunter"

      genn?(card_info) ->
        :"Even Hunter"

      "King Togwaggle" in card_info.card_names ->
        :"Tog Hunter"

      "Mecha'thun" in card_info.card_names ->
        :"Mecha'thun Hunter"

      "Beastmaster Leoroxx" in card_info.card_names ->
        :"Leoroxx Hunter"

      midrange?(card_info) ->
        :"Midrange Hunter"

      "Floppy Hydra" in card_info.card_names ->
        :"Floppy Hunter"

      "Adaptive Amalgam" in card_info.card_names ->
        :"Amalgam Hunter"

      min_keyword_count?(card_info, 8, "taunt", unique: false) ->
        :"Taunt Hunter"

      companion?(card_info) ->
        :"Companion Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  defp midrange?(card_info) do
    min_count?(card_info.card_names, 4, [
      "Exarch Naielle",
      "Acidmaw",
      "Dreadscale",
      "Razorscale",
      "Loatheb",
      "Blademaster Okani",
      "Dirty Rat"
    ])
  end
end
