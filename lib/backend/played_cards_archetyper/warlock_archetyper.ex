# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Tick Tock Warlock", ["Battle at the End Time"]},
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
    {:Egglock,
     [
       "Holy Eggbearer",
       "The Egg of Khelos",
       "Dissolving Ooze",
       "Abusive Sergeant"
     ]},
    # 5.5
    {:"Wallow Warlock",
     [
       "Raptor Herald",
       "Overgrown Horror",
       "Treacherous Tormentor",
       "Wallow, the Wretched",
       "Avant-Gardening",
       "Creature of Madnes",
       "Foreboding Flame",
       "Demonic Studies",
       "Shadowflame Stalker"
     ]},
    {:Shredslock,
     [
       "Devious Coyote",
       "Horizon's Edge",
       "Flame Imp",
       "Zergling",
       "Party Fiend",
       "Cursed Souvenir",
       "Sizzling Cinder",
       "Prescient Slitherdrake",
       "Ruinous Velocidrake",
       "Entropic Continuity"
     ]},
    # {:"Divergence Warlock",
    #  [
    #    "Divergence",
    #    "Agamaggan",
    #    "Shaladrassil"
    #  ]},
    {:"Starship Warlock",
     ["Heart of the Legion", "Felfire Thrusters", "Dimensional Core", "The Exodar"]},
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
       "Murloc Tidehunter"
     ]},
    # 10.5
    {:"Mill Warlock",
     [
       "Stranglevine",
       "Bucket of Soldiers",
       "Adaptive Amalgam",
       "Archdruid of Thorns",
       "Escape Pod",
       "Plated Beetle",
       "Living Flame",
       "Prize Vendor"
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
