# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"Whizbang DH", ["Wish", "Chaos Nova"]},
    {:"Armor DH",
     [
       "Arkonite Defense Crystal",
       "The Exodar",
       "Dimensional Core",
       "Felfused Battery",
       "The Legion's Bane",
       "Shattershard Turret"
     ]},
    {:"Aggro Demon Hunter",
     [
       "Sock Puppet Slitherspear",
       "King Mukla",
       "Acupuncture",
       "Living Flame",
       "Hot Coals",
       "Sizzling Cinder",
       "Battlefiend",
       "Spirit of the Team"
     ]},
    {:"Peddler DH",
     [
       "Plucky Paintfin",
       "Factory Assemblybot",
       "Spirit Peddler",
       "Wisp",
       "Endbringer Umbra",
       "Overplanner",
       "Climbing Hook",
       "Window Shopper",
       "Raging Felscreamer",
       "Octosari",
       "Elise the Navigator",
       "Fyrakk the Blazing",
       "The Curator",
       "Ysera, Emerald Aspect",
       "Ancient of Yore",
       "Zai, the Incredible"
     ]},
    # 5.5
    {:"Cliff Dive DH",
     [
       "Cliff Dive",
       "Colifero the Artist",
       "Illidari Inquisitor",
       "Magtheridon, Unreleased",
       "Ragnaros the Firelord",
       "Blob of Tar",
       "Ravenous Felhunter",
       "Return Policy",
       "Wyvern's Slumber"
     ]},
    {:"Armor DH", ["Warp Drive"]},
    {:"Aggro DH", ["Tortollan Storyteller", "Brain Masseuse"]},
    {:"Peddler DH",
     ["Tuskpiercer", "Nightmare Lord Xavius", "Creature of Madness", "Grim Harvest"]},
    {:"Aggro DH", ["Infestation", "Insect Claw", "Chaos Strike"]},
    # 10.5
    {:"Peddler DH", ["Blind Box", "Illidari Studies"]}
  ]
  @wild_config [
    {:"Pirate Demon Hunter",
     [
       "Ship's Cannon",
       "Hozen Roughhouser",
       "Treasure Distributor",
       "Field of Strife",
       "Magnifying Glaive",
       "Parachute Brigand",
       "Southsea Captain",
       "Patches the Pirate",
       "Mistake",
       "Space Pirate",
       "Adrenaline Fiend",
       "Dangerous Cliffside"
     ]},
    {:"Questline DH",
     [
       "Crimson Sigil Runner",
       "Glaivetar",
       "Fierce Outsider",
       "Vengeful Walloper",
       "Irebound Brute",
       "Felosophy",
       "Double Jump",
       "Patches the Pilot",
       "Aranna, Thrill Seeker",
       "Spectral Sight",
       "Illidari Studies",
       "Final Showdown",
       "Sigil of Alacrity",
       "Mana Burn",
       "Glide",
       "Paraglide",
       "Dispose of Evidence",
       "Spectral Sight",
       "Illidari Studies",
       "Sigil of Time",
       "Consume Magic"
     ]}
  ]

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other DH")
  end
end
