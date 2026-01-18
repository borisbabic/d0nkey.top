# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Whizbang Warrior",
     [
       "Madame Lazul",
       "Hagatha's Scheme",
       "Swampqueen Hagatha",
       "Heistbaron Togwaggle",
       "EVIL Miscreant",
       "EVIL Recruiter",
       "EVIL Quartermaster",
       "Dr. Boom, Mad Genius",
       "EVIL Cable Rat",
       "Dark Pharaoh Tekahn",
       "Grand Lackey Erkh",
       "EVIL Conscripter",
       "Sinister Deal",
       "Whispers of EVIL",
       "Arch-Villain Rafaam",
       "Weaponized Wasp",
       "EVIL Totem",
       "Livewire Lance",
       "Togwaggle's Scheme"
     ]},
    {:"Control Warrior",
     [
       "Enter the Lost City"
     ]},
    {:"Dragon Warrior",
     [
       "Lo'Gosh, Blood Fighter",
       "Illusory Greenwing",
       "Broll, Blood Fighter",
       "Valeera, Blood Fighter",
       "Whelp of the Bronze",
       "Petal Peddler",
       "Royal Librarian",
       "Brood Keeper",
       "Chrono-Lord Epoch",
       "Whelp of the Infinite",
       "Portal Vanguard",
       "Fyrakk the Blazing",
       "Stadium Announcer",
       "Stonecarver",
       "Giftwrapped Whelp",
       "Windpeak Wyrm",
       "Darkrider",
       "Dreamplanner Zephrys",
       "Demolition Renovator",
       "Sanguine Depths",
       "Keeper of the Flame",
       "Shadowflame Suffusion",
       "Prescient Slitherdrake",
       "Dragon Turtle"
     ]},
    # {:"Boom Wrench Warrior",
    #  [
    #    "Prize Vendor",
    #    "Boom Wrench",
    #    "Part Scrapper",
    #    "Testing Dummy",
    #    "Safety Expert"
    #  ]},
    {:"Control Warrior",
     [
       "The Exodar",
       "Arkonite Defense Crystal",
       "Yamato Cannon",
       "Jim Raynor",
       "Sleep Under the Stars",
       "Battlecruiser",
       "Tortollan Traveler",
       "Brawl",
       "Bulwark of Azzinoth",
       "Starport",
       "Hydration Station",
       "Tortolla",
       "Elise the Navigator",
       "Hostile Invader",
       "New Heights",
       "Murozond, Unbounded",
       "The Ceaseless Expanse",
       "Dirty Rat",
       "Marin the Manager",
       "Ancient of Yore",
       "Shield Slam",
       "Bob the Bartender"
     ]},
    {:"Draenei Warrior",
     [
       "Stranded Spaceman",
       "Crimson Commander",
       "Stalwart Avenger",
       "Expedition Sergeant",
       "Unyielding Vindicator",
       "Starlight Wanderer",
       "Velen, Leader of the Exiled"
     ]},
    {:"Dragon Warrior",
     [
       "Griftah, Trusted Vendor",
       "Grommash Hellscream",
       "Naralex, Herald of the Flight",
       "Quality Assurance",
       "Gnomelia, S.A.F.E. Pilot",
       "Precursory Strike",
       "Dimensional Weaponsmith",
       "The Great Dracorex",
       "Naralex, Hearld of the Flight",
       "Time-Twisted Seer",
       "Eternal Toil",
       "Zilliax Deluxe 3000",
       "Tormented Dreadwing"
     ]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warrior")
  end

  def wild(_card_info) do
    nil
  end
end
