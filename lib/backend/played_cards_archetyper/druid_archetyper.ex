# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DruidArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Druid", ["Restore the Wild"]},
    {:"Imbue Druid",
     [
       "Dreambound Disciple",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Sing-Along Buddy",
       "Charred Chameleon"
     ]},
    {:"Ownlonius Druid", ["Ownlonius", "Sparkling Phial"]},
    {:"Hydration Druid",
     [
       "Starlight Reactor",
       "Exarch Othaar",
       "The Exodar",
       "Sha'tari Cloakfield",
       "Arkonite Defense Crystal",
       "Greybough"
     ]},
    {:"Aviana Druid",
     [
       "Un'guro Brochure",
       "Reforestation",
       "Raven Idol",
       "Final Frontier",
       "Sky Mother Aviana",
       "Hyration Station",
       "Tortollan Traveller"
     ]},
    {:"Ownlonius Druid",
     [
       "Incindius",
       "Ancient of Yore",
       "Seabreeze Chalice",
       "Magical Dollhouse",
       "Woodland Wonders",
       "Elise the Navigator",
       "Bob the Bartender",
       "Mistah Vistah"
     ]},
    {:"Hydration Druid",
     ["Kil'jaedan", "Carnivorous Cubicle", "Endbringer Umbra", "Blob of Tar", "Marin the Manager"]},
    {:"Imbue Druid", ["Symbiosis", "Hybridization", "Dreamplanner Zephyrs", "Photosynthesis"]},
    {:"Aviana Druid", ["Wrath", "Horn of Plenty", "Astral Phaser", "Trail Mix"]},
    {:"Ownlonius Druid", ["Zilliax Deluxe 3000", "Bottomless Toy Chest", "Swipe"]},
    {:"Hydration Druid", ["Ysera, Emerald Aspect"]},
    {:"Aviana Druid", ["Nightmare Lord Xavius"]},
    {:"Ownlonius Druid",
     ["Amirdrassil", "Sleep Under the Stars", "Story of Barnabus", "New Heights"]},
    {:"Hydration Druid", ["Shaladrassil"]},
    {:"Aviana Druid", ["Arkonite Revelations", "Living Roots"]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Druid")
  end

  def wild(_card_info) do
    nil
  end
end
