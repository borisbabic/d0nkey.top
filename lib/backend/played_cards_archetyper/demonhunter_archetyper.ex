# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"Whizbang DH", ["Wish", "Chaos Nova"]},
    {:"Peddler DH",
     [
       "Spirit Peddler",
       "Fyrakk the Blazing",
       "Raging Felscreamer",
       "Window Shopper",
       "Chrono-Lord Deios",
       "Incindius",
       "Elise the Navigator"
     ]},
    {:"Aggro Demon Hunter",
     [
       "Sock Puppet Slitherspear",
       "King Mukla",
       "Acupuncture",
       "Living Flame",
       "Hot Coals",
       "Sizzling Cinder",
       "Slumbering Sprite",
       "Dreamplanner Zephyrs",
       "Battlefiend",
       "Spirit of the Team"
     ]},
    {:"Cliff Dive DH",
     [
       "Cliff Dive",
       "Colifero the Artist",
       "Illidari Inquisitor",
       "Fae Trickster",
       "Briarspawn Drake",
       "Magtheridon, Unreleased"
     ]},
    # 5.5
    {:"No Minion DH",
     [
       "Hounds of Fury",
       "Blind Box",
       "The Eternal Hold",
       "Lasting Legacy",
       "Emergency Meeting",
       "Demonic Deal"
     ]},
    {:"Armor DH",
     [
       "Arkonite Defense Crystal",
       "The Exodar",
       "Dimensional Core",
       "Dissolving Ooze",
       "Shattershard Turret",
       "Felfused Battery"
     ]},
    {:"Cliff Dive DH",
     ["Blob of Tar", "Headhunt", "Aeon Rend", "Ravenous Felhunter", "Inflitrate"]},
    {:"Peddler DH",
     [
       "Tuskpiercer",
       "Nightmare Lord Xavius",
       "Ancient of Yore",
       "Wyvern's Slumber",
       "Perennial Serpent"
       # "Axe of Cenarius",
       # "First Portal to Argus"
     ]},
    {:"Aggro DH", ["Time-Lost Glaive", "Zilliax Deluxe 3000"]},
    # 10.5
    {:"Peddler DH",
     [
       "Illidari Studies",
       "Grim Harvest",
       "Infestation",
       "Red Card",
       "Inflitrate",
       "Return Policy"
     ]},
    {:"No Minion DH", ["Solitude"]}
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
