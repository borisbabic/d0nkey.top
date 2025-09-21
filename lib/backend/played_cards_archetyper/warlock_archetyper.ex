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
    {:Egglock,
     [
       "Dissolving Ooze",
       "Holy Eggbearer",
       "Eliza Goreblade",
       "The Egg of Khelos",
       "Carnivorous Cubicle",
       "Eat! The! Imp!"
     ]},
    {:"Bot? Warlock",
     [
       "Coldlight Seer",
       "Sunfury Protector",
       "Raid Leader",
       "Murloc Warleader",
       "Dire Wolf Alpha",
       "Murloc Tidecaller",
       "Twilight Drake",
       "Redgill Razorjaw",
       "Annoy-o-Tron",
       "Lifedrinker",
       "Murloc Tidehunter",
       "Abusive Seargeant"
     ]},
    # 5.5
    {:"Animacer Warlock",
     [
       "Ultragigasaur",
       "Meadowstrider",
       "Travel Security",
       "Possessed Animancer",
       "Asphyxiodon",
       "Beached Whale"
     ]},
    {:"Mill Warlock",
     [
       "Adaptive Amalgam",
       "Archdruid of Thorns",
       "Escape Pod",
       "Plated Beetle",
       "Frostbitten Freebooter",
       "Prize Vendor"
     ]},
    {:"Wallow Warlock",
     [
       "Raptor Herald",
       "Overgrown Horror",
       "Treacherous Tormentor",
       "Wallow, the Wretched",
       "Avant-Gardening"
     ]},
    {:"Concierge Warlock",
     [
       "Concierge",
       "Champions of Azeroth",
       "Rockskipper",
       "Sleepy Resident",
       "Mixologist",
       "Griftah, Trusted Vendor",
       "Tidepool Pupil",
       "Corpsicle"
     ]},
    {:"Deathrattle Warlock",
     [
       "Brittlebone Buccaneer",
       "Felfire Bonfire",
       "Bat Mask",
       "The Exodar",
       "The Ceaseless Expanse",
       "Wheel of DEATH!!!",
       "Arkonite Defense Crystal"
     ]},
    # 10.5
    {:"Dorian Warlock",
     [
       "Shaladrassil",
       "Puppetmaster Dorian",
       "Agamaggan",
       "Deadline",
       "Ragnaros the Firelord",
       "The Solarium",
       "Overplanner",
       "Demonic Studies",
       "Spelunker",
       "Kerrigan, Queen of Blades",
       "Mortal Coil"
     ]},
    {:"Whizbang Warlock", ["Tar Slime", "Scarab Keychain"]}
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
