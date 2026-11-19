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
    Rafaamlock: [all: [["Archmage Rafaam"], ["Nightmare Lord Xavius"]]],
    "Wallow Warlock": [all: [["Creature of Madness"], ["Cult Neophyte"]]],
    Zoolock: [all: [["Tachyon Barrage"], ["Vaultkeeper"]]],
    Rafaamlock: [
      all: [
        ["Warchief Rafaam"],
        ["Elise the Navigator", "Nightmare Lord Xavius", "Prize Vendor", "Ysera, Emerald Aspect"]
      ],
      all: [["Eternal Toil"], ["Archmage Rafaam", "Green Rafaam", "Tiny Rafaam"]],
      all: [
        ["Explorer Rafaam"],
        ["Crystalline Golem", "Hellfire", "Ysera, Emerald Aspect"]
      ],
      all: [["Timethief Rafaam"], ["Godfrey the Betrayer", "Spire of Solitude"]],
      all: [["Darkest Depths"], ["Green Rafaam"]],
      all: [["Rotheart Dryad"], ["Tiny Rafaam"]]
    ],
    Zoolock: [all: [["Floating Lessons"], ["Vaultkeeper"]]],
    Rafaamlock: [
      all: [
        ["Green Rafaam"],
        [
          "Elise the Navigator",
          "Harsh Sentence",
          "Mindflayer R'faam",
          "Nightmare Lord Xavius",
          "Possessed Animancer",
          "Prize Vendor",
          "RAFAAM LADDER!!",
          "Rotheart Dryad",
          "Timethief Rafaam",
          "Ultraxion"
        ]
      ],
      all: [
        ["Mindflayer R'faam"],
        [
          "Elise the Navigator",
          "Giant Rafaam",
          "Harsh Sentence",
          "Mawman Cultist",
          "Nightmare Lord Xavius",
          "Possessed Animancer",
          "RAFAAM LADDER!!",
          "Ultraxion"
        ]
      ],
      all: [
        ["Tiny Rafaam"],
        [
          "C'Thun, Eye of the Empire",
          "Crystalline Golem",
          "Drain Soul",
          "Mawman Cultist",
          "RAFAAM LADDER!!",
          "Timethief Rafaam",
          "Y'Shaarj, Titan Bane"
        ]
      ],
      all: [
        ["Harsh Sentence"],
        ["Calamitous Rafaam", "Explorer Rafaam", "Giant Rafaam", "Murloc Rafaam", "Warchief Rafaam"]
      ],
      all: [
        ["Murloc Rafaam"],
        ["Elise the Navigator", "Nightmare Lord Xavius", "Possessed Animancer", "RAFAAM LADDER!!"]
      ],
      all: [
        ["Explorer Rafaam"],
        ["Godfrey the Betrayer", "RAFAAM LADDER!!", "Ultraxion"]
      ],
      all: [
        ["Giant Rafaam"],
        ["C'Thun, Eye of the Empire", "RAFAAM LADDER!!", "Ultraxion"]
      ],
      all: [["Calamitous Rafaam"], ["Possessed Animancer", "RAFAAM LADDER!!"]],
      all: [["Warchief Rafaam"], ["Ultraxion", "Y'Shaarj, Titan Bane"]],
      all: [["Ancient Augur"], ["Archmage Rafaam"]],
      all: [["Ritual of C'Thun"], ["Timethief Rafaam"]]
    ],
    "Wallow Warlock": [
      all: [["Creature of Madness"], ["Twilight Timehopper"]],
      all: [["Nightmare Lord Xavius"], ["Treacherous Tormentor"]]
    ],
    Zoolock: [all: [["Platysaur"], ["Royal Librarian"]]],
    Rafaamlock: [
      all: [["Glacial Shard"], ["Murloc Rafaam", "Warchief Rafaam"]],
      all: [["Mindflayer R'faam"], ["Ancient Augur", "Rotheart Dryad"]],
      all: [["Caged Cranium"], ["Tiny Rafaam"]],
      all: [["Explorer Rafaam"], ["Godfather Kazakus"]]
    ],
    Zoolock: [all: [["Vaultkeeper"], ["Twilight Egg", "Twilight Timehopper"]]],
    Rafaamlock: [
      all: [["Tiny Rafaam"], ["Ritual of C'Thun", "Spawn of C'Thun"]],
      all: [["Explorer Rafaam"], ["Giant Rafaam"]]
    ],
    Rafaamlock: [all: [["Tiny Rafaam"], ["Ancient Augur", "Ritual of Summoning"]]],
    Zoolock: [all: [["Twilight Egg"], ["Blasphemy", "Tachyon Barrage"]]],
    Zoolock: [
      all: [
        ["Platysaur"],
        ["Cult Neophyte", "Floating Lessons", "Twilight Egg", "Zakajz the Corruptor"]
      ]
    ],
    Rafaamlock: [all: [["Murloc Rafaam"], ["Rotheart Dryad"]]],
    "Wallow Warlock": [all: [["Mawman Cultist"], ["Raptor Herald"]]],
    "C'Thun Warlock": [all: [["Defias Smuggler"], ["Ultraxion"]]],
    Rafaamlock: [
      all: [["Ancient Augur"], ["Murloc Rafaam"]],
      all: [["Ritual of Summoning"], ["Warchief Rafaam"]]
    ],
    Rafaamlock: [all: [["Gargantuan Slitherer"], ["Warchief Rafaam"]]],
    Zoolock: [all: [["Floating Lessons"], ["Twilight Egg"]]],
    Rafaamlock: [
      all: [["Ritual of C'Thun"], ["Green Rafaam", "Warchief Rafaam"]],
      all: [["Calamitous Rafaam"], ["Hellfire"]]
    ],
    "Yogg Warlock": [all: [["Mastermind Yogg-Saron"], ["Titanic Thrasher"]]],
    "C'Thun Warlock": [
      all: [["Ultraxion"], ["Darkest Depths", "Treasure Fiend"]],
      all: [["Defias Smuggler"], ["Drain Soul"]]
    ],
    Rafaamlock: [
      all: [["Calamitous Rafaam"], ["Ritual of Summoning", "Spawn of C'Thun"]],
      all: [["Godfather Kazakus"], ["Green Rafaam", "Warchief Rafaam"]],
      all: [["Green Rafaam"], ["Spawn of C'Thun"]],
      all: [["Mindflayer R'faam"], ["Murloc Rafaam"]]
    ],
    Zoolock: [all: [["Blasphemy"], ["Entropic Continuity"]]],
    "Wallow Warlock": [all: [["Avant-Gardening"], ["Wallow, the Wretched"]]],
    "C'Thun Warlock": [all: [["Archwitch Willow"], ["Spawn of C'Thun"]]],
    Rafaamlock: [
      all: [["Cursed Chains"], ["Mindflayer R'faam"]],
      all: [["Explorer Rafaam"], ["Shadowsworn Disciple"]]
    ],
    Zoolock: [all: [["Mawman Cultist"], ["Twilight Egg"]]],
    Rafaamlock: [all: [["Explorer Rafaam"], ["Tiny Rafaam"]]],
    Egglock: [all: [["Holy Eggbearer"], ["The Egg of Khelos"]]],
    Rafaamlock: [
      all: [["Calamitous Rafaam"], ["Cursed Catacombs", "Ritual of C'Thun"]],
      all: [["Murloc Rafaam"], ["Caged Cranium", "Ritual of C'Thun"]],
      all: [["Green Rafaam"], ["Shadowsworn Disciple"]]
    ],
    Rafaamlock: [all: [["Green Rafaam"], ["The Unseen Atlas"]]],
    Rafaamlock: [all: [["Tiny Rafaam"], ["Imp Gang Stooge", "The Unseen Atlas"]]],
    Rafaamlock: [
      all: [["The Unseen Atlas"], ["Murloc Rafaam", "Warchief Rafaam"]]
    ],
    Zoolock: [all: [["Cult Neophyte"], ["Entropic Continuity"]]],
    "C'Thun Warlock": [
      all: [["C'Thun, Eye of the Empire"], ["Godfrey the Betrayer"]],
      all: [["Darkest Depths"], ["Defias Smuggler"]]
    ],
    "Wallow Warlock": [all: [["Creature of Madness"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [
      all: [
        ["C'Thun, Eye of the Empire"],
        ["Deathwing, Worldbreaker", "Drain Soul"]
      ],
      all: [["Shrine of Twilight"], ["Treasure Fiend"]]
    ],
    Rafaamlock: [
      all: [["The Unseen Atlas"], ["Calamitous Rafaam", "Mindflayer R'faam"]],
      all: [["Explorer Rafaam"], ["Imp Gang Stooge"]]
    ],
    "C'Thun Warlock": [all: [["Drain Soul"], ["Ultraxion"]]],
    "Yogg Warlock": [
      all: [
        ["Mastermind Yogg-Saron"],
        ["Crystalline Golem", "Elise the Navigator", "Mawman Cultist", "Rotheart Dryad", "Zakajz the Corruptor"]
      ],
      all: [["Titanic Thrasher"], ["Treasure Fiend"]]
    ],
    "C'Thun Warlock": [
      all: [["Gargantuan Slitherer"], ["Whelp of the Infinite"]],
      all: [["Moragg"], ["Spawn of C'Thun"]]
    ],
    Zoolock: [all: [["Cult Neophyte"], ["Blasphemy", "Twilight Egg"]]],
    "Wallow Warlock": [
      all: [["Avant-Gardening"], ["Creature of Madness"]],
      all: [["Raptor Herald"], ["Treacherous Tormentor"]]
    ],
    "C'Thun Warlock": [
      all: [["C'Thun, Eye of the Empire"], ["Hellfire", "Shrine of Twilight"]],
      all: [["Deathwing, Worldbreaker"], ["Spawn of C'Thun"]],
      all: [["Frame Job"], ["Shrine of Twilight"]],
      all: [["Glacial Shard"], ["Ultraxion"]]
    ],
    Zoolock: [
      all: [["Blasphemy"], ["Twilight Timehopper"]],
      all: [["Mawman Cultist"], ["Platysaur"]]
    ],
    "C'Thun Warlock": [all: [["Conflagrate"], ["Spawn of C'Thun"]]],
    "C'Thun Warlock": [all: [["Cho'gall, Mastermind"], ["Shrine of Twilight"]]],
    "Drake Warlock": [all: [["Drain Soul"], ["Earthen Drake"]]],
    "C'Thun Warlock": [all: [["Ancient Augur"], ["Treasure Fiend"]]],
    Zoolock: [
      all: [
        ["Entropic Continuity"],
        ["Floating Lessons", "Glacial Shard", "Zakajz the Corruptor"]
      ]
    ],
    "C'Thun Warlock": [
      all: [
        ["Deathwing, Worldbreaker"],
        ["Ancient Augur", "Cursed Catacombs", "Drain Soul"]
      ],
      all: [["C'Thun, Eye of the Empire"], ["Spire of Solitude"]],
      all: [["Drain Soul"], ["Gargantuan Slitherer"]]
    ],
    "Demon Warlock": [
      all: [
        ["Archwitch Willow"],
        ["Endbringer Umbra", "Moragg", "N'Zoth, Dream's End"]
      ]
    ],
    "Yogg Warlock": [
      all: [["Elise the Navigator"], ["Treasure Fiend"]],
      all: [["Spire of Solitude"], ["Titanic Thrasher"]]
    ],
    "C'Thun Warlock": [all: [["Spawn of C'Thun"], ["Treasure Fiend"]]],
    Zoolock: [all: [["Cursed Catacombs"], ["Twilight Egg"]]],
    "C'Thun Warlock": [all: [["Ultraxion"], ["Cursed Catacombs", "Hellfire"]]],
    "Wallow Warlock": [all: [["Raptor Herald"], ["Ritual of C'Thun"]]],
    "C'Thun Warlock": [
      all: [["Defias Smuggler"], ["Spire of Solitude", "Treasure Fiend"]],
      all: [["Devious Coyote"], ["Ritual of C'Thun"]],
      all: [["Gargantuan Slitherer"], ["Shrine of Twilight"]]
    ],
    "Yogg Warlock": [
      all: [["Treasure Fiend"], ["Mawman Cultist", "Rotheart Dryad"]]
    ],
    "C'Thun Warlock": [all: [["Darkest Depths"], ["Treasure Fiend"]]],
    "Godfrey Warlock": [all: [["Chronoclaws"], ["The Unseen Atlas"]]],
    "C'Thun Warlock": [
      all: [["C'Thun, Eye of the Empire"], ["Cursed Chains"]],
      all: [["Drain Soul"], ["Spawn of C'Thun"]],
      all: [["Glacial Shard"], ["Shrine of Twilight"]]
    ],
    "Yogg Warlock": [all: [["Hellfire"], ["Titanic Thrasher"]]],
    "Wallow Warlock": [all: [["Creature of Madness"], ["Godfather Kazakus"]]],
    Zoolock: [
      all: [["Entropic Continuity"], ["Mawman Cultist"]],
      all: [["Ritual of Summoning"], ["Twilight Egg"]]
    ],
    "C'Thun Warlock": [
      all: [
        ["Shrine of Twilight"],
        ["Annihilation", "Darkest Depths", "Deathwing, Worldbreaker", "Harsh Sentence", "Spawn of C'Thun"]
      ],
      all: [
        ["Deathwing, Worldbreaker"],
        ["Ritual of C'Thun", "Spire of Solitude", "The Unseen Atlas"]
      ],
      all: [
        ["Ultraxion"],
        ["Ritual of C'Thun", "Spire of Solitude", "The Unseen Atlas"]
      ],
      all: [["Annihilation"], ["Gargantuan Slitherer", "Spawn of C'Thun"]],
      all: [["Darkest Depths"], ["Gargantuan Slitherer"]]
    ],
    "Wallow Warlock": [all: [["Sizzling Cinder"], ["Twilight Timehopper"]]],
    Rafaamlock: [all: [["Explorer Rafaam"], ["Ritual of C'Thun"]]],
    Zoolock: [all: [["Floating Lessons"], ["Twilight Timehopper"]]],
    Egglock: [all: [["Shadowsworn Disciple"], ["The Egg of Khelos"]]],
    "Yogg Warlock": [all: [["Mastermind Yogg-Saron"], ["Treasure Fiend"]]],
    "Drake Warlock": [
      all: [["M.O.T.H.E.R."], ["Cursed Chains", "Shadowsworn Disciple"]]
    ],
    "Demon Warlock": [
      all: [["Moragg"], ["Elise the Navigator", "Endbringer Umbra"]]
    ],
    Zoolock: [all: [["Entropic Continuity"], ["Godfather Kazakus"]]],
    "C'Thun Warlock": [all: [["Drain Soul"], ["Treasure Fiend"]]],
    Zoolock: [all: [["Ritual of Summoning"], ["Twilight Timehopper"]]],
    "C'Thun Warlock": [
      all: [
        ["Gargantuan Slitherer"],
        ["Hellfire", "Imp Gang Stooge", "Shadowsworn Disciple"]
      ],
      all: [["C'Thun, Eye of the Empire"], ["Godfather Kazakus"]],
      all: [["Shrine of Twilight"], ["Spire of Solitude"]]
    ],
    Rafaamlock: [all: [["Imp Gang Stooge"], ["Murloc Rafaam"]]],
    "Yogg Warlock": [
      all: [["Zuramat's Prison"], ["Ritual of C'Thun", "The Unseen Atlas"]]
    ],
    Zoolock: [all: [["Ritual of Summoning"], ["Ruinous Velocidrake"]]],
    "Demon Warlock": [all: [["Annihilation"], ["Archwitch Willow"]]],
    "Yogg Warlock": [
      all: [["Elise the Navigator"], ["Glacial Shard", "Mawman Cultist"]],
      all: [["Titanic Thrasher"], ["Caged Cranium", "The Unseen Atlas"]]
    ],
    "Godfrey Warlock": [all: [["Blasphemy"], ["The Unseen Atlas"]]],
    "C'Thun Warlock": [all: [["Defias Smuggler"], ["The Unseen Atlas"]]],
    "Drake Warlock": [all: [["Glacial Shard"], ["RAFAAM LADDER!!"]]],
    "C'Thun Warlock": [all: [["Frame Job"], ["Imp Gang Stooge"]]],
    "Yogg Warlock": [all: [["Treasure Fiend"], ["Zakajz the Corruptor"]]],
    "C'Thun Warlock": [
      all: [["Ancient Augur"], ["Glacial Shard"]],
      all: [["Godfrey the Betrayer"], ["Shrine of Twilight"]],
      all: [["Harsh Sentence"], ["Treasure Fiend"]]
    ],
    Rafaamlock: [all: [["Imp Gang Stooge"], ["Mindflayer R'faam"]]],
    "Demon Warlock": [all: [["Archwitch Willow"], ["Imp Gang Stooge"]]],
    "Drake Warlock": [all: [["Bat Mask"], ["The Unseen Atlas"]]],
    "Wallow Warlock": [all: [["Creature of Madness"], ["Shadowflame Stalker"]]],
    Zoolock: [all: [["Floating Lessons"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [
      all: [
        ["Spawn of C'Thun"],
        ["Caged Cranium", "Godfrey the Betrayer", "Hellfire"]
      ],
      all: [["Darkest Depths"], ["Caged Cranium", "Spire of Solitude"]],
      all: [["Eldritch Tentacles"], ["Ancient Augur", "Ritual of Summoning"]],
      all: [["Drain Soul"], ["Shrine of Twilight"]],
      all: [["Glacial Shard"], ["Harsh Sentence"]]
    ],
    "Demon Warlock": [all: [["Godfather Kazakus"], ["Mo'arg Forgefiend"]]],
    Zoolock: [all: [["Cursed Catacombs"], ["Twilight Timehopper"]]],
    "Yogg Warlock": [all: [["Nightmare Lord Xavius"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [
      all: [
        ["Shrine of Twilight"],
        ["Gnomeferatu", "Godfather Kazakus", "Kith'ix"]
      ]
    ],
    Zoolock: [all: [["Blasphemy"], ["Ritual of C'Thun"]]],
    "Yogg Warlock": [all: [["Caged Cranium"], ["Mawman Cultist"]]],
    "Demon Warlock": [all: [["Moragg"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [
      all: [["Shadowsworn Disciple"], ["Gnomeferatu", "Treasure Fiend"]],
      all: [["Ancient Augur"], ["Caged Cranium"]]
    ],
    "Yogg Warlock": [all: [["Kith'ix"], ["Treasure Fiend"]]],
    "C'Thun Warlock": [
      all: [["Spawn of C'Thun"], ["Godfather Kazakus", "Ritual of Summoning"]],
      all: [["Cursed Chains"], ["Treasure Fiend"]]
    ],
    "Yogg Warlock": [all: [["Ritual of Excess"], ["Treasure Fiend"]]],
    Zoolock: [
      all: [["Twilight Timehopper"], ["Godfather Kazakus", "Ritual of C'Thun"]]
    ],
    "Yogg Warlock": [all: [["Mawman Cultist"], ["Spire of Solitude"]]],
    "C'Thun Warlock": [
      all: [
        ["Shrine of Twilight"],
        ["Cursed Catacombs", "Hellfire", "Ritual of Summoning", "The Unseen Atlas"]
      ],
      all: [["Gargantuan Slitherer"], ["Godfather Kazakus", "The Unseen Atlas"]]
    ],
    Zoolock: [
      all: [
        ["Floating Lessons"],
        ["Cult Neophyte", "Mawman Cultist", "Ritual of C'Thun"]
      ],
      all: [["Cult Neophyte"], ["Mawman Cultist"]]
    ],
    "Yogg Warlock": [
      all: [["Glacial Shard"], ["Mawman Cultist", "Zakajz the Corruptor"]]
    ],
    "C'Thun Warlock": [
      all: [["Darkest Depths"], ["Godfather Kazakus"]],
      all: [["Drain Soul"], ["Ritual of Summoning"]],
      all: [["Glacial Shard"], ["Shadowsworn Disciple"]]
    ],
    Rafaamlock: [all: [["RAFAAM LADDER!!"], ["Ritual of C'Thun"]]],
    "Demon Warlock": [all: [["Annihilation"], ["Conflagrate"]]],
    "C'Thun Warlock": [
      all: [
        ["Shadowsworn Disciple"],
        [
          "Annihilation",
          "Caged Cranium",
          "Harsh Sentence",
          "Ritual of Summoning",
          "Spire of Solitude",
          "The Unseen Atlas"
        ]
      ],
      all: [
        ["Spire of Solitude"],
        ["Annihilation", "Cursed Chains", "Dirty Rat", "Harsh Sentence"]
      ],
      all: [["Ancient Augur"], ["Annihilation", "Cursed Chains", "Drain Soul"]],
      all: [["Caged Cranium"], ["Annihilation", "Harsh Sentence"]],
      all: [["Harsh Sentence"], ["The Unseen Atlas"]],
      all: [["Hellfire"], ["Treasure Fiend"]]
    ],
    Rafaamlock: [all: [["Caged Cranium"], ["Possessed Animancer"]]],
    "Drake Warlock": [
      all: [["Annihilation"], ["Crystalline Golem", "Drain Soul"]]
    ],
    "Yogg Warlock": [all: [["Glacial Shard"], ["Kith'ix"]]],
    Rafaamlock: [
      all: [["Ancient Augur"], ["Ritual of Excess", "Spire of Solitude"]],
      all: [["Caged Cranium"], ["Dirty Rat"]]
    ],
    "Yogg Warlock": [all: [["Nightmare Lord Xavius"], ["Spire of Solitude"]]],
    "C'Thun Warlock": [all: [["Ritual of C'Thun"], ["Treasure Fiend"]]],
    Rafaamlock: [all: [["Ancient Augur"], ["Dirty Rat"]]],
    "C'Thun Warlock": [all: [["Drain Soul"], ["Kith'ix"]]],
    Rafaamlock: [
      all: [["Dirty Rat"], ["Shadowsworn Disciple"]],
      all: [["Prize Vendor"], ["Ritual of C'Thun"]]
    ],
    "Yogg Warlock": [all: [["Glacial Shard"], ["Rotheart Dryad"]]],
    "Demon Warlock": [
      all: [["Conflagrate"], ["Imp Gang Stooge"]],
      all: [["Hellfire"], ["Moragg"]]
    ],
    "C'Thun Warlock": [
      all: [["Drain Soul"], ["Caged Cranium", "Ritual of C'Thun"]],
      all: [["Crystalline Golem"], ["Kith'ix"]]
    ],
    Rafaamlock: [
      all: [
        ["Shadow Rounds"],
        ["Cursed Catacombs", "Ritual of C'Thun", "Spire of Solitude", "The Unseen Atlas"]
      ],
      all: [["Ritual of Summoning"], ["Rotheart Dryad"]]
    ],
    "C'Thun Warlock": [
      all: [
        ["Imp Gang Stooge"],
        ["Caged Cranium", "Shrine of Twilight", "Spawn of C'Thun", "Spire of Solitude"]
      ],
      all: [
        ["The Unseen Atlas"],
        ["Hellfire", "Ritual of Summoning", "Spawn of C'Thun"]
      ],
      all: [["Caged Cranium"], ["Ritual of Summoning"]],
      all: [["Ritual of C'Thun"], ["Shrine of Twilight"]]
    ],
    Rafaamlock: [
      all: [
        ["Dirty Rat"],
        ["Cursed Catacombs", "Ritual of Excess", "The Unseen Atlas"]
      ]
    ],
    Rafaamlock: [all: [["Ritual of Excess"], ["Spawn of C'Thun"]]],
    "Yogg Warlock": [
      all: [["Caged Cranium"], ["Rotheart Dryad"]],
      all: [["Glacial Shard"], ["Spire of Solitude"]]
    ],
    Rafaamlock: [all: [["Ritual of Excess"], ["Rotheart Dryad"]]],
    "C'Thun Warlock": [
      all: [["Dirty Rat"], ["Imp Gang Stooge"]],
      all: [["The Unseen Atlas"], ["Treasure Fiend"]]
    ],
    Rafaamlock: [
      all: [["Ancient Augur"], ["Ritual of C'Thun"]],
      all: [["Caged Cranium"], ["Ritual of Excess"]]
    ],
    "C'Thun Warlock": [all: [["Possessed Animancer"], ["Ritual of C'Thun"]]],
    Zoolock: [all: [["Mawman Cultist"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [
      all: [["Godfather Kazakus"], ["Spire of Solitude", "The Unseen Atlas"]],
      all: [["Ritual of C'Thun"], ["Caged Cranium", "Imp Gang Stooge"]]
    ],
    Rafaamlock: [
      all: [
        ["Ritual of Excess"],
        ["Cursed Chains", "Imp Gang Stooge", "The Unseen Atlas"]
      ],
      all: [["Spire of Solitude"], ["Ritual of C'Thun", "The Unseen Atlas"]],
      all: [["Cursed Chains"], ["Imp Gang Stooge"]]
    ],
    Rafaamlock: [
      all: [["The Unseen Atlas"], ["Imp Gang Stooge", "Ritual of C'Thun"]]
    ],
    "C'Thun Warlock": [all: [["Hellfire"], ["Ritual of C'Thun"]]],
    Zoolock: [all: [["Ritual of C'Thun"], ["Ritual of Summoning"]]],
    Rafaamlock: [
      all: [["Godfather Kazakus"], ["Ritual of Excess", "Shadowsworn Disciple"]],
      all: [["Ritual of C'Thun"], ["Ritual of Excess"]]
    ],
    Rafaamlock: [all: [["Godfather Kazakus"], ["Hellfire", "Imp Gang Stooge"]]],
    Zoolock: [all: [["Godfather Kazakus"], ["Ritual of Summoning"]]],
    "C'Thun Warlock": [all: [["Cursed Catacombs"], ["Godfather Kazakus"]]],
    "C'Thun Warlock": [all: [["Godfather Kazakus"], ["Ritual of C'Thun"]]]
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
