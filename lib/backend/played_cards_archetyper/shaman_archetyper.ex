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
    {:"Hagatha Shaman",
     [
       "Furious Fowls",
       "Death Roll",
       "Living Flame",
       "Bumbling Bellhop",
       "Furious Fowls",
       "Wish Upon a Star",
       "Parrot Sanctuary",
       "Al'Akir the Windlord"
     ]},
    {:"Masochist Shaman",
     [
       "Stormrook",
       "Nascent Bolt",
       "Lightning Rod",
       "Acolyte of Pain"
     ]},
    # {:"Pirate Shaman",
    #  [
    #    "Treasure Distributor",
    #    "Hozenm Roughhouser",
    #    "Undercover Cultist",
    #    "Sigil of Skydiving",
    #    "Adrenaline Fiend"
    #  ]},
    {:"Terran Shaman",
     [
       "SCV",
       "Lift Off",
       "Jim Raynor",
       "The Exodar",
       "Arkonite Defense Crystal"
     ]},
    # 5.5
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
    {:"Hagatha Shaman",
     [
       "Hagatha the Fabled",
       "Birdwatching",
       "Turbulus",
       "Shudderblock",
       "Elise the Navigator",
       "Frosty Décor",
       "Murloc Growfin",
       "Flight of the Firehawk",
       "Zilliax Deluxe 3000",
       "Primordial Overseer",
       "Pop-Up Book",
       "Muradin, High King",
       "Avatar Form",
       "High King's Hammer",
       "Static Shock"
     ]},
    {:"Masochist Shaman", ["Sand Art Elemental", "Skirting Death"]},
    {:"Imbue Shaman", ["Aspect's Embrace"]},
    {:"Elemental Shaman", ["Sizzling Swarm", "Volcanic Thrasher", "Lava Flow"]},
    {:"Terran Shaman", ["Starport", "Lock On"]}
    # 15.5
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
