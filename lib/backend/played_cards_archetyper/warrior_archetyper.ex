# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Mech Warrior", ["Part Scrapper", "Wreck'em and Deck'em", "Boom Wrench", "Testing Dummy"]},
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
       "New Heights"
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
    {:"Mech Warrior",
     [
       "Carnivorous Cubicle",
       "Endbringer Umbra",
       "Inventor Boom",
       "Nightmare Lord Xavius",
       "Mixologist",
       "Slam",
       "Quality Assurance"
     ]},
    {:"Control Warrior",
     [
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

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warrior")
  end

  def wild(_card_info) do
    nil
  end
end
