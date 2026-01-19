# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{
    :"Blobxigar DH" => [
      "Moonstone Mauler",
      "Platysaur",
      "Glacial Shard",
      "Crimson Sigil Runner",
      "Wyvern's Slumber",
      "Colifero the Artist",
      "Illidari Inquisitor",
      "Magtheridon, Unreleased",
      "Cliff Dive",
      "Briarspawn Drake",
      "Illidari"
    ],
    :"Broxigar DH" => [
      "Return Policy",
      "Blob of Tar",
      "Ravenous Felhunter",
      "Hounds of Fury",
      "The Eternal Hold",
      "Solitude",
      "Lasting Legacy"
    ],
    :"Ravenous Cliff Dive DH" => [
      "Platysaur",
      "Youthful Brewmaster",
      "Patches the Pilot",
      "Fae Trickster",
      "Spirit Peddler",
      "Remnant of Rage"
    ],
    :"Cliff Dive DH " => [
      "Return Policy",
      "Blob of Tar",
      "Ravenous Felhunter",
      "Hounds of Fury",
      "The Eternal Hold",
      "Solitude",
      "Lasting Legacy",
      "Colifero the Artist",
      "Climbing Hook",
      "Magtheridon, Unreleased",
      "Elise the Navigator"
    ],
    :"No Minion DH" => [
      "Youthful Brewmaster",
      "Fae Trickster",
      "Remnant of Rage",
      "Cliff Dive",
      "Blob of Tar"
    ],
    :"Peddler DH" => ["Cliff Dive"]
  }
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
    {:"Broxigar DH",
     [
       "Platysaur",
       "Glacial Shard",
       "Youthful Brewmaster",
       "Moonstone Mauler",
       "Crimson Sigil Runner",
       "Immolation Aura"
     ]},
    {:"No Minion DH",
     [
       "Hounds of Fury",
       "The Eternal Hold",
       "Solitude",
       "Lasting Legacy",
       "Emergency Meeting"
     ]},
    {:"Peddler DH",
     [
       "Spirit Peddler",
       # "Fyrakk the Blazing",
       "Raging Felscreamer",
       "Window Shopper",
       "Octosari",
       "Chrono-Lord Deios",
       "Plucky Paintfin"
     ]},
    # 5.5
    {:"Aggro Demon Hunter",
     [
       "Sock Puppet Slitherspear",
       "King Mukla",
       "Acupuncture",
       "Slumbering Sprite",
       "Dreamplanner Zephyrs",
       "Living Flame",
       "Dreamplanner Zephyrs",
       "Battlefiend",
       "Spirit of the Team"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Colifero the Artist",
       "Climbing Hook",
       "Magtheridon, Unreleased"
     ]},
    {:"Cliff Dive DH",
     [
       "Fae Trickster",
       "Champions of Azeroth",
       # "Cham"
       "Sigil of Cinder",
       "Time-Lost Glaive"
       # "Insect Claw",
       # "Illidari Studies"
       # "Tuskpiercer"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Briarspawn Drake",
       "Illidari Inquisitor",
       "Cliff Dive"
     ]},
    {:"Dragon Demon Hunter",
     [
       "Petal Peddler",
       "Prescient Slitherdrake",
       "Giftwrapped Whelp",
       "Tormented Dreadwing",
       "Netherspite Historian"
     ]},
    # 10.5
    {:"Blobxigar DH",
     [
       "Demolition Renovator",
       "The Ceaseless Expanse"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Wyvern's Slumber",
       "Elise the Navigator"
     ]},
    {:"Blobxigar DH",
     [
       "Remnant of Rage",
       "Press the Advantage"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Blob of Tar",
       "Ravenous Felhunter",
       "Return Policy",
       "Tuskpiercer"
     ]},
    {:"Broxigar DH",
     [
       "Incindius",
       "Paraglide",
       "Press the Advantage",
       "Axe of Cenarius",
       "First Portal to Argus",
       "Dangerous Cliffside",
       "Illidari Studies",
       "Patches the Pilot"
     ]},
    {:"Blobxigar DH",
     [
       "Blob of Tar",
       "Ravenous Felhunter",
       "Return Policy",
       "Tuskpiercer",
       "Patches the Pilot",
       "Paraglide",
       "Incindius",
       "Dangerous Cliffside",
       "First Portal to Argus",
       "Axe of Cenarius"
     ]},
    {:"Cliff Dive DH",
     [
       "Cliff Dive"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Infestation",
       "Grim Harvest"
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

  def standard_config(), do: add_excludes(@standard_config, @standard_excludes)
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DH")
  end
end
