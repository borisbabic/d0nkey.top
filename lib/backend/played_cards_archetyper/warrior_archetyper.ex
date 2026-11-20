# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @pirate_warrior_excludes [
    "Brood Keeper",
    "Darkrider",
    "Darkscale Broodmother",
    "Petal Peddler",
    "Prescient Slitherdrake",
    "Shadowed Informant",
    "Windpeak Wyrm"
  ]
  @dragon_warrior_excludes [
    "Blastpowder Engineer",
    "Cannonmaster",
    "Captain Crowley",
    "Follow the Fuse",
    "Hook n' Heave",
    "Hand Cannon",
    "Land Ho!",
    "Sky Raider",
    "Southsea Captain"
  ]
  @standard_config [
    "Quest Warrior": ["Enter the Lost City"],
    "Harold Warrior": [
      {:all,
       [
         ["Envoy of the End"],
         [
           "Cataclysmic War Axe",
           "Deathwing, Worldbreaker",
           "Decimation",
           "For Glory!",
           "Living Flame",
           "Nightmare Lord Xavius",
           "Precursory Strike",
           "Ragnaros, the Great Fire",
           "Scorching Ravager",
           "Shield Block",
           "Tol'vir Vanguard",
           "Ultraxion"
         ]
       ]},
      {:all,
       [
         ["Scorching Ravager"],
         [
           "Crowd Control",
           "Crystalline Golem",
           "Decimation",
           "For Glory!",
           "Living Flame",
           "N'Zoth, Dream's End",
           "Nightmare Lord Xavius",
           "Scramble for Gear",
           "Tol'vir Vanguard"
         ]
       ]},
      {:all,
       [
         ["Cataclysmic War Axe"],
         ["Crowd Control", "Scramble for Gear"]
       ]},
      {:all,
       [
         ["Ragnaros, the Great Fire"],
         ["Shield Block", "Tol'vir Vanguard"]
       ]},
      {:all,
       [
         ["Tol'vir Vanguard"],
         ["Ultraxion"]
       ]}
    ],
    "Pirate Warrior": [
      {:all,
       [
         ["Hand Cannon"],
         [
           "Archaedas",
           "Chainbreaker Hogger",
           "Erupting Volcano",
           "Eternal Toil",
           "Forge of Origination",
           "Living Flame",
           "Searing Fissure",
           "Tol'vir Vanguard"
         ]
       ]},
      {:all,
       [
         ["Blastpowder Engineer"],
         ["Eternal Toil"]
       ]}
    ],
    # 3.5
    "N'Zoth Warrior": [
      {:all,
       [
         ["N'Zoth, Dream's End"],
         [
           "Broll, Blood Fighter",
           "Crystalline Golem",
           "Decimation",
           "Dirty Rat",
           "Eternal Toil",
           "Forge of Origination",
           "Living Flame",
           "Nightmare Lord Xavius",
           "Royal Librarian",
           "Setesh",
           "Slam",
           "Torch"
         ]
       ]}
    ],
    # 4.5
    "Dragon Warrior": [
      {:all,
       [
         ["Brood Keeper"],
         [
           "Archaedas",
           "Cannonmaster",
           "Carrier Whelp",
           "Darkrider",
           "Darkscale Broodmother",
           "Hook n' Heave",
           "Mother Duck",
           "Prescient Slitherdrake",
           "Sanguine Depths",
           "Searing Fissure",
           "Shadowflame Suffusion",
           "Stadium Announcer",
           "Torch",
           "Windpeak Wyrm"
         ]
       ]},
      {:all,
       [
         ["Prescient Slitherdrake"],
         [
           "Cannonmaster",
           "Forge of Origination",
           "Hook n' Heave",
           "Mother Duck",
           "Sanguine Depths",
           "Searing Fissure",
           "Stadium Announcer",
           "Torch",
           "Windpeak Wyrm"
         ]
       ]},
      {:all,
       [
         ["Windpeak Wyrm"],
         ["Cannonmaster", "Carrier Whelp", "Hook n' Heave", "Mother Duck", "Searing Fissure", "Stadium Announcer"]
       ]},
      {:all,
       [
         ["Darkrider"],
         ["Cannonmaster", "Hook n' Heave", "Mother Duck", "Searing Fissure", "Stadium Announcer"]
       ]},
      {:all,
       [
         ["Darkscale Broodmother"],
         ["Cannonmaster", "Hook n' Heave", "Mother Duck", "Searing Fissure", "Torch"]
       ]},
      {:all,
       [
         ["Carrier Whelp"],
         ["Searing Fissure", "Stadium Announcer"]
       ]}
    ],
    # 5.5
    "Pirate Warrior": [
      {:all,
       [
         ["Hand Cannon"],
         [
           "Cannonmaster",
           "Captain Crowley",
           "Mother Duck",
           "Sanguine Depths",
           "Shadowflame Suffusion",
           "Sky Raider",
           "Torch"
         ]
       ]},
      {:all,
       [
         ["Land Ho!"],
         ["Blastpowder Engineer", "Sky Raider", "Southsea Captain", "Stadium Announcer"]
       ]},
      {:all,
       [
         ["Blastpowder Engineer"],
         ["Cult Neophyte", "Stadium Announcer"]
       ]},
      {:all,
       [
         ["Sky Raider"],
         ["Stadium Announcer"]
       ]}
    ],
    # 6.5
    "N'Zoth Warrior": [
      {:all,
       [
         ["Crystalline Golem"],
         [
           "Archaedas",
           "Decimation",
           "Eternal Toil",
           "For Glory!",
           "Forge of Origination",
           "Living Flame",
           "Lo'Gosh, Blood Fighter",
           "Nightmare Lord Xavius",
           "Precursory Strike",
           "Shield Block",
           "Slam",
           "Tol'vir Vanguard",
           "Torch"
         ]
       ]},
      {:all,
       [
         ["Unstable Prototype"],
         ["Decimation", "For Glory!", "Prize Vendor"]
       ]},
      {:all,
       [
         ["Tol'vir Vanguard"],
         ["Twilight Egg"]
       ]}
    ],
    # 7.5
    "Yogg Warrior": [
      {:all,
       [
         ["Brassknuckle Brawler"],
         ["Erupting Volcano", "Searing Fissure"]
       ]},
      {:all,
       [
         ["Chisel"],
         ["Commander Geddon", "Slow Motion"]
       ]},
      {:all,
       [
         ["Ancient of Yore"],
         ["Slow Motion"]
       ]}
    ],
    "Harold Warrior": [
      "Scorching Ravager",
      "Cataclysmic War Axe"
    ],
    # 9.5
    "Pirate Warrior": [
      {:all,
       [
         ["Land Ho!"],
         ["Cannonmaster", "Captain Crowley", "Hook n' Heave", "Mother Duck", "Searing Fissure"]
       ]},
      {:all,
       [
         ["Eternal Toil"],
         ["Stadium Announcer"]
       ]}
    ],
    # 10.5
    #
    "Yogg Warrior": [
      {:all,
       [
         ["Mastermind Yogg-Saron"],
         ["Cannonmaster", "Captain Crowley", "Hook n' Heave", "Sanguine Depths", "Searing Fissure"]
       ]},
      {:all,
       [
         ["Sanguine Depths"],
         ["Forge of Origination", "Stone Gauntlet", "Tol'vir Vanguard"]
       ]},
      {:all,
       [
         ["Searing Fissure"],
         ["Setesh"]
       ]}
    ],
    # 11.5
    "Pirate Warrior": [
      {:all,
       [
         ["Blastpowder Engineer"],
         ["Precursory Strike", "Sanguine Depths", "Southsea Captain"]
       ]},
      {:all,
       [
         ["Sky Raider"],
         ["Sanguine Depths", "Southsea Captain"]
       ]}
    ],
    # 12.5
    "Lo'Gosh Warrior": [
      {:all,
       [
         ["Portal Vanguard"],
         ["Crowd Control", "Eternal Toil", "Living Flame", "Mastermind Yogg-Saron", "Slam"]
       ]},
      {:all,
       [
         ["Erupting Volcano"],
         ["Broll, Blood Fighter", "Mastermind Yogg-Saron", "Valeera, Blood Fighter"]
       ]},
      {:all,
       [
         ["Decimation"],
         ["Mother Duck", "Warptooth"]
       ]},
      {:all,
       [
         ["Mastermind Yogg-Saron"],
         ["Eternal Toil", "Valeera, Blood Fighter"]
       ]},
      {:all,
       [
         ["For Glory!"],
         ["Mother Duck"]
       ]}
    ],
    # 13.5
    "Dragon Warrior": [
      {:all,
       [
         ["Carrier Whelp"],
         ["Hook n' Heave"]
       ]}
    ],
    # 14.5
    "Armor Warrior": [
      {:all,
       [
         ["Animator of Iron"],
         ["Barricade Basher", "Shellnado"]
       ]}
    ],
    # 15.5
    "N'Zoth Warrior": [
      {:all,
       [
         ["Taelan Fordring"],
         ["Decimation", "Eternal Toil", "Living Flame"]
       ]},
      {:all,
       [
         ["Royal Librarian"],
         ["Eternal Toil", "Slam"]
       ]}
    ],
    # 16.5
    "Lo'Gosh Warrior": [
      {:all,
       [
         ["Y'Shaarj, Titan Bane"],
         ["Broll, Blood Fighter", "Eternal Toil", "Lo'Gosh, Blood Fighter"]
       ]},
      {:all,
       [
         ["Acolyte of Pain"],
         ["Shadowflame Suffusion"]
       ]}
    ],
    # 17.5
    # auto gen
    "Egg Warrior": [all: [["Holy Eggbearer"], ["Sanguine Depths"]]],
    "Pirate Warrior": [all: [["Living Flame"], ["Stadium Announcer"]]],
    "Yogg Warrior": [all: [["Chisel"], ["Execute"]]],
    "Pirate Warrior": [
      all: [["Blastpowder Engineer"], ["Searing Fissure", "Torch"]]
    ],
    "Yogg Warrior": [all: [["Searing Fissure"], ["Stone Gauntlet"]]],
    "Pirate Warrior": [all: [["Mother Duck"], ["Sky Raider"]]],
    "Pirate Warrior": [
      all: [["Sky Raider"], ["Cannonmaster", "Shadowflame Suffusion"]]
    ],
    "N'Zoth Warrior": [all: [["Eternal Toil"], ["Forge of Origination"]]],
    "Pirate Warrior": [all: [["Captain Crowley"], ["Eternal Toil"]]],
    "Lo'Gosh Warrior": [all: [["Erupting Volcano"], ["Lo'Gosh, Blood Fighter"]]],
    "Pirate Warrior": [
      all: [["Blastpowder Engineer"], ["Living Flame"]],
      all: [["Cannonmaster"], ["Eternal Toil"]],
      all: [["Captain Crowley"], ["Lo'Gosh, Blood Fighter"]]
    ],
    "Yogg Warrior": [
      all: [
        ["Setesh"],
        ["Cannonmaster", "Captain Crowley", "Erupting Volcano", "Hook n' Heave"]
      ],
      all: [["Living Flame"], ["Cannonmaster", "Captain Crowley"]],
      all: [["Forge of Origination"], ["Searing Fissure"]]
    ],
    "Pirate Warrior": [
      all: [
        ["Animator of Iron"],
        ["Cannonmaster", "Captain Crowley", "Hook n' Heave"]
      ],
      all: [["Cannonmaster"], ["Blastpowder Engineer", "King Mukla"]],
      all: [["Eternal Toil"], ["Hook n' Heave"]]
    ],
    "Pirate Warrior": [all: [["Blastpowder Engineer"], ["Hook n' Heave"]]],
    "N'Zoth Warrior": [
      all: [["Afflicted Devastator"], ["Precursory Strike"]],
      all: [["Living Flame"], ["Valeera, Blood Fighter"]]
    ],
    "Lo'Gosh Warrior": [all: [["Decimation"], ["Erupting Volcano"]]],
    "N'Zoth Warrior": [all: [["Living Flame"], ["Lo'Gosh, Blood Fighter"]]],
    "Armor Warrior": [all: [["Forge of Origination"], ["Fortify"]]],
    "N'Zoth Warrior": [all: [["Broll, Blood Fighter"], ["Prize Vendor"]]],
    "Pirate Warrior": [all: [["Cannonmaster"], ["Precursory Strike"]]],
    "Lo'Gosh Warrior": [all: [["Mother Duck"], ["Precursory Strike"]]],
    "N'Zoth Warrior": [all: [["Prize Vendor"], ["Show of Force"]]],
    "Yogg Warrior": [
      all: [["Tol'vir Vanguard"], ["Cannonmaster", "Searing Fissure"]],
      all: [["Captain Crowley"], ["Warptooth"]],
      all: [["Hook n' Heave"], ["Living Flame"]]
    ],
    "N'Zoth Warrior": [
      all: [["Eternal Toil"], ["Living Flame", "Valeera, Blood Fighter"]],
      all: [["Broll, Blood Fighter"], ["Living Flame"]]
    ],
    "Yogg Warrior": [
      all: [["Living Flame"], ["Chisel", "Execute", "Mother Duck"]]
    ],
    "Armor Warrior": [all: [["Animator of Iron"], ["Show of Force"]]],
    "Lo'Gosh Warrior": [all: [["Fortify"], ["Animator of Iron", "Crowd Control"]]],
    "N'Zoth Warrior": [
      all: [
        ["Slam"],
        ["Eternal Toil", "Forge of Origination", "Living Flame", "Lo'Gosh, Blood Fighter", "Valeera, Blood Fighter"]
      ],
      all: [
        ["Living Flame"],
        ["For Glory!", "Forge of Origination", "Precursory Strike"]
      ],
      all: [["Eternal Toil"], ["Lo'Gosh, Blood Fighter", "Tol'vir Vanguard"]],
      all: [["Nightmare Lord Xavius"], ["Prize Vendor"]]
    ],
    "Lo'Gosh Warrior": [
      all: [["Erupting Volcano"], ["For Glory!", "Precursory Strike"]],
      all: [["Mastermind Yogg-Saron"], ["Shadowflame Suffusion"]]
    ],
    "Dragon Warrior": [all: [["Carrier Whelp"], ["Shadowflame Suffusion"]]],
    "Yogg Warrior": [all: [["Archaedas"], ["Captain Crowley"]]],
    "Pirate Warrior": [all: [["Erupting Volcano"], ["Stadium Announcer"]]],
    "Yogg Warrior": [
      all: [
        ["Hook n' Heave"],
        ["Archaedas", "Erupting Volcano", "Forge of Origination", "Stone Gauntlet", "Tol'vir Vanguard"]
      ],
      all: [
        ["Cannonmaster"],
        ["Archaedas", "Erupting Volcano", "Forge of Origination", "Stone Gauntlet"]
      ],
      all: [
        ["Captain Crowley"],
        ["Erupting Volcano", "Forge of Origination", "Stone Gauntlet", "Tol'vir Vanguard"]
      ],
      all: [["Archaedas"], ["Searing Fissure"]],
      all: [["Erupting Volcano"], ["Stone Gauntlet"]]
    ],
    "Quest Warrior": [
      all: [["Commander Geddon"], ["Setesh"]],
      all: [["Show of Force"], ["Y'Shaarj, Titan Bane"]]
    ],
    "Pirate Warrior": [all: [["Forge of Origination"], ["Land Ho!"]]],
    "Lo'Gosh Warrior": [all: [["Erupting Volcano"], ["Shield Block"]]],
    "N'Zoth Warrior": [
      all: [
        ["Living Flame"],
        ["Decimation", "Nightmare Lord Xavius", "Shield Block"]
      ],
      all: [["Prize Vendor"], ["Tol'vir Vanguard"]]
    ],
    "Yogg Warrior": [
      all: [["Living Flame"], ["Sanguine Depths", "Stone Gauntlet"]],
      all: [["Chisel"], ["Dirty Rat"]]
    ],
    "Lo'Gosh Warrior": [all: [["Shield Block"], ["Warptooth"]]],
    "Lo'Gosh Warrior": [all: [["Axe of the Forefathers"], ["Scramble for Gear"]]],
    "Pirate Warrior": [
      all: [["Stadium Announcer"], ["Cannonmaster", "Sanguine Depths"]]
    ],
    "Yogg Warrior": [all: [["Hook n' Heave"], ["Sanguine Depths"]]],
    "Armor Warrior": [all: [["Barricade Basher"], ["Scramble for Gear"]]],
    "N'Zoth Warrior": [
      all: [["Forge of Origination"], ["Royal Librarian"]],
      all: [["Setesh"], ["Valeera, Blood Fighter"]]
    ],
    "Lo'Gosh Warrior": [all: [["Stone Gauntlet"], ["Valeera, Blood Fighter"]]],
    "N'Zoth Warrior": [
      all: [
        ["Valeera, Blood Fighter"],
        ["Archaedas", "Forge of Origination", "Tol'vir Vanguard"]
      ]
    ],
    "Quest Warrior": [all: [["Slam"], ["The Great Dracorex"]]],
    "Other Warrior": [all: [["Elder Word: Foresight"], ["Lunarwing Messenger"]]],
    "N'Zoth Warrior": [all: [["Broll, Blood Fighter"], ["Dirty Rat", "Slam"]]],
    "Armor Warrior": [all: [["Scramble for Gear"], ["Stone Gauntlet"]]],
    "N'Zoth Warrior": [all: [["Broll, Blood Fighter"], ["Eternal Toil"]]],
    "Lo'Gosh Warrior": [all: [["Decimation"], ["Stone Gauntlet"]]],
    "N'Zoth Warrior": [
      all: [
        ["Decimation"],
        ["Broll, Blood Fighter", "Forge of Origination", "Lo'Gosh, Blood Fighter"]
      ],
      all: [["Eternal Toil"], ["Nightmare Lord Xavius"]]
    ],
    "Armor Warrior": [all: [["Barricade Basher"], ["Tol'vir Vanguard"]]],
    "Lo'Gosh Warrior": [
      all: [["Broll, Blood Fighter"], ["Shadowflame Suffusion"]],
      all: [["For Glory!"], ["Stone Gauntlet"]]
    ],
    "N'Zoth Warrior": [all: [["For Glory!"], ["Forge of Origination"]]],
    "Lo'Gosh Warrior": [all: [["Mastermind Yogg-Saron"], ["Precursory Strike"]]],
    "N'Zoth Warrior": [
      all: [["Slam"], ["Archaedas", "Nightmare Lord Xavius", "Precursory Strike"]],
      all: [["Dirty Rat"], ["Eternal Toil", "Forge of Origination"]],
      all: [["Setesh"], ["Broll, Blood Fighter", "Eternal Toil"]],
      all: [["Forge of Origination"], ["Precursory Strike"]],
      all: [["Living Flame"], ["Tol'vir Vanguard"]]
    ],
    "Yogg Warrior": [all: [["Captain Crowley"], ["Sanguine Depths"]]],
    "Lo'Gosh Warrior": [all: [["Lo'Gosh, Blood Fighter"], ["Stone Gauntlet"]]],
    "N'Zoth Warrior": [
      all: [["Forge of Origination"], ["Lo'Gosh, Blood Fighter"]]
    ],
    "Yogg Warrior": [all: [["Mother Duck"], ["Setesh"]]],
    "N'Zoth Warrior": [all: [["Broll, Blood Fighter"], ["For Glory!"]]],
    "Yogg Warrior": [
      all: [["Captain Crowley"], ["Mother Duck", "Shadowflame Suffusion"]]
    ],
    "N'Zoth Warrior": [
      all: [["Slam"], ["Decimation", "For Glory!", "Tol'vir Vanguard"]],
      all: [["Archaedas"], ["Eternal Toil"]]
    ],
    "N'Zoth Warrior": [all: [["Eternal Toil"], ["Shield Block"]]],
    "Lo'Gosh Warrior": [all: [["Precursory Strike"], ["Stone Gauntlet"]]],
    "Yogg Warrior": [all: [["Erupting Volcano"], ["Living Flame"]]],
    "N'Zoth Warrior": [all: [["Archaedas"], ["Living Flame"]]],
    "Lo'Gosh Warrior": [all: [["Mother Duck"], ["Shield Block"]]],
    "N'Zoth Warrior": [
      all: [["Lo'Gosh, Blood Fighter"], ["Archaedas", "Tol'vir Vanguard"]],
      all: [["Forge of Origination"], ["Shield Block"]]
    ],
    "Yogg Warrior": [
      all: [
        ["Searing Fissure"],
        ["Cannonmaster", "Mother Duck", "Sanguine Depths"]
      ],
      all: [["Cannonmaster"], ["Captain Crowley"]],
      all: [["Hook n' Heave"], ["Shadowflame Suffusion"]]
    ],
    "Lo'Gosh Warrior": [all: [["Mother Duck"], ["Nightmare Lord Xavius"]]],
    "N'Zoth Warrior": [all: [["Forge of Origination"], ["Nightmare Lord Xavius"]]],
    "Yogg Warrior": [
      all: [["Erupting Volcano"], ["Forge of Origination", "Tol'vir Vanguard"]],
      all: [["Mother Duck"], ["Forge of Origination", "Tol'vir Vanguard"]]
    ],
    "N'Zoth Warrior": [all: [["Broll, Blood Fighter"], ["Tol'vir Vanguard"]]],
    "Yogg Warrior": [
      all: [["Cannonmaster"], ["Hook n' Heave", "Torch"]],
      all: [["Mother Duck"], ["Erupting Volcano", "Hook n' Heave"]]
    ],
    "Lo'Gosh Warrior": [all: [["Animator of Iron"], ["Precursory Strike"]]],
    "N'Zoth Warrior": [
      all: [["Precursory Strike"], ["Archaedas", "Setesh", "Tol'vir Vanguard"]]
    ],
    "N'Zoth Warrior": [all: [["Dirty Rat"], ["Precursory Strike"]]],
    "Yogg Warrior": [
      all: [["Afflicted Devastator"], ["For Glory!", "Shield Block"]],
      all: [["Clutch of Corruption"], ["Torch"]],
      all: [["Mother Duck"], ["Sanguine Depths"]],
      all: [["Shadowflame Suffusion"], ["Stone Gauntlet"]]
    ],
    "N'Zoth Warrior": [
      all: [
        ["Archaedas"],
        ["For Glory!", "Nightmare Lord Xavius", "Setesh", "Shield Block"]
      ],
      all: [["Tol'vir Vanguard"], ["Decimation", "For Glory!", "Shield Block"]],
      all: [["Nightmare Lord Xavius"], ["Decimation", "Shield Block"]]
    ],
    "N'Zoth Warrior": [all: [["Nightmare Lord Xavius"], ["Precursory Strike"]]],
    "Yogg Warrior": [all: [["Forge of Origination"], ["Stone Gauntlet"]]],
    "N'Zoth Warrior": [
      all: [["Forge of Origination"], ["Archaedas", "Tol'vir Vanguard"]]
    ],
    "N'Zoth Warrior": [
      all: [["Precursory Strike"], ["Decimation", "For Glory!"]],
      all: [["Dirty Rat"], ["Shield Block"]],
      all: [["Nightmare Lord Xavius"], ["Tol'vir Vanguard"]]
    ],
    "Yogg Warrior": [
      all: [["Shadowflame Suffusion"], ["Cannonmaster", "Erupting Volcano"]]
    ],
    "N'Zoth Warrior": [
      all: [["Tol'vir Vanguard"], ["Archaedas", "Dirty Rat", "Torch"]]
    ],
    "N'Zoth Warrior": [all: [["For Glory!"], ["Shield Block"]]],
    "Yogg Warrior": [all: [["Shadowflame Suffusion"], ["Torch"]]],
    "Dragon Warrior": [all: [["Darkrider"], ["Shadowflame Suffusion"]]]
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

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warrior")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other Warrior")
  end
end
