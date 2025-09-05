# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Warlock", ["Escape the Underfel"]},
    {:"Whizbang Warlock",
     [
       "Furnace Fuel",
       "Archivist Elysiana",
       "Waste Remover",
       "Rin, Orchestrator of Doom",
       "Blood Shard Bristleback",
       "Barrens Scavenger",
       "Fanottem, Lord of the Opera",
       "Chaos Creation",
       "Neeru Fireblade",
       "Fracking",
       "Chef Nomi"
     ]},
    {:"Starship Warlock", ["Heart of the Legion", "Felfire Thrusters", "Dimensional Core"]},
    {:"Wallow Warlock",
     [
       "Raptor Herald",
       "Overgrown Horror",
       "Treacherous Tormentor",
       "Wallow, the Wretched",
       "Avant-Gardening"
     ]},
    {:"Mill Warlock", ["Adaptive Amalgam", "Archdruid of Thorns", "Escape Pod", "Plated Beetle"]},
    # 5.5
    {:"Deathrattle Warlock", ["Travel Security", "Brittlebone Buccaneer", "Felfire Bonfire"]},
    {:"Concierge Warlock",
     [
       "Concierge",
       "Champions of Azeroth",
       "Rockskipper",
       "Sleepy Resident",
       "Mixologist",
       "Griftah, Trusted Vendor"
     ]},
    {:"Starship Warlock", ["Arkonite Defense Crystal"]},
    {:"Deckless Warlock",
     [
       "Clearance Promoter",
       "Youthful Brewmaster",
       "Wheel of DEATH!!!",
       "Kil'jaeden",
       "Dirty Rat",
       "Sleepy Resident",
       "The Ceaseless Expanse",
       "Cursed Campaign"
     ]},
    {:"Dorian Warlock",
     [
       "Shaladrassil",
       "Puppetmaster Dorian",
       "Agamaggan",
       "Naralex, Herald of the Flights",
       "Fyrakk the Blazing",
       "Deadline",
       "Ragnaros the Firelord",
       "Mortal Coil"
     ]},
    # 10.5
    {:"Mill Warlock", ["Prize Vendor", "Gnomelia, S.A.F.E. Pilot"]},
    {:"Animancer Warlock",
     [
       "Asphyxiodon",
       "Beached Whale",
       "Possessed Animancer",
       "Kerrigan, Queen of Blades",
       "Soul Searching",
       "Demonic Studies",
       "Bloodpetal Biome"
     ]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warlock")
  end

  def wild(_card_info) do
    nil
  end
end
