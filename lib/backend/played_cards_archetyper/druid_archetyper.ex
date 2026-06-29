# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DruidArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Druid": ["Restore the Wild"],
    "Imbue Druid": [
      "Bitterbloom Knight",
      "Charred Chameleon",
      "Dreambound Disciple",
      "Flutterwing Guardian",
      "Hamuul Runetotem",
      "Malorne the Waywatcher",
      "Petal Picker",
      "Resplendent Dreamweaver"
    ],
    "Merithra Druid": ["Merithra of the Dream"],
    "Hostage Druid": ["Dark Iron Harbinger", "Grove Shaper"],
    "Token Druid": ["Forest's Gift", "Hatchery Helper", "Overheat", "Platysaur", "Twilight Egg"],
    "Merithra Druid": ["Darkscale Broodmother"],
    "Hostage Druid": ["Tindral Sageswift"],
    "Krona Druid": ["Disciple of Demise"],
    "Azshara Druid": ["Welcome Home!"],
    "Krona Druid": ["Plated Beetle"],
    "Hostage Druid": ["Mo'arg Forgefiend"],
    "Merithra Druid": ["Broodwatcher", "Fyrakk the Blazing"],
    "Hostage Druid": ["Hopeful Dryad", "Longneck Egg"],
    "Krona Druid": ["Krona, Keeper of Eons"],
    "Azshara Druid": ["Briarspawn Drake", "Lady Azshara", "The Well of Eternity", "Zin-Azshari", "Zin-Azshari"],
    "Merithra Druid": ["Vanessa the Ringleader", "Wickerfang"],
    "Hostage Druid": ["Glacial Shard", "Shaladrassil"],
    "Deios Druid": ["Omen of the End"],
    "Hostage Druid": [
      "Chrono-Lord Deios",
      "Endbringer Umbra",
      "Heartroot Stones",
      "Naralex, Herald of the Flights",
      "Underking"
    ],
    "Merithra Druid": [
      "Bashana Runetotem",
      "Ebb and Flow",
      "Elise the Navigator",
      "Evergreen Stag",
      "Horn of Plenty",
      "Nightmare Lord Xavius"
    ],
    "Krona Druid": ["Prize Vendor"],
    "Merithra Druid": [
      "Acceleration Aura",
      "Amirdrassil",
      "Felwood Treant",
      "Innervate",
      "Press the Advantage",
      "Waveshaping"
    ]
  ]
  @wild_config []
  # @wild_config [
  #   {:"Astral Communion Druid",
  #    [
  #      "Deathwing the Destroyer",
  #      "Astral Communion",
  #      "Factory Assemblybot",
  #      "Harth Stonebrew",
  #      "Ysera the Dreamer",
  #      "Avatar of Hearthstone",
  #      "Carrier",
  #      "Forest Lord Cenarius",
  #      "Magatha, Bane of Music"
  #    ]},
  #   {:"Mill Druid",
  #    [
  #      "Selfish Shellfish",
  #      "Coldlight Oracle",
  #      "Dew Process"
  #    ]},
  #   {:"Barnes Druid",
  #    [
  #      "Barnes",
  #      "Starfire",
  #      "Magical Dollhouse",
  #      "Funnel Cake"
  #    ]},
  #   {:"OTK Druid",
  #    [
  #      "Malygos",
  #      "Moonbeam",
  #      "Travelmaster Dungar",
  #      "Champions of Azeroth"
  #    ]},
  #   {:"Egg Druid",
  #    [
  #      "The Egg of Khelos",
  #      "The Egg of Khelos",
  #      "Spiritsinger Umbra",
  #      "Power of the Wild",
  #      "Savage Roar"
  #    ]},
  #   # 5.5
  #   {:"Mecha'thun Druid",
  #    [
  #      "Mecha'thun",
  #      "Lady Anacondra"
  #    ]},
  #   {:"Therazane Druid",
  #    [
  #      "Therazane",
  #      "Stone Drake",
  #      "Bouldering Buddy",
  #      "Death Blossom Whomper",
  #      "Hydration Station"
  #    ]},
  #   {:"Highlander Druid",
  #    [
  #      "Zephrys the Great",
  #      "Razorscale",
  #      "Rheastrasza",
  #      "Mutanus the Devourer",
  #      "Alexstrasza",
  #      "Reno, Lone Ranger",
  #      "Juicy Psychmelon",
  #      "Loatheb",
  #      "Dirty Rat",
  #      "Trogg Gemtosser",
  #      "Widowbloom Seedsman",
  #      "Seabreeze Chalice",
  #      "Astalor Bloodsworn",
  #      "Reno Jackson"
  #    ]},
  #   {:"Astral Communion Druid",
  #    [
  #      "Death Beetle"
  #    ]},
  #   {:"Mill Druid",
  #    [
  #      "Sleepy Resident",
  #      "Rising Waves",
  #      "Branching Paths"
  #    ]},
  #   # 10.5
  #   {:"Treant Druid",
  #    [
  #      "Aeroponics",
  #      "Cultivation",
  #      "Blood Treant",
  #      "Treenforcements",
  #      "Overgrown Beanstalk",
  #      "Umbral Owl"
  #    ]},
  #   {:"OTK Druid",
  #    [
  #      "Aviana"
  #    ]},
  #   {:"Boar OTK Druid",
  #    [
  #      "Stormpike Quartermaster",
  #      "Stonetusk Boar",
  #      "Oracle of Elune"
  #    ]},
  #   {:"Therazane Druid",
  #    [
  #      "Tar Slime",
  #      "Imposing Anubisath",
  #      "Fire Fly",
  #      "Acolyte of Pain",
  #      "Tar Creeper",
  #      "Far Watch Post",
  #      "Evergreen Stag"
  #    ]},
  #   {:"Old Aggro Druid",
  #    [
  #      "Pride's Fury",
  #      "Beaming Sidekick",
  #      "Crooked Cook",
  #      "Vicious Slitherspear",
  #      "Herald of Nature",
  #      "Peasant"
  #    ]},
  #   # 15.5
  #   {:"Linecracker Druid",
  #    [
  #      "Gadgetzan Auctioneer",
  #      "Earthen Scales",
  #      "Linecracker",
  #      "Moonfire",
  #      "BEEEES!!!"
  #    ]},
  #   {:"Mecha'thun Druid",
  #    [
  #      "Celestial Alignment"
  #    ]},
  #   {:"OTK Druid",
  #    [
  #      "Ultimate Infestation",
  #      "Nightshade Bud"
  #    ]},
  #   {:"Imbue Druid",
  #    [
  #      "Dreambound Disciple",
  #      "Charred Chameleon",
  #      "Bitterbloom Knight",
  #      "Sing-Along Buddy",
  #      "Malorne the Waywatcher",
  #      "Petal Picker",
  #      "Flutterwing Guardian",
  #      "Resplendent Dreamweaver"
  #    ]},
  #   {:"Astral Communion Druid",
  #    [
  #      "Marin the Manager",
  #      "Innervate",
  #      "Yogg-Saron, Unleashed",
  #      "Reforestation",
  #      "Fyrakk the Blazing"
  #    ]},
  #   # 20.5
  #   {:"Mill Druid",
  #    [
  #      "Mistah Vistah"
  #    ]},
  #   {:"Barnes Druid",
  #    [
  #      "Capture Coldtooth Mine"
  #    ]},
  #   {:"OTK Druid",
  #    [
  #      "Overflow",
  #      "Ysiel Windsinger",
  #      "Sleep under the Stars",
  #      "Malfurion's Gift",
  #      "Overgrowth",
  #      "Wild Growth"
  #    ]},
  #   {:"Mill Druid",
  #    [
  #      "Theotar, the Mad Duke"
  #    ]},
  #   {:"Egg Druid",
  #    [
  #      "Story of Barnabus"
  #    ]},
  #   # 25.5
  #   {:"Mecha'thun Druid",
  #    [
  #      "Trail Mix",
  #      "Lifebinder's Gift"
  #    ]},
  #   {:"Astral Communion Druid",
  #    [
  #      "Arkonite Revelation"
  #    ]},
  #   {:"Barnes Druid",
  #    [
  #      "Swipe"
  #    ]},
  #   {:"Mill Druid",
  #    [
  #      "Naturalize",
  #      "Poison Seeds",
  #      "Sir Finley, Sea Guide",
  #      "Bob the Bartender",
  #      "Frost Lotus Seedling",
  #      "Spreading Plague"
  #    ]},
  #   {:"Barnes Druid",
  #    [
  #      "Bottomless Toy Chest",
  #      "Biology Project",
  #      "Solar Eclipse",
  #      "Pendant of Earth"
  #    ]},
  #   # 30.5
  #   {:"Astral Communion Druid",
  #    [
  #      "E.T.C., Band Manager",
  #      "Bottomless Toy Chest",
  #      "Aquatic Form"
  #    ]},
  #   {:"OTK Druid",
  #    [
  #      "Nourish",
  #      "New Heights"
  #    ]},
  #   {:"Highlander Druid", ["Prince Renethal"]}
  # ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Druid")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other Druid")
  end
end
