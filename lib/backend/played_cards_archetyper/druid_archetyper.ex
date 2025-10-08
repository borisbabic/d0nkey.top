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
    {:"Owlonius Druid", ["Owlonius", "Go with the Flow", "Ethereal Oracle", "Sparkling Phial"]},
    {:"Imbue Druid",
     [
       "Hamuul Runetotem",
       "Dreambound Disciple",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Sing-Along Buddy",
       "Petal Picker",
       "Malorne the Waywatcher",
       "Charred Chameleon"
     ]},
    {:"Huddle Up Druid",
     [
       "Huddle Up",
       "Mister Clocksworth",
       "Tsunami",
       "King Tide",
       "Forest Lord Cenarius"
     ]},
    # 5.5
    {:"Hydration Druid",
     [
       "Starlight Reactor",
       "Exarch Othaar",
       "The Exodar",
       "Thickhide Kodo",
       "Seismopod",
       "Ensmallen",
       "Sha'tari Cloakfield",
       "Arkonite Defense Crystal",
       "Greybough",
       "Hydration Station",
       "Endbringer Umbra",
       "Carnivorous Cubicle",
       "Blob of Tar",
       "Tortollan Traveler"
     ]},
    {:"Aviana Druid",
     [
       "Un'Goro Brochure",
       "Reforestation",
       "Raven Idol",
       "Final Frontier",
       "Sky Mother Aviana"
     ]},
    {:"Token Druid",
     [
       "Fire Fly",
       "Longneck Egg",
       "Power of the Wild",
       "Skyscreamer Eggs",
       "Holy Eggbearer",
       "Panther Mask",
       "Mark of the Wild",
       "Bucket of Soldiers",
       "Life Cycle",
       "Hatchery Helper",
       "Ravenous Flock",
       "Vibrant Squirrel",
       "Overheat"
     ]},
    {:"Owlonius Druid",
     [
       "Incindius",
       "Ancient of Yore",
       "Seabreeze Chalice",
       "Magical Dollhouse",
       "Bottomless Toy Chest",
       "Rising Waves",
       "Living Roots",
       "Amirdrassil",
       "Story of Barnabus",
       "New Heights",
       "Swipe",
       "Arkonite Revelation",
       "Innervate",
       "Woodland Wonders",
       "Sleep Under the Stars",
       "Elise the Navigator",
       "Bob the Bartender",
       "Mistah Vistah"
     ]},
    {:"Imbue Druid", ["Symbiosis"]},
    # 10.5
    {:"Aviana Druid", ["Wrath", "Horn of Plenty", "Astral Phaser"]}
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
