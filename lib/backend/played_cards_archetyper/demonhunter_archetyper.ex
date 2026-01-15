# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"Whizbang DH", ["Wish", "Chaos Nova"]},
    # {:"Cliff Dive DH",
    #  [
    #    "Cliff Dive",
    #    "Colifero the Artist",
    #    # "Illidari Inquisitor",
    #    "Fae Trickster"
    #    # "Briarspawn Drake",
    #    # "Magtheridon, Unreleased"
    #  ]},
    {:"No Minion DH",
     [
       "Hounds of Fury",
       # "Blind Box",
       "The Eternal Hold",
       "Lasting Legacy"
       # "Emergency Meeting",
       # "Mutalisk",
       # "Nydus Worm",
       # "Creep Tumor",
       # "Sigil of Cinder",
       # "Demonic Deal",
       # "Solitude",
       # "Headhunt",
       # "Aeon Rend"
     ]},
    {:"Peddler DH",
     [
       "Spirit Peddler",
       # "Fyrakk the Blazing",
       "Raging Felscreamer",
       "Window Shopper"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Colifero the Artist",
       "Magtheridon, Unreleased",
       "Climbing Hook",
       "Blob of Tar",
       "Ravenous Felhunter"
     ]},
    # 5.5
    {:"Broxigar DH",
     [
       "Youthful Brewmaster",
       "Platysaur",
       # "Broxigar",
       "Remnant of Rage",
       "Crimson Sigil Runner",
       "Glacial Shard",
       "Immolation Aura",
       "The Ceaseless Expanse",
       "Patches the Pilot",
       "Paraglide"
     ]},
    {:"No Minion DH",
     [
       "Solitude"
     ]},
    {:"Aggro Demon Hunter",
     [
       "Sock Puppet Slitherspear",
       "King Mukla",
       "Acupuncture",
       "Slumbering Sprite",
       "Dreamplanner Zephyrs",
       "Living Flame",
       "Hot Coals",
       "Dreamplanner Zephyrs",
       "Kayn Sunfury",
       "Bloodmage Thalnos",
       "Battlefiend",
       "Spirit of the Team"
     ]},
    {:"Cliff Dive DH",
     [
       "Fae Trickster",
       "Sigil of Cinder",
       "Time-Lost Glaive",
       "Insect Claw",
       "Illidari Studies"
       # "Tuskpiercer"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Elise the Navigator",
       "Tuskpiercer",
       "Cliff Dive"
     ]}
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
