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
       "Shambling Zombietank",
       "Nerubian Swarmguard",
       "Blood Tap"
     ]},
    # 5.5
    {:"Menagerie DK", ["Menagerie Mug", "Menagerie Jug", "Fire Fly", "Malignant Horror"]},
    {:"Herenn DK",
     [
       "High Cultist Herenn",
       "Overplanner",
       "Wakener of Souls",
       "Meltemental",
       "Travel Security",
       "Mother Duck",
       "Slippery Slope",
       "Bonechill Stegodon",
       "Ancient Raptor",
       "Ghouls' Night"
     ]},
    {:"Control DK",
     [
       "The Ceaseless Expanse",
       "Naralex, Herald of the Flights",
       "Vampiric Blood",
       "Griftah, Trusted Vendor",
       "Hideous Husk",
       "Matching Outfits",
       "Stitched Giant",
       "Shaladrassil",
       "Reanimated Pterrodax",
       "Fyrakk the Blazing",
       "Dreamplanner Zephyrus",
       "Ysera, Emerald Aspect",
       "Exarch Maladaar",
       "Zilliax Deluxe 3000",
       "Frosty Decor",
       "Threads of Despair",
       "Staff of the Endbringer",
       "Blob of Tar",
       "Airlock Breach",
       "Bob the Bartender",
       "Marin the Manager",
       "Kil'jaeden",
       "Corpse Explosion",
       "Staff of the Enderbringer",
       "Infested Breath",
       "Sanguine Infestation",
       "Morbid Swarm",
       "Dreadhound Handler",
       "Elise the Navigator",
       "Chillfallen Baron",
       "Ancient of Yore",
       "Dirty Rat",
       "Creature of Madness",
       "Nightmare Lord Xavius",
       "Scarab Keychain",
       "Foamrender",
       "Vampiric Blood",
       "Poison Breath",
       "Demolition Renovator",
       "Grotesque Runeblade",
       "Steamcleaner",
       "Stranded Spaceman",
       "Headless Horseman",
       "Adaptive Amalgam",
       "Floppy Hydra",
       "Threads of Despair",
       "Braingill",
       "The 8 Hands from Beyond",
       "The Headless Horseman"
     ]},
    {:"Frost DK", ["Frostwyrm's Fury", "Cryosleep", "Thassarian", "Marrow Manipulator"]},
    {:"Zerg DK", ["Baneling Barrage", "Hive Queen", "Infestor", "Spawning Pool"]},
    # 10.5
    {:"Unholy DK",
     ["Grave Strength", "Tomb Guardians", "Battlefield Necromancer", "Skeletal Sidekick"]},
    {:"Menagerie DK", ["Monstrous Mosquito", "Murmy", "Observer of Mysteries"]},
    {:"Herren DK",
     [
       "Horn of Winter",
       "Frost Strike",
       "Crypt Map",
       "Rambunctious Stuffy",
       "Glacial Shard",
       "Mixologist",
       "Troubled Mechanic"
     ]},
    {:"Starship DK", ["Brittlebone Buccaneer", "Silk Stitching"]},
    {:"Handbuff DK",
     [
       "Toysnatching Geist",
       "Rainbow Seamstress",
       "Gnome Muncher"
     ]},
    # 15.5
    {:"Control DK",
     [
       "Rite of Atrocity",
       "Prize Vendor",
       "Wisp",
       "Ursoc",
       "Floppy Hydra",
       "Orbital Moon",
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
