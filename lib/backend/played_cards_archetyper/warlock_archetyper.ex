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
    {:Rafaamlock,
     [
       "Tiny Rafaam",
       "Green Rafaam",
       "Murloc Rafaam",
       "Explorer Rafaam",
       "Warchief Rafaam",
       "Calamitous Rafaam",
       "Mindflayer R'faam",
       "Giant Rafaam",
       "Archmage Rafaam",
       "Timethief Rafaam"
     ]},
    {:Shredslock,
     [
       "Whelp of the Infinite",
       "Horizon's Edge",
       "Dreadhound Handler",
       "Living Paradox",
       "Ancient Raptor",
       "Devious Coyote",
       "Murmy",
       "Petal Peddler",
       "Ruinous Velocidrake",
       "Zergling",
       "Flame Imp",
       "Giftwrapped Whelp",
       "Dreambound Raptor",
       "Fatebreaker",
       "Fiendish Servant",
       "King Mukla",
       "Twilight Timehopper",
       "Entropic Continuity",
       "Tachyon Barrage",
       "The Solarium",
       "Razidir",
       "Party Planner Vona",
       "PArty Fiend",
       "Sizzling Cinder"
     ]},
    {:Egglock,
     [
       "Dissolving Ooze",
       "Holy Eggbearer",
       "Eliza Goreblade",
       "The Egg of Khelos",
       "Eat! The! Imp!"
     ]},
    # 5.5
    {:"Divergence Warlock",
     [
       "Divergence",
       "Agamaggan",
       "Shaladrassil",
       "Spelunker",
       "Kerrigan, Queen of Blades"
     ]},
    {:Egglock,
     [
       "Abusive Sergeant"
     ]},
    {:"Starship Warlock", ["Heart of the Legion", "Felfire Thrusters", "Dimensional Core"]},
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
    {:"Animacer Warlock",
     [
       "Ultragigasaur",
       "Meadowstrider",
       "Travel Security",
       "Possessed Animancer",
       "Asphyxiodon",
       "Beached Whale"
     ]},
    # 10.5
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
