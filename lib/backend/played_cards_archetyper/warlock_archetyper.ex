# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{
    "Zoo Warlock" => [{:start_of_game, ["Godfrey the Betrayer"]}]
  }
  @standard_config [
    "Tick Tock Warlock": {["Battle at the End Time"], []},
    "Quest Warlock": {["Escape the Underfel"], []},
    Rafaamlock:
      {[
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
       ], []},
    "Wallow Warlock": [
      all: [["Creature of Madness"], ["Cult Neophyte"]],
      all: [["Cursed Catacombs"], ["Wallow, the Wretched"]]
    ],
    Zoolock: [all: [["Tachyon Barrage"], ["Vaultkeeper"]]],
    "Wallow Warlock": [all: [["Raptor Herald"], ["Treacherous Tormentor"]]],
    Zoolock: [
      all: [
        ["Vaultkeeper"],
        [
          "Cult Neophyte",
          "Entropic Continuity",
          "Floating Lessons",
          "Glacial Shard",
          "Platysaur",
          "Ruinous Velocidrake",
          "Twilight Egg",
          "Twilight Timehopper",
          "Zakajz the Corruptor"
        ]
      ],
      all: [["Blasphemy"], ["Royal Librarian"]],
      all: [["Tachyon Barrage"], ["Twilight Egg"]]
    ],
    "C'Thun Warlock": [all: [["Defias Smuggler"], ["Ultraxion"]]],
    Zoolock: [
      all: [["Blasphemy"], ["Entropic Continuity", "Platysaur", "Twilight Egg"]],
      all: [["Platysaur"], ["Kith'ix", "Zakajz the Corruptor"]],
      all: [["Floating Lessons"], ["Twilight Egg"]]
    ],
    "Wallow Warlock": [
      all: [["Raptor Herald"], ["Mawman Cultist", "Twilight Timehopper"]],
      all: [["Creature of Madness"], ["Twilight Timehopper"]]
    ],
    "Yogg Warlock": [all: [["Mastermind Yogg-Saron"], ["Titanic Thrasher"]]],
    Zoolock: [all: [["Glacial Shard"], ["Platysaur"]]],
    "C'Thun Warlock": [
      all: [["Defias Smuggler"], ["Darkest Depths", "Deathwing, Worldbreaker"]],
      all: [["Treasure Fiend"], ["Ultraxion"]]
    ],
    Zoolock: [all: [["Cult Neophyte"], ["Platysaur"]]],
    "C'Thun Warlock": [
      all: [["Archwitch Willow"], ["Spawn of C'Thun"]],
      all: [["Frame Job"], ["Shrine of Twilight"]]
    ],
    Zoolock: [
      all: [["Cult Neophyte"], ["Entropic Continuity"]],
      all: [["Platysaur"], ["Twilight Egg"]]
    ],
    Egglock: [
      all: [
        ["The Egg of Khelos"],
        ["Conflagrate", "Drain Soul", "Holy Eggbearer"]
      ]
    ],
    "C'Thun Warlock": [
      all: [
        ["Drain Soul"],
        ["Deathwing, Worldbreaker", "Defias Smuggler", "Ultraxion"]
      ],
      all: [["Moragg"], ["Spawn of C'Thun"]],
      all: [["Shrine of Twilight"], ["Steamcleaner"]]
    ],
    "Drake Warlock": [all: [["Drain Soul"], ["Earthen Drake"]]],
    "Yogg Warlock": [
      all: [["Mastermind Yogg-Saron"], ["Crystalline Golem", "Mawman Cultist"]]
    ],
    "C'Thun Warlock": [
      all: [["C'Thun, Eye of the Empire"], ["Godfrey the Betrayer"]]
    ],
    "Wallow Warlock": [
      all: [
        ["Creature of Madness"],
        ["Avant-Gardening", "Ritual of Summoning", "Wallow, the Wretched"]
      ],
      all: [["Raptor Herald"], ["Ritual of Summoning"]]
    ],
    "C'Thun Warlock": [
      all: [
        ["C'Thun, Eye of the Empire"],
        ["Deathwing, Worldbreaker", "Drain Soul", "Hellfire", "Spire of Solitude"]
      ],
      all: [["Gargantuan Slitherer"], ["Whelp of the Infinite"]],
      all: [["Shrine of Twilight"], ["Treasure Fiend"]]
    ],
    Zoolock: [all: [["Mawman Cultist"], ["Twilight Egg"]]],
    "Yogg Warlock": [all: [["Titanic Thrasher"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [all: [["Conflagrate"], ["Spawn of C'Thun"]]],
    Zoolock: [all: [["Blasphemy"], ["Cult Neophyte", "Twilight Timehopper"]]],
    "C'Thun Warlock": [
      all: [
        ["Deathwing, Worldbreaker"],
        ["Ancient Augur", "Cursed Catacombs", "Spawn of C'Thun"]
      ],
      all: [["Caged Cranium"], ["Cho'gall, Mastermind"]]
    ],
    Zoolock: [
      all: [["Entropic Continuity"], ["Zakajz the Corruptor"]],
      all: [["Platysaur"], ["Ritual of Summoning"]]
    ],
    "Yogg Warlock": [all: [["Mastermind Yogg-Saron"], ["Rotheart Dryad"]]],
    "Demon Warlock": [all: [["Archwitch Willow"], ["Caged Cranium"]]],
    "C'Thun Warlock": [
      all: [["Drain Soul"], ["Gargantuan Slitherer"]],
      all: [["Glacial Shard"], ["Ultraxion"]]
    ],
    "C'Thun Warlock": [all: [["Rotten Apple"], ["Spawn of C'Thun"]]],
    Zoolock: [
      all: [["Floating Lessons"], ["Entropic Continuity", "Glacial Shard"]]
    ],
    "C'Thun Warlock": [
      all: [["Ancient Augur"], ["C'Thun, Eye of the Empire"]],
      all: [["Defias Smuggler"], ["Treasure Fiend"]]
    ],
    "C'Thun Warlock": [all: [["Kith'ix"], ["Ultraxion"]]],
    Zoolock: [all: [["Twilight Egg"], ["Cult Neophyte", "Twilight Timehopper"]]],
    "C'Thun Warlock": [
      all: [["Cho'gall, Mastermind"], ["Imp Gang Stooge", "Shrine of Twilight"]],
      all: [["Ancient Augur"], ["Treasure Fiend"]],
      all: [["Defias Smuggler"], ["Spire of Solitude"]],
      all: [["Gargantuan Slitherer"], ["Shrine of Twilight"]]
    ],
    "Wallow Warlock": [all: [["Creature of Madness"], ["Ritual of C'Thun"]]],
    "Yogg Warlock": [
      all: [["Treasure Fiend"], ["Elise the Navigator", "Mastermind Yogg-Saron"]],
      all: [["Spire of Solitude"], ["Titanic Thrasher"]]
    ],
    "C'Thun Warlock": [all: [["Spawn of C'Thun"], ["Treasure Fiend"]]],
    "Godfrey Warlock": [all: [["Blasphemy"], ["Spire of Solitude"]]],
    "Demon Warlock": [all: [["Archwitch Willow"], ["Moragg"]]],
    "C'Thun Warlock": [all: [["Caged Cranium"], ["Ultraxion"]]],
    "C'Thun Warlock": [all: [["Deathwing, Worldbreaker"], ["Shrine of Twilight"]]],
    Zoolock: [all: [["Entropic Continuity"], ["Glacial Shard"]]],
    "C'Thun Warlock": [
      all: [
        ["Annihilation"],
        ["Gargantuan Slitherer", "Shrine of Twilight", "Spawn of C'Thun"]
      ],
      all: [["C'Thun, Eye of the Empire"], ["Shadowsworn Disciple"]],
      all: [["Darkest Depths"], ["Treasure Fiend"]],
      all: [["The Unseen Atlas"], ["Ultraxion"]]
    ],
    "C'Thun Warlock": [all: [["Devious Coyote"], ["Ritual of C'Thun"]]],
    "Yogg Warlock": [all: [["Mawman Cultist"], ["Treasure Fiend"]]],
    Zoolock: [all: [["Entropic Continuity"], ["Mawman Cultist"]]],
    "Yogg Warlock": [all: [["Hellfire"], ["Titanic Thrasher"]]],
    "C'Thun Warlock": [
      all: [
        ["Shrine of Twilight"],
        ["Drain Soul", "Glacial Shard", "Spawn of C'Thun"]
      ],
      all: [["Darkest Depths"], ["Gargantuan Slitherer"]],
      all: [["Drain Soul"], ["Spawn of C'Thun"]]
    ],
    "Wallow Warlock": [all: [["Sizzling Cinder"], ["Tachyon Barrage"]]],
    "Drake Warlock": [all: [["Crystalline Golem"], ["M.O.T.H.E.R."]]],
    "C'Thun Warlock": [all: [["Divergence"], ["Rotheart Dryad"]]],
    Zoolock: [
      all: [["Cursed Catacombs"], ["Ruinous Velocidrake"]],
      all: [["Ritual of Summoning"], ["Twilight Egg"]]
    ],
    "Demon Warlock": [all: [["Annihilation"], ["Archwitch Willow"]]],
    "Godfrey Warlock": [all: [["Chronoclaws"], ["The Unseen Atlas"]]],
    "Demon Warlock": [all: [["Elise the Navigator"], ["Moragg"]]],
    Zoolock: [
      all: [
        ["Twilight Timehopper"],
        ["Cursed Catacombs", "Floating Lessons", "Ritual of Summoning"]
      ]
    ],
    "Yogg Warlock": [all: [["Treasure Fiend"], ["Zakajz the Corruptor"]]],
    "C'Thun Warlock": [
      all: [["Drain Soul"], ["Treasure Fiend"]],
      all: [["Godfrey the Betrayer"], ["Spawn of C'Thun"]]
    ],
    "Drake Warlock": [
      all: [["Glacial Shard"], ["Mortal Coil", "RAFAAM LADDER!!"]]
    ],
    "Impformant Warlock": [all: [["Follow the Evidence"], ["Harsh Sentence"]]],
    "C'Thun Warlock": [
      all: [
        ["Gargantuan Slitherer"],
        ["Hellfire", "Shadow Rounds", "Shadowsworn Disciple"]
      ]
    ],
    "Yogg Warlock": [all: [["The Unseen Atlas"], ["Titanic Thrasher"]]],
    "C'Thun Warlock": [all: [["Defias Smuggler"], ["The Unseen Atlas"]]],
    "Demon Warlock": [all: [["Gnomeferatu"], ["Possessed Animancer"]]],
    "Yogg Warlock": [all: [["Rotheart Dryad"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [all: [["Shrine of Twilight"], ["Spire of Solitude"]]],
    "Wallow Warlock": [all: [["Avant-Gardening"], ["Ritual of C'Thun"]]],
    "Yogg Warlock": [all: [["Elise the Navigator"], ["Nightmare Lord Xavius"]]],
    Zoolock: [all: [["Blasphemy"], ["Godfather Kazakus"]]],
    "C'Thun Warlock": [
      all: [["C'Thun, Eye of the Empire"], ["Godfather Kazakus"]]
    ],
    "Demon Warlock": [
      all: [
        ["Endbringer Umbra"],
        ["Imp Gang Stooge", "Moragg", "Shadowsworn Disciple"]
      ]
    ],
    "C'Thun Warlock": [
      all: [
        ["Spawn of C'Thun"],
        ["Caged Cranium", "Darkest Depths", "Godfather Kazakus", "Hellfire", "Ritual of Summoning"]
      ],
      all: [
        ["Gargantuan Slitherer"],
        ["Cursed Chains", "Imp Gang Stooge", "Spire of Solitude"]
      ],
      all: [["Frame Job"], ["Imp Gang Stooge", "The Unseen Atlas"]],
      all: [["Glacial Shard"], ["Ancient Augur", "Harsh Sentence"]],
      all: [["Gnomeferatu"], ["Shrine of Twilight"]],
      all: [["Ritual of Excess"], ["Tachyon Barrage"]]
    ],
    "Yogg Warlock": [
      all: [["Caged Cranium"], ["Titanic Thrasher"]],
      all: [["Mastermind Yogg-Saron"], ["Spire of Solitude"]]
    ],
    "C'Thun Warlock": [all: [["Envoy of the End"], ["Ritual of Excess"]]],
    Zoolock: [all: [["Cult Neophyte"], ["Ritual of Summoning"]]],
    "Wallow Warlock": [all: [["Creature of Madness"], ["Shadowflame Stalker"]]],
    "Drake Warlock": [all: [["Bat Mask"], ["The Unseen Atlas"]]],
    "Yogg Warlock": [all: [["Mawman Cultist"], ["Spire of Solitude"]]],
    Zoolock: [
      all: [["Floating Lessons"], ["Ritual of C'Thun", "Ritual of Summoning"]]
    ],
    "C'Thun Warlock": [all: [["Deathwing, Worldbreaker"], ["The Unseen Atlas"]]],
    "Yogg Warlock": [all: [["Nightmare Lord Xavius"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [
      all: [["Shrine of Twilight"], ["Godfrey the Betrayer", "Moragg"]]
    ],
    "C'Thun Warlock": [all: [["Darkest Depths"], ["Shrine of Twilight"]]],
    "Yogg Warlock": [all: [["Kith'ix"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [
      all: [["Darkest Depths"], ["Drain Soul"]],
      all: [["Hellfire"], ["Shrine of Twilight"]]
    ],
    "Demon Warlock": [
      all: [
        ["Archwitch Willow"],
        ["Godfather Kazakus", "Hellfire", "Imp Gang Stooge", "The Unseen Atlas"]
      ]
    ],
    "C'Thun Warlock": [all: [["Annihilation"], ["Harsh Sentence"]]],
    Zoolock: [all: [["Ritual of C'Thun"], ["Twilight Egg"]]],
    "Demon Warlock": [all: [["N'Zoth, Dream's End"], ["Ritual of Excess"]]],
    "Drake Warlock": [all: [["Crystalline Golem"], ["Doomsayer"]]],
    "C'Thun Warlock": [all: [["Gnomeferatu"], ["Shadowsworn Disciple"]]],
    "Yogg Warlock": [all: [["Elise the Navigator"], ["Mawman Cultist"]]],
    Rafaamlock: [all: [["Dirty Rat"], ["Rotheart Dryad"]]],
    Zoolock: [all: [["Tachyon Barrage"], ["Twilight Timehopper"]]],
    "C'Thun Warlock": [
      all: [["Possessed Animancer"], ["Annihilation", "Kith'ix"]]
    ],
    "Yogg Warlock": [all: [["Ritual of Summoning"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [
      all: [
        ["Ancient Augur"],
        ["Annihilation", "Caged Cranium", "Cursed Chains", "Godfrey the Betrayer", "Kith'ix", "Rotten Apple"]
      ],
      all: [["Cult Neophyte"], ["Defias Smuggler", "Spawn of C'Thun"]],
      all: [["Dirty Rat"], ["Kith'ix", "Spire of Solitude"]],
      all: [["Shrine of Twilight"], ["Godfather Kazakus", "Ritual of Summoning"]],
      all: [["Caged Cranium"], ["Harsh Sentence"]],
      all: [["Glacial Shard"], ["Shadowsworn Disciple"]]
    ],
    "Drake Warlock": [all: [["Conflagrate"], ["Treasure Fiend"]]],
    Zoolock: [all: [["Twilight Timehopper"], ["Cult Neophyte", "Glacial Shard"]]],
    "Godfrey Warlock": [all: [["Caged Cranium"], ["Tachyon Barrage"]]],
    "Yogg Warlock": [
      all: [["Zakajz the Corruptor"], ["Glacial Shard", "Hellfire"]]
    ],
    Zoolock: [all: [["Godfather Kazakus"], ["Ruinous Velocidrake"]]],
    "C'Thun Warlock": [
      all: [["Cursed Chains"], ["Treasure Fiend"]],
      all: [["Darkest Depths"], ["Godfather Kazakus"]]
    ],
    "Yogg Warlock": [all: [["Ritual of Excess"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [all: [["Shadowsworn Disciple"], ["Treasure Fiend"]]],
    Rafaamlock: [all: [["RAFAAM LADDER!!"], ["Ritual of Summoning"]]],
    "Yogg Warlock": [all: [["Elise the Navigator"], ["Glacial Shard"]]],
    Zoolock: [all: [["Ritual of C'Thun"], ["Twilight Timehopper"]]],
    Rafaamlock: [all: [["Caged Cranium"], ["Possessed Animancer"]]],
    "C'Thun Warlock": [
      all: [["Harsh Sentence"], ["Shadowsworn Disciple"]],
      all: [["Spire of Solitude"], ["Treasure Fiend"]]
    ],
    "C'Thun Warlock": [all: [["Hellfire"], ["Treasure Fiend"]]],
    "Yogg Warlock": [all: [["Glacial Shard"], ["Rotheart Dryad"]]],
    Rafaamlock: [all: [["Shadow Rounds"], ["Spawn of C'Thun"]]],
    "C'Thun Warlock": [
      all: [["Caged Cranium"], ["Gnomeferatu"]],
      all: [["Drain Soul"], ["Kith'ix"]]
    ],
    "Demon Warlock": [
      all: [["Godfrey the Betrayer"], ["Moragg"]],
      all: [["Mo'arg Forgefiend"], ["The Unseen Atlas"]]
    ],
    "Drake Warlock": [all: [["Drain Soul"], ["RAFAAM LADDER!!"]]],
    Rafaamlock: [all: [["RAFAAM LADDER!!"], ["Ritual of C'Thun"]]],
    "C'Thun Warlock": [
      all: [
        ["Caged Cranium"],
        [
          "Annihilation",
          "Darkest Depths",
          "Gargantuan Slitherer",
          "Hellfire",
          "Ritual of Summoning",
          "Shadowsworn Disciple",
          "Treasure Fiend"
        ]
      ],
      all: [
        ["Spire of Solitude"],
        ["Drain Soul", "Godfather Kazakus", "Hellfire", "Shadowsworn Disciple"]
      ],
      all: [["Drain Soul"], ["Ritual of C'Thun", "Shadowsworn Disciple"]],
      all: [["Gargantuan Slitherer"], ["Ritual of C'Thun", "The Unseen Atlas"]],
      all: [["Spawn of C'Thun"], ["Cursed Catacombs", "Shadowsworn Disciple"]],
      all: [["Godfather Kazakus"], ["Treasure Fiend"]]
    ],
    Rafaamlock: [
      all: [["Caged Cranium"], ["Shadow Rounds"]],
      all: [["Elise the Navigator"], ["Ritual of Summoning"]]
    ],
    "C'Thun Warlock": [
      all: [["Dirty Rat"], ["Drain Soul"]],
      all: [["Shadowsworn Disciple"], ["Shrine of Twilight"]]
    ],
    Rafaamlock: [all: [["Caged Cranium"], ["Dirty Rat"]]],
    Rafaamlock: [all: [["Dirty Rat"], ["Shrine of Twilight"]]],
    "C'Thun Warlock": [all: [["Kith'ix"], ["Spawn of C'Thun"]]],
    "Demon Warlock": [all: [["Moragg"], ["The Unseen Atlas"]]],
    Zoolock: [all: [["Glacial Shard"], ["Ritual of Summoning"]]],
    "Yogg Warlock": [all: [["Glacial Shard"], ["Mawman Cultist"]]],
    "C'Thun Warlock": [
      all: [["Shrine of Twilight"], ["Caged Cranium", "Ritual of C'Thun"]],
      all: [["Annihilation"], ["Ritual of Summoning"]]
    ],
    "C'Thun Warlock": [all: [["Ritual of Summoning"], ["Shadowsworn Disciple"]]],
    "Demon Warlock": [all: [["Moragg"], ["Ritual of Summoning"]]],
    Rafaamlock: [
      all: [["Ancient Augur"], ["Ritual of C'Thun", "Ritual of Excess"]],
      all: [["Dirty Rat"], ["Shadow Rounds"]],
      all: [["Prize Vendor"], ["Ritual of C'Thun"]],
      all: [["Ritual of Summoning"], ["Rotheart Dryad"]]
    ],
    Zoolock: [all: [["Cult Neophyte"], ["Ritual of C'Thun"]]],
    "C'Thun Warlock": [all: [["Ancient Augur"], ["Hellfire"]]],
    "Yogg Warlock": [all: [["Kith'ix"], ["Rotheart Dryad"]]],
    Rafaamlock: [all: [["The Unseen Atlas"], ["Zakajz the Corruptor"]]],
    "C'Thun Warlock": [all: [["Cursed Chains"], ["Dirty Rat"]]],
    Zoolock: [all: [["Mawman Cultist"], ["Twilight Timehopper"]]],
    Rafaamlock: [
      all: [["Spire of Solitude"], ["Ritual of Excess", "Spawn of C'Thun"]]
    ],
    "C'Thun Warlock": [
      all: [["Spire of Solitude"], ["Cursed Catacombs", "Cursed Chains"]]
    ],
    "C'Thun Warlock": [all: [["Ritual of C'Thun"], ["Spawn of C'Thun"]]],
    Rafaamlock: [all: [["Spawn of C'Thun"], ["The Unseen Atlas"]]],
    Zoolock: [all: [["Mawman Cultist"], ["Ritual of Summoning"]]],
    "Demon Warlock": [all: [["Conflagrate"], ["Imp Gang Stooge"]]],
    "C'Thun Warlock": [all: [["Godfather Kazakus"], ["Godfrey the Betrayer"]]],
    Rafaamlock: [
      all: [["Dirty Rat"], ["Godfather Kazakus"]],
      all: [["Gnomeferatu"], ["The Unseen Atlas"]]
    ],
    "C'Thun Warlock": [all: [["Possessed Animancer"], ["Ritual of C'Thun"]]],
    Rafaamlock: [
      all: [["Imp Gang Stooge"], ["Elise the Navigator", "Spawn of C'Thun"]]
    ],
    "C'Thun Warlock": [
      all: [["Imp Gang Stooge"], ["Kith'ix", "Shrine of Twilight"]],
      all: [["Kith'ix"], ["Ritual of Summoning"]]
    ],
    Rafaamlock: [all: [["Dirty Rat"], ["Ritual of C'Thun"]]],
    Rafaamlock: [all: [["Eternal Toil"], ["The Unseen Atlas"]]],
    "C'Thun Warlock": [
      all: [["Ritual of Summoning"], ["Hellfire", "The Unseen Atlas"]]
    ],
    Rafaamlock: [all: [["Dirty Rat"], ["Cursed Catacombs", "The Unseen Atlas"]]],
    "C'Thun Warlock": [
      all: [["Ancient Augur"], ["The Unseen Atlas"]],
      all: [["Dirty Rat"], ["Imp Gang Stooge"]]
    ],
    Rafaamlock: [all: [["Ancient Augur"], ["Imp Gang Stooge"]]],
    Rafaamlock: [all: [["Caged Cranium"], ["Ritual of Excess"]]],
    "C'Thun Warlock": [all: [["Caged Cranium"], ["Godfather Kazakus"]]],
    "Demon Warlock": [all: [["Moragg"], ["Ritual of C'Thun"]]],
    Rafaamlock: [all: [["Ritual of C'Thun"], ["Shadow Rounds"]]],
    "C'Thun Warlock": [
      all: [
        ["Hellfire"],
        ["Ritual of C'Thun", "Shadowsworn Disciple", "The Unseen Atlas"]
      ],
      all: [["Annihilation"], ["The Unseen Atlas"]],
      all: [["Crystalline Golem"], ["Rotheart Dryad"]],
      all: [["Imp Gang Stooge"], ["Ritual of Summoning"]]
    ],
    Rafaamlock: [
      all: [["Rotheart Dryad"], ["Godfather Kazakus", "The Unseen Atlas"]]
    ],
    "C'Thun Warlock": [all: [["Cursed Chains"], ["Godfather Kazakus"]]],
    Rafaamlock: [all: [["Caged Cranium"], ["Imp Gang Stooge"]]],
    "C'Thun Warlock": [
      all: [["Ritual of C'Thun"], ["Caged Cranium", "Spire of Solitude"]]
    ],
    Rafaamlock: [all: [["Spire of Solitude"], ["The Unseen Atlas"]]],
    Zoolock: [all: [["Godfather Kazakus"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [
      all: [["Ritual of C'Thun"], ["Imp Gang Stooge", "The Unseen Atlas"]]
    ],
    Rafaamlock: [all: [["Ritual of Excess"], ["The Unseen Atlas"]]],
    Zoolock: [all: [["Mawman Cultist"], ["Ritual of C'Thun"]]],
    Rafaamlock: [
      all: [["Godfather Kazakus"], ["Ritual of Excess", "The Unseen Atlas"]],
      all: [["Ritual of C'Thun"], ["Ritual of Excess"]]
    ],
    "C'Thun Warlock": [all: [["Godfather Kazakus"], ["Imp Gang Stooge"]]],
    Zoolock: [all: [["Floating Lessons"], ["Mawman Cultist"]]],
    Rafaamlock: [
      all: [
        ["Imp Gang Stooge"],
        ["Cursed Chains", "Shadowsworn Disciple", "The Unseen Atlas"]
      ]
    ],
    "C'Thun Warlock": [all: [["Caged Cranium"], ["The Unseen Atlas"]]],
    Zoolock: [all: [["Ritual of C'Thun"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [all: [["Cursed Chains"], ["Shadowsworn Disciple"]]],
    "C'Thun Warlock": [
      all: [["Hellfire"], ["Drain Soul", "Imp Gang Stooge"]],
      all: [["Godfather Kazakus"], ["Ritual of C'Thun"]]
    ],
    "C'Thun Warlock": [all: [["Cursed Catacombs"], ["Godfather Kazakus"]]]
  ]
  @wild_config [
    Discolock: [
      "Boneweb Egg",
      "Chronoclaws",
      "Disposable Acolytes",
      "Duke of Below",
      "Entropic Continuity",
      "Irondeep Trogg",
      "Party Fiend",
      "Platysaur",
      "Silverware Golem",
      "Silverware Golem",
      "Soul Barrage",
      "Walking Dead",
      "Wicked Whispers"
    ],
    "XL HL Tick Tock Warlock": ["Kerrigan, Queen of Blades", "Nydus Worm", "Spawning Pool", "Witchwood Piper"],
    Boarlock: ["Shadowborn"],
    "XL Highlander Warlock": ["Mixologist", "Void Contract"],
    "Fatigue Seedlock": ["Blood Shard Bristleback"],
    "XL Highlander Warlock": ["Deathlord", "Rin, Orchestrator of Doom", "Soul Seeker"],
    "XL HL Tick Tock Warlock": [
      "Battle at the End Time",
      "Speaker Stomper",
      "The Curator",
      "Timeline Accelerator",
      "Ultralisk Cavern"
    ],
    "XL Highlander Warlock": ["Mutanus the Devourer", "Theotar, the Mad Duke"],
    "XL Demon Boarlock": ["Crane Game"],
    "XL Seedlock": ["Tachyon Barrage"],
    Boarlock: ["Eat! The! Imp!", "Elwynn Boar", "Tour Guide"],
    Evenlock: ["Goldshire Gnoll", "Mountain Giant"],
    "Fatigue Seedlock": ["Fanottem, Lord of the Opera"],
    "XL Warlock": ["Messmaker"],
    "XL Highlander Warlock": ["Altar of Fire", "Bygone Doomspeaker", "Dar'Khan Drathir", "Eredar Brute"],
    "XL Seedlock": ["Celestial Projectionist", "Imployee of the Month"],
    Discolock: ["Soulfire"],
    "XL SoU Quest Warlock": ["Supreme Archaeology"],
    "Insanity Warlock": ["Encroaching Insanity"],
    "XL Demon Boarlock": ["Fae Trickster"],
    "XL Seedlock": ["Shadowblade Slinger"],
    "XL Highlander Warlock": ["Far Watch Post", "Zilliax Deluxe 3000"],
    "XL Seedlock": ["Spirit Bomb"],
    "STD Harold Egglock": ["Abusive Sergeant"],
    Seedlock: ["Flesh Giant", "Molten Giant"],
    "XL Highlander Warlock": ["Cataclysm", "Gnomeferatu", "Zilliax Deluxe 3000"],
    Boarlock: ["Rain of Fire"],
    Boarlock: ["Old Murk-Eye"],
    "Other Warlock": ["Treachery"],
    "XL HL Tick Tock Warlock": ["Grimoire of Sacrifice"],
    "Other Warlock": ["Barrens Scavenger"],
    "Fatigue Seedlock": ["Chamber of Viscidus"],
    "STD Harold Egglock": ["Holy Eggbearer"],
    Boarlock: ["Conflagrate"],
    "Insanity Warlock": ["Void Virtuoso"],
    "XL Highlander Warlock": ["Blademaster Okani", "Demonic Project"],
    Boarlock: ["Felstring Harp", "Fracking"],
    Seedlock: ["Healthstone", "Imprisoned Horror"],
    "XL HL Tick Tock Warlock": ["Cult Neophyte", "Plot Twist", "Smothering Starfish"],
    Discolock: ["The Soularium"],
    "XL Highlander Warlock": [
      "Dark Skies",
      "Full-Blown Evil",
      "Nightmare Lord Xavius",
      "Sargeras, the Destroyer",
      "Symphony of Sins",
      "Wing Welding",
      "Zephrys the Great"
    ],
    "XL Warlock": ["Burrow Buster"],
    "XL Warlock": ["Mo'arg Drillfist"],
    Discolock: ["Ocular Occultist"],
    "XL Seedlock": ["The Demon Seed"],
    "Ashtongue Warlock": ["Mass Production"],
    Boarlock: ["Kobold Librarian"],
    "XL Highlander Warlock": ["Dirty Rat"],
    "Other Warlock": ["\"Health\" Drink"],
    Boarlock: ["Darkbomb", "Darkbomb", "Domino Effect"],
    Discolock: ["Cursed Catacombs"]
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Warlock")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Warlock")
  end
end
