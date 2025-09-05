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
    {:"Terran Shaman",
     ["Arkonite Defense Crystal", "Lift Off", "Jim Raynor", "The Exodar", "SCV", "Ghost"]},
    {:"Nebula Shaman",
     [
       "Bumbling Bellhop",
       "Al'Akir the Windlord",
       "Nebula",
       "With Upon a Star",
       "Beast Speaker Taka",
       "Naralex, Herald of the Flights"
     ]},
    {:"Imbue Shaman",
     [
       "Flutterwing Guardian",
       "Bitterbloom Knight",
       "Petal Picker",
       "Living Garden",
       "Resplendent Dreamweaver",
       "Glowroot Lure",
       "Plucky Podling",
       "Malorne the Waywatcher"
     ]},
    # 5.5
    {:"Elemental Shaman",
     [
       "Wailing Vapor",
       "Sizzling Cinder",
       "Slagmaw",
       "Fire Fly",
       "Menacing Nimbus",
       "Tar Slime",
       "Lamplighter",
       "Fire Breath",
       "Bralma Searstone",
       "Lava Flow",
       "Chatty Macaw",
       "Blob of Tar",
       "Cinderfin"
     ]},
    {:"Asteroid Shaman",
     [
       "Ethereal Oracle",
       "Moonstone Mauler",
       "Ultraviolet Breaker",
       "Novice Zapper",
       "Emerald Bounty",
       "Bloodmage Thalnos",
       "Bolide Behemoth",
       "Meteor Storm",
       "Paraglide"
     ]},
    {:"Nebula Shaman",
     [
       "Cabaret Headliner",
       "Dissolving Ooze",
       "Hagatha the Fabled",
       "Parrot Sanctuary",
       "Frosty Décor",
       "Elise the Navigator",
       "Fyrakk the Blazing",
       "Bob the Bartender",
       "Lightning Storm",
       "Fairy Tale Forest",
       "Ysera, Emerald Aspect",
       "The Ceaseless Expanse",
       "Farseer Nobundo"
     ]},
    {:"Imbue Shaman", ["Aspect's Embrace"]},
    {:"Elemental Shaman", ["Sizzling Swarm", "Volcanic Thrasher", "Lava Flow"]},
    # 10.5
    {:"Terran Shaman", ["Starport", "Lock On", "Dirty Rat"]},
    {:"Nebula Shaman",
     [
       "Murloc Growfin",
       "Pop-Up Book",
       "Hex",
       "Baking Soda Volcano",
       "Shudderblock",
       "Cosmonaut",
       "Living Flame",
       "Birdwatching",
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
