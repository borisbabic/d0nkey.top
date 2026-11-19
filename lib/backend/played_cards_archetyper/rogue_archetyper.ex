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
    "Quasar Rogue": ["Shiv"],
    "Alex Rogue": ["Darkscale Broodmother"],
    "Quasar Rogue": ["Knickknack Shack", "Mimic Pod", "Quasar", "Shadow of Death", "Street Trickster"],
    "Miracle Rogue": ["Scribbling Stenographer"],
    "XL Mill Rogue": ["Vanndar Stormpike"],
    "777 Miracle Rogue": ["Arcane Giant", "Everything Must Go!", "Triple Sevens"],
    "JtU Quest Rogue": ["The Caverns Below"],
    "Pirate Rogue": ["Swordfish"],
    "Hostage Rogue": ["Jade Telegram"],
    "Kingsbane Rogue": ["Blade Flurry"],
    "Kingslayer Pirate Rogue": ["Sailboat Captain"],
    "XL Velarok Rogue": ["Wildpaw Gnoll"],
    "Alex Rogue": ["Foxy Fraud", "Shadowcaster"],
    "XL Mill Rogue": ["Armor Vendor", "Scabbs Cutterbutter", "The Curator", "War'loc"],
    "Hostage Rogue": ["Garrote"],
    "XL HL Thief Rogue": ["Reno, Lone Ranger"],
    "XL Velarok Rogue": ["Petty Theft", "Space Pirate"],
    "Deathrattle Rogue": ["Smokescreen"],
    "XL LC Quest Rogue": ["Moonstone Mauler"],
    "Well Rogue": ["Wishing Well"],
    "XL HL Thief Rogue": ["Reno Jackson"],
    "Kingsbane Rogue": ["Kingsbane"],
    "XL Velarok Rogue": ["Cutting Class"],
    "Kingslayer Pirate Rogue": ["Hozen Roughhouser", "Treasure Distributor"],
    "STD Harold Rogue": ["Spymistress"],
    "HL Velarok Rogue": ["Cold Blood", "Southsea Deckhand"],
    "Hostage Rogue": ["Chrono Daggers", "Cloak of Shadows"],
    "XL HL Thief Rogue": ["Mixologist", "Robocaller"],
    "Quasar Rogue": ["Mic Drop"],
    "777 Miracle Rogue": ["Blackwater Cutlass", "Smothering Starfish"],
    "XL LC Quest Rogue": ["Augmented Elekk"],
    "HL Velarok Rogue": ["Swarthy Swordshiner"],
    "Well Rogue": ["Oh, Manager!"],
    "Miracle Rogue": ["Greedy Partner"],
    "Quasar Rogue": ["Fan of Knives", "Ghostly Strike"],
    "Alex Rogue": ["Shroud of Concealment"],
    "XL HL Thief Rogue": ["Party Fiend"],
    "XL Velarok Rogue": ["Deadly Poison"],
    "HL Velarok Rogue": ["Filletfighter", "Jolly Roger"],
    "777 Miracle Rogue": ["Cult Neophyte", "Shaladrassil"],
    "XL HL Thief Rogue": ["Zephrys the Great"],
    "STD Harold Rogue": ["Flashback"],
    "XL Imbue Rogue": ["Adaptive Amalgam"],
    "XL Mill Rogue": ["Pit Stop"],
    "Quasar Rogue": ["Quick Pick"],
    "XL Velarok Rogue": [
      "Parrrley",
      "Queen Azshara",
      "Savory Deviate Delight",
      "Shadowed Informant",
      "Spore Hallucination"
    ],
    "XL Imbue Rogue": ["Lotus Agents"],
    "XL LC Quest Rogue": ["Lie in Wait"],
    "777 Miracle Rogue": ["Agent of the Old Ones"],
    "XL Velarok Rogue": ["Sinestra"],
    "Quasar Rogue": ["Ethereal Oracle"],
    "Hostage Rogue": ["Potion of Illusion"],
    "XL Imbue Rogue": ["Envoy of the End"],
    "XL HL Thief Rogue": ["Underbelly Fence"],
    "XL Velarok Rogue": ["Agency Espionage", "Rite of Twilight", "Spectral Cutlass"],
    "XL HL Thief Rogue": ["Wand Thief"],
    "Velarok Rogue": ["Kobold Miner"],
    "XL HL Thief Rogue": ["Kaja'mite Creation"],
    "XL Mill Rogue": ["Spirit of the Shark"],
    "STD Harold Rogue": ["Darkbomb", "Shadow Word: Pain"],
    "XL Mill Rogue": ["Coldlight Oracle"],
    "STD Harold Rogue": ["Mad Scientist"],
    "Mill Rogue": ["Necrium Blade"],
    "Quasar Rogue": ["Swindle"],
    "777 Miracle Rogue": ["Gear Shift", "Gone Fishin'"],
    "Hostage Rogue": ["Dig for Treasure"],
    "XL Imbue Rogue": ["Flutterwing Guardian"],
    "XL Velarok Rogue": ["Treasure Hunter Eudora"],
    "XL HL Thief Rogue": ["Iso'rath"],
    "Deathrattle Rogue": ["Door of Shadows"],
    "XL Velarok Rogue": ["Stick Up"],
    "XL HL Thief Rogue": ["Maestra, Mask Merchant"],
    "Quasar Rogue": ["Cultist Map"],
    "STD Harold Rogue": ["Dirty Rat"],
    "XL Velarok Rogue": ["Bitterbloom Knight", "Deja Vu", "Nightmare Fuel"],
    "Velarok Rogue": ["Counterfeit Coin", "Preparation"]
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
