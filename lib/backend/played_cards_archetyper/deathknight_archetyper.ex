# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DK", ["Reanimate the Terror"]},
    {:"Whizbang DK",
     [
       "Thrive in the Shadows",
       "Wild Growth",
       "Elemental Inspiration",
       "Spore Hallucination",
       "Multicaster",
       "Bash",
       "Hipster",
       "Primordial Glyph",
       "Patchwork Pals",
       "Coral Keeper",
       "Chaos Strike",
       "Hellfire",
       "Consecration"
     ]},
    {:"Bot? DK",
     [
       "Stormwind Champion",
       "Life Drinker",
       "Sen'jin Shieldmasta",
       "Dire Wolf Alpha",
       "Annoy-o-Tron",
       "Murloc Tidehunter",
       "Mo'arg Forgefiend"
     ]},
    {:"Starship DK",
     [
       "Guiding Figure",
       "Soulbound Spire",
       "Arkonite Defense Crystal",
       "The Spirit's Passage",
       "The Exodar",
       "Suffocate",
       "Dimensional Core"
     ]},
    {:"Handbuff DK",
     [
       "City Chief Esho",
       "Lesser Spinel Spellstone",
       "Darkthorn Quilter",
       "Amateur Puppeteer",
       "Blood Tap"
     ]},
    # 5.5
    {:"Menagerie DK", ["Menagerie Mug", "Menagerie Jug"]},
    {:"Herenn DK",
     ["High Cultist Herenn", "Overplanner", "Wakener of Souls", "Meltemental", "Travel Security"]},
    {:"Control DK",
     ["The Ceaseless Expanse", "Naralex, Herald of the Flights", "Vampiric Blood"]},
    {:"Control DK",
     [
       "Dirty Rat",
       "Plucky Paintfin",
       "Steamcleaner",
       "Stranded Spaceman",
       "Headless Horseman",
       "Corpse Explosion",
       "Orbital Moon",
       "Adaptive Amalgam",
       "Floppy Hydra",
       "Threads of Despair",
       "Braingill",
       "The 8 Hands from Beyond",
       "The Headless Horseman"
     ]},
    {:"Frost DK", ["Frostwyrm's Fury", "Cryosleep", "Thassarian", "Marrow Manipulator"]},
    # 10.5
    {:"Menagerie DK", ["Fire Fly"]},
    {:"Herren DK",
     [
       "Slippery Slope",
       "Bonechill Stegodon"
       #  "Meltemental",
       #  "Malted Magma",
       #  "Clearance Promoter",
       #  "Bonechill Stegodon",
       #  "Slippery Slope",
       #  "Travel Security",
       #  "Ancient Raptor",
       #  "Endbringer Umbra",
       #  "Eternal Layover",
       #  "Ancient Raptor"
     ]},
    {:"Zerg DK", ["Baneling Barrage", "Hive Queen", "Infestor", "Spawning Pool"]},
    {:"Unholy DK",
     ["Grave Strength", "Tomb Guardians", "Battlefield Necromancer", "Skeletal Sidekick"]},
    {:"Menagerie DK", ["Monstrous Mosquito", "Murmy", "Observer of Mysteries"]},
    # 15.5
    {:"Control DK",
     [
       "Stitched Giant",
       "Fyrakk the Blazing",
       "Griftah, Trusted Vendor",
       "Frosty Decor",
       "Threads of Despair",
       "Staff of the Endbringer",
       "Hematurge",
       "Blob of Tar",
       "Airlock Breach",
       "Bob the Bartender",
       "Marin the Manager",
       "Kil'jaeden",
       "Corpse Explosion",
       "Reluctant Wrangler",
       "Staff of the Enderbringer",
       "Hideous Husk",
       "Infested Breath",
       "Sanguine Infestation",
       "Morbid Swarm",
       "Dreadhound Handler",
       "Elise the Navigator",
       "Chillfallen Baron",
       "Ancient of Yore",
       "Zilliax Deluxe 3000",
       "Dirty Rat",
       "Creature of Madness",
       "Nightmare Lord Xavius",
       "Ysera, Emerald Aspect",
       "The Ceaseless Expanse",
       "Exarch Maladaar",
       "Scarab Keychain",
       "Orbital Moon",
       "Foamrender",
       "Vampiric Blood",
       "Poison Breath",
       "Reluctant Wrangler",
       "Shaladrassil",
       "Demolition Renovator",
       "Grotesque Runeblade",
       "Gnomelia, S.A.F.E. Pilot"
     ]},
    {:"Herren DK",
     [
       "Horn of Winter",
       "Frost Strike",
       "Slippery Slope",
       "Crypt Map",
       "Rambunctious Stuffy",
       "Glacial Shard",
       "Mixologist",
       "Troubled Mechanic",
       "Ancient Raptor",
       "Ghouls' Night"
     ]},
    {:"Starship DK", ["Brittlebone Buccaneer", "Silk Stitching"]},
    {:"Handbuff DK",
     [
       "Toysnatching Geist",
       "Rainbow Seamstress",
       "Nerubian Swarmguard",
       "Gnome Muncher"
     ]},
    {:"Control DK",
     [
       "Dreamplanner Zephryus",
       "Rite of Atrocity",
       "Prize Vendor",
       "Wisp",
       "Ursoc",
       "Floppy Hydra",
       "Death Strike"
     ]},
    {:"Herren DK", ["Malted Magma", "Asphyxiate"]}
  ]

  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DK")
  end

  def wild(_card_info) do
    nil
  end
end
