# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Warrior": ["Enter the Lost City"],
    "Dragon Warrior": ["Darkscale Broodmother", "Petal Peddler", "Prescient Slitherdrake", "Stadium Announcer"],
    "Egg Warrior": [
      "Endbringer Umbra",
      "Holy Eggbearer",
      "Shellnado",
      "Siphoning Growth",
      "The Egg of Khelos"
    ],
    "Gladiator Warrior": ["Gladiatorial Combat"],
    "Lo'Gosh Warrior": ["Ancient Raptor"],
    "Patron Warrior": ["Destructive Blaze"],
    "Harold Warrior": ["Ultraxion"],
    "Enrage Warrior": ["Injured Tol'vir"],
    "Lo'Gosh Warrior": ["City Defenses"],
    "Harold Warrior": ["Envoy of the End"],
    "Dragon Warrior": ["Shadowed Informant"],
    "Lo'Gosh Warrior": ["Bloodmage Thalnos", "Sands of Time"],
    "Harold Warrior": ["Cataclysmic War Axe", "Ragnaros, the Great Fire", "Scorching Ravager"],
    "Dragon Warrior": ["Brood Keeper"],
    "Lo'Gosh Warrior": ["Broll, Blood Fighter", "Lo'Gosh, Blood Fighter"],
    "Dragon Warrior": ["Darkrider", "Windpeak Wyrm"],
    "Lo'Gosh Warrior": ["P1CK-P0K3T", "Scrappy Defender"],
    "Lo'Gosh Warrior": ["Mother Duck", "Nightmare Lord Xavius", "Precursory Strike"],
    "Enrage Warrior": ["Ball and Chain", "Ominous Nightmares", "Rioter", "Stonecarver", "Time-Twisted Seer"],
    "Dragon Warrior": ["Carrier Whelp"],
    "Egg Warrior": ["Acolyte of Pain", "Axe of the Forefathers", "For Glory!", "Slam"],
    "Dragon Warrior": ["Sanguine Depths", "Shadowflame Suffusion"]
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
