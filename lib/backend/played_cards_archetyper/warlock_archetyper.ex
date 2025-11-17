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
       "Horizon's Edge",
       "Petal Peddler",
       "Whelp of the Infinite",
       "Dreadhound Handler",
       "Ruinous Velocidrake",
       "Giftwrapped Whelp",
       "Party Planner Vona"
     ]},
    {:"Wallow Warlock",
     [
       "Raptor Herald",
       "Overgrown Horror",
       "Treacherous Tormentor",
       "Wallow, the Wretched",
       "Avant-Gardening",
       "Shadowflame Stalker"
     ]},
    # 5.5
    {:Egglock,
     [
       "Dissolving Ooze",
       "Holy Eggbearer",
       "The Egg of Khelos",
       "Abusive Sergeant"
     ]},
    {:"Divergence Warlock",
     [
       "Divergence",
       "Agamaggan",
       "Shaladrassil"
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
    {:"Mill Warlock",
     [
       "Adaptive Amalgam",
       "Archdruid of Thorns",
       "Escape Pod",
       "Plated Beetle",
       "Living Flame",
       "Prize Vendor"
     ]},
    # 10.5
    {:Shredslock,
     [
       "Living Paradox",
       "Maze Guide",
       "Corpsicle",
       "Dreambound Raptor",
       "Murmy"
     ]},
    {:Painlock,
     [
       "Wisp",
       "Spelunker",
       "Sizzling Cinder",
       "Platysaur",
       "Dreamplanner Zphrys",
       "The Solariumn",
       "Glacial Shard",
       "Party Fiend",
       "Cursed Souvenir",
       "Zilliax Deluxe 3000",
       "Devious Coyote",
       "Cult Neophyte",
       "Entropic Continuity",
       "Flame Imp",
       "Tachyon Barrage",
       "Twilight Timehoppor"
     ]},
    {:"Wallow Warlock",
     [
       "Creature of Madness",
       "Foreboding Flame"
     ]},
    {:Rafaamlock,
     [
       "Rotheart Dryad",
       "Dirty Rat"
     ]},
    {:"Wallow Warlock",
     [
       "Demonic Studies",
       "Mixologist"
     ]},
    {:"Divergence Warlock",
     [
       "Dark Alley Pact",
       "Drain Soul",
       "Fractured Power"
     ]},

    # {:"Concierge Warlock",
    #  [
    #    "Concierge",
    #    "Champions of Azeroth",
    #    "Rockskipper",
    #    "Sleepy Resident",
    #    "Mixologist",
    #    "Griftah, Trusted Vendor",
    #    "Tidepool Pupil"
    #  ]},
    # {:"Deathrattle Warlock",
    #  [
    #    "Brittlebone Buccaneer",
    #    "Felfire Bonfire",
    #    "Bat Mask",
    #    "The Exodar",
    #    "The Ceaseless Expanse",
    #    "Wheel of DEATH!!!",
    #    "Arkonite Defense Crystal"
    #  ]},
    # 10.5
    {:"Whizbang Warlock", ["Tar Slime", "Scarab Keychain"]},
    {:"Animacer Warlock",
     [
       "Ultragigasaur",
       "Meadowstrider",
       "Travel Security",
       "Possessed Animancer",
       "Asphyxiodon",
       "Beached Whale"
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
