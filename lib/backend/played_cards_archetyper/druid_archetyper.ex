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
  @wild_config [
    {:"Astral Communion Druid",
     [
       "Deathwing the Destroyer",
       "Astral Communion",
       "Factory Assemblybot",
       "Harth Stonebrew",
       "Ysera the Dreamer",
       "Avatar of Hearthstone",
       "Carrier",
       "Forest Lord Cenarius",
       "Magatha, Bane of Music"
     ]},
    {:"Mill Druid",
     [
       "Selfish Shellfish",
       "Coldlight Oracle",
       "Dew Process"
     ]},
    {:"Barnes Druid",
     [
       "Barnes",
       "Starfire",
       "Magical Dollhouse",
       "Funnel Cake"
     ]},
    {:"OTK Druid",
     [
       "Malygos",
       "Moonbeam",
       "Travelmaster Dungar",
       "Champions of Azeroth"
     ]},
    {:"Egg Druid",
     [
       "The Egg of Khelos",
       "The Egg of Khelos",
       "Spiritsinger Umbra",
       "Power of the Wild",
       "Savage Roar"
     ]},
    # 5.5
    {:"Mecha'thun Druid",
     [
       "Mecha'thun",
       "Lady Anacondra"
     ]},
    {:"Therazane Druid",
     [
       "Therazane",
       "Stone Drake",
       "Bouldering Buddy",
       "Death Blossom Whomper",
       "Hydration Station"
     ]},
    {:"Highlander Druid",
     [
       "Zephrys the Great",
       "Razorscale",
       "Rheastrasza",
       "Mutanus the Devourer",
       "Alexstrasza",
       "Reno, Lone Ranger",
       "Juicy Psychmelon",
       "Loatheb",
       "Dirty Rat",
       "Trogg Gemtosser",
       "Widowbloom Seedsman",
       "Seabreeze Chalice",
       "Astalor Bloodsworn",
       "Reno Jackson"
     ]},
    {:"Astral Communion Druid",
     [
       "Death Beetle"
     ]},
    {:"Mill Druid",
     [
       "Sleepy Resident",
       "Rising Waves",
       "Branching Paths"
     ]},
    # 10.5
    {:"Treant Druid",
     [
       "Aeroponics",
       "Cultivation",
       "Blood Treant",
       "Treenforcements",
       "Overgrown Beanstalk",
       "Umbral Owl"
     ]},
    {:"OTK Druid",
     [
       "Aviana"
     ]},
    {:"Boar OTK Druid",
     [
       "Stormpike Quartermaster",
       "Stonetusk Boar",
       "Oracle of Elune"
     ]},
    {:"Therazane Druid",
     [
       "Tar Slime",
       "Imposing Anubisath",
       "Fire Fly",
       "Acolyte of Pain",
       "Tar Creeper",
       "Far Watch Post",
       "Evergreen Stag"
     ]},
    {:"Old Aggro Druid",
     [
       "Pride's Fury",
       "Beaming Sidekick",
       "Crooked Cook",
       "Vicious Slitherspear",
       "Herald of Nature",
       "Peasant"
     ]},
    # 15.5
    {:"Linecracker Druid",
     [
       "Gadgetzan Auctioneer",
       "Earthen Scales",
       "Linecracker",
       "Moonfire",
       "BEEEES!!!"
     ]},
    {:"Mecha'thun Druid",
     [
       "Celestial Alignment"
     ]},
    {:"OTK Druid",
     [
       "Ultimate Infestation",
       "Nightshade Bud"
     ]},
    {:"Imbue Druid",
     [
       "Dreambound Disciple",
       "Charred Chameleon",
       "Bitterbloom Knight",
       "Sing-Along Buddy",
       "Malorne the Waywatcher",
       "Petal Picker",
       "Flutterwing Guardian",
       "Resplendent Dreamweaver"
     ]},
    {:"Astral Communion Druid",
     [
       "Marin the Manager",
       "Innervate",
       "Yogg-Saron, Unleashed",
       "Reforestation",
       "Fyrakk the Blazing"
     ]},
    # 20.5
    {:"Mill Druid",
     [
       "Mistah Vistah"
     ]},
    {:"Barnes Druid",
     [
       "Capture Coldtooth Mine"
     ]},
    {:"OTK Druid",
     [
       "Overflow",
       "Ysiel Windsinger",
       "Sleep under the Stars",
       "Malfurion's Gift",
       "Overgrowth",
       "Wild Growth"
     ]},
    {:"Mill Druid",
     [
       "Theotar, the Mad Duke"
     ]},
    {:"Egg Druid",
     [
       "Story of Barnabus"
     ]},
    # 25.5
    {:"Mecha'thun Druid",
     [
       "Trail Mix",
       "Lifebinder's Gift"
     ]},
    {:"Astral Communion Druid",
     [
       "Arkonite Revelation"
     ]},
    {:"Barnes Druid",
     [
       "Swipe"
     ]},
    {:"Mill Druid",
     [
       "Naturalize",
       "Poison Seeds",
       "Sir Finley, Sea Guide",
       "Bob the Bartender",
       "Frost Lotus Seedling",
       "Spreading Plague"
     ]},
    {:"Barnes Druid",
     [
       "Bottomless Toy Chest",
       "Biology Project",
       "Solar Eclipse",
       "Pendant of Earth"
     ]},
    # 30.5
    {:"Astral Communion Druid",
     [
       "E.T.C., Band Manager",
       "Bottomless Toy Chest",
       "Aquatic Form"
     ]},
    {:"OTK Druid",
     [
       "Nourish",
       "New Heights"
     ]},
    {:"Highlander Druid", ["Prince Renethal"]}
  ]

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Druid")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other Druid")
  end
end
