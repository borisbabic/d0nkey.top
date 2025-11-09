# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Shaman", ["Spirit of the Mountain"]},
    {:"Whizbang Shaman",
     [
       "Turn the Tides",
       "Sludge Slurper",
       "Serpentshrine Portal",
       "Finders Keepers",
       "Gorloc Ravager",
       "Spawnpool Forager",
       "Primalfin Lookout",
       "Clownfish",
       "Quest Accepted!",
       "Fishflinger",
       "Brrrloc",
       "Scargil",
       "South Coast Chieftain",
       "Ancestral Knowledge",
       "Command of Neptulon",
       "Underbelly Angler"
     ]},
    {:"Masochist Shaman",
     [
       "Stormrook",
       "Nascent Bolt",
       "Lightning Rod",
       "Acolyte of Pain"
     ]},
    {:"Pirate Shaman",
     [
       "Treasure Distributor",
       "Hozenm Roughhouser",
       "Undercover Cultist",
       "Sigil of Skydiving",
       "Adrenaline Fiend"
     ]},
    {:"Terran Shaman",
     [
       "SCV",
       "Lift Off",
       "Jim Raynor",
       "The Exodar",
       "Arkonite Defense Crystal"
     ]},
    # 5.5
    {:"Nebula Shaman",
     [
       "Nebula"
     ]},
    {:"Imbue Shaman",
     [
       "Flutterwing Guardian",
       "Bitterbloom Knight",
       "Petal Picker",
       "Resplendent Dreamweaver",
       "Glowroot Lure",
       "Plucky Podling"
     ]},
    {:"Elemental Shaman",
     [
       "Bralma Searstone",
       "Lampligher",
       "City Chief Esho",
       "Fire Fly",
       "Menacing Nimbus",
       "Fire Breath",
       "Wailing Vaipor",
       "Slagclaw"
     ]},
    {:"Asteroid Shaman",
     [
       "Moonstone Mauler",
       "Ultraviolet Breaker"
     ]},
    {:"Endseer Shaman",
     [
       "Endbringer Umbra",
       "Troubled Mechanic",
       "Critter Caretaker",
       "Mixologist",
       "Prize Vendor",
       "Meteor Storm",
       "Wisp",
       "Demolition Renovator",
       "The Ceaseless Expanse",
       "Incindius",
       "Scarab Keychain",
       "Farseer Nobundo"
     ]},
    # 10.5
    {:"Nebula Shaman",
     [
       "Planetary Navigator",
       "Marin the Manager",
       "Matching Outfits",
       "Ysera, Emerald Aspect",
       "Naralex, Herald of the Flights"
     ]},
    {:"Pirate Shaman", ["Hozen Roughhouser"]},
    {:"Masochist Shaman", ["Sand Art Elemental", "Skirting Death"]},
    {:"Imbue Shaman", ["Aspect's Embrace"]},
    {:"Nebula Shaman",
     [
       "Parrot Sanctuary",
       "Shudderblock",
       "Turbulus",
       "Baking Soda Volcano",
       "Birdwatching",
       "Bumbling Bellhop",
       "Hagatha the Fabled",
       "Elise the Navigator",
       "Frosty Décor"
     ]},
    # 15.5
    {:"Masochist Shamkan",
     [
       "Primordial Overseer",
       "Flux Revenant",
       "Paraglide",
       "High King's Hammer",
       "Thunderquake"
     ]},
    {:"Pirate Shaman",
     [
       "Zilliax Deluxe 3000",
       "Patches the Pilot",
       "Weapons Attendant",
       "Space Pirate"
     ]},
    {:"Elemental Shaman", ["Sizzling Swarm", "Volcanic Thrasher", "Lava Flow"]},
    {:"Endseer Shaman", ["Dirty Rat"]},
    {:"Terran Shaman", ["Starport", "Lock On"]},
    {:"Nebula Shaman",
     [
       "Murloc Growfin",
       "Hex",
       "Cosmonaut",
       "Far Sight"
     ]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Shaman")
  end

  def wild(_card_info) do
    nil
  end
end
