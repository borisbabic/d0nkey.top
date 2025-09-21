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
       "The Exodar",
       "Arkonite Defense Crystal",
       "Yamato Cannon",
       "Jim Raynor",
       "Marin the Manager",
       "The Ceaseless Expanse",
       "Ancient of Yore",
       "Sleep Under the Stars",
       "Hostile Invader",
       "Battlecruiser",
       "New Heights"
     ]},
    {:"Mech Warrior",
     [
       "Part Scrapper",
       "Wreck'em and Deck'em",
       "Boom Wrench",
       "Testing Dummy",
       "Inventor Boom",
       "Mixologist",
       "Endbringer Umbra",
       "Quality Assurance",
       "Slam",
       "Crazed Alchemist",
       "Cubicle",
       "Safety Goggles",
       "Nightmare Lord Xavius",
       "Chemical Spill",
       "Elise the Navigator"
     ]},
    {:"Enrage Warrior",
     [
       "Tindral Sageswift",
       "Ominous Nightmares",
       "Eggbasher",
       "Stonecarver",
       "Sanguine Depths"
     ]},
    {:"Dragon Warrior",
     [
       "Windpeak Wyrm",
       "Clutch of Corruption",
       "Darkrider",
       "Brood Keeper",
       "Giftwrapped Whelp",
       "Illusory Greenwing",
       "Succumb to Madness",
       "Petal Peddler"
     ]},
    {:"Draenei Warrior",
     [
       "Unyielding Vindicator",
       "Stalwart Avenger",
       "Troubled Mechanic",
       "Crystalline Greatmace",
       "Crimson Commander",
       "Starlight Wanderer",
       "Expedition Sergeant",
       "Captain's Log",
       "Stranded Spaceman"
     ]},
    {:"Control Warrior",
     [
       "Guard Duty",
       "Blob of Tar",
       "Demolition Renovator",
       "Tortollan Traveler",
       "Brawl",
       "Shellnado",
       "Bulwark of Azzinoth",
       "Hamm, the Hungry"
     ]},
    {:"Dragon Warrior",
     [
       "Cloud Serpent",
       "Dragon Turtle",
       "Creature of Madness",
       "Fyrakk the Blazing",
       "Ysondre",
       "Naralex",
       "Gorgonzormu"
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
    {:"Dragon Warrior", ["Shadowflame Suffusion"]},
    {:"Mech Warrior", ["All You Can Eat", "Axe of the Forefathers"]}
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
