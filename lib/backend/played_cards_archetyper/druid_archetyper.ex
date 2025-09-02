# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DruidArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Druid", ["Restore the Wild"]},
    {:"Whizbang Druid",
     [
       "Yogg-Saron, Master of Fate",
       "Wild Growth",
       "Convoke the Spirits",
       "Ultimate Infestation",
       "Overgrowth",
       "Kun the Forgotten King",
       "Nourish",
       "Invigorate",
       "Moment of Discovery",
       "Crystal Cluster",
       "Eonar, the Life-Binder"
     ]},
    {:"Imbue Druid",
     [
       "Dreambound Disciple",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Sing-Along Buddy",
       "Charred Chameleon"
     ]},
    {:"Owlonius Druid", ["Owlonius", "Go with the Flow", "Ethereal Oracle"]},
    {:"Aviana Druid",
     [
       "Un'Goro Brochure",
       "Reforestation",
       "Raven Idol",
       "Final Frontier",
       "Sky Mother Aviana"
     ]},

    # {:"Owlonius Druid", ["Owlonius", "Sparkling Phial"]},
    {:"Hydration Druid",
     [
       "Starlight Reactor",
       "Exarch Othaar",
       "The Exodar",
       "Sha'tari Cloakfield",
       "Arkonite Defense Crystal",
       "Greybough",
       "Hydration Station",
       "Tortollan Traveller"
     ]},
    {:"Owlonius Druid",
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
    {:"Owlonius Druid", ["Zilliax Deluxe 3000", "Bottomless Toy Chest", "Swipe"]},
    {:"Hydration Druid", ["Ysera, Emerald Aspect"]},
    {:"Aviana Druid", ["Nightmare Lord Xavius"]},
    {:"Owlonius Druid",
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
