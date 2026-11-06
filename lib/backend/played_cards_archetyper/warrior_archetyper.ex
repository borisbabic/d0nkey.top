# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @pirate_warrior_excludes [
    "Brood Keeper",
    "Darkrider",
    "Darkscale Broodmother",
    "Petal Peddler",
    "Prescient Slitherdrake",
    "Shadowed Informant",
    "Windpeak Wyrm"
  ]
  @dragon_warrior_excludes [
    "Blastpowder Engineer",
    "Cannonmaster",
    "Captain Crowley",
    "Follow the Fuse",
    "Hook n' Heave",
    "Hand Cannon",
    "Land Ho!",
    "Sky Raider",
    "Southsea Captain"
  ]
  @standard_config [
    "Quest Warrior": ["Enter the Lost City"],
    "Pirate Warrior": ["Southsea Captain"],
    "Harold Warrior": ["Envoy of the End"],
    "Dragon Warrior": [
      "Brood Keeper",
      "Carrier Whelp",
      "Darkrider",
      "Darkscale Broodmother",
      "Petal Peddler",
      "Prescient Slitherdrake",
      "Windpeak Wyrm"
    ],
    "Pirate Warrior": ["Hand Cannon"],
    "Harold Warrior": ["Deathwing, Worldbreaker", "Ragnaros, the Great Fire", "Scorching Ravager", "Ultraxion"],
    "Pirate Warrior": ["Sky Raider"],
    "N'Zoth Warrior": ["Crystalline Golem", "Destructive Blaze", "N'Zoth, Dream's End"],
    "Egg Warrior": ["Holy Eggbearer"],
    "Armor Warrior": ["Barricade Basher"],
    "Pirate Warrior": ["Blastpowder Engineer", "Captain Crowley", "Land Ho!"],
    "Harold Warrior": ["Cataclysmic War Axe"],
    "N'Zoth Warrior": ["Eternal Toil", "Living Flame", "Lo'Gosh, Blood Fighter", "Loot Hoarder"],
    "Armor Warrior": ["Brassknuckle Brawler"],
    "Lo'Gosh Warrior": ["Scrappy Defender"],
    "Other Warrior": ["Ravaging Ghoul"],
    "Armor Warrior": ["Ancient of Yore", "Animator of Iron", "Bash", "Fortify", "Hookfist-3000", "Shellnado"],
    "N'Zoth Warrior": [
      "Broll, Blood Fighter",
      "Decimation",
      "Precursory Strike",
      "Prize Vendor",
      "Slam",
      "Valeera, Blood Fighter"
    ],
    "Dragon Warrior": ["Anvil of Reshaping"],
    "Pirate Warrior": ["Erupting Volcano"],
    "Dragon Warrior": ["Cannonmaster", "Hook n' Heave", "Mother Duck", "Searing Fissure", "Stadium Announcer"],
    "N'Zoth Warrior": [
      "Archaedas",
      "For Glory!",
      "Forge of Origination",
      "Nightmare Lord Xavius",
      "Shield Block",
      "Tol'vir Vanguard"
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
