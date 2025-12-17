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
    {:Egglock,
     [
       "Holy Eggbearer",
       "The Egg of Khelos",
       "Abusive Sergeant"
     ]},
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
    # 5.5
    {:Rafaamlock,
     [
       "Mixologist",
       "Blob of Tar",
       "Dirty Rat"
     ]},
    {:Shredslock,
     [
       "Devious Coyote",
       "Horizon's Edge",
       "Flame Imp",
       "Zergling",
       "Entropic Continuity"
     ]},
    # {:"Divergence Warlock",
    #  [
    #    "Divergence",
    #    "Agamaggan",
    #    "Shaladrassil"
    #  ]},
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
     ]},
    {:Rafaamlock,
     [
       "Rotheart Dryad",
       "Petal Peddler",
       "Possessed Animancer",
       "Whelp of the Infinite",
       "Giftwrapped Whelp",
       "Nightmare Lord Xavius",
       "Twilight Timehopper",
       "Fatebreaker",
       "Glacial Shard",
       "Dreadhound Handler",
       "Griftah, Trusted Vendor",
       "Drain Soul",
       "RAFAAM LADDER!!",
       "Portal Vanguard",
       "Creature of Madness"
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
    # {:Egglock, [
    # "Dissolving Ooze",
    # "Conflagrate",
    # "Spirit Bomb",
    # "Eat! The! Imp!",
    # "Archdruid of Thorns",
    # "Summoner Darkmarrow"
    # ]},
    {:"Whizbang Warlock", ["Tar Slime", "Scarab Keychain"]}
    # {:"Animacer Warlock",
    #  [
    #    "Ultragigasaur",
    #    "Meadowstrider",
    #    "Travel Security",
    #    "Possessed Animancer",
    #    "Asphyxiodon",
    #    "Beached Whale"
    #  ]},
    # {:"Divergence Warlock",
    #  [
    #    "Dark Alley Pact",
    #    "Drain Soul",
    #    "Fractured Power"
    #  ]},
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
