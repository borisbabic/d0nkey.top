# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.HunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Hunter": ["The Food Chain"],
    "Tick Tock Hunter": ["Battle at the End Time"],
    # auto gen
    "Imbue Hunter": [all: [["Flutterwing Guardian"], ["Umbraclaw"]]],
    "Companion Hunter": [
      all: [["Animal Companion"], ["Spiritspeaker"]],
      all: [["Raptor-Nest Nurse"], ["Roam Free"]]
    ],
    "N'Zoth Mech Hunter": [all: [["Overdrive"], ["Vaultkeeper"]]],
    "N'Zoth Hunter": [all: [["The Egg of Khelos"], ["Wound Prey"]]],
    "N'Zoth Mech Hunter": [
      all: [
        ["N'Zoth, Dream's End"],
        [
          "Bombardment",
          "Clockwork Boars",
          "Cult Neophyte",
          "Flamespitter",
          "Mimiron",
          "Quel'dorei Fletcher",
          "Ranger General Sylvanas",
          "Ranger Initiate Vereesa",
          "Reload",
          "Tank Regiment",
          "Tinker",
          "Vaultkeeper"
        ]
      ],
      all: [["Sizzling Cinder"], ["Mimiron", "Overdrive", "Vaultkeeper"]],
      all: [["Vaultkeeper"], ["Mimiron", "Sylvanas's Triumph"]]
    ],
    "Dragon Hunter": [
      all: [
        ["Carrier Whelp"],
        ["Prescient Slitherdrake", "Whelp of the Infinite"]
      ]
    ],
    "N'Zoth Hunter": [all: [["N'Zoth, Dream's End"], ["The Egg of Khelos"]]],
    "Companion Hunter": [
      all: [
        ["Migrating Elekk"],
        ["Call of the Wild", "R4T-C4TCH3R", "Sands of Time", "Spiritspeaker"]
      ],
      all: [
        ["Roam Free"],
        ["Call of the Wild", "Ranger Initiate Vereesa", "Tracking", "Underbelly Network"]
      ],
      all: [["Spiritspeaker"], ["Tame Pet", "Tracking"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [
        ["Bombardment"],
        ["Gemstone Hoarder", "Guard Dog", "Quel'dorei Fletcher", "Sizzling Cinder"]
      ],
      all: [["Sizzling Cinder"], ["Clockwork Boars", "Tank Regiment", "Tinker"]],
      all: [["Sylvanas's Triumph"], ["Tank Regiment"]]
    ],
    "N'Zoth Hunter": [all: [["Taelan Fordring"], ["Tame Pet"]]],
    "Face Hunter": [
      all: [["Rockskipper"], ["Quel'dorei Fletcher", "Reinforcement Rallier"]],
      all: [["Slumbering Sprite"], ["Arcane Tripwire", "Smuggled Shovel"]]
    ],
    "N'Zoth Hunter": [all: [["Primal Rockfang"], ["Untimely Death"]]],
    "N'Zoth Mech Hunter": [all: [["Magmaw"], ["Quel'dorei Fletcher"]]],
    "N'Zoth Hunter": [
      all: [["Confront the Tol'vir"], ["Crystalline Golem"]],
      all: [["Platysaur"], ["Taelan Fordring"]],
      all: [["Raptor-Nest Nurse"], ["The Egg of Khelos"]]
    ],
    "N'Zoth Mech Hunter": [all: [["Ranger Initiate Vereesa"], ["Vaultkeeper"]]],
    "Imbue Hunter": [all: [["Petal Picker"], ["Underbelly Network"]]],
    "N'Zoth Hunter": [all: [["Loot Hoarder"], ["Sizzling Cinder"]]],
    "Face Hunter": [all: [["Arrow Retriever"], ["Smuggled Shovel"]]],
    "N'Zoth Mech Hunter": [
      all: [
        ["Cult Neophyte"],
        ["Flamespitter", "Quel'dorei Fletcher", "Raptor-Nest Nurse", "Unstable Prototype"]
      ],
      all: [["Guard Dog"], ["Flamespitter", "Mimiron", "Overdrive", "Tinker"]],
      all: [
        ["Concealing Confection"],
        ["Amphibian's Spirit", "Stranglevine", "Sylvanas's Triumph"]
      ],
      all: [["Quel'dorei Fletcher"], ["Tank Regiment", "Unstable Prototype"]],
      all: [
        ["Vaultkeeper"],
        ["Ranger Captain Alleria", "Ranger General Sylvanas"]
      ],
      all: [["Flamespitter"], ["Sylvanas's Triumph"]]
    ],
    "Companion Hunter": [all: [["Migrating Elekk"], ["Ranger Initiate Vereesa"]]],
    "Beast Hunter": [all: [["Guard Dog"], ["Primordial Wyrm"]]],
    "N'Zoth Hunter": [
      all: [["Guard Dog"], ["Holy Eggbearer", "The Egg of Khelos"]],
      all: [["Amphibian's Spirit"], ["Untimely Death"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [["Black Market Overseer"], ["Mimiron"]],
      all: [["Bombardment"], ["Nightmare Lord Xavius"]]
    ],
    "Dragon Hunter": [all: [["Carrier Whelp"], ["King of the Underbelly"]]],
    "N'Zoth Hunter": [all: [["Gemstone Hoarder"], ["Primal Rockfang"]]],
    "N'Zoth Mech Hunter": [
      all: [["Concealing Confection"], ["Bombardment", "Ranger General Sylvanas"]],
      all: [["Mimiron"], ["Crystalline Golem", "Tank Regiment"]]
    ],
    "Dragon Hunter": [all: [["Beast Tripwire"], ["Carrier Whelp"]]],
    "N'Zoth Hunter": [
      all: [["Black Market Overseer"], ["Untimely Death"]],
      all: [["Guard Dog"], ["Loot Hoarder"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [
        ["Vaultkeeper"],
        ["Flamespitter", "Raptor-Nest Nurse", "Underbelly Network"]
      ],
      all: [
        ["Tank Regiment"],
        ["King of the Underbelly", "Ranger Initiate Vereesa"]
      ],
      all: [["Flamespitter"], ["Sizzling Cinder"]],
      all: [["Gemstone Hoarder"], ["Tinker"]],
      all: [["Mechacycle"], ["Sylvanas's Triumph"]],
      all: [["Ranger Captain Alleria"], ["Unstable Prototype"]]
    ],
    "N'Zoth Hunter": [
      all: [["Sizzling Cinder"], ["Amphibian's Spirit", "King of the Underbelly"]],
      all: [["Stranglevine"], ["Twilight Egg"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [["Concealing Confection"], ["Mechacycle", "Underbelly Network"]],
      all: [["Ranger Initiate Vereesa"], ["Mechacycle", "Unstable Prototype"]],
      all: [["Black Market Overseer"], ["Flamespitter"]],
      all: [["Magmaw"], ["Mimiron"]],
      all: [["Ranger General Sylvanas"], ["Unstable Prototype"]]
    ],
    "N'Zoth Mech Hunter": [all: [["Bombardment"], ["Raptor-Nest Nurse"]]],
    "N'Zoth Hunter": [all: [["Platysaur"], ["Raptor-Nest Nurse"]]],
    "Imbue Hunter": [all: [["Flutterwing Guardian"], ["Underbelly Network"]]],
    "Dragon Hunter": [all: [["Shadowed Informant"], ["Tracking"]]],
    "N'Zoth Mech Hunter": [all: [["Flamespitter"], ["Mimiron"]]],
    "N'Zoth Hunter": [
      all: [["Black Market Overseer"], ["Sizzling Cinder"]],
      all: [["Gemstone Hoarder"], ["Magmaw"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [["Flamespitter"], ["Mechacycle", "Tinker", "Underbelly Network"]],
      all: [["Mechacycle"], ["Ranger Captain Alleria"]]
    ],
    "N'Zoth Hunter": [
      all: [
        ["Untimely Death"],
        ["Guard Dog", "Prize Vendor", "Raptor-Nest Nurse"]
      ]
    ],
    "N'Zoth Mech Hunter": [all: [["Mechacycle"], ["Ranger General Sylvanas"]]],
    "Imbue Hunter": [all: [["Bitterbloom Knight"], ["Umbraclaw"]]],
    "Deathrattle Hunter": [all: [["Doomsayer"], ["Glacial Shard"]]],
    "N'Zoth Hunter": [
      all: [
        ["Crystalline Golem"],
        ["Amphibian's Spirit", "Holy Eggbearer", "The Egg of Khelos"]
      ],
      all: [["Amphibian's Spirit"], ["Chrono-Lord Deios"]],
      all: [["Holy Eggbearer"], ["Stranglevine"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [["Sylvanas's Triumph"], ["Guard Dog", "Unstable Prototype"]]
    ],
    "Companion Hunter": [all: [["Migrating Elekk"], ["Tame Pet"]]],
    "N'Zoth Mech Hunter": [all: [["Black Market Overseer"], ["Tinker"]]],
    "Face Hunter": [all: [["Quel'dorei Fletcher"], ["Wound Prey"]]],
    "N'Zoth Mech Hunter": [
      all: [["Tinker"], ["Mechacycle", "Underbelly Network"]]
    ],
    "Beast Hunter": [all: [["Ball of Spiders"], ["Jeweled Macaw"]]],
    "N'Zoth Mech Hunter": [all: [["Mechacycle"], ["Sizzling Cinder"]]],
    "N'Zoth Hunter": [all: [["Prize Vendor"], ["Taelan Fordring"]]],
    "N'Zoth Mech Hunter": [all: [["Raptor-Nest Nurse"], ["Tinker"]]],
    "N'Zoth Hunter": [
      all: [["Tracking"], ["Amphibian's Spirit", "The Egg of Khelos"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [
        ["Unstable Prototype"],
        ["Guard Dog", "Mechacycle", "Underbelly Network"]
      ],
      all: [["Guard Dog"], ["Ranger Captain Alleria"]],
      all: [["Ranger Initiate Vereesa"], ["Sizzling Cinder"]]
    ],
    "N'Zoth Hunter": [all: [["Crystalline Golem"], ["Prize Vendor"]]],
    "N'Zoth Mech Hunter": [
      all: [["Tinker"], ["Ranger Initiate Vereesa", "Unstable Prototype"]],
      all: [["Tracking"], ["Unstable Prototype"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [["Mechacycle"], ["Guard Dog", "Underbelly Network"]]
    ],
    "N'Zoth Mech Hunter": [all: [["Guard Dog"], ["Raptor-Nest Nurse"]]],
    "Tripwire Hunter": [all: [["Arcane Tripwire"], ["Wound Prey"]]],
    "N'Zoth Mech Hunter": [all: [["Tinker"], ["Tracking"]]],
    "N'Zoth Hunter": [all: [["Crystalline Golem"], ["Tracking"]]],
    "N'Zoth Mech Hunter": [all: [["Sizzling Cinder"], ["Underbelly Network"]]],
    "Dragon Hunter": [
      all: [["Underbelly Network"], ["Earthen Roar", "Tol'vir Carver"]]
    ],
    "Companion Hunter": [all: [["Tame Pet"], ["Tracking"]]],
    "N'Zoth Mech Hunter": [all: [["Raptor-Nest Nurse"], ["Tracking"]]],
    "Beast Hunter": [all: [["Jeweled Macaw"], ["Platysaur"]]],
    "N'Zoth Mech Hunter": [
      all: [["Guard Dog"], ["Tracking", "Underbelly Network"]]
    ],
    "N'Zoth Mech Hunter": [
      all: [["Ranger Captain Alleria"], ["Underbelly Network"]]
    ],
    "Imbue Hunter": [all: [["Exotic Houndmaster"], ["Tracking"]]],
    "Face Hunter": [
      all: [["Arcane Tripwire"], ["Beast Tripwire", "Smuggled Shovel"]]
    ],
    "N'Zoth Mech Hunter": [all: [["Tracking"], ["Underbelly Network"]]]
  ]
  @wild_config [
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Clumsy Steward"],
            [
              "Blademaster Okani",
              "Dreadscale",
              "Observer of Myths",
              "Selective Breeder",
              "Spawning Pool",
              "Spirit Poacher",
              "Zephrys the Great"
            ]
          ],
          all: [
            ["Forensic Duster"],
            [
              "Blademaster Okani",
              "Cult Neophyte",
              "Kerrigan, Queen of Blades",
              "Observer of Myths",
              "Ranger Initiate Vereesa",
              "Spawning Pool"
            ]
          ],
          all: [
            ["Coilfang Constrictor"],
            ["Bargain Bin", "Cult Neophyte", "Prince Renathal", "Smothering Starfish", "Spawning Pool"]
          ],
          all: [["Beaststalker Tavish"], ["Explosive Trap"]],
          all: [["Instrument Tech"], ["Sphere of Sapience"]],
          all: [["Mojomaster Zihi"], ["Tracking"]]
        ]
      ]
    ],
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Beastmaster Leoroxx"],
            ["Acidmaw", "Devouring Swarm", "Dirty Rat", "Far Watch Post", "The Curator"]
          ],
          all: [["Bargain Bin"], ["Glacial Shard"]],
          all: [["Timeline Accelerator"], ["Wound Prey"]]
        ]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Loatheb"], ["Pressure Plate"]],
          all: [["Lorekeeper Polkelt"], ["Mojomaster Zihi"]]
        ]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Customs Enforcer"], ["Mystery Egg"]],
          all: [["Far Watch Post"], ["Messmaker"]]
        ]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Kerrigan, Queen of Blades"],
            ["Acidmaw", "Devouring Swarm", "Observer of Myths", "Razorscale", "Wound Prey"]
          ],
          all: [
            ["Pressure Plate"],
            ["Beaststalker Tavish", "Miracle Salesman", "Wild Spirits", "ZOMBEEEES!!!"]
          ],
          all: [["Spawning Pool"], ["Smothering Starfish", "Speaker Stomper"]],
          all: [["Beaststalker Tavish"], ["Lorekeeper Polkelt"]],
          all: [["Costumed Singer"], ["Snipe"]]
        ]
      ]
    ],
    "Amalgam Hunter":
      {[
         all: [["Adaptive Amalgam"], ["Exarch Naielle"]],
         all: [["Animated Broomstick"], ["Feign Death"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Arcane Hunter":
      {[
         all: [["Silvermoon Farstrider"], ["Eversong Portal", "ZOMBEEEES!!!"]],
         all: [["Wild Spirits"], ["ZOMBEEEES!!!"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Mine Hunter": {[all: [["Naval Mine"], ["Holy Eggbearer", "Mystery Egg"]]], [start_of_game: ["Prince Renathal"]]},
    "Amalgam Hunter":
      {[
         all: [
           ["Adaptive Amalgam"],
           ["Birdwatching", "Mystery Egg", "Primal Rockfang", "Tracking"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Other Hunter":
      {[
         all: [["Mystery Egg"], ["Goblin Prank", "Yelling Yodeler"]],
         all: [["Trinket Tracker"], ["Yelling Yodeler"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Zerg Hunter":
      {[
         all: [["Jungle Gym"], ["Parrot Sanctuary", "Underbelly Network"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Awakening Tremors"], ["Sphere of Sapience"]]]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bargain Bin"], ["Beaststalker Tavish"]]]
      ]
    ],
    "Odd Questline Hunter":
      {[
         all: [["Defend the Dwarven District"], ["Ethereal Oracle"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Curator"], ["Timeline Accelerator"]]]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Far Watch Post"], ["Mystery Egg"]]]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Mojomaster Zihi"],
            ["Blademaster Okani", "Observer of Myths", "Theldurin the Lost", "Troubled Mechanic"]
          ],
          all: [
            ["Spawning Pool"],
            ["Cult Neophyte", "Hope of Quel'Thalas", "Miracle Salesman", "Underbelly Network"]
          ],
          all: [
            ["Beaststalker Tavish"],
            ["Miracle Salesman", "Patchwork Pals", "Sneaky Snakes"]
          ],
          all: [["Zilliax Deluxe 3000"], ["Awakening Tremors", "Far Watch Post"]]
        ]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pressure Plate"], ["Holy Eggbearer", "Play Dead"]]]
      ]
    ],
    "Questline Hunter":
      {[
         all: [
           ["Defend the Dwarven District"],
           ["Arcane Shot", "Ricochet Shot", "Wound Prey"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Speaker Stomper"], ["Dirty Rat", "Far Watch Post", "Loatheb"]]]
      ]
    ],
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Beastmaster Leoroxx"], ["Selective Breeder"]]]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Devouring Swarm"], ["Wild Spirits"]],
          all: [["Hope of Quel'Thalas"], ["Lorekeeper Polkelt"]],
          all: [["Trinket Tracker"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ranger General Sylvanas"], ["Sphere of Sapience"]]]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Costumed Singer"], ["Hope of Quel'Thalas"]]]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Play Dead"], ["Stitched Tracker"]]]
      ]
    ],
    "STD N'Zoth Mech Hunter": {[all: [["Mechacycle"], ["Unstable Prototype"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Hunter": {[all: [["Exotic Houndmaster"], ["Birdwatching", "Fetch!"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Far Watch Post"],
            [
              "Loatheb",
              "Miracle Salesman",
              "Patchwork Pals",
              "Ranger General Sylvanas",
              "Spirit Poacher",
              "Wild Spirits"
            ]
          ],
          all: [
            ["Dreadscale"],
            ["Acidmaw", "King of the Underbelly", "Loatheb", "Miracle Salesman", "Spirit Poacher"]
          ],
          all: [
            ["Miracle Salesman"],
            ["Devouring Swarm", "Observer of Myths", "Wound Prey", "Zephrys the Great"]
          ],
          all: [
            ["Speaker Stomper"],
            ["Razorscale", "Selective Breeder", "Wild Spirits"]
          ],
          all: [["E.T.C., Band Manager"], ["Serpentbloom"]],
          all: [["Razorscale"], ["Spirit Poacher"]],
          all: [["Sneaky Snakes"], ["Wound Prey"]],
          all: [["Wild Spirits"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Loatheb"],
            ["Exarch Naielle", "Patchwork Pals", "Selective Breeder"]
          ],
          all: [["Exarch Naielle"], ["Spirit Poacher"]],
          all: [["Observer of Myths"], ["Patchwork Pals"]]
        ]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Awakening Tremors"],
            ["Hope of Quel'Thalas", "Miracle Salesman", "Spirit Poacher"]
          ],
          all: [["Cult Neophyte"], ["Razorscale", "Selective Breeder"]],
          all: [["Hope of Quel'Thalas"], ["Dirty Rat", "Ranger General Sylvanas"]],
          all: [["Miracle Salesman"], ["Selective Breeder"]],
          all: [["Ranger Captain Alleria"], ["Sneaky Snakes"]],
          all: [["Troubled Mechanic"], ["Wound Prey"]]
        ]
      ]
    ],
    "Mine Hunter": {[all: [["Holy Eggbearer"], ["Mystery Egg"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Hunter":
      {[
         all: [["Parrot Sanctuary"], ["Fetch!", "Rangari Scout"]],
         all: [["Devouring Swarm"], ["Rangari Scout"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Selective Breeder"], ["Sneaky Snakes"]]]
      ]
    ],
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bargain Bin"], ["Ranger Initiate Vereesa", "Tracking"]]]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Exarch Naielle"]]]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Messmaker"], ["Mystery Egg"]]]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Reno Jackson"], ["Theldurin the Lost", "Zephrys the Great"]],
          all: [["Exarch Naielle"], ["Serpentbloom"]],
          all: [["Observer of Myths"], ["Zephrys the Great"]],
          all: [["Selective Breeder"], ["Theldurin the Lost"]]
        ]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mystery Egg"], ["Devouring Swarm", "Trueaim Crescent"]]]
      ]
    ],
    "Amalgam Hunter": {[all: [["Prize Vendor"], ["Tracking"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Hunter":
      {[
         all: [["Trinket Tracker"], ["Exarch Naielle", "Fetch!", "Flare"]],
         all: [["Alien Encounters"], ["Tracking"]],
         all: [["Fetch!"], ["Flare"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Secret Hunter":
      {[
         all: [
           ["Hidden Meaning"],
           ["Dun Baldar Bunker", "Freezing Trap", "Wandering Monster"]
         ],
         all: [["Wandering Monster"], ["Dun Baldar Bunker", "Freezing Trap"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Awakening Tremors"], ["Exarch Naielle", "Theldurin the Lost"]],
          all: [["Exarch Naielle"], ["Far Watch Post"]],
          all: [["Theldurin the Lost"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Exarch Naielle"], ["Troubled Mechanic"]]]
      ]
    ],
    "STD N'Zoth Mech Hunter":
      {[
         all: [["Underbelly Network"], ["Flamespitter", "Guard Dog", "Tinker"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Ranger Captain Alleria"],
            ["Ranger General Sylvanas", "Ranger Initiate Vereesa"]
          ]
        ]
      ]
    ],
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Stitched Tracker"], ["Rangari Scout", "Tracking"]]]
      ]
    ],
    "Other Hunter": {[all: [["Birdwatching"], ["Play Dead"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander Hunter":
      {[all: [["Exarch Naielle"], ["Ranger General Sylvanas"]]], [start_of_game: ["Prince Renathal"]]},
    "Amalgam Hunter": {[all: [["Birdwatching"], ["Exarch Naielle"]]], [start_of_game: ["Prince Renathal"]]},
    "Rivendare Hunter": {[all: [["Flare"], ["Tracking"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Hunter": {[all: [["Birdwatching"], ["Tracking"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander Hunter":
      {[
         all: [["Ranger Captain Alleria"], ["Ranger General Sylvanas"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Other Hunter":
      {[
         all: [["Tracking"], ["Exarch Naielle", "Underbelly Network"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Birdwatching"], ["Tracking"]]]
      ]
    ],
    "XL HL Leoroxx Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Exarch Naielle"], ["Tracking"]]]
      ]
    ]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Hunter")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Hunter")
  end
end
