# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DruidArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Druid"

      any?(card_info, [
        "Dreambound Disciple",
        "Bitterbloom Knight",
        "Flutterwing Guardian",
        "Sing-Along Buddy",
        "Charred Chameleon"
      ]) ->
        :"Imbue Druid"

      any?(card_info, ["Ownlonius", "Sparkling Phial"]) ->
        :"Ownlonius Druid"

      any?(card_info, [
        "Starlight Reactor",
        "Exarch Othaar",
        "The Exodar",
        "Sha'tari Cloakfield",
        "Arkonite Defense Crystal",
        "Greybough"
      ]) ->
        :"Hydration Druid"

      any?(card_info, [
        "Un'guro Brochure",
        "Reforestation",
        "Raven Idol",
        "Final Frontier",
        "Sky Mother Aviana",
        "Hyration Station",
        "Tortollan Traveller"
      ]) ->
        :"Aviana Druid"

      any?(card_info, [
        "Incindius",
        "Ancient of Yore",
        "Seabreeze Chalice",
        "Magical Dollhouse",
        "Woodland Wonders",
        "Elise the Navigator",
        "Bob the Bartender",
        "Mistah Vistah"
      ]) ->
        :"Ownlonius Druid"

      any?(card_info, [
        "Kil'jaedan",
        "Carnivorous Cubicle",
        "Endbringer Umbra",
        "Blob of Tar",
        "Marin the Manager"
      ]) ->
        :"Hydration Druid"

      any?(card_info, ["Symbiosis", "Hybridization", "Dreamplanner Zephyrs", "Photosynthesis"]) ->
        :"Imbue Druid"

      any?(card_info, ["Wrath", "Horn of Plenty", "Astral Phaser", "Trail Mix"]) ->
        :"Aviana Druid"

      any?(card_info, ["Zilliax Deluxe 3000", "Bottomless Toy Chest", "Swipe"]) ->
        :"Ownlonius Druid"

      any?(card_info, ["Ysera, Emerald Aspect"]) ->
        :"Hydration Druid"

      any?(card_info, ["Nightmare Lord Xavius"]) ->
        :"Aviana Druid"

      any?(card_info, ["Amirdrassil", "Sleep Under the Stars", "Story of Barnabus", "New Heights"]) ->
        :"Ownlonius Druid"

      any?(card_info, ["Shaladrassil"]) ->
        :"Hydration Druid"

      any?(card_info, ["Arkonite Revelations", "Living Roots"]) ->
        :"Aviana Druid"

      true ->
        :"Other Druid"
    end
  end

  def wild(_card_info) do
    nil
  end
end
