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
       "Murozond, Unbounded",
       "The Ceaseless Expanse",
       "Dirty Rat",
       "Marin the Manager"
     ]},
    {:"Dragon Warrior",
     [
       "Plucky Paintfin",
       "The Curator",
       "Lo'Gosh, Blood Fighter",
       "Illusory Greenwing",
       "Broll, Blood Fighter",
       "Valeera, Blood Fighter",
       "Whelp of the Bronze",
       "Petal Peddler",
       "Royal Librarian",
       "Brood Keeper",
       "Stadium Announcer",
       "Stonecarver",
       "Giftwrapped Whelp",
       "Windpeak Wyrm",
       "Darkrider",
       "Dreamplanner Zephrys",
       "Demolition Renovator",
       "Sanguine Depths",
       "Quality Assurance",
       "Keeper of the Flame",
       "Shadowflame Suffusion",
       "Dragon Turtle"
     ]},
    {:"Boom Wrench Warrior",
     [
       "Prize Vendor",
       "Boom Wrench",
       "Part Scrapper",
       "Testing Dummy",
       "Safety Expert"
     ]},
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
       "New Heights"
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
