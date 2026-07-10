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
    "Chef Druid": [
      "Chef Neth'rek",
      "Commissary Crook",
      "Kaldorei Cultivator",
      "Lethal Recipe",
      "Spiteful Chef"
    ],
    "Hostage Druid": [
      "Chrono-Lord Deios",
      "Endbringer Umbra",
      "Grove Shaper",
      "Sewer Imp",
      "Tindral Sageswift"
    ],
    "Merithra Druid": ["Darkscale Broodmother", "Fyrakk the Blazing"],
    # 5.5
    "Attack Druid": ["Infest the Scullery", "Savage Striker"],
    "Merithra Druid": ["Merithra of the Dream"],
    # auto gen
    "Chef Druid": [
      "Azshara's Triumph",
      "Creature of Madness",
      "Doomsayer",
      "Glacial Shard",
      "Mossbinding",
      "Photosynthesis",
      "Raven Idol",
      "Sands of Time",
      "Spider Rider",
      "Symbiosis"
    ],
    "Token Druid": ["Hatchery Helper", "Living Roots", "Longneck Egg", "Ravenous Flock", "Twilight Egg"],
    "Merithra Druid": [
      "Bashana Runetotem",
      "Broodwatcher",
      "Ebb and Flow",
      "Elise the Navigator",
      "Nightmare Lord Xavius",
      "Shaladrassil",
      "Welcome Home!",
      "Wickerfang",
      "Ysera, Emerald Aspect",
      "Zuramat's Prison"
    ],
    # 10.5
    "Chef Druid": ["Spiderling"],
    "Merithra Druid": ["Acceleration Aura", "Felwood Treant", "Horn of Plenty", "Waveshaping"]
  ]
  @wild_config [
    "Barnes Druid": ["Starfire"],
    "Mill Druid": ["Dew Process", "Selfish Shellfish"],
    "Mecha'thun Druid": ["Mecha'thun"],
    "Token Druid": ["Aeroponics"],
    "Highlander Druid": ["Alexstrasza", "Rheastrasza", "The Curator", "Warmaster Blackhorn"],
    "Dragon Druid": ["Razormane Battleguard"],
    "Linecracker Druid": ["Linecracker"],
    "XL Dragon Druid": ["Tormented Dreadwing", "Ysera the Dreamer"],
    "XL Deios Druid": ["Jepetto Joybuzz", "Kun the Forgotten King"],
    "Barnes Druid": ["Magical Dollhouse"],
    "Champions Druid": ["Barnes"],
    "XL HL Tog Druid": ["Azalina Soulthief", "King Togwaggle"],
    "XL Dragon Druid": ["Summer Flowerchild"],
    "Highlander Druid": ["Trogg Gemtosser", "Twilight Timereaver"],
    "Mill Druid": ["Branching Paths", "Rising Waves"],
    "Highlander Druid": ["Smothering Starfish"],
    "Mecha'thun Druid": ["Germination"],
    "Astral Druid": ["Astral Communion"],
    "Highlander Druid": ["Loatheb"],
    "XL HL Tog Druid": ["Blademaster Okani"],
    "Linecracker Druid": ["Moonfire"],
    "Highlander Druid": ["Razorscale"],
    "Boar OTK Druid": ["Stormpike Quartermaster"],
    "Mill Druid": ["Floop's Glorious Gloop", "Mistah Vistah"],
    "XL Dragon Druid": ["Whelp of the Infinite"],
    "Highlander Druid": ["Death Beetle"],
    "XL HL Tog Druid": ["Tortollan Traveler"],
    "OTK Druid": ["Nightshade Bud"],
    "XL Therazane Druid": ["Stone Drake"],
    "XL Deios Druid": ["Chrono-Lord Deios"],
    "Highlander Druid": [
      "Brann Bronzebeard",
      "Breath of Dreams",
      "Desert Nestmatron",
      "Dirty Rat",
      "Reno Jackson",
      "Reno, Lone Ranger",
      "Splish-Splash Whelp",
      "Zephrys the Great"
    ],
    "Splendiferous Whizbang": ["Moment of Discovery"],
    "Old Aggro Druid": [
      "Herald of Nature",
      "Irondeep Trogg",
      "Jerry Rig Carpenter",
      "Mark of the Wild",
      "Peasant",
      "Planted Evidence",
      "Vicious Slitherspear"
    ],
    "Token Druid": ["Sow the Soil"],
    "Mill Druid": ["Naturalize", "Poison Seeds"],
    "OTK Druid": ["Overflow"],
    "Champions Druid": ["Champions of Azeroth"],
    "STD Merithra Druid": ["Darkscale Broodmother", "Ebb and Flow"],
    "Mecha'thun Druid": ["Wrath"],
    "Star Grazer Druid": ["Death Blossom Whomper"],
    "Questline Druid": ["Lost in the Park"],
    "XL Deios Druid": ["Astalor Bloodsworn"],
    "XL HL Tog Druid": ["Amirdrassil", "Skulking Geist"],
    "Mill Druid": ["Theotar, the Mad Duke"],
    "XL Deios Druid": ["Juicy Psychmelon"],
    "Mill Druid": ["Spreading Plague"],
    "OTK Druid": ["Ultimate Infestation"],
    "Champions Druid": ["Swipe"],
    "Linecracker Druid": ["Capture Coldtooth Mine", "Lifebinder's Gift"],
    "Mill Druid": ["Bob the Bartender", "Heartroot Stones", "Sleepy Resident"],
    "Highlander Druid": ["Jungle Giants"],
    "Star Grazer Druid": ["Hedge Maze"],
    "Highlander Druid": ["Acceleration Aura"],
    "Mill Druid": ["Frost Lotus Seedling"],
    "Barnes Druid": ["Bottomless Toy Chest"],
    "Mecha'thun Druid": ["Trail Mix"],
    "Mill Druid": ["E.T.C., Band Manager", "Moonlit Guidance", "New Heights", "Sir Finley, Sea Guide"],
    "Champions Druid": ["Pendant of Earth", "Solar Eclipse"],
    "Highlander Druid": [
      "Malfurion's Gift",
      "Nourish",
      "Overgrowth",
      "Prince Renathal",
      "Wild Growth",
      "Wildheart Guff"
    ],
    "Mill Druid": ["Invigorate"],
    "Highlander Druid": ["Dark Peddler", "Darkbomb", "Forgotten Torch", "Shadow Word: Pain"],
    "Mill Druid": ["Aquatic Form"],
    "Highlander Druid": ["Waveshaping"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Druid")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Druid")
  end
end
