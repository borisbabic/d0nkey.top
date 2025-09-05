# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"Armor DH",
     [
       "Arkonite Defense Crystal",
       "The Exodar",
       "Dimensional Core",
       "Felfused Battery",
       "The Legion's Bane",
       "Shattershard Turret"
     ]},
    {:"Cliff Dive DH",
     [
       "Cliff Dive",
       "Colifero the Artist",
       "Illidari Inquisitor",
       "Magtheridon, Unreleased",
       "Ragnaros the Firelord"
     ]},
    {:"Aggro Demon Hunter",
     [
       "Sock Puppet Slitherspear",
       "King Mukla",
       "Acupuncture",
       "Living Flame",
       "Hot Coals",
       "Cult Neophyte",
       "Sizzling Cinder",
       "Battlefiend",
       "Spirit of the Team"
     ]},
    {:"Cliff Dive DH", ["Blob of Tar"]},
    # 5.5
    {:"Deathrattle DH",
     [
       "Endbringer Umbra",
       "Ferocious Felbat",
       "Carnivorous Cubicle",
       "Spirit Pedler",
       "Return Policy",
       "Sleepy Resident",
       "Ysera, Emerald Aspect",
       "Ancient of Yore",
       "Elise the Navigator",
       "Spirit Peddler",
       "Octosari",
       "Plucky Paintfin",
       "Fyrakk the Blazing",
       "Aranna, Thrill Seeker",
       "Wisp",
       "Raging Felscreamer",
       "Bob the Bartender",
       "Raging Felscreamer",
       "Paraglide"
     ]},
    {:"Cliff Dive DH",
     [
       "Wyvern's Slumber",
       "Insect Claw",
       "Dangerous Cliffside",
       "Ravenous Felhunter",
       "Infestation",
       "Red Card",
       "Infiltrate",
       "Illidari Studies"
     ]},
    {:"Armor DH", ["Tuskpiercer", "Grim Harvest"]}
    # {:"Aggro Demon Hunter",
    #  [
    #    "Bloodmage Thalnos",
    #    "Dreamplanner Zephrys",
    #    "Observer of Mysteries",
    #    "Royal Librarian",
    #    "Brain Masseuse",
    #    "Rockspitter",
    #    "Chaos Strike"
    #  ]},
    # {:"Octosari DH", ["Octosari", "Aranna Thrill Seeker"]},
    # {:"Cliff Dive DH", ["Illidari Studies"]},
    # {:"Armor DH", ["Tuskpiercer"]},
    # {:"Aggro Demon Hunter", ["Insect Claw", "Infestation", "Dangerous Cliffside", "Kayn Sunfury"]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DH")
  end

  def wild(_card_info) do
    nil
  end
end
