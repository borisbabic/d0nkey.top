# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Rogue": ["Lie in Wait"],
    "Harold Rogue": [all: [["SI:7 Supplier"], ["Sinestra", "Ultraxion"]]],
    "AYAYA Rogue": [
      all: [
        ["Mastermind Yogg-Saron"],
        [
          "Backstab",
          "Blackpaw's Whip",
          "Garona's Last Stand",
          "Nightmare Lord Xavius",
          "Portal Vanguard",
          "Time Adm'ral Hooktail"
        ]
      ],
      all: [
        ["Portal Vanguard"],
        ["Aya, Lotus Kingpin", "Blackpaw's Whip", "Garona's Last Stand", "Time Adm'ral Hooktail"]
      ],
      all: [["Blackpaw's Whip"], ["Defias Wannabe"]],
      all: [["Nightmare Lord Xavius"], ["Time Adm'ral Hooktail"]]
    ],
    "Mill Rogue": [
      all: [["Platysaur"], ["Chrono-Lord Deios", "Prize Vendor"]],
      all: [["Prize Vendor"], ["Twisted Webweaver"]]
    ],
    "Harold Rogue": [
      all: [["Ultraxion"], ["Opu the Unseen", "Web of Deception"]],
      all: [["Deja Vu"], ["Envoy of the End"]]
    ],
    "AYAYA Rogue": [all: [["Fan of Knives"], ["Time Adm'ral Hooktail"]]],
    "Harold Rogue": [all: [["Elise the Navigator"], ["Sinestra"]]],
    "AYAYA Rogue": [all: [["Shadow Dance"], ["Time Adm'ral Hooktail"]]],
    "Mill Rogue": [all: [["Broodchamber Tunneler"], ["Prize Vendor"]]],
    "AYAYA Rogue": [all: [["Blackpaw's Whip"], ["Deja Vu"]]],
    "Harold Rogue": [
      all: [["Maniacal Follower"], ["Mathias Shaw", "Sands of Time"]],
      all: [["Eventuality"], ["Sinestra"]]
    ],
    "Harold Rogue": [all: [["Deja Vu"], ["Sinestra"]]],
    "Mill Rogue": [
      all: [["Defias Smuggler"], ["Mimicry", "Prize Vendor"]],
      all: [["Chrono-Lord Deios"], ["Prize Vendor"]]
    ],
    "AYAYA Rogue": [all: [["Nightmare Fuel"], ["Time Adm'ral Hooktail"]]],
    "Harold Rogue": [all: [["Maniacal Follower"], ["Spymistress"]]],
    "AYAYA Rogue": [all: [["Defias Smuggler"], ["Plated Beetle"]]],
    "Harold Rogue": [
      all: [
        ["Sinestra"],
        ["Defias Smuggler", "Drest'agath", "Glacial Shard", "N'Zoth, Dream's End", "Web of Deception"]
      ]
    ],
    "Mill Rogue": [
      all: [["Glacial Shard"], ["Crystal Tusk", "Mimicry", "Prize Vendor"]],
      all: [["Mimicry"], ["Doomsayer", "Prize Vendor"]],
      all: [["Prize Vendor"], ["Shadow Dance"]]
    ],
    "Burn Rogue": [all: [["Chrono Daggers"], ["Rite of Twilight"]]],
    "AYAYA Rogue": [all: [["Garona Halforcen"], ["Mastermind Yogg-Saron"]]],
    "Harold Rogue": [
      all: [["Bitterbloom Knight"], ["Ultraxion"]],
      all: [["Maniacal Follower"], ["SI:7 Supplier"]]
    ],
    "Two-Bit Rogue": [all: [["Jade Guardians"], ["Lotus Troublemaker"]]],
    "AYAYA Rogue": [
      all: [
        ["Blackpaw's Whip"],
        ["Blob of Tar", "Fan of Knives", "Garona's Last Stand", "Nightmare Fuel", "Titanic Thrasher"]
      ],
      all: [
        ["Mastermind Yogg-Saron"],
        ["Deadly Bribe", "Fan of Knives", "The Kingslayers"]
      ],
      all: [
        ["Garona's Last Stand"],
        ["Aya, Lotus Kingpin", "Nightmare Lord Xavius"]
      ],
      all: [["Time Adm'ral Hooktail"], ["Deja Vu", "Rite of Twilight"]]
    ],
    "AYAYA Rogue": [all: [["Blackpaw's Whip"], ["Plated Beetle"]]],
    "Harold Rogue": [all: [["Crystalline Golem"], ["Sinestra"]]],
    "Mill Rogue": [all: [["Disguised Operator"], ["Loot Hoarder"]]],
    "Harold Rogue": [
      all: [["Broodchamber Tunneler"], ["Maniacal Follower"]],
      all: [["Deathwing, Worldbreaker"], ["The Kingslayers"]],
      all: [["Elise the Navigator"], ["Ultraxion"]]
    ],
    "AYAYA Rogue": [all: [["Deja Vu"], ["Portal Vanguard"]]],
    "Harold Rogue": [
      all: [["Maniacal Follower"], ["Elise the Navigator", "Glacial Shard"]],
      all: [["Deja Vu"], ["Ultraxion"]],
      all: [["Rite of Twilight"], ["Shaladrassil"]]
    ],
    "Harold Rogue": [
      all: [["Ultraxion"], ["Crystalline Golem", "Drest'agath"]],
      all: [["Jagged Edge of Time"], ["Maniacal Follower"]]
    ],
    "Mill Rogue": [all: [["Broodchamber Tunneler"], ["Mimicry"]]],
    "AYAYA Rogue": [
      all: [
        ["Portal Vanguard"],
        ["Nightmare Fuel", "Nightmare Lord Xavius", "Rite of Twilight"]
      ],
      all: [["Aya, Lotus Kingpin"], ["Deja Vu", "Nightmare Fuel"]],
      all: [["Blackpaw's Whip"], ["Shadow Dance"]]
    ],
    "Harold Rogue": [
      all: [
        ["Maniacal Follower"],
        ["Bitterbloom Knight", "Deja Vu", "Nightmare Fuel"]
      ],
      all: [["Deathwing, Worldbreaker"], ["Nightmare Fuel"]]
    ],
    "AYAYA Rogue": [all: [["Blackpaw's Whip"], ["Glacial Shard"]]],
    "Mill Rogue": [all: [["Cult Neophyte"], ["Prize Vendor"]]],
    "AYAYA Rogue": [
      all: [["Aya, Lotus Kingpin"], ["Plated Beetle"]],
      all: [["Defias Smuggler"], ["Fast Forward"]]
    ],
    "Mill Rogue": [
      all: [["Prize Vendor"], ["Agent of N'Zoth", "Everburning Phoenix"]]
    ],
    "AYAYA Rogue": [
      all: [
        ["Time Adm'ral Hooktail"],
        [
          "Agent of the Old Ones",
          "Aya, Lotus Kingpin",
          "Backstab",
          "Blackpaw's Whip",
          "Cultist Map",
          "Deadly Bribe",
          "Garona Halforcen",
          "Lotus Bookie",
          "Preparation",
          "The Kingslayers"
        ]
      ],
      all: [
        ["Blackpaw's Whip"],
        ["Aya, Lotus Kingpin", "Backstab", "Garona Halforcen", "Nightmare Lord Xavius", "The Kingslayers"]
      ],
      all: [["Agent of the Old Ones"], ["Portal Vanguard"]],
      all: [["Aya, Lotus Kingpin"], ["Nightmare Lord Xavius"]]
    ],
    "Two-Bit Rogue": [
      all: [["Cult Neophyte"], ["Escape Artist", "Jade Guardians"]]
    ],
    "Harold Rogue": [
      all: [["Rite of Twilight"], ["Envoy of the End", "Ultraxion"]],
      all: [["Deathwing, Worldbreaker"], ["Maniacal Follower"]],
      all: [["Preparation"], ["Ultraxion"]]
    ],
    "Mill Rogue": [
      all: [["Mimicry"], ["Daze", "Everburning Phoenix", "The Kingslayers"]],
      all: [["Platysaur"], ["Backstab", "Disguised Operator"]],
      all: [["Fast Forward"], ["Prize Vendor"]]
    ],
    "AYAYA Rogue": [
      all: [["Agent of the Old Ones"], ["Garona's Last Stand"]],
      all: [["Bloatray"], ["Crystalline Golem"]]
    ],
    "Harold Rogue": [
      all: [["Elise the Navigator"], ["Deja Vu", "Rite of Twilight"]]
    ],
    "AYAYA Rogue": [all: [["Lotus Bookie"], ["Portal Vanguard"]]],
    "Burn Rogue": [all: [["Maniacal Follower"], ["Tunneling Geomancer"]]],
    "Harold Rogue": [all: [["Maniacal Follower"], ["Opu the Unseen"]]],
    "Mill Rogue": [all: [["Fan of Knives"], ["Prize Vendor"]]],
    "Harold Rogue": [
      all: [["Maniacal Follower"], ["Nightmare Lord Xavius", "Prize Vendor"]]
    ],
    "Mill Rogue": [
      all: [["Prize Vendor"], ["Aya, Lotus Kingpin", "Disguised Operator"]]
    ],
    "Imbue Rogue": [all: [["Backstab"], ["Flutterwing Guardian"]]],
    "AYAYA Rogue": [
      all: [
        ["Deadly Bribe"],
        [
          "Aya, Lotus Kingpin",
          "Backstab",
          "Fan of Knives",
          "Garona Halforcen",
          "Nightmare Fuel",
          "Nightmare Lord Xavius",
          "The Kingslayers"
        ]
      ],
      all: [["Aya, Lotus Kingpin"], ["Fan of Knives"]],
      all: [["Garona's Last Stand"], ["Lotus Bookie"]]
    ],
    "Harold Rogue": [all: [["Sinestra"], ["Lotus Bookie", "Rite of Twilight"]]],
    "Mill Rogue": [
      all: [["Mimicry"], ["Backstab", "Garona Halforcen", "Shadow Dance"]],
      all: [
        ["Twisted Webweaver"],
        ["Aya, Lotus Kingpin", "Cult Neophyte", "Garona Halforcen"]
      ],
      all: [["Aya, Lotus Kingpin"], ["Cult Neophyte"]],
      all: [["Prize Vendor"], ["The Kingslayers"]]
    ],
    "Two-Bit Rogue": [all: [["Bloodmage Thalnos"], ["Shadowed Informant"]]],
    "Harold Rogue": [
      all: [["Maniacal Follower"], ["Fan of Knives", "Rite of Twilight"]]
    ],
    "Mill Rogue": [all: [["Everburning Phoenix"], ["Glacial Shard"]]],
    "AYAYA Rogue": [all: [["Aya, Lotus Kingpin"], ["Rite of Twilight"]]],
    "Mill Rogue": [
      all: [["Defias Smuggler"], ["Shadow Dance"]],
      all: [["Fan of Knives"], ["Mimicry"]]
    ],
    "AYAYA Rogue": [all: [["Aya, Lotus Kingpin"], ["Defias Smuggler"]]],
    "Burn Rogue": [all: [["Fan of Knives"], ["Shade of the End Time"]]],
    "Harold Rogue": [
      all: [["Lotus Bookie"], ["Spymistress"]],
      all: [["Mathias Shaw"], ["Rite of Twilight"]]
    ],
    "Mill Rogue": [all: [["Backstab"], ["Prize Vendor"]]],
    "Two-Bit Rogue": [all: [["Bitterbloom Knight"], ["Escape Artist"]]],
    "Combo Rogue": [all: [["Aqir Swarmer"], ["Foxy Fraud"]]],
    "Mill Rogue": [all: [["Lotus Bookie"], ["Mimicry"]]],
    "Mill Rogue": [all: [["Disguised Operator"], ["Twisted Webweaver"]]],
    "Mill Rogue": [all: [["Disguised Operator"], ["Doomsayer"]]],
    "AYAYA Rogue": [
      all: [["Agent of the Old Ones"], ["Blackpaw's Whip"]],
      all: [["Aya, Lotus Kingpin"], ["Backstab"]]
    ],
    "Mill Rogue": [all: [["Agent of N'Zoth"], ["Platysaur"]]],
    "AYAYA Rogue": [
      all: [
        ["Blackpaw's Whip"],
        ["Cultist Map", "Lotus Bookie", "Rite of Twilight"]
      ]
    ],
    "Mill Rogue": [all: [["Disguised Operator"], ["Mimicry"]]],
    "AYAYA Rogue": [all: [["Agent of the Old Ones"], ["Nightmare Lord Xavius"]]],
    "N'Zoth Rogue": [
      all: [["Cult Neophyte"], ["Backstab", "Nightmare Lord Xavius"]]
    ],
    "AYAYA Rogue": [all: [["Fan of Knives"], ["Nightmare Fuel"]]],
    "AYAYA Rogue": [all: [["Portal Vanguard"], ["The Kingslayers"]]],
    "Harold Rogue": [all: [["Nightmare Fuel"], ["SI:7 Supplier"]]],
    "N'Zoth Combo Rogue": [all: [["Aqir Swarmer"], ["Crystalline Golem"]]],
    "Mill Rogue": [
      all: [["Agent of the Old Ones"], ["Prize Vendor"]],
      all: [["Cult Neophyte"], ["Disguised Operator"]]
    ],
    "Combo Rogue": [all: [["Foxy Fraud"], ["Incubate"]]],
    "Harold Rogue": [
      all: [["Disguised Operator"], ["Maniacal Follower"]],
      all: [["Glacial Shard"], ["Opu the Unseen"]],
      all: [["Rite of Twilight"], ["Spymistress"]]
    ],
    "Mill Rogue": [
      all: [["Backstab"], ["Defias Smuggler", "Glacial Shard"]],
      all: [["Defias Smuggler"], ["Garona Halforcen"]],
      all: [["Everburning Phoenix"], ["Shadow Dance"]]
    ],
    "Imbue Rogue": [all: [["Flutterwing Guardian"], ["Sands of Time"]]],
    "AYAYA Rogue": [all: [["Nightmare Lord Xavius"], ["Plated Beetle"]]],
    "Mill Rogue": [all: [["Everburning Phoenix"], ["Fan of Knives"]]],
    "AYAYA Rogue": [all: [["Deja Vu"], ["Fan of Knives"]]],
    "Imbue Rogue": [all: [["Creature of Madness"], ["Eventuality"]]],
    "AYAYA Rogue": [
      all: [
        ["Aya, Lotus Kingpin"],
        ["Agent of the Old Ones", "Lotus Bookie", "The Kingslayers"]
      ],
      all: [
        ["Nightmare Lord Xavius"],
        ["Lotus Bookie", "Nightmare Fuel", "The Kingslayers"]
      ],
      all: [["Nightmare Fuel"], ["The Kingslayers"]]
    ],
    "Harold Rogue": [
      all: [["Deja Vu"], ["Twilight Mistress"]],
      all: [["Drest'agath"], ["Maniacal Follower"]]
    ],
    "AYAYA Rogue": [all: [["Deja Vu"], ["Garona Halforcen", "The Kingslayers"]]],
    "Harold Rogue": [all: [["Lotus Bookie"], ["Maniacal Follower"]]],
    "Mill Rogue": [all: [["Lotus Bookie"], ["Chrono-Lord Deios", "Prize Vendor"]]],
    "Two-Bit Rogue": [all: [["Jade Guardians"], ["Rite of Twilight"]]],
    "Mill Rogue": [
      all: [["Cultist Map"], ["Mimicry"]],
      all: [["Disguised Operator"], ["Everburning Phoenix"]]
    ],
    "AYAYA Rogue": [all: [["Disguised Operator"], ["Plated Beetle"]]],
    "Harold Rogue": [all: [["Agent of the Old Ones"], ["SI:7 Supplier"]]],
    "AYAYA Rogue": [all: [["Agent of the Old Ones"], ["Deadly Bribe"]]],
    "Harold Rogue": [all: [["Crystalline Golem"], ["Opu the Unseen"]]],
    "AYAYA Rogue": [all: [["Backstab"], ["Nightmare Fuel"]]],
    "Mill Rogue": [
      all: [["Agent of N'Zoth"], ["Backstab"]],
      all: [["Disguised Operator"], ["Garona Halforcen"]],
      all: [["Glacial Shard"], ["Shadow Dance"]]
    ],
    "Harold Rogue": [
      all: [["SI:7 Slayer"], ["SI:7 Supplier", "Spymistress"]],
      all: [["Deja Vu"], ["Dirty Rat"]],
      all: [["Glacial Shard"], ["Rite of Twilight"]]
    ],
    "Mill Rogue": [all: [["Disguised Operator"], ["Glacial Shard"]]],
    "AYAYA Rogue": [all: [["Garona Halforcen"], ["Rite of Twilight"]]],
    "Combo Rogue": [
      all: [["Aqir Swarmer"], ["Broodchamber Tunneler", "Incubate"]]
    ],
    "Burn Rogue": [all: [["Frontline Ironborn"], ["Shadow Dance"]]],
    "Mill Rogue": [
      all: [["Disguised Operator"], ["Fan of Knives", "The Kingslayers"]]
    ],
    "AYAYA Rogue": [
      all: [
        ["The Kingslayers"],
        ["Agent of the Old Ones", "Backstab", "Fan of Knives", "Lotus Bookie", "Rite of Twilight"]
      ],
      all: [["Fan of Knives"], ["Agent of the Old Ones", "Lotus Bookie"]]
    ],
    "AYAYA Rogue": [all: [["Deja Vu"], ["Backstab", "Lotus Bookie"]]],
    "AYAYA Rogue": [all: [["Lotus Bookie"], ["Nightmare Fuel"]]],
    "Harold Rogue": [all: [["Flutterwing Guardian"], ["Rite of Twilight"]]],
    "Imbue Rogue": [all: [["Flutterwing Guardian"], ["Jagged Edge of Time"]]],
    "Mill Rogue": [all: [["Backstab"], ["Disguised Operator"]]],
    "AYAYA Rogue": [
      all: [["Agent of the Old Ones"], ["Backstab", "Deja Vu", "Lotus Bookie"]],
      all: [["Backstab"], ["Cultist Map", "Lotus Bookie"]],
      all: [["Deadly Bribe"], ["Lotus Bookie"]],
      all: [["Fan of Knives"], ["Nightmare Lord Xavius"]]
    ],
    "Harold Rogue": [
      all: [["Bitterbloom Knight"], ["Nightmare Fuel"]],
      all: [["Jagged Edge of Time"], ["Rite of Twilight"]]
    ],
    "AYAYA Rogue": [all: [["Agent of the Old Ones"], ["Nightmare Fuel"]]],
    "Mill Rogue": [
      all: [["Agent of the Old Ones"], ["Disguised Operator"]],
      all: [["Crystalline Golem"], ["Everburning Phoenix"]]
    ],
    "AYAYA Rogue": [
      all: [
        ["Cultist Map"],
        ["Agent of the Old Ones", "Nightmare Fuel", "The Kingslayers"]
      ],
      all: [["Deja Vu"], ["Nightmare Fuel"]]
    ],
    "Mill Rogue": [
      all: [["Disguised Operator"], ["Agent of N'Zoth", "Lotus Bookie"]]
    ],
    "AYAYA Rogue": [all: [["Cultist Map"], ["Deja Vu", "Lotus Bookie"]]],
    "Harold Rogue": [
      all: [
        ["Deja Vu"],
        ["Bitterbloom Knight", "Eventuality", "Rite of Twilight"]
      ]
    ],
    "Mill Rogue": [all: [["Crystalline Golem"], ["Disguised Operator"]]],
    "AYAYA Rogue": [all: [["Agent of the Old Ones"], ["Rite of Twilight"]]],
    "Harold Rogue": [all: [["Crystalline Golem"], ["Rite of Twilight"]]],
    "Imbue Rogue": [all: [["Eventuality"], ["Jagged Edge of Time"]]],
    "AYAYA Rogue": [all: [["Garona Halforcen"], ["The Kingslayers"]]],
    "Harold Rogue": [all: [["Eventuality"], ["Rite of Twilight"]]],
    "AYAYA Rogue": [all: [["Lotus Bookie"], ["Preparation", "Rite of Twilight"]]],
    "AYAYA Rogue": [all: [["Preparation"], ["Rite of Twilight"]]],
    "AYAYA Rogue": [all: [["Crystalline Golem"], ["Drest'agath"]]],
    "Harold Rogue": [all: [["Bitterbloom Knight"], ["Eventuality"]]],
    "AYAYA Rogue": [all: [["Cultist Map"], ["Preparation"]]]
  ]
  @wild_config [
    "Kingsbane Rogue": {[all: [["Deadly Poison"], ["Doomerang"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue":
      {[
         all: [
           ["Masked Reveler"],
           ["Backstab", "Savory Deviate Delight", "Scourge Illusionist"]
         ],
         all: [["Eviscerate"], ["Sketchy Information"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Alex Rogue": {[all: [["Shadowcaster"], ["Shadowstep"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Eventuality"], ["Nab"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Cult Neophyte"], ["Secret Passage"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Nab"], ["Scourge Illusionist"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Scribbling Stenographer"], ["Door of Shadows", "Greedy Partner"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Kingsbane Rogue": {[all: [["Deadly Poison"], ["Kingsbane"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Record Scratcher"], ["Shattershambler"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue":
      {[
         all: [["Sketchy Information"], ["Backstab", "Eventuality", "Nab"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [
           ["Arcane Giant"],
           [
             "Blackwater Cutlass",
             "Breakdance",
             "Cold Blood",
             "Dig for Treasure",
             "Door of Shadows",
             "Oh, Manager!",
             "Preparation"
           ]
         ],
         all: [["Aqir Goliath"], ["Preparation"]],
         all: [["Door of Shadows"], ["Nightmare Fuel"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prize Vendor"], ["Snowfall Graveyard"]]]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eredar Brute"], ["Kobold Miner", "Shattershambler"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Incubate"],
            ["Dirty Rat", "Dragon's Hoard", "Kaja'mite Creation", "Underbelly Fence", "Vendetta"]
          ],
          all: [
            ["Wildpaw Gnoll"],
            ["Bitterbloom Knight", "Dirty Rat", "Dragon's Hoard", "Zephrys the Great"]
          ],
          all: [
            ["Broodchamber Tunneler"],
            ["Reno, Lone Ranger", "Zephrys the Great"]
          ],
          all: [["Dragon's Hoard"], ["Aya, Lotus Kingpin", "Loatheb"]],
          all: [["Loatheb"], ["Underbelly Fence"]]
        ]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Bloodrock Co. Shovel"],
            ["Agent of the Old Ones", "Pit Stop", "Quick Pick", "Robocaller", "Stick Up", "The Kingslayers"]
          ],
          all: [["Kobold Miner"], ["Quick Pick", "Stick Up", "The Kingslayers"]],
          all: [["Drilly the Kid"], ["Quick Pick", "The Kingslayers"]],
          all: [["Pit Stop"], ["Disguised Operator", "The Kingslayers"]]
        ]
      ]
    ],
    "Alex Rogue":
      {[
         all: [["Foxy Fraud"], ["Scabbs Cutterbutter", "Spirit of the Shark"]],
         all: [["E.T.C., Band Manager"], ["Scabbs Cutterbutter"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue":
      {[
         all: [["Renferal, the Malignant"], ["Tess Greymane", "Vanish"]],
         all: [["Potion of Illusion"], ["Shenanigans"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue":
      {[
         all: [["Shadow Dance"], ["Cindersword", "Crystal Tusk"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Backstab"], ["Potion of Illusion"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Deafen"], ["Kobold Illusionist"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue":
      {[all: [["Savory Deviate Delight"], ["Scourge Illusionist"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue":
      {[
         all: [["Shattershambler"], ["Bloodrock Co. Shovel", "Serrated Tooth"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Kobold Illusionist"], ["Metal Detector"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue":
      {[
         all: [["Masked Reveler"], ["Gone Fishin'", "Sheltered Survivor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Kobold Illusionist"], ["Shadow of Death"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue":
      {[
         all: [["Bounce Around (ft. Garona)"], ["Cloak of Shadows"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Kingsbane Rogue": {[all: [["Instrument Tech"], ["Kingsbane"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Cultist Map"], ["Scourge Illusionist"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[all: [["Savory Deviate Delight"], ["Shadow Hunter Vol'jin"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Blackpaw's Whip"], ["Shattershambler"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Aqir Goliath"], ["Oh, Manager!"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[
         all: [
           ["Disguised Operator"],
           [
             "Filletfighter",
             "Jolly Roger",
             "Patches the Pirate",
             "Prize Plunderer",
             "Shadow Hunter Vol'jin",
             "Shadow of Death",
             "Toy Boat"
           ]
         ],
         all: [
           ["Knickknack Shack"],
           ["Cavern Shinyfinder", "Prize Plunderer", "Shadow Hunter Vol'jin", "Toy Boat"]
         ],
         all: [["Blackwater Cutlass"], ["Shadow Hunter Vol'jin"]],
         all: [["Mastermind Yogg-Saron"], ["Toy Boat"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prize Vendor"], ["Shadestone Skulker"]]]
      ]
    ],
    "XL Kingsbane Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Kingsbane"], ["Cavern Shinyfinder", "Cutting Class"]]]
      ]
    ],
    "Mill Rogue": {[all: [["Snowfall Graveyard"], ["Sonya Shadowdancer"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Shadow of Death"], ["Shattershambler"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Ghostly Strike"], ["Shadow Hunter Vol'jin"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["Gone Fishin'"], ["Griftah, Trusted Vendor"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Nightmare Fuel"], ["Ghostly Strike", "Oh, Manager!"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Knickknack Shack"], ["Shattershambler"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Disguised Operator"], ["Tess Greymane"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[
         all: [["Shadow Hunter Vol'jin"], ["Door of Shadows", "Preparation"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Everything Must Go!"], ["Oh, Manager!"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Zephrys the Great"],
            ["Dragon's Hoard", "Tooth of Nefarian", "Vendetta"]
          ],
          all: [["Dragon's Hoard"], ["Kaja'mite Creation"]],
          all: [["Reno, Lone Ranger"], ["Vendetta"]],
          all: [["Robocaller"], ["Treasure Hunter Eudora"]]
        ]
      ]
    ],
    "Illusionist Rogue": {[all: [["Kobold Illusionist"], ["Quick Pick"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Counterfeit Coin"], ["Nightmare Fuel"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[
         all: [["Shadow Hunter Vol'jin"], ["Counterfeit Coin", "Gone Fishin'"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Bounty Wrangler"], ["Sketchy Information"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Everything Must Go!"], ["Deafen", "Dig for Treasure"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Mixologist"], ["Quick Pick", "The Kingslayers"]],
          all: [["Timeline Accelerator"], ["Zilliax Deluxe 3000"]]
        ]
      ]
    ],
    "XL HL SoU Quest Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bazaar Burglary"], ["Maniacal Follower"]]]
      ]
    ],
    "Hostage Rogue":
      {[all: [["Disguised Operator"], ["Maestra, Mask Merchant"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Cloak of Shadows"], ["Snatch and Grab"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Rogue":
      {[all: [["Myra's Unstable Element"], ["Shattershambler"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue":
      {[
         all: [["Shattershambler"], ["Deafen", "Sphere of Sapience"]],
         all: [["Door of Shadows"], ["Kobold Illusionist"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Reconnaissance"],
            ["Crystalline Golem", "Disguised Operator", "Prize Vendor", "Quick Pick"]
          ],
          all: [["Mimicry"], ["Prize Vendor"]]
        ]
      ]
    ],
    "N'Zoth Rogue": {[all: [["Backstab"], ["Savory Deviate Delight"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Agent of the Old Ones"], ["Toy Boat"]]], [start_of_game: ["Prince Renathal"]]},
    "Mill Rogue": {[all: [["Barrens Trapper"], ["Disguised Operator"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Rogue": {[all: [["Dig for Treasure"], ["Treasure Distributor"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Scourge Illusionist"], ["Serrated Bone Spike"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Blackpaw's Whip"], ["Door of Shadows"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Oh, Manager!"], ["Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "Kingsbane Rogue": {[all: [["Cavern Shinyfinder"], ["Kingsbane"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue":
      {[
         all: [["Broodchamber Tunneler"], ["Savory Deviate Delight"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue":
      {[
         all: [["Crystal Tusk"], ["Dig for Treasure", "Shattershambler"]],
         all: [["Prize Plunderer"], ["Shattershambler"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Evasion"], ["Perjury"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue":
      {[
         all: [["Broodchamber Tunneler"], ["Patches the Pirate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Cloak of Shadows"], ["Maestra, Mask Merchant"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Aqir Goliath"], ["Dig for Treasure", "Everything Must Go!"]],
         all: [["Everything Must Go!"], ["Swindle"]],
         all: [["Ghostly Strike"], ["Preparation"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate Rogue": {[all: [["Filletfighter"], ["Swordfish"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["Preparation"], ["Zephrys the Great"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Barrens Trapper"], ["Swindle"]]]
      ]
    ],
    "Miracle Rogue": {[all: [["Ghostly Strike"], ["Oh, Manager!"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[
         all: [["Cavern Shinyfinder"], ["Patches the Pirate"]],
         all: [["Door of Shadows"], ["Jolly Roger"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Nightmare Fuel"], ["Gone Fishin'", "Swindle"]],
         all: [["Gear Shift"], ["Ghostly Strike"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Sketchy Information"], ["Sphere of Sapience"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bitterbloom Knight"], ["Parrrley"]]]
      ]
    ],
    "HL Velarok Rogue": {[all: [["Maestra of the Masquerade"], ["Toy Boat"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Plague of Madness"],
            ["Agent of the Old Ones", "Zephrys the Great"]
          ],
          all: [["Iso'rath"], ["Quick Pick"]],
          all: [["Time Adm'ral Hooktail"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Illusionist Rogue": {[all: [["Counterfeit Coin"], ["Kobold Illusionist"]]], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Greedy Partner"], ["Stick Up"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Sketchy Information"], ["Stick Up"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue":
      {[
         all: [["Blademaster Okani"], ["Counterfeit Coin"]],
         all: [["Toy Boat"], ["Zephrys the Great"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Dig for Treasure"], ["Field Contact"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Deafen"], ["Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Rogue": {[all: [["Dart Throw"], ["Sands of Time"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Chrono Daggers"], ["Evasion"]]], [start_of_game: ["Prince Renathal"]]},
    "Well Rogue": {[all: [["Contraband Stash"], ["Oh, Manager!"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Cavern Shinyfinder"], ["Jolly Roger"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL SoU Quest Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bazaar Burglary"], ["Wand Thief"]]]
      ]
    ],
    "HL Velarok Rogue":
      {[all: [["Filletfighter"], ["Maestra of the Masquerade"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Deadly Poison"], ["Sketchy Stranger"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Kaja'mite Creation"],
            ["Reno, Lone Ranger", "Zephrys the Great"]
          ],
          all: [["Treasure Hunter Eudora"], ["Reno Jackson", "Reno, Lone Ranger"]],
          all: [["Agency Espionage"], ["Zephrys the Great"]],
          all: [["Deja Vu"], ["Evasion"]],
          all: [["Dragon's Hoard"], ["Maestra, Mask Merchant"]]
        ]
      ]
    ],
    "N'Zoth Rogue": {[all: [["Counterfeit Coin"], ["Scourge Illusionist"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue":
      {[
         all: [
           ["Southsea Deckhand"],
           ["Serrated Bone Spike", "Sir Finley, Sea Guide"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Kobold Illusionist"], ["Shattershambler"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Deafen"], ["Ghostly Strike"]]], [start_of_game: ["Prince Renathal"]]},
    "STD AYAYA Rogue": {[all: [["Deadly Bribe"], ["Lotus Bookie"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[
         all: [["Garona Halforcen"], ["Gone Fishin'"]],
         all: [["Gear Shift"], ["Patches the Pirate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Backstab"], ["Maestra, Mask Merchant"]]], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Savory Deviate Delight"], ["Wishing Well"]]], [start_of_game: ["Prince Renathal"]]},
    "XL LC Quest Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Agency Espionage"], ["Lie in Wait"]]]
      ]
    ],
    "Illusionist Rogue": {[all: [["Bloodrock Co. Shovel"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Ghostly Strike"], ["Counterfeit Coin", "Cultist Map"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Alex Rogue": {[all: [["Foxy Fraud"], ["Shroud of Concealment"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Shattershambler"], ["Sheltered Survivor"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shadow Dance"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Hostage Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Chrono Daggers"], ["Cloak of Shadows"]]]
      ]
    ],
    "Illusionist Rogue":
      {[
         all: [
           ["Shattershambler"],
           ["Blackwater Cutlass", "Dig for Treasure", "Evasion", "Shroud of Concealment"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Dig for Treasure"], ["Ghostly Strike"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[
         all: [["The Kingslayers"], ["Cavern Shinyfinder", "Gone Fishin'"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Necrium Blade"], ["Crystalline Golem", "Disguised Operator"]],
          all: [["Coldlight Oracle"], ["Swindle"]]
        ]
      ]
    ],
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["N'Zoth, Dream's End"], ["Quick Pick"]]]
      ]
    ],
    "Well Rogue": {[all: [["Agent of the Old Ones"], ["Dart Throw"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Prize Plunderer"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Ghostly Strike"], ["Quick Pick", "Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "Mill Rogue": {[all: [["Naval Mine"], ["Space Pirate"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue":
      {[
         all: [
           ["Griftah, Trusted Vendor"],
           ["Filletfighter", "Swarthy Swordshiner"]
         ],
         all: [["Broodchamber Tunneler"], ["Prize Plunderer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Petty Theft"], ["Preparation"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Maestra, Mask Merchant"], ["Underbelly Fence"]],
          all: [["Spectral Cutlass"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "N'Zoth Rogue": {[all: [["Backstab"], ["Serrated Bone Spike", "Stick Up"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Counterfeit Coin"], ["Crystalline Golem"]]]
      ]
    ],
    "Other Rogue": {[all: [["Tenwu of the Red Smoke"], ["Togwaggle's Scheme"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Maestra, Mask Merchant"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Yogg Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Everything Must Go!"], ["Gear Shift"]]]
      ]
    ],
    "Illusionist Rogue": {[all: [["Blackpaw's Whip"], ["Quick Pick"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Pit Stop"], ["Robocaller"]],
          all: [["Quick Pick"], ["Reno, Lone Ranger"]],
          all: [["Sir Finley, Sea Guide"], ["The Curator"]]
        ]
      ]
    ],
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shadow Dance"], ["Spectral Cutlass"]]]
      ]
    ],
    "Velarok Rogue": {[all: [["Meat Wagon"], ["Serrated Bone Spike"]]], [start_of_game: ["Prince Renathal"]]},
    "Well Rogue": {[all: [["Gone Fishin'"], ["Meat Wagon"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Agent of the Old Ones"], ["Jolly Roger"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Kaja'mite Creation"]]]
      ]
    ],
    "XL Imbue Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Flutterwing Guardian"], ["Jagged Edge of Time"]]]
      ]
    ],
    "Miracle Rogue": {[all: [["Ghostly Strike"], ["Gone Fishin'"]]], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Greedy Partner"], ["Savory Deviate Delight"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue":
      {[all: [["Savory Deviate Delight"], ["Sketchy Information"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Eventuality"], ["Savory Deviate Delight"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["E.T.C., Band Manager"], ["Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue":
      {[all: [["Toy Boat"], ["Gear Shift", "Savory Deviate Delight"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Breakdance"], ["Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Iso'rath"], ["The Kingslayers"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Spectral Cutlass"], ["Tooth of Nefarian"]],
          all: [["Stick Up"], ["Wand Thief"]]
        ]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Maestra, Mask Merchant"]],
          all: [["Iso'rath"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Imbue Rogue": {[all: [["Bitterbloom Knight"], ["Flutterwing Guardian"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["Broodchamber Tunneler"], ["Filletfighter"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cloak of Shadows"], ["Tess Greymane"]]]
      ]
    ],
    "Illusionist Rogue": {[all: [["Shattershambler"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "Mine Rogue": {[all: [["Door of Shadows"], ["Naval Mine"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Garona Halforcen"], ["Toy Boat"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Preparation"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate Rogue": {[all: [["Prize Plunderer"], ["Raiding Party"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Rogue": {[all: [["Counterfeit Coin"], ["Treasure Hunter Eudora"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Oh, Manager!"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Gear Shift"], ["Serrated Bone Spike"]]], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Serrated Bone Spike"], ["Wishing Well"]]], [start_of_game: ["Prince Renathal"]]},
    "Mill Rogue": {[all: [["Rotten Rodent"], ["Space Pirate"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["Cold Blood"], ["Stick Up"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Patches the Pirate"], ["Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Dig for Treasure"], ["Prize Plunderer"]],
         all: [["Gear Shift"], ["Swindle"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Toy Boat"], ["Gone Fishin'", "Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Dig for Treasure"], ["E.T.C., Band Manager"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sands of Time"], ["Thistle Tea Set"]]]
      ]
    ],
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Gone Fishin'"], ["Prize Vendor"]]]
      ]
    ],
    "Velarok Rogue":
      {[
         all: [["Serrated Bone Spike"], ["Greedy Partner", "Oh, Manager!"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Serrated Bone Spike"], ["Sketchy Information"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Kaja'mite Creation"], ["Maestra, Mask Merchant"]]]
      ]
    ],
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Stick Up"], ["Thistle Tea Set"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Stick Up"], ["Underbelly Fence"]]]
      ]
    ],
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Iso'rath"], ["Spirit of the Shark"]]]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Zephrys the Great"]]]
      ]
    ],
    "Hostage Rogue": {[all: [["Evasion"], ["Maestra, Mask Merchant"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Quick Pick"], ["Sphere of Sapience"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Cultist Map"], ["Sphere of Sapience"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Zephrys the Great"], ["Counterfeit Coin", "Quick Pick"]]]
      ]
    ],
    "Yogg Rogue": {[all: [["Jolly Roger"], ["Prize Plunderer"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["Stick Up"], ["The Kingslayers"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prize Vendor"], ["Shadowcrafter Scabbs"]]]
      ]
    ],
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dubious Purchase"], ["Evasion", "Swindle"]],
          all: [["Prize Vendor"], ["Savory Deviate Delight"]]
        ]
      ]
    ],
    "Miracle Rogue": {[all: [["Deafen"], ["Gone Fishin'"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Cultist Map"], ["Eventuality"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Gone Fishin'"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Disguised Operator"], ["Mimicry"]],
          all: [["Scourge Illusionist"], ["Stick Up"]]
        ]
      ]
    ],
    "Hostage Rogue":
      {[
         all: [["Maestra, Mask Merchant"], ["Shroud of Concealment"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Dig for Treasure"], ["Maestra, Mask Merchant"]]], [start_of_game: ["Prince Renathal"]]},
    "Mine Rogue": {[all: [["Necrium Blade"], ["Snowfall Graveyard"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Gear Shift"], ["Savory Deviate Delight"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Cultist Map"], ["Toy Boat"]]], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue":
      {[all: [["Door of Shadows"], ["Shroud of Concealment"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Savory Deviate Delight", "Zephrys the Great"]],
          all: [["Barrens Trapper"], ["Sonya Shadowdancer"]]
        ]
      ]
    ],
    "Velarok Rogue": {[all: [["Agent of the Old Ones"], ["Meat Wagon"]]], [start_of_game: ["Prince Renathal"]]},
    "Well Rogue":
      {[
         all: [
           ["Agent of the Old Ones"],
           ["Door of Shadows", "Sketchy Information"]
         ],
         all: [["Aya, Lotus Kingpin"], ["Sketchy Information"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Gone Fishin'"], ["Sketchy Information"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Gone Fishin'"], ["Oh, Manager!"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Gone Fishin'"], ["Greedy Partner"]]], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Greedy Partner"], ["Quick Pick"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue":
      {[
         all: [["Sketchy Information"], ["Cultist Map", "Gear Shift"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue":
      {[
         all: [["Zephrys the Great"], ["Jolly Roger", "The Kingslayers"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Jolly Roger"], ["The Kingslayers"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Rogue": {[all: [["Cultist Map"], ["Maestra, Mask Merchant"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Everything Must Go!"], ["Preparation"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Dig for Treasure"], ["Gear Shift"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Gear Shift"], ["Stick Up"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Dig for Treasure"], ["Disguised Operator"]]], [start_of_game: ["Prince Renathal"]]},
    "Splendiferous Whizbang": {[all: [["Dig for Treasure"], ["Filletfighter"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Stick Up"],
            ["Cavern Shinyfinder", "Mic Drop", "Treasure Hunter Eudora"]
          ],
          all: [["Agency Espionage"], ["Cultist Map"]],
          all: [["Spectral Cutlass"], ["Treasure Hunter Eudora"]]
        ]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shadowstep"], ["Vendetta"]]]
      ]
    ],
    "N'Zoth Rogue":
      {[
         all: [["Savory Deviate Delight"], ["Gone Fishin'", "Stick Up"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Counterfeit Coin"], ["Deafen"]],
         all: [["Gone Fishin'"], ["Prize Plunderer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Garona Halforcen"]]]
      ]
    ],
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Crystalline Golem"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Prize Vendor"], ["Sonya Shadowdancer", "Stick Up"]],
          all: [["Fast Forward"], ["Gear Shift"]]
        ]
      ]
    ],
    "STD AYAYA Rogue": {[all: [["Agent of the Old Ones"], ["Blackpaw's Whip"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Cultist Map"]]]
      ]
    ],
    "XL Hostage Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Maestra, Mask Merchant"], ["Shroud of Concealment"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bitterbloom Knight"], ["Stick Up"]]]
      ]
    ],
    "N'Zoth Rogue": {[all: [["Backstab"], ["Cultist Map"]]], [start_of_game: ["Prince Renathal"]]},
    "Alex Rogue": {[all: [["Serrated Bone Spike"], ["Shroud of Concealment"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Rogue": {[all: [["Agent of the Old Ones"], ["Gone Fishin'"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[all: [["Cultist Map"], ["Blackwater Cutlass", "Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spirit of the Shark"], ["Stick Up"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Maestra, Mask Merchant"], ["Zephrys the Great"]]]
      ]
    ],
    "N'Zoth Rogue": {[all: [["Preparation"], ["Sketchy Information"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Counterfeit Coin"], ["Sketchy Information"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Counterfeit Coin"], ["Gone Fishin'"]],
         all: [["Oh, Manager!"], ["Quick Pick"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Door of Shadows"], ["Quick Pick"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Gone Fishin'"], ["Quick Pick"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["The Kingslayers"]]]
      ]
    ],
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Crystalline Golem"], ["Evasion"]]]
      ]
    ],
    "N'Zoth Rogue": {[all: [["Gear Shift"], ["Gone Fishin'"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Evasion"], ["Eredar Brute", "Vanish"]],
          all: [["Cloak of Shadows"], ["Potion of Illusion"]]
        ]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Maestra, Mask Merchant"], ["Quick Pick"]]]
      ]
    ],
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Disguised Operator"], ["Swindle"]]]
      ]
    ],
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mic Drop"], ["Spectral Cutlass"]]]
      ]
    ],
    "Yogg Rogue": {[all: [["Jolly Roger"], ["Toy Boat"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Velarok Rogue": {[all: [["Quick Pick"], ["Swarthy Swordshiner"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Counterfeit Coin"], ["Swindle"]],
         all: [["Cultist Map"], ["Door of Shadows"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cultist Map"], ["Deja Vu"]]]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Robocaller"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Deja Vu"], ["Stick Up"]],
          all: [["Eventuality"], ["Maestra, Mask Merchant"]]
        ]
      ]
    ],
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spectral Cutlass"], ["Bitterbloom Knight", "Preparation"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Cavern Shinyfinder"], ["Spectral Cutlass"]],
          all: [["Garona Halforcen"], ["The Kingslayers"]],
          all: [["Shadowstep"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Harold Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Maniacal Follower"], ["Rite of Twilight"]]]
      ]
    ],
    "XL Velarok Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Preparation"], ["Sketchy Information"]]]
      ]
    ],
    "Yogg Rogue": {[all: [["Agent of the Old Ones"], ["The Kingslayers"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Rogue": {[all: [["Evasion"], ["Preparation"]]], [start_of_game: ["Prince Renathal"]]},
    "N'Zoth Rogue": {[all: [["Cultist Map"], ["Stick Up"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue":
      {[
         all: [["Gone Fishin'"], ["Cultist Map", "Preparation"]],
         all: [["Prize Plunderer"], ["Shadowstep"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Stick Up"], ["Swindle"]]]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Maestra, Mask Merchant"]],
          all: [["Gone Fishin'"], ["Stick Up"]]
        ]
      ]
    ],
    "Miracle Rogue":
      {[
         all: [["Counterfeit Coin"], ["Oh, Manager!"]],
         all: [["Cultist Map"], ["Quick Pick"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Illusionist Rogue": {[all: [["Quick Pick"], ["Swindle"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aya, Lotus Kingpin"], ["Counterfeit Coin"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Bitterbloom Knight"], ["Shadowstep"]],
          all: [["E.T.C., Band Manager"], ["Maestra, Mask Merchant"]]
        ]
      ]
    ],
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Agent of the Old Ones"], ["Stick Up"]]]
      ]
    ],
    "Miracle Rogue":
      {[
         all: [["Counterfeit Coin"], ["Breakdance", "Cultist Map", "Gear Shift"]],
         all: [["Cultist Map"], ["Gear Shift"]],
         all: [["Oh, Manager!"], ["Preparation"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Maestra, Mask Merchant"], ["Shadowstep"]],
          all: [["Preparation"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    "XL Alex Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Counterfeit Coin"], ["Serrated Bone Spike"]]]
      ]
    ],
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Stick Up"], ["Cultist Map", "Shadowstep"]]]
      ]
    ],
    "Yogg Rogue": {[all: [["Garona Halforcen"], ["The Kingslayers"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Preparation"]]]
      ]
    ],
    "XL HL Imbue Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bitterbloom Knight"], ["Eventuality"]]]
      ]
    ],
    "XL Miracle Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Gone Fishin'"], ["Counterfeit Coin", "Preparation"]],
          all: [["Breakdance"], ["Preparation"]]
        ]
      ]
    ],
    "Hostage Rogue": {[all: [["Preparation"], ["Shroud of Concealment"]]], [start_of_game: ["Prince Renathal"]]},
    "Velarok Rogue": {[all: [["Counterfeit Coin"], ["Shadowstep"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cultist Map"], ["Shadowstep"]]]
      ]
    ],
    "Other Rogue": {[all: [["Preparation"], ["Shadowstep"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Cultist Map"], ["Preparation"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Rogue": {[all: [["Counterfeit Coin"], ["Quick Pick"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Rogue": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cultist Map"], ["Preparation"]]]
      ]
    ]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Rogue")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Rogue")
  end
end
