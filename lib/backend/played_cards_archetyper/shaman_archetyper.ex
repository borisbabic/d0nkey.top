# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Shaman", ["Spirit of the Mountain"]},
    {:"Terran Shaman",
     ["Arkonite Defense Crystal", "Lift Off", "Jim Raynor", "The Exodar", "SCV", "Ghost"]},
    {:"Imbue Shaman",
     ["Flutterwing Guardian", "Bitterbloom Knight", "Petal Picker", "Living Garden"]},
    {:"Asteroid Shaman",
     [
       "Ethereal Oracle",
       "Moonstone Mauler",
       "Ultraviolet Breaker",
       "Novice Zapper",
       "Bloodmage Thalnost",
       "Bolide Behemoth"
     ]},
    {:"Elemental Shaman",
     ["Wailing Vapor", "Sizzling Cinder", "Slagmaw", "Fire Fly", "Menacing Nimbus", "Tar Slime"]},
    {:"Nebula Shaman", ["Bumbling Belhop", "Al'Akir the Windlord", "Nebula", "With Upon a Star"]},
    {:"Imbue Shaman", ["Matching Outfits"]},
    {:"Nebula Shaman",
     [
       "Cabaret Headliner",
       "Hagatha the Fabled",
       "Parrot Sanctuary",
       "Frosty Décor",
       "Elise the Navigator",
       "Fyrakk the Blazing",
       "The Ceaseless Expanse",
       "Farseer Nobundo",
       "Flight of the Firehawk"
     ]},
    {:"Imbue Shaman", ["Aspect's Embrace"]},
    {:"Elemental Shaman", ["Sizzling Swarm", "Volcanic Thrasher", "Lava Flow"]},
    {:"Terran Shaman", ["Starport", "Lock On", "Marin the Manager", "Dirty Rat"]},
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

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Shaman")
  end

  def wild(_card_info) do
    nil
  end
end
