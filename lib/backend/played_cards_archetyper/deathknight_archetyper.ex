# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DK", ["Reanimate the Terror"]},
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
    {:"Menagerie DK", ["Menagerie Mug", "Fire Fly", "Menagerie Jug", "Murmy"]},
    {:"Herren DK",
     [
       "Bonechill Stegodon",
       "Overplanner",
       "Travel Security",
       "Ancient Raptor",
       "Endbringer Umbra",
       "Wakener of Souls",
       "Eternal Layover",
       "Ancient Raptor"
     ]},
    {:"Control DK",
     [
       "Fyrakk the Blazing",
       "Griftah, Trusted Vendor",
       "Frosty Decor",
       "Threads of Despair",
       "Staff of the Endbringer",
       "Hematurge",
       "Dirty Rat",
       "Blob of Tar",
       "Airlock Breach",
       "Bob the Bartender",
       "Marin the Manager",
       "Kil'jaeden",
       "Corpse Explosion",
       "Reluctant Wrangler",
       "Steamcleaner",
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
       "The Headless Horseman",
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
       "Auchenai Death-Speaker",
       "Troubled Mechanic",
       "High Cultist Herenn",
       "Ghouls' Night"
     ]},
    {:"Starship DK", ["Brittlebone Buccaneer", "Silk Stitching", "Wild Pyromancer"]},
    {:"Handbuff DK",
     [
       "Toysnatching Geist",
       "Rainbow Seamstress",
       "Reanimated Pterrordax",
       "Nerubian Swarmguard",
       "Gnome Muncher",
       "Shambling Zombietank"
     ]},
    {:"Menagerie DK", ["Monstrous Mosquito", "Harbringer of Winter", "Menagerie DK"]},
    {:"Control DK",
     [
       "Buttons",
       "Zergling",
       "Dreamplanner Zephryus",
       "Rite of Atrocity",
       "Prize Vendor",
       "Wisp",
       "Adaptive Amalgam",
       "Kerrigan, Queen of Blades",
       "Ursoc",
       "Plucky Paintfin",
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
