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
       "Enter the Lost City",
       "Murozond, Unbounded"
     ]},
    {:"Mech Warrior",
     [
       "Part Scrapper",
       "Boom Wrench",
       "Testing Dummy",
       "Slam",
       "Wreck'em and Deck'em",
       "Crazed Alchemist",
       "Mixologist"
     ]},
    {:"Lo'Gosh Warrior",
     [
       "Plucky Paintfin",
       "The Curator",
       "Lo'Gosh, Blood Fighter",
       "Petal Peddler",
       "Illusory Greenwing",
       "Broll, Blood Fighter",
       "Royal Librarian",
       "Brood Keeper",
       "Stonecarver",
       "Windpeak Wyrm",
       "Giftwrapped Whelp",
       "Darkrider",
       "Stadium Announcer",
       "Sanguine Depths"
     ]},
    {:"Mech Warrior",
     [
       "Nightmare Lord Xavius"
     ]},
    {:"Control Warrior",
     [
       "The Exodar",
       "Arkonite Defense Crystal",
       "Yamato Cannon",
       "Jim Raynor",
       "Marin the Manager",
       "The Ceaseless Expanse",
       "Sleep Under the Stars",
       "Hostile Invader",
       "Battlecruiser",
       "New Heights"
     ]},
    {:"Control Warrior",
     [
       "Guard Duty",
       "Blob of Tar",
       "Demolition Renovator",
       "Tortollan Traveler",
       "Brawl",
       "Bulwark of Azzinoth",
       "Hamm, the Hungry"
     ]},
    {:"Control Warrior",
     [
       "Shield Block",
       "Starport",
       "Concussive Shells",
       "Dirty Rat",
       "Hydration Station",
       "Bob the Bartender",
       "Tortolla",
       "Dreamplanner Zephyrs",
       "Griftah, Trusted Vendor",
       "Ysera, Emerald Aspect"
     ]},
    {:"Mech Warrior",
     ["All You Can Eat", "Quality Assurance", "Precursory Strike", "For Glory!", "Shellnado"]}
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
