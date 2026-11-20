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
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["The Demon Seed"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Augur"], ["Skulking Geist"]]]
      ]
    ],
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Imprisoned Horror"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mixologist"], ["Void Contract"]]]
      ]
    ],
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Mass Production"], ["Tachyon Barrage"]],
          all: [["Spirit Bomb"], ["The Demon Seed"]]
        ]
      ]
    ],
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Flesh Giant"], ["Elementium Geode", "Mass Production"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Demonic Studies"],
            [
              "\"Health\" Drink",
              "Ancient Augur",
              "Blademaster Okani",
              "Brann Bronzebeard",
              "Bygone Doomspeaker",
              "Cataclysm",
              "Chaotic Consumption",
              "Corrupting Mist",
              "Cursed Catacombs",
              "Demonic Project",
              "Dirty Rat",
              "Domino Effect",
              "Far Watch Post",
              "Godfather Kazakus",
              "Harsh Sentence",
              "Hellfire",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Pop'gar the Putrid",
              "Razorscale",
              "Reno Jackson",
              "Reno, Lone Ranger",
              "Rin, Orchestrator of Doom",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Ritual of Summoning",
              "Sargeras, the Destroyer",
              "Sir Finley, Sea Guide",
              "Symphony of Sins",
              "Theotar, the Mad Duke",
              "Zephrys the Great",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Reno, Lone Ranger"],
            [
              "\"Health\" Drink",
              "Altar of Fire",
              "Ancient Augur",
              "Blademaster Okani",
              "Brann Bronzebeard",
              "Bygone Doomspeaker",
              "Cataclysm",
              "Corrupting Mist",
              "Dar'Khan Drathir",
              "Darkbomb",
              "Demonic Project",
              "Dirty Rat",
              "Far Watch Post",
              "Full-Blown Evil",
              "Godfather Kazakus",
              "Gul'dan's Gift",
              "Harsh Sentence",
              "Hysteria",
              "Kith'ix",
              "Mixologist",
              "Mortal Eradication",
              "Mutanus the Devourer",
              "Raise Dead",
              "Razorscale",
              "Reverberations",
              "Rin, Orchestrator of Doom",
              "Ritual of C'Thun",
              "Ritual of Summoning",
              "Sargeras, the Destroyer",
              "Theotar, the Mad Duke",
              "Void Contract",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Mixologist"],
            [
              "Altar of Fire",
              "Blademaster Okani",
              "Bygone Doomspeaker",
              "Cataclysm",
              "Cursed Catacombs",
              "Dar'Khan Drathir",
              "Darkbomb",
              "Defile",
              "Demonic Project",
              "Dirty Rat",
              "E.T.C., Band Manager",
              "Full-Blown Evil",
              "Gnomeferatu",
              "Godfather Kazakus",
              "Gul'dan's Gift",
              "Hellfire",
              "Hysteria",
              "Mortal Eradication",
              "Mutanus the Devourer",
              "Pop'gar the Putrid",
              "Raise Dead",
              "Reno Jackson",
              "Rin, Orchestrator of Doom",
              "Sargeras, the Destroyer",
              "Sir Finley, Sea Guide",
              "Symphony of Sins",
              "Theotar, the Mad Duke",
              "Wing Welding",
              "Zephrys the Great",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Zephrys the Great"],
            [
              "Altar of Fire",
              "Ancient Augur",
              "Blademaster Okani",
              "Bygone Doomspeaker",
              "Cataclysm",
              "Corrupting Mist",
              "Curse of Agony",
              "Dar'Khan Drathir",
              "Darkbomb",
              "Deathlord",
              "Demonic Project",
              "Dirty Rat",
              "Far Watch Post",
              "Full-Blown Evil",
              "Godfather Kazakus",
              "Gul'dan's Gift",
              "Kith'ix",
              "Mortal Eradication",
              "Mutanus the Devourer",
              "Raise Dead",
              "Razorscale",
              "Reverberations",
              "Rin, Orchestrator of Doom",
              "Ritual of C'Thun",
              "Shadow Rounds",
              "Skulking Geist",
              "Theotar, the Mad Duke",
              "Void Contract",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Zilliax Deluxe 3000"],
            [
              "Ancient Augur",
              "Blademaster Okani",
              "Bygone Doomspeaker",
              "Cataclysm",
              "Corrupting Mist",
              "Cursed Catacombs",
              "Dar'Khan Drathir",
              "Far Watch Post",
              "Full-Blown Evil",
              "Godfather Kazakus",
              "Gul'dan's Gift",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Mutanus the Devourer",
              "Raise Dead",
              "Razorscale",
              "Reno Jackson",
              "Rin, Orchestrator of Doom",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Ritual of Summoning",
              "Sir Finley, Sea Guide",
              "The Curator",
              "Theotar, the Mad Duke",
              "Timeline Accelerator",
              "Wing Welding"
            ]
          ],
          all: [
            ["Far Watch Post"],
            [
              "\"Health\" Drink",
              "Ancient Augur",
              "Cataclysm",
              "Corrupting Mist",
              "Cursed Chains",
              "Felstring Harp",
              "Full-Blown Evil",
              "Godfather Kazakus",
              "Hellfire",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Mortal Eradication",
              "Mutanus the Devourer",
              "Pop'gar the Putrid",
              "Razorscale",
              "Reno Jackson",
              "Rin, Orchestrator of Doom",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Ritual of Summoning",
              "Skulking Geist"
            ]
          ],
          all: [
            ["Mutanus the Devourer"],
            [
              "\"Health\" Drink",
              "Blademaster Okani",
              "Cataclysm",
              "Darkbomb",
              "Demonic Project",
              "Full-Blown Evil",
              "Godfather Kazakus",
              "Gul'dan's Gift",
              "Hellfire",
              "Hysteria",
              "Kith'ix",
              "Mortal Eradication",
              "Pop'gar the Putrid",
              "Razorscale",
              "Reno Jackson",
              "Rin, Orchestrator of Doom",
              "Ritual of Excess",
              "Ritual of Summoning",
              "Sir Finley, Sea Guide",
              "Theotar, the Mad Duke"
            ]
          ],
          all: [
            ["Corrupting Mist"],
            [
              "Ancient Augur",
              "Cursed Catacombs",
              "Defile",
              "Dirty Rat",
              "Godfather Kazakus",
              "Harsh Sentence",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Pop'gar the Putrid",
              "Razorscale",
              "Reno Jackson",
              "Rin, Orchestrator of Doom",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Ritual of Summoning",
              "Sargeras, the Destroyer",
              "Symphony of Sins",
              "Theotar, the Mad Duke"
            ]
          ],
          all: [
            ["Rin, Orchestrator of Doom"],
            [
              "Ancient Augur",
              "Blademaster Okani",
              "Cataclysm",
              "Dar'Khan Drathir",
              "Dark Skies",
              "Darkbomb",
              "Dirty Rat",
              "Full-Blown Evil",
              "Gul'dan's Gift",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Reno Jackson",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Ritual of Summoning",
              "Theotar, the Mad Duke",
              "Timeline Accelerator"
            ]
          ],
          all: [
            ["Theotar, the Mad Duke"],
            [
              "\"Health\" Drink",
              "Ancient Augur",
              "Dar'Khan Drathir",
              "Dark Skies",
              "Full-Blown Evil",
              "Gul'dan's Gift",
              "Hellfire",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Marin the Manager",
              "Razorscale",
              "Reno Jackson",
              "Reverberations",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Ritual of Summoning"
            ]
          ],
          all: [
            ["Ritual of Summoning"],
            [
              "Altar of Fire",
              "Ancient Augur",
              "Brann Bronzebeard",
              "Bygone Doomspeaker",
              "Cataclysm",
              "Demonic Project",
              "Dirty Rat",
              "Felstring Harp",
              "Harsh Sentence",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Raise Dead",
              "Razorscale",
              "Skulking Geist",
              "Timeline Accelerator"
            ]
          ],
          all: [
            ["Blademaster Okani"],
            [
              "Ancient Augur",
              "Dar'Khan Drathir",
              "Deathlord",
              "Full-Blown Evil",
              "Gul'dan's Gift",
              "Hysteria",
              "Kith'ix",
              "Razorscale",
              "Reno Jackson",
              "Reverberations",
              "Ritual of Excess",
              "Skulking Geist",
              "Void Contract"
            ]
          ],
          all: [
            ["Cataclysm"],
            [
              "Ancient Augur",
              "Brann Bronzebeard",
              "Full-Blown Evil",
              "Godfather Kazakus",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Pop'gar the Putrid",
              "Razorscale",
              "Reno Jackson",
              "Ritual of C'Thun",
              "Ritual of Excess"
            ]
          ],
          all: [
            ["Ancient Augur"],
            [
              "\"Health\" Drink",
              "Brann Bronzebeard",
              "Godfather Kazakus",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Kith'ix",
              "Razorscale",
              "Reno Jackson",
              "Ritual of C'Thun",
              "Ritual of Excess"
            ]
          ],
          all: [
            ["Kith'ix"],
            [
              "Altar of Fire",
              "Brann Bronzebeard",
              "Bygone Doomspeaker",
              "Demonic Project",
              "Dirty Rat",
              "Hysteria",
              "Kerrigan, Queen of Blades",
              "Raise Dead",
              "Razorscale"
            ]
          ],
          all: [
            ["Reno Jackson"],
            [
              "\"Health\" Drink",
              "Altar of Fire",
              "Bygone Doomspeaker",
              "Darkbomb",
              "Demonic Project",
              "Full-Blown Evil",
              "Mortal Eradication",
              "Razorscale"
            ]
          ],
          all: [
            ["Deathlord"],
            [
              "\"Health\" Drink",
              "Altar of Fire",
              "Cursed Catacombs",
              "Raise Dead",
              "Sargeras, the Destroyer",
              "Sir Finley, Sea Guide",
              "Symphony of Sins"
            ]
          ],
          all: [
            ["Skulking Geist"],
            [
              "Bygone Doomspeaker",
              "Cursed Catacombs",
              "Dirty Rat",
              "Raise Dead",
              "Ritual of C'Thun",
              "Ritual of Excess",
              "Sargeras, the Destroyer"
            ]
          ],
          all: [
            ["Hysteria"],
            [
              "Bygone Doomspeaker",
              "Godfather Kazakus",
              "Harsh Sentence",
              "Kerrigan, Queen of Blades",
              "Razorscale",
              "Ritual of C'Thun"
            ]
          ],
          all: [
            ["Dark Skies"],
            ["Altar of Fire", "Bygone Doomspeaker", "Demonic Project", "Gnomeferatu", "Raise Dead"]
          ],
          all: [
            ["Gul'dan's Gift"],
            ["Dar'Khan Drathir", "Darkbomb", "Full-Blown Evil", "Hellfire", "Mortal Eradication"]
          ],
          all: [
            ["Razorscale"],
            ["Brann Bronzebeard", "Bygone Doomspeaker", "Darkbomb", "Ritual of C'Thun", "Ritual of Excess"]
          ],
          all: [
            ["Godfather Kazakus"],
            ["Dar'Khan Drathir", "Darkbomb", "Full-Blown Evil", "Kerrigan, Queen of Blades"]
          ],
          all: [
            ["Brann Bronzebeard"],
            ["Kerrigan, Queen of Blades", "Ritual of C'Thun", "Ritual of Excess"]
          ],
          all: [["Dirty Rat"], ["Dar'Khan Drathir", "Void Contract"]],
          all: [
            ["Kerrigan, Queen of Blades"],
            ["Ritual of C'Thun", "Ritual of Excess"]
          ],
          all: [["E.T.C., Band Manager"], ["Void Contract"]],
          all: [["Marin the Manager"], ["Symphony of Sins"]],
          all: [["Ritual of C'Thun"], ["Timeline Accelerator"]],
          all: [["Ritual of Excess"], ["Smothering Starfish"]]
        ]
      ]
    ],
    Boarlock: {[all: [["Elwynn Boar"], ["Glacial Shard"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Seedlock":
      {[all: [["Fanottem, Lord of the Opera"], ["Healthstone"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Elwynn Boar"], ["Ritual of C'Thun"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock:
      {[
         all: [
           ["The Soularium"],
           ["Chronoclaws", "Duke of Below", "Party Fiend", "Platysaur", "Wicked Whispers"]
         ],
         all: [["Duke of Below"], ["Symphony of Sins"]],
         all: [["Walking Dead"], ["Wicked Whispers"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock:
      {[
         all: [
           ["Elwynn Boar"],
           [
             "Chamber of Viscidus",
             "Chaotic Consumption",
             "Chronoclaws",
             "Cruel Dinomancer",
             "Cursed Catacombs",
             "Dark Pact",
             "Defile",
             "Demonic Project",
             "Domino Effect",
             "Explosive Sheep",
             "Fracking",
             "Free Admission",
             "Furnace Fuel",
             "Grimoire of Sacrifice",
             "Hand of Gul'dan",
             "Harsh Sentence",
             "Ocular Occultist",
             "Plague of Flames",
             "Ritual of Doom",
             "Rotheart Dryad",
             "Sir Finley, Sea Guide",
             "Soulfreeze",
             "Unstable Felbolt",
             "Wing Welding"
           ]
         ],
         all: [
           ["Explosive Sheep"],
           ["Chaotic Consumption", "Chronoclaws", "Domino Effect", "Sir Finley, Sea Guide", "Soulfreeze"]
         ],
         all: [["Chronoclaws"], ["Defile", "Wing Welding"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Demon Seed"],
            ["Dirty Rat", "Tour Guide", "Unlicensed Apothecary"]
          ],
          all: [["Crystallizer"], ["Hellfire"]]
        ]
      ]
    ],
    "XL Boarlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Elwynn Boar"], ["The Unseen Atlas"]]]
      ]
    ],
    "Chad Seedlock":
      {[
         all: [["Sacrificial Summoner"], ["Kobold Librarian", "Mass Production"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock":
      {[
         all: [["Patches the Pirate"], ["Leper Gnome", "Sketch Artist"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Discolock:
      {[
         all: [["Boneweb Egg"], ["Chronoclaws", "Disposable Acolytes"]],
         all: [["Soul Barrage"], ["Wicked Whispers"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Burnlock:
      {[all: [["Trogg Gemtosser"], ["Kobold Librarian", "Tram Mechanic"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Disposable Acolytes"], ["Party Fiend"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock": {[all: [["Rotheart Dryad"], ["Tamsin's Phylactery"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock:
      {[
         all: [
           ["Wicked Whispers"],
           [
             "Chronoclaws",
             "Cursed Catacombs",
             "Duke of Below",
             "Entropic Continuity",
             "Ocular Occultist",
             "Party Fiend",
             "Platysaur",
             "Soulfire"
           ]
         ],
         all: [["Duke of Below"], ["Party Fiend"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Tachyon Barrage"], ["The Demon Seed"]]]
      ]
    ],
    "XL Tick Tock Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Battle at the End Time"], ["The Unseen Atlas"]]]
      ]
    ],
    Seedlock: {[all: [["Cult Neophyte"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Healthstone"],
            ["Animated Broomstick", "Domino Effect", "Kobold Librarian", "The Demon Seed"]
          ],
          all: [["Harsh Sentence"], ["Imprisoned Horror", "The Demon Seed"]],
          all: [["Soulfreeze"], ["The Demon Seed"]]
        ]
      ]
    ],
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Demon Seed"], ["Demonic Project", "Domino Effect"]]]
      ]
    ],
    Burnlock: {[all: [["Hellfire"], ["Tram Mechanic"]]], [start_of_game: ["Prince Renathal"]]},
    "Tick Tock Warlock": {[all: [["Battle at the End Time"], ["Fracking"]]], [start_of_game: ["Prince Renathal"]]},
    Burnlock:
      {[
         all: [["Chamber of Viscidus"], ["Tram Mechanic"]],
         all: [["Kobold Librarian"], ["Leper Gnome"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Seedlock: {[all: [["Flesh Giant"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock": {[all: [["Furnace Fuel"], ["Tamsin's Phylactery"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Seedlock": {[all: [["Chamber of Viscidus"], ["Imprisoned Horror"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Boarlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Elwynn Boar"], ["Dark Pact", "Furnace Fuel"]],
          all: [["Explosive Sheep"], ["Furnace Fuel"]]
        ]
      ]
    ],
    Evenlock: {[all: [["Goldshire Gnoll"], ["Recombobulator"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock":
      {[
         all: [
           ["Spawning Pool"],
           ["Cruel Dinomancer", "Ocular Occultist", "Ritual of Doom", "Rotheart Dryad"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Party Fiend"], ["Platysaur"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock":
      {[
         "\"Health\" Drink",
         {:all, [["Barrel of Sludge"], ["Pop'gar the Putrid"]]}
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Seedlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Demon Seed"],
            ["Defile", "Elementium Geode", "Kobold Librarian", "Mass Production"]
          ],
          all: [["Crystallizer"], ["Elementium Geode"]]
        ]
      ]
    ],
    Discolock: {[all: [["Cursed Catacombs"], ["Disposable Acolytes"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Zephrys the Great"], ["\"Health\" Drink", "Harsh Sentence"]]]
      ]
    ],
    Boarlock:
      {[
         all: [
           ["Explosive Sheep"],
           ["Defile", "Demonic Project", "Fracking", "Rotheart Dryad"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock:
      {[
         all: [
           ["Explosive Sheep"],
           ["Cursed Catacombs", "Ocular Occultist", "Wing Welding"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    Seedlock: {[all: [["Dragged Below"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Deck of Chaos"], ["Fae Trickster"]]]
      ]
    ],
    "C'Thun Warlock": {[all: [["Cruel Dinomancer"], ["Ritual of C'Thun"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Entropic Continuity"], ["Party Fiend"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Cruel Dinomancer"], ["Demonic Project"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Deckless Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Altar of Fire"], ["Kobold Librarian"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Godfather Kazakus"],
            ["Altar of Fire", "Bygone Doomspeaker", "Dirty Rat"]
          ],
          all: [["Dirty Rat"], ["Ritual of C'Thun"]]
        ]
      ]
    ],
    Burnlock: {[all: [["Ashen Elemental"], ["Kobold Librarian"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Entropic Continuity"], ["Soulfire"]]], [start_of_game: ["Prince Renathal"]]},
    Seedlock: {[all: [["Tachyon Barrage"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock":
      {[
         all: [["Barrens Scavenger"], ["Elementium Geode", "Kobold Librarian"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Boarlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Explosive Sheep"], ["Rotheart Dryad"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Altar of Fire"],
            ["Darkbomb", "Hellfire", "Mortal Eradication", "Ritual of C'Thun", "Wing Welding"]
          ],
          all: [
            ["Blademaster Okani"],
            ["Godfather Kazakus", "Hellfire", "Ritual of C'Thun"]
          ],
          all: [
            ["Cursed Catacombs"],
            ["Deck of Chaos", "Hysteria", "Zephrys the Great"]
          ],
          all: [["Dirty Rat"], ["Hellfire", "Mortal Eradication"]],
          all: [["Gnomeferatu"], ["Godfather Kazakus", "Wing Welding"]],
          all: [["Symphony of Sins"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Highlander Warlock":
      {[all: [["Blademaster Okani"], ["Symphony of Sins"]]], [start_of_game: ["Prince Renathal"]]},
    Burnlock: {[all: [["Chronoclaws"], ["Tram Mechanic"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Seedlock":
      {[
         all: [["Chamber of Viscidus"], ["Crystallizer", "The Demon Seed"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Tick Tock Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Battle at the End Time"], ["Fracking"]]]
      ]
    ],
    Boarlock: {[all: [["Cruel Dinomancer"], ["Defile", "Furnace Fuel"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock": {[all: [["Ashen Elemental"], ["Sir Finley, Sea Guide"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock": {[all: [["Ritual of C'Thun"], ["Wing Welding"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock:
      {[
         all: [["Wing Welding"], ["Chamber of Viscidus", "Sir Finley, Sea Guide"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock": {[all: [["Altar of Fire"], ["Elementium Geode"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Bygone Doomspeaker"],
            ["\"Health\" Drink", "Ritual of C'Thun", "Ritual of Excess"]
          ],
          all: [["Domino Effect"], ["Reno Jackson"]]
        ]
      ]
    ],
    "Pirate Burnlock":
      {[
         all: [["Space Pirate"], ["Gemstone Hoarder", "Rain of Fire"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Burnlock: {[all: [["Dragged Below"], ["Tachyon Barrage"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Seedlock": {[all: [["Flesh Giant"], ["Spirit Bomb"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Ocular Occultist"], ["Wing Welding"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock": {[all: [["Fracking"], ["Kobold Miner"]]], [start_of_game: ["Prince Renathal"]]},
    Seedlock:
      {[
         all: [["Mass Production"], ["Plague of Flames"]],
         all: [["Rotten Apple"], ["The Demon Seed"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Rivendare Warlock": {[all: [["Sense Demons"], ["Voidcaller"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Altar of Fire"],
            ["Blademaster Okani", "Rin, Orchestrator of Doom"]
          ],
          all: [["Gnomeferatu"], ["\"Health\" Drink", "Mortal Eradication"]],
          all: [["Blademaster Okani"], ["Far Watch Post"]],
          all: [["Demonic Project"], ["Ritual of Excess"]],
          all: [["Dirty Rat"], ["Razorscale"]],
          all: [["Full-Blown Evil"], ["Symphony of Sins"]],
          all: [["Pop'gar the Putrid"], ["Ritual of C'Thun"]]
        ]
      ]
    ],
    "XL Boarlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Explosive Sheep"], ["Harsh Sentence"]]]
      ]
    ],
    "Pirate Burnlock":
      {[
         all: [["Ashen Elemental"], ["Space Pirate", "Treasure Fiend"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Ritual of Doom"], ["Wing Welding"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock": {[all: [["Fracking"], ["Space Pirate"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock:
      {[
         all: [["Demonic Project"], ["Rotheart Dryad"]],
         all: [["Furnace Fuel"], ["Wing Welding"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Domino Effect"], ["Ocular Occultist"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Discolock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cursed Catacombs"], ["Wicked Whispers"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Blademaster Okani"],
            ["Bygone Doomspeaker", "Defile", "Demonic Project", "E.T.C., Band Manager", "Symphony of Sins"]
          ],
          all: [
            ["Altar of Fire"],
            ["Defile", "E.T.C., Band Manager", "Prince Renathal", "Symphony of Sins"]
          ],
          all: [
            ["E.T.C., Band Manager"],
            ["Bygone Doomspeaker", "Razorscale", "Theotar, the Mad Duke"]
          ],
          all: [["Dirty Rat"], ["\"Health\" Drink", "Pop'gar the Putrid"]],
          all: [["Godfather Kazakus"], ["Hellfire", "Pop'gar the Putrid"]],
          all: [["Razorscale"], ["Demonic Project", "Symphony of Sins"]],
          all: [["Ritual of Excess"], ["Harsh Sentence", "Symphony of Sins"]],
          all: [["Murloc Rafaam"], ["Tiny Rafaam"]]
        ]
      ]
    ],
    "Tick Tock Warlock":
      {[
         all: [["Battle at the End Time"], ["Cursed Catacombs"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sir Finley, Sea Guide"], ["Zephrys the Great"]]]
      ]
    ],
    Discolock: {[all: [["Entropic Continuity"], ["Ocular Occultist"]]], [start_of_game: ["Prince Renathal"]]},
    "Deckless Warlock":
      {[
         all: [["Spawning Pool"], ["Demonic Studies", "Free Admission"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Bygone Doomspeaker"],
            ["Symphony of Sins", "Theotar, the Mad Duke"]
          ],
          all: [["Altar of Fire"], ["Cursed Catacombs"]],
          all: [["E.T.C., Band Manager"], ["Gnomeferatu"]]
        ]
      ]
    ],
    Burnlock: {[all: [["Mawman Cultist"], ["Sizzling Cinder"]]], [start_of_game: ["Prince Renathal"]]},
    Evenlock: {[all: [["Anetheron"], ["Cursed Catacombs"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Altar of Fire"], ["Demonic Project", "Gnomeferatu"]],
          all: [["Bygone Doomspeaker"], ["Far Watch Post"]]
        ]
      ]
    ],
    Boarlock: {[all: [["Ocular Occultist"], ["Ritual of Doom"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock": {[all: [["Smokestack"], ["Youthful Brewmaster"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Duke of Below"], ["Platysaur"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Rotheart Dryad"], ["Sir Finley, Sea Guide"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Domino Effect"], ["Ritual of Summoning"]]]
      ]
    ],
    "Pirate Burnlock":
      {[
         all: [["Leper Gnome"], ["Sir Finley, Sea Guide", "Space Pirate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Demonic Project"], ["Ocular Occultist"]]], [start_of_game: ["Prince Renathal"]]},
    Seedlock: {[all: [["Elementium Geode"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bygone Doomspeaker"], ["Gnomeferatu"]]]
      ]
    ],
    "XL Boarlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Elwynn Boar"], ["Ocular Occultist"]]]
      ]
    ],
    Burnlock:
      {[all: [["Kobold Librarian"], ["Sizzling Cinder", "Sketch Artist"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Godfather Kazakus"],
            ["Cursed Catacombs", "Demonic Project", "Ritual of C'Thun", "Ritual of Summoning"]
          ],
          all: [["Dirty Rat"], ["Altar of Fire", "Bygone Doomspeaker"]],
          all: [["Ritual of C'Thun"], ["Ritual of Excess", "Ritual of Summoning"]],
          all: [["Symphony of Sins"], ["Gnomeferatu", "Theotar, the Mad Duke"]],
          all: [["Cursed Catacombs"], ["Rin, Orchestrator of Doom"]],
          all: [["Deck of Chaos"], ["Sphere of Sapience"]]
        ]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Godfather Kazakus"], ["Harsh Sentence"]]]
      ]
    ],
    "XL Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Critter Caretaker"], ["Kobold Librarian"]]]
      ]
    ],
    "Miracle Seedlock": {[all: [["Furnace Fuel"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "Insanity Warlock":
      {[
         all: [
           ["Void Virtuoso"],
           ["Cursed Catacombs", "Fracking", "Pop'gar the Putrid"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock": {[all: [["Expired Merchant"], ["Patches the Pirate"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Ocular Occultist"], ["Sir Finley, Sea Guide"]]], [start_of_game: ["Prince Renathal"]]},
    "SoU Quest Warlock": {[all: [["Plot Twist"], ["Supreme Archaeology"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock:
      {[
         all: [["Defile"], ["Ocular Occultist"]],
         all: [["Furnace Fuel"], ["Rotheart Dryad"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Fracking"], ["Wing Welding"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Pop'gar the Putrid"], ["Defile", "Harsh Sentence", "Hellfire"]],
          all: [["Godfather Kazakus"], ["Domino Effect", "Symphony of Sins"]],
          all: [["Dirty Rat"], ["Far Watch Post"]]
        ]
      ]
    ],
    "XL Highlander Warlock": {[all: [["Godfather Kazakus"], ["Harsh Sentence"]]], [start_of_game: ["Prince Renathal"]]},
    "Deckless Warlock":
      {[
         all: [["Arkonite Defense Crystal"], ["Cursed Catacombs"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock": {[all: [["Gargantuan Slitherer"], ["Imp Gang Stooge"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Seedlock": {[all: [["Fracking"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    Seedlock: {[all: [["Demonic Project"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock": {[all: [["Kobold Librarian"], ["Symphony of Sins"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Rotheart Dryad"], ["Defile", "Ocular Occultist"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Chamber of Viscidus"], ["Rotheart Dryad"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Ocular Occultist"], ["Platysaur"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock":
      {[
         all: [["Ocular Occultist"], ["Sizzling Cinder", "Space Pirate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "STD Zoolock": {[all: [["Ritual of Summoning"], ["Twilight Timehopper"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Fracking"], ["Ocular Occultist"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["\"Health\" Drink"],
            ["Harsh Sentence", "Hellfire", "Pop'gar the Putrid", "Symphony of Sins"]
          ],
          all: [["Dirty Rat"], ["Symphony of Sins"]],
          all: [["Far Watch Post"], ["Harsh Sentence"]]
        ]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Defile"], ["Hellfire"]],
          all: [["Domino Effect"], ["Pop'gar the Putrid"]]
        ]
      ]
    ],
    Seedlock: {[all: [["Molten Giant"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    Burnlock: {[all: [["Harsh Sentence"], ["Tachyon Barrage"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock":
      {[
         all: [
           ["Space Pirate"],
           ["Expired Merchant", "Sizzling Cinder", "Soulfire", "Tachyon Barrage"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    Burnlock:
      {[all: [["Cult Neophyte"], ["Chamber of Viscidus", "Chronoclaws"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Cursed Catacombs"], ["Party Fiend"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock": {[all: [["Crane Game"], ["Fracking"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Demonic Project"], ["Fracking"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock":
      {[
         all: [["Cursed Catacombs"], ["Zephrys the Great"]],
         all: [["Harsh Sentence"], ["Symphony of Sins"]]
       ], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Fracking"], ["Rotheart Dryad"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Boarlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Elwynn Boar"], ["Fracking"]]]
      ]
    ],
    "XL C'Thun Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Fracking"], ["Spawning Pool"]]]
      ]
    ],
    "Splendiferous Whizbang": {[all: [["Barrens Scavenger"], ["Fracking"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Symphony of Sins"],
            ["Demonic Project", "Hellfire", "Mortal Eradication", "Sargeras, the Destroyer"]
          ],
          all: [
            ["Bygone Doomspeaker"],
            ["Demonic Project", "Sir Finley, Sea Guide"]
          ],
          all: [["Dirty Rat"], ["Domino Effect"]],
          all: [["The Curator"], ["Timeline Accelerator"]]
        ]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Demonic Project"], ["Dirty Rat", "E.T.C., Band Manager"]],
          all: [["Dirty Rat"], ["Sir Finley, Sea Guide"]],
          all: [["E.T.C., Band Manager"], ["Symphony of Sins"]]
        ]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Harsh Sentence"]]]
      ]
    ],
    Seedlock: {[all: [["Hellfire"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock":
      {[
         all: [
           ["Cursed Catacombs"],
           ["Kobold Miner", "Mo'arg Drillfist", "Smokestack"]
         ],
         all: [["Mo'arg Drillfist"], ["Smokestack"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cursed Catacombs"], ["Dirty Rat"]]]
      ]
    ],
    "Chad Seedlock": {[all: [["Soulfreeze"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    Seedlock:
      {[
         all: [
           ["The Demon Seed"],
           ["Domino Effect", "Mass Production", "Sir Finley, Sea Guide"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock":
      {[
         all: [["Ashen Elemental"], ["Leper Gnome", "Sizzling Cinder"]],
         all: [["Sizzling Cinder"], ["Tachyon Barrage"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Deckless Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sir Finley, Sea Guide"], ["Skull of the Man'ari"]]]
      ]
    ],
    "XL Tick Tock Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Battle at the End Time"], ["Cursed Catacombs"]]]
      ]
    ],
    "XL Pirate Burnlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ashen Elemental"], ["Space Pirate"]]]
      ]
    ],
    "XL Burnlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Ashen Elemental"], ["Kobold Librarian", "Tram Mechanic"]],
          all: [["Cult Neophyte"], ["Tram Mechanic", "Treasure Fiend"]],
          all: [["Mawman Cultist"], ["Treasure Fiend"]]
        ]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Harsh Sentence"], ["Bygone Doomspeaker", "Ritual of C'Thun"]]]
      ]
    ],
    Boarlock: {[all: [["Rotheart Dryad"], ["Wing Welding"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Cursed Catacombs"], ["Rotheart Dryad"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Pirate Burnlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Space Pirate"],
            ["Chronoclaws", "Expired Merchant", "Harsh Sentence", "Sketch Artist"]
          ]
        ]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["\"Health\" Drink"], ["Sir Finley, Sea Guide"]],
          all: [["Harsh Sentence"], ["Symphony of Sins"]]
        ]
      ]
    ],
    Burnlock:
      {[
         all: [["Hellfire"], ["Expired Merchant", "Sketch Artist"]],
         all: [["Ashen Elemental"], ["Tachyon Barrage"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock": {[all: [["Ritual of C'Thun"], ["Spawning Pool"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock": {[all: [["Chronoclaws"], ["Sizzling Cinder"]]], [start_of_game: ["Prince Renathal"]]},
    Seedlock: {[all: [["Raise Dead"], ["The Demon Seed"]]], [start_of_game: ["Prince Renathal"]]},
    "Insanity Warlock": {[all: [["Encroaching Insanity"], ["Felstring Harp"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock": {[all: [["Chamber of Viscidus"], ["Leper Gnome"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Carnivorous Cube"], ["Carnivorous Cubicle"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["\"Health\" Drink"], ["Defile"]],
          all: [["Prince Renathal"], ["Symphony of Sins"]]
        ]
      ]
    ],
    Discolock: {[all: [["Ocular Occultist"], ["Soulfire"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Warlock": {[all: [["Ritual of C'Thun"], ["Spawn of C'Thun"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Deckless Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Wing Welding"], ["Instrument Tech", "Skull of the Man'ari"]]]
      ]
    ],
    "XL Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Kobold Miner"], ["Smokestack"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["\"Health\" Drink"], ["Cursed Catacombs", "Domino Effect"]]]
      ]
    ],
    Boarlock: {[all: [["Cursed Catacombs"], ["Furnace Fuel"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Burnlock":
      {[all: [["Sketch Artist"], ["Chronoclaws", "Leper Gnome"]]], [start_of_game: ["Prince Renathal"]]},
    Discolock: {[all: [["Cursed Catacombs"], ["Platysaur"]]], [start_of_game: ["Prince Renathal"]]},
    Boarlock: {[all: [["Cursed Catacombs"], ["Ocular Occultist"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Defile"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    Evenlock: {[all: [["Cursed Catacombs"], ["Table Flip"]]], [start_of_game: ["Prince Renathal"]]},
    "Mill Warlock": {[all: [["Cursed Catacombs"], ["Prize Vendor"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Seedlock": {[all: [["Imprisoned Horror"], ["Kobold Librarian"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Deckless Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Skull of the Man'ari"], ["Carnivorous Cube", "Defile"]]]
      ]
    ],
    Boarlock: {[all: [["Cursed Catacombs"], ["Sir Finley, Sea Guide"]]], [start_of_game: ["Prince Renathal"]]},
    Burnlock:
      {[
         all: [["Expired Merchant"], ["Chamber of Viscidus", "Tachyon Barrage"]],
         all: [["Cursed Catacombs"], ["Sketch Artist"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Cursed Catacombs"],
            ["Ritual of C'Thun", "Sir Finley, Sea Guide"]
          ],
          all: [["Demonic Project"], ["Harsh Sentence"]],
          all: [["Domino Effect"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    Boarlock: {[all: [["Chamber of Viscidus"], ["Cursed Catacombs"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Burnlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cursed Catacombs"], ["Chronoclaws", "Sketch Artist"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cursed Catacombs"], ["Demonic Project", "E.T.C., Band Manager"]]]
      ]
    ],
    "XL Deckless Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bloodbloom"], ["Crane Game"]]]
      ]
    ],
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Cursed Catacombs"], ["Prince Renathal", "Wing Welding"]],
          all: [["Domino Effect"], ["Harsh Sentence"]]
        ]
      ]
    ],
    "Other Warlock": {[all: [["Kobold Librarian"], ["Raise Dead"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Defile"], ["Cursed Catacombs", "Domino Effect"]]]
      ]
    ],
    Boarlock: {[all: [["Cursed Catacombs"], ["Defile", "Demonic Project"]]], [start_of_game: ["Prince Renathal"]]},
    "Zerg Warlock": {[all: [["Bloodbloom"], ["Darkest Hour"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Deckless Warlock": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Instrument Tech"], ["Skull of the Man'ari"]]]
      ]
    ],
    Boarlock: {[all: [["Cursed Catacombs"], ["Harsh Sentence"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Warlock": {[all: [["Cursed Catacombs"], ["Kobold Librarian"]]], [start_of_game: ["Prince Renathal"]]}
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
