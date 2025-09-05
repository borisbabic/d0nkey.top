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
       "Hamuul Runetotem",
       "Dreambound Disciple",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Sing-Along Buddy",
       "Petal Picker",
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

    # 5.5
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
    {:"Token Druid",
     [
       "Vicious Slitherspear",
       "Coconut Cannoneer",
       "Wisp",
       "Nerubian Egg",
       "Fire Fly",
       "Longneck Egg",
       "Power of the Wild",
       "Overheat",
       "Fire Fly",
       "Nerubian Egg"
     ]},
    {:"Owlonius Druid",
     [
       "Sparkling Phial",
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
    {:"Imbue Druid", ["Symbiosis"]},
    # 10.5
    {:"Aviana Druid", ["Wrath", "Horn of Plenty"]},
    {:"Token Druid", ["Ravenous Flock", "Hatchery Helper", "Vibrant Squirrel"]}
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
