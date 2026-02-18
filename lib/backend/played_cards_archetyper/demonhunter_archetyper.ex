# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @aggro_eliminators [
    "Sock Puppet Slitherspear",
    "King Mukla",
    "Acupuncture",
    "Living Flame",
    "Battlefiend",
    "Spirit of the Team"
  ]
  @peddler_eliminators [
    "Spirit Peddler",
    "Octosari",
    "Raging Felscreamer"
  ]
  @no_minion_eliminators [
    "Hounds of Fury",
    "The Eternal Hold",
    "Lasting Legacy"
  ]
  @elise_dh [
    "Climbing Hook",
    "Blob of Tar",
    "Ravenous Felhunter",
    "Youthful Brewmaster",
    "The Ceaseless Expanse",
    "Infiltrate",
    "Demolition Renovator",
    "Remnant of Rage",
    "Patches the Pilot",
    "Elise the Navigator",
    "Kerrigan, Queen of Blades",
    "Rustrot Viper",
    "Gnomelia, S.A.F.E. Pilot",
    "First Portal to Argus",
    "Zilliax Deluxe 3000",
    "Return Policy",
    "Press the Advantage",
    "Infestation",
    "Tuskpiercer",
    "Grim Harvest",
    "Red Card"
  ]
  @standard_excludes %{
    :"Elise DH" =>
      [
        "Moonstone Mauler",
        "Platysaur",
        "Glacial Shard",
        "Crimson Sigil Runner",
        "Colifero the Artist",
        "Magtheridon, Unreleased",
        "Fae Trickster",
        "Cliff Dive",
        "Briarspawn Drake"
      ] ++ @aggro_eliminators ++ @peddler_eliminators ++ @no_minion_eliminators,
    :"Broxigar DH" =>
      [
        "Return Policy",
        "Blob of Tar",
        "Ravenous Felhunter",
        "Elise the Navigator",
        "Kerrigan, Queen of Blades",
        "Hounds of Fury",
        "Entomologist Toru",
        "Ragnaros the Firelord",
        "Magtheridon, Unreleased"
      ] ++ @aggro_eliminators ++ @peddler_eliminators ++ @no_minion_eliminators,
    :"Ravenous Cliff Dive DH" =>
      [
        "Platysaur",
        "Youthful Brewmaster",
        "Patches the Pilot",
        "Fae Trickster",
        "Spirit Peddler",
        "Remnant of Rage"
      ] ++ @aggro_eliminators ++ @peddler_eliminators ++ @no_minion_eliminators,
    :"Cliff Dive DH" =>
      [
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
        "Elise the Navigator",
        "Platysaur",
        "Glacial Shard",
        "Crimson Sigil Runner",
        "Youthful Brewmaster",
        "Remnant of Rage"
      ] ++ @aggro_eliminators ++ @peddler_eliminators,
    :"No Minion DH" =>
      [
        "Youthful Brewmaster",
        "Fae Trickster",
        "Remnant of Rage",
        "Cliff Dive",
        "Blob of Tar",
        "Ravenous Felhunter",
        "Platysaur",
        "Elise the Navigator",
        "Zilliax Deluxe 3000",
        "Nightmare Lord Xavius",
        "Demolition Renovator",
        "Dirdra, Rebel Captain",
        "Kayn Sunfury",
        "Patches the Pilot",
        "Astral Vigilant",
        "Starlight Wanderer",
        "Troubled Mechanic",
        "Voronei Recruiter",
        "Spirit of the Team",
        # peddler
        "Chrono-Lord Deios",
        "Ysera, Emerald Aspect"
      ] ++ @aggro_eliminators ++ @peddler_eliminators,
    :"Peddler DH" =>
      [
        "Cliff Dive",
        "Crimson Sigil Runner",
        "Moonstone Mauler",
        "Platysaur"
      ] ++ @aggro_eliminators,
    :"Aggro DH" =>
      [
        "Elise the Navigator",
        "Chrono-Lord Deios",
        "Climbing Hook",
        "The Ceaseless Expanse",
        "Ysera, Emerald Aspect"
      ] ++ @peddler_eliminators
  }
  @standard_config [
    {:"Quest DH", ["Unleash the Colossus"]},
    {:"Whizbang DH", ["Wish", "Chaos Nova"]},
    {:"No Minion DH", ["Hounds of Fury", "Lasting Legacy"]},
    {:"Aggro DH", ["Living Flame", "Kobold Geomancer"]},
    {:"Cliff Dive DH", ["Fae Trickster"]},
    # 5.5
    {:"Peddler DH", ["Octosari", "Spirit Peddler"]},
    {:"Aggro DH", ["King Mukla", "Slumbering Sprite", "Sock Puppet Slitherspear"]},
    {:"Ravenous Cliff Dive DH", ["Colifero the Artist"]},
    {:"Other DH", ["Arkonite Defense Crystal"]},
    {:"Whizbang DH", ["Chaos Nova", "Moment of Discovery"]},
    # 10.5
    {:"Broxigar DH", ["Platysaur"]},
    {:"Elise DH",
     [
       "Rustrot Viper",
       "Demolition Renovator",
       "Kerrigan, Queen of Blades",
       "The Ceaseless Expanse",
       "Remnant of Rage",
       "Patches the Pilot"
     ]},
    {:"Whizbang DH",
     {["Umpire's Grasp", "Workshop Mishap", "Window Shopper"], @peddler_eliminators}},
    {:"No Minion DH", ["The Eternal Hold"]},
    {:"Broxigar DH", ["Critter Caretaker"]},
    # 15.5
    {:"Whizbang DH", ["Aldrachi Warblades"]},
    {:"Aggro DH", ["Acupuncture"]},
    {:"Other DH", ["Cloud Serpent", "Gan'arg Glaivesmith"]},
    {:"Ravenous Cliff Dive DH", ["Briarspawn Drake", "Cliff Dive", "Magtheridon"]},
    {:"Elise DH", ["Elise the Navigator", "Climbing Hook"]},
    # 20.5
    {:"Broxigar DH", ["Incindius"]},
    {:"Elise DH", {@elise_dh, ["Wyvern's Slumber", "Insect Claw", "Illidari Inquisitor"]}},
    {:"No Minion DH",
     [
       "Hounds of Fury",
       "The Eternal Hold",
       "Lasting Legacy",
       "Blind Box",
       "Solitude",
       "Time-Lost Glaive",
       "The Eternal Hold",
       "Wyvern's Slumber",
       "Dangerous Cliffside",
       "Axe of Cenarius",
       "Sigil of Cinder",
       "Insect Claw",
       "First Portal to Argus",
       "Illidari Studies",
       "Hive Map",
       "Headhunt",
       "Emergency Meeting",
       "Red Card"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Colifero the Artist",
       "Wyvern's Slumber",
       "Blob of Tar",
       "Ravenous Felhunter",
       "Elise the Navigator",
       "Colifero the Artist",
       "Magtheridon, Unreleased",
       "Elise the Navigator"
     ]},
    {:"Elise DH", @elise_dh},
    {:"Aggro DH",
     [
       "Living Flame",
       "Slumbering Sprite",
       "Sock Puppet Slitherspear",
       "Acupuncture",
       "Hot Coals",
       "Chronikar",
       "Dreamplanner Zephrys",
       "Kayn Sunfury",
       "Spirit of the Team",
       "Perennial Serpent",
       "Bloodmage Thalnos",
       "Aranna, Thrill Seeker",
       "Battlefiend",
       "Zilliax Deluxe 3000"
     ]},
    # 5.5
    {:"Peddler DH",
     [
       "Spirit Peddler",
       "Octosari",
       "Window Shopper",
       "Nightmare Lord Xavius",
       "Ferocious Felbat",
       "Raging Felscreamer"
     ]},
    {:"Cliff Dive DH",
     [
       "Illidari Inquisitor",
       "Briarspawn Drake",
       "Fae Trickster",
       "Infiltrate",
       "Cliff Dive",
       "Wyvern's Slumber",
       "Hive Map",
       "Time-Lost Glaive",
       "Press the Advantage",
       "Insect Claw",
       "Tuskpiercer",
       "Grim Harvest",
       "Sigil of Cinder",
       "Red Card",
       "Illidari Studies",
       "Infestation",
       "Axe of Cenarius",
       "Dangerous Cliffside",
       "First Portal to Argus",
       "Headhunt"
     ]},
    {:"Ravenous Cliff Dive DH",
     [
       "Cliff Dive",
       "First Portal to Argus",
       "Climbing Hook",
       "Return Policy",
       "Dangerous Cliffside",
       "Insect Claw",
       "Axe of Cenarius",
       "Tuskpiercer",
       "Infestation",
       "Grim Harvest",
       "Return Policy"
     ]},
    {:"Broxigar DH",
     [
       "The Ceaseless Expanse",
       "Demolition Renovator",
       "Youthful Brewmaster",
       "Incindius",
       "Platysaur",
       "Broxigar",
       "Crimson Sigil Runner",
       "Remnant of Rage",
       "Glacial Shard",
       "Patches the Pilot",
       "Illidari Studies",
       "Dangerous Cliffside",
       "Infestation",
       "Immolation Aura",
       "Axe of Cenarius",
       "Grim Harvest",
       "Press the Advantage",
       "First Portal to Argus",
       "Paraglide",
       "Red Card"
     ]},
    {:"Dragon Demon Hunter",
     [
       "Petal Peddler",
       "Prescient Slitherdrake",
       "Giftwrapped Whelp",
       "Tormented Dreadwing",
       "Netherspite Historian"
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

  def standard_excludes(), do: @standard_excludes
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, @standard_excludes)
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DH")
  end
end
