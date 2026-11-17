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
    "XL Taunt Warrior": [
      "Far Watch Post",
      "Imposing Anubisath",
      "Miracle Salesman",
      "Plucky Paintfin",
      "Power Slider",
      "Scrap Golem",
      "Tar Slime",
      "The One-Amalgam Band"
    ],
    "XL LC Quest Warrior": ["Blast Tortoise", "Eredar Brute", "Unlucky Powderman"],
    "XL HL LC Quest Warrior": ["Enter the Lost City"],
    "XL HL Igneous Warrior": [
      "Astalor Bloodsworn",
      "Bladestorm",
      "Bob the Bartender",
      "Boomboss Tho'grun",
      "Brawl",
      "Bulwark of Azzinoth",
      "Card Grader",
      "Deepminer Brann",
      "Dirty Rat",
      "Drywhisker Armorer",
      "Hamm, the Hungry",
      "Iceblood Garrison",
      "Lord Barov",
      "Marin the Manager",
      "Mutanus the Devourer",
      "New Heights",
      "Prince Renathal",
      "Quality Assurance",
      "Reno Jackson",
      "Reno, Lone Ranger",
      "Skulking Geist",
      "Sleep Under the Stars",
      "Sleepy Resident",
      "Theotar, the Mad Duke",
      "Ysera, Emerald Aspect",
      "Zephrys the Great",
      "Zilliax Deluxe 3000",
      "Zola the Gorgon"
    ],
    "Blaze Warrior": ["Destructive Blaze", "Spammy Arcanist"],
    "Sul'thraze Warrior": ["Bloodsail Deckhand"],
    "STD Dragon Warrior": ["Prescient Slitherdrake"],
    "XL Rock 'n' Roll Warrior": ["Ethereal Oracle"],
    "Igneous Odyn Warrior": ["Blacksmithing Hammer", "Lorekeeper Polkelt", "Odyn, Prime Designate"],
    "Rock 'n' Roll Warrior": ["Bladed Gauntlet", "Charge"],
    "STD Dragon Warrior": ["Brood Keeper", "Stadium Announcer"],
    "Igneous Odyn Warrior": ["Forge of Souls", "Last Stand", "Nightmare Lord Xavius", "Sanitize"],
    "Harold Warrior": ["Envoy of the End"],
    "XL HL Questline Warrior": ["Raid the Docks"],
    "STD Dragon Warrior": ["Darkrider"],
    "Sul'thraze Warrior": ["Sul'thraze"],
    "XL HL Igneous Warrior": ["E.T.C., Band Manager"],
    "Igneous Odyn Warrior": [
      "Aftershocks",
      "All You Can Eat",
      "For Glory!",
      "From the Depths",
      "Igneous Lavagorger",
      "Safety Goggles",
      "Shield Shatter",
      "Sir Finley, Sea Guide",
      "Sphere of Sapience",
      "Unleash the Crocolisks"
    ],
    "XL HL Igneous Warrior": ["Shield Block"]
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
