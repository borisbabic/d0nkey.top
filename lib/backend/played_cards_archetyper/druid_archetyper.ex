# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DruidArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Druid", ["Restore the Wild"]},
    {:"Imbue Druid",
     [
       "Hamuul Runetotem",
       "Dreambound Disciple",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Resplendent Dreamweaver",
       "Malorne the Waywatcher",
       "Petal Picker",
       "Charred Chameleon"
     ]},
    {:"Token Druid",
     [
       "Overheat",
       "Platysaur",
       "Power of the Wild",
       "Longneck Egg",
       "Holy Eggbearer",
       "Ravenous Flock",
       "Vibrant Squirrel",
       "Ancient Raptor",
       "Panther Mask"
     ]},
    {:"Imbue Druid",
     {[
        "Symbiosis"
      ],
      [
        "Merithra",
        "Darkscale Broodmother",
        "Broodwatcher",
        "Carrier Whelp",
        "Elise the Navigator"
      ]}},
    {:"Merithra Druid",
     [
       "Merithra of the Dream",
       "Fyrakk the Blazing",
       "Naralex, Herald of Flights",
       "Elise the Navigator"
     ]},
    # 5.5
    {:"Imbue Druid", ["Horn of Plenty", "Photosynthesis"]},
    {:"Token Druid", ["Twilight Egg"]},
    {:"Merithra Druid",
     ["Ebb and Flow", "Whelp of the Infinite", "Azshara's Triumph", "Nightmare Lord Xavius"]},
    {:"Imbue Druid", ["Mark of the Wild", "Forest's Gift", "Living Roots", "Crystalspine Cub"]},
    {:"Merithra Druid", ["Darkscale Broodmother", "Broodwatcher", "Carrier Whelp"]},
    # 10.5
    {:"Krona Druid",
     [
       "Chrono-Lord Deios",
       "Endbringer Umbra",
       "Glacial Shard",
       "Wrath"
     ]},
    {:"Merithra Druid",
     [
       "Story of Barnabus",
       "Krona, Keeper of Eons",
       "Acceleration Aura",
       "Contigency",
       "Twilight Timereaver",
       "Underking"
     ]},
    {:"Imbue Druid",
     [
       "Felwood Treant",
       "Innervate",
       "Hatchery Helper",
       "Wickerfang",
       "Waveshaping"
     ]}
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

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Druid")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other Druid")
  end
end
