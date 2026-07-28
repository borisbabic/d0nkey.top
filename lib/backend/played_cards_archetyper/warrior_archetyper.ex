# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Warrior": ["Enter the Lost City"],
    "Dragon Warrior": [
      "Darkscale Broodmother",
      "Petal Peddler",
      "Brood Keeper",
      "Windpeak Wyrm",
      "Prescient Slitherdrake"
    ],
    "Egg Warrior": [
      "Endbringer Umbra",
      "Holy Eggbearer",
      "Shellnado",
      "Siphoning Growth",
      "The Egg of Khelos"
    ],
    "Harold Warrior": [
      "Cataclysmic War Axe",
      "Envoy of the End",
      "Scorching Ravager",
      "Ultraxion"
    ],
    "Other Warrior": ["Gladiatorial Combat"],
    "Lo'Gosh Warrior": ["Valeera, Blood Fighter"],
    "Burn Warrior": ["Rockskipper"],
    "Lo'Gosh Warrior": [
      "Acolyte of Pain",
      "Axe of the Forefathers",
      "Broll, Blood Fighter",
      "Bulwark of Azzinoth",
      "Chainbreaker Hogger",
      "City Defenses",
      "Crowd Control",
      "Destructive Blaze",
      "Disguised Watchman",
      "Erupting Volcano",
      "Eternal Toil",
      "Execute",
      "For Glory!",
      "Latorvian Armorer",
      "Lo'Gosh, Blood Fighter",
      "Mother Duck",
      "Nightmare Lord Xavius",
      "Portal Vanguard",
      "Precursory Strike",
      "Release the Beasts",
      "Rustrot Viper",
      "Scramble for Gear",
      "Searing Fissure",
      "Shadowflame Suffusion",
      "Shield Block",
      "Slam",
      "Torch",
      "Twilight Egg"
    ]
  ]
  @wild_config [
    "XL Taunt Warrior": [
      "Far Watch Post",
      "Imposing Anubisath",
      "Miracle Salesman",
      "Plucky Paintfin",
      "Power Slider",
      "Scrap Golem",
      "Tar Slime",
      "The One-Amalgam Band"
    ],
    "XL LC Quest Warrior": ["Blast Tortoise", "Eredar Brute", "Unlucky Powderman"],
    "XL HL LC Quest Warrior": ["Enter the Lost City"],
    "XL HL Igneous Warrior": [
      "Astalor Bloodsworn",
      "Bladestorm",
      "Bob the Bartender",
      "Boomboss Tho'grun",
      "Brawl",
      "Bulwark of Azzinoth",
      "Card Grader",
      "Deepminer Brann",
      "Dirty Rat",
      "Drywhisker Armorer",
      "Hamm, the Hungry",
      "Iceblood Garrison",
      "Lord Barov",
      "Marin the Manager",
      "Mutanus the Devourer",
      "New Heights",
      "Prince Renathal",
      "Quality Assurance",
      "Reno Jackson",
      "Reno, Lone Ranger",
      "Skulking Geist",
      "Sleep Under the Stars",
      "Sleepy Resident",
      "Theotar, the Mad Duke",
      "Ysera, Emerald Aspect",
      "Zephrys the Great",
      "Zilliax Deluxe 3000",
      "Zola the Gorgon"
    ],
    "Blaze Warrior": ["Destructive Blaze", "Spammy Arcanist"],
    "Sul'thraze Warrior": ["Bloodsail Deckhand"],
    "STD Dragon Warrior": ["Prescient Slitherdrake"],
    "XL Rock 'n' Roll Warrior": ["Ethereal Oracle"],
    "Igneous Odyn Warrior": ["Blacksmithing Hammer", "Lorekeeper Polkelt", "Odyn, Prime Designate"],
    "Rock 'n' Roll Warrior": ["Bladed Gauntlet", "Charge"],
    "STD Dragon Warrior": ["Brood Keeper", "Stadium Announcer"],
    "Igneous Odyn Warrior": ["Forge of Souls", "Last Stand", "Nightmare Lord Xavius", "Sanitize"],
    "Harold Warrior": ["Envoy of the End"],
    "XL HL Questline Warrior": ["Raid the Docks"],
    "STD Dragon Warrior": ["Darkrider"],
    "Sul'thraze Warrior": ["Sul'thraze"],
    "XL HL Igneous Warrior": ["E.T.C., Band Manager"],
    "Igneous Odyn Warrior": [
      "Aftershocks",
      "All You Can Eat",
      "For Glory!",
      "From the Depths",
      "Igneous Lavagorger",
      "Safety Goggles",
      "Shield Shatter",
      "Sir Finley, Sea Guide",
      "Sphere of Sapience",
      "Unleash the Crocolisks"
    ],
    "XL HL Igneous Warrior": ["Shield Block"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warrior")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other Warrior")
  end
end
