# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @herald_package [
    "Armored Bloodletter",
    "Azshara, Ocean Lord",
    "Deathwing, Worldbreaker",
    "Envoy of the End",
    "Ultraxion"
  ]
  @broxigar_dh_minions [
    "Bloodmage Thalnos",
    "Devious Coyote",
    "Dreadsoul Corrupter",
    "Felfire Blaze",
    "Glacial Shard",
    "Kayn Sunfury",
    "Remnant of Rage",
    "Slumbering Sprite",
    "Wild Pyromancer"
  ]
  @standard_excludes %{
    :"Spell DH" =>
      @herald_package ++
        ["Elise the Navigator", "Scorchreaver", "Felfire Blaze", "Ravenous Felfisher" | @broxigar_dh_minions]
  }
  @standard_config [
    "Quest DH": ["Unleash the Colossus"],
    "Raza DH": [
      {:all,
       [
         ["Soul Immolation"],
         [
           "Axe of Cenarius",
           "Broxigar",
           "Broxigar's Last Stand",
           "Dark Bribe",
           "Enduring Roach",
           "Eredar Deceptor",
           "First Portal to Argus",
           "Fumigate",
           "Glacial Shard",
           "Grim Harvest",
           "Hungering Cavern",
           "Illidari Studies",
           "Infestation",
           "Remnant of Rage",
           "Royal Librarian",
           "Rustrot Viper",
           "Sigil of Hatching"
         ]
       ]},
      {:all,
       [
         ["Enduring Roach"],
         [
           "Axe of Cenarius",
           "Broxigar",
           "Broxigar's Last Stand",
           "Dark Bribe",
           "Eredar Deceptor",
           "First Portal to Argus",
           "Fumigate",
           "Glacial Shard",
           "Grim Harvest",
           "Hungering Cavern",
           "Illidari Studies",
           "Infestation",
           "Remnant of Rage",
           "Sigil of Hatching"
         ]
       ]},
      {:all,
       [
         ["Eredar Deceptor"],
         [
           "Axe of Cenarius",
           "Broxigar's Last Stand",
           "Dark Bribe",
           "First Portal to Argus",
           "Fumigate",
           "Glacial Shard",
           "Grim Harvest",
           "Hungering Cavern",
           "Illidari Studies",
           "Infestation",
           "Press the Advantage",
           "Remnant of Rage",
           "Sigil of Hatching"
         ]
       ]},
      {:all,
       [
         ["Dark Bribe"],
         ["Fumigate"]
       ]}
    ],
    # 2.5
    "Void Soul DH": [
      {:all,
       [
         ["Ravenous Felhunter"],
         ["Stardust Scythe", "Vicious Voidscale", "Void Blast", "Void Soul"]
       ]},
      {:all,
       [
         ["Press the Advantage"],
         ["Stardust Scythe", "Vicious Voidscale", "Void Blast"]
       ]},
      {:all,
       [
         ["Spectral Sight"],
         ["Stardust Scythe", "Vicious Voidscale"]
       ]},
      {:all,
       [
         ["Stardust Scythe"],
         ["Vicious Voidscale"]
       ]}
    ],
    # 3.5
    "Void C'Thun DH": [
      {:all,
       [
         ["Cosmic Manifestations"],
         ["Attentive Tender", "Devious Coyote", "King Mukla", "Sizzling Cinder", "Watfin"]
       ]},
      {:all,
       [
         ["Devious Coyote"],
         ["Gorishi Stinger", "Wormriddled Wriggler"]
       ]},
      {:all,
       [
         ["King Mukla"],
         ["Sizzling Cinder"]
       ]},
      {:all,
       [
         ["Sigil of Cinder"],
         ["Wormriddled Wriggler"]
       ]}
    ],
    # 4.5
    "C'Thun DH": [
      {:all,
       [
         ["Remnant of Rage"],
         ["C'Thun, Eye of the Empire", "Cult Neophyte", "Gargantuan Slitherer", "Spawn of C'Thun", "Tentacle Lash"]
       ]},
      {:all,
       [
         ["Sigil of Hatching"],
         ["C'Thun, Eye of the Empire", "Gargantuan Slitherer", "Spawn of C'Thun"]
       ]},
      {:all,
       [
         ["C'Thun, Eye of the Empire"],
         ["Defias Smuggler"]
       ]}
    ],
    # 5.5
    "Void C'Thun DH": [
      {:all,
       [
         ["Watfin"],
         ["Attentive Tender", "Cult Neophyte", "Devious Coyote", "Sigil of Cinder", "Wormriddled Wriggler"]
       ]},
      {:all,
       [
         ["Cosmic Manifestations"],
         ["Cult Neophyte", "Sigil of Cinder"]
       ]},
      {:all,
       [
         ["Cult Neophyte"],
         ["Wormriddled Wriggler"]
       ]}
    ],
    # 6.5
    "Void C'Thun DH": [
      {:all,
       [
         ["Devious Coyote"],
         [
           "Attentive Tender",
           "Cult Neophyte",
           "Gargantuan Slitherer",
           "Grim Harvest",
           "Illidari Studies",
           "Infestation",
           "Irida Sinseeker",
           "Kayn Sunfury",
           "Nightmare Lord Xavius",
           "Sigil of Cinder",
           "Sigil of the Seas",
           "Sizzling Cinder",
           "Spawn of C'Thun",
           "Tentacle Lash",
           "Wyvern's Slumber"
         ]
       ]},
      {:all,
       [
         ["Sizzling Cinder"],
         [
           "Gargantuan Slitherer",
           "Irida Sinseeker",
           "Sigil of Cinder",
           "Spawn of C'Thun",
           "Tentacle Lash",
           "Wyvern's Slumber"
         ]
       ]},
      {:all,
       [
         ["Cult Neophyte"],
         ["Irida Sinseeker", "Sigil of Cinder"]
       ]},
      {:all,
       [
         ["Irida Sinseeker"],
         ["Sigil of Cinder"]
       ]}
    ],
    # 7.5
    "N'Zoth DH": [
      {:all,
       [
         ["Attentive Tender"],
         ["Broxigar", "Crystalline Golem", "Ferocious Felbat", "N'Zoth, Dream's End", "Ravenous Felhunter", "Vyranoth"]
       ]},
      {:all,
       [
         ["Press the Advantage"],
         ["Crystalline Golem", "N'Zoth, Dream's End", "Titanic Thrasher", "Vyranoth"]
       ]},
      {:all,
       [
         ["Frontline Ironborn"],
         ["Illidari Inquisitor", "Portal Vanguard"]
       ]},
      {:all,
       [
         ["Illidari Inquisitor"],
         ["N'Zoth, Dream's End"]
       ]}
    ],
    # 8.5
    "Harold DH": [
      {:all,
       [
         ["Armored Bloodletter"],
         [
           "Axe of Cenarius",
           "Azshara, Ocean Lord",
           "Broxigar's Last Stand",
           "C'Thun, Eye of the Empire",
           "Deathwing, Worldbreaker",
           "Envoy of the End",
           "Fel Infusion",
           "First Portal to Argus",
           "Gargantuan Slitherer",
           "Grim Harvest",
           "Hive Map",
           "Illidari Studies",
           "Infestation",
           "Nightmare Lord Xavius",
           "Sigil of the Seas",
           "Spawn of C'Thun",
           "Tentacle Lash",
           "Ultraxion",
           "Wyvern's Slumber"
         ]
       ]},
      {:all,
       [
         ["Fel Infusion"],
         [
           "Axe of Cenarius",
           "Azshara, Ocean Lord",
           "Broxigar's Last Stand",
           "C'Thun, Eye of the Empire",
           "Deathwing, Worldbreaker",
           "Envoy of the End",
           "First Portal to Argus",
           "Grim Harvest",
           "Spawn of C'Thun",
           "Tentacle Lash",
           "Ultraxion",
           "Wyvern's Slumber"
         ]
       ]},
      {:all,
       [
         ["Ultraxion"],
         [
           "Deathwing, Worldbreaker",
           "First Portal to Argus",
           "Hive Map",
           "Illidari Studies",
           "Infestation",
           "Sigil of the Seas",
           "Tentacle Lash"
         ]
       ]},
      {:all,
       [
         ["Infestation"],
         ["Deathwing, Worldbreaker", "Envoy of the End"]
       ]}
    ],
    # 9.5
    "Void C'Thun DH": [
      {:all,
       [
         ["Irida Sinseeker"],
         ["C'Thun, Eye of the Empire", "Gargantuan Slitherer", "Spawn of C'Thun", "Watfin"]
       ]},
      {:all,
       [
         ["Spawn of C'Thun"],
         ["Cosmic Manifestations", "Wormriddled Wriggler"]
       ]}
    ],
    # 10.5
    # auto gen
    "Void DH": [
      all: [
        ["Cosmic Manifestations"],
        ["Doomsayer", "Mythical Terror", "Portal Vanguard", "Titanic Thrasher", "Vyranoth"]
      ],
      all: [["Doomsayer"], ["Mythical Terror"]]
    ],
    "C'Thun DH": [all: [["Broxigar"], ["Cult Neophyte"]]],
    "Void C'Thun DH": [all: [["Attentive Tender"], ["Sigil of Cinder"]]],
    "C'Thun DH": [all: [["Cult Neophyte"], ["Sigil of Hatching"]]],
    "Void C'Thun DH": [
      all: [["C'Thun, Eye of the Empire"], ["Wormriddled Wriggler"]]
    ],
    "C'Thun DH": [all: [["Broxigar's Last Stand"], ["Cult Neophyte"]]],
    "Void C'Thun DH": [all: [["Cosmic Manifestations"], ["Gargantuan Slitherer"]]],
    "Void Soul DH": [all: [["Broxigar's Last Stand"], ["Void Blast"]]],
    "Void C'Thun DH": [all: [["Gargantuan Slitherer"], ["Sigil of Cinder"]]],
    "N'Zoth DH": [all: [["Irida Sinseeker"], ["Remnant of Rage"]]],
    "C'Thun DH": [all: [["Defias Smuggler"], ["Spawn of C'Thun"]]],
    "Void Soul DH": [all: [["Vicious Voidscale"], ["Void Blast"]]],
    "N'Zoth DH": [all: [["Endbringer Umbra"], ["Grim Harvest"]]],
    "Void C'Thun DH": [all: [["Gargantuan Slitherer"], ["Watfin"]]],
    "C'Thun DH": [all: [["C'Thun, Eye of the Empire"], ["Frontline Ironborn"]]],
    "Void Soul DH": [all: [["Infestation"], ["Vicious Voidscale"]]],
    "Void C'Thun DH": [
      all: [
        ["Sigil of Cinder"],
        ["C'Thun, Eye of the Empire", "Spawn of C'Thun", "Tentacle Lash"]
      ]
    ],
    "Void Soul DH": [
      all: [["Stardust Scythe"], ["Grim Harvest", "Illidari Studies"]]
    ],
    "C'Thun DH": [
      all: [
        ["Spawn of C'Thun"],
        ["Broxigar", "Broxigar's Last Stand", "Frontline Ironborn", "Hungering Cavern"]
      ],
      all: [
        ["Gargantuan Slitherer"],
        ["Broxigar's Last Stand", "Glacial Shard", "Hungering Cavern"]
      ],
      all: [["Broxigar's Last Stand"], ["C'Thun, Eye of the Empire"]],
      all: [["Cult Neophyte"], ["Hungering Cavern"]]
    ],
    "Void C'Thun DH": [
      all: [
        ["Watfin"],
        ["C'Thun, Eye of the Empire", "Kayn Sunfury", "Spawn of C'Thun", "Tentacle Lash"]
      ],
      all: [["Attentive Tender"], ["Cult Neophyte"]],
      all: [["Gargantuan Slitherer"], ["Wormriddled Wriggler"]]
    ],
    "N'Zoth DH": [
      all: [
        ["Remnant of Rage"],
        ["Crystalline Golem", "N'Zoth, Dream's End", "Ravenous Felhunter", "Wormriddled Wriggler"]
      ],
      all: [["Crystalline Golem"], ["Ravitz"]],
      all: [["Elise the Navigator"], ["Titanic Thrasher"]],
      all: [["Hungering Cavern"], ["N'Zoth, Dream's End"]]
    ],
    "Void C'Thun DH": [all: [["Cosmic Manifestations"], ["Tentacle Lash"]]],
    "Raza DH": [all: [["Dark Bribe"], ["Rustrot Viper"]]],
    "Void DH": [all: [["Cosmic Manifestations"], ["Hellraiser"]]],
    "Void C'Thun DH": [all: [["Escape Artist"], ["Spawn of C'Thun"]]],
    "Void DH": [all: [["Perennial Serpent"], ["Titanic Thrasher"]]],
    "C'Thun DH": [all: [["Sigil of Hatching"], ["Tentacle Lash"]]],
    "Void C'Thun DH": [all: [["Hellraiser"], ["Tentacle Lash"]]],
    "Raza DH": [all: [["Dark Bribe"], ["Royal Librarian"]]],
    "Spell DH": [all: [["First Portal to Argus"], ["Time-Lost Glaive"]]],
    "N'Zoth DH": [all: [["Crystalline Golem"], ["Dirty Rat"]]],
    "Void Soul DH": [all: [["Grim Harvest"], ["Void Blast"]]],
    "Raza DH": [all: [["Dark Bribe"], ["Remnant of Rage"]]],
    "Void C'Thun DH": [all: [["Sigil of Cinder"], ["Wyvern's Slumber"]]],
    "C'Thun DH": [all: [["Broxigar's Last Stand"], ["Tentacle Lash"]]],
    "Raza DH": [all: [["Broxigar's Last Stand"], ["Dark Bribe"]]],
    "N'Zoth DH": [
      all: [["Glacial Shard"], ["Attentive Tender", "Ferocious Felbat"]]
    ],
    "C'Thun DH": [all: [["Sigil of Hatching"], ["Wyvern's Slumber"]]],
    "Void C'Thun DH": [
      all: [["Tentacle Lash"], ["Irida Sinseeker", "Wormriddled Wriggler"]],
      all: [["Sigil of the Seas"], ["Watfin"]]
    ],
    "C'Thun DH": [all: [["Hungering Cavern"], ["Tentacle Lash"]]],
    "N'Zoth DH": [all: [["Broxigar's Last Stand"], ["Crystalline Golem"]]],
    "Void DH": [all: [["Cosmic Manifestations"], ["Crystalline Golem"]]],
    "Void C'Thun DH": [all: [["Cosmic Manifestations"], ["Wormriddled Wriggler"]]],
    "Void Soul DH": [all: [["Sigil of the Seas"], ["Void Blast"]]],
    "N'Zoth DH": [all: [["Hungering Cavern"], ["Vyranoth"]]],
    "Void DH": [all: [["Glacial Shard"], ["Portal Vanguard"]]],
    "N'Zoth DH": [
      all: [["Glacial Shard"], ["Ravenous Felhunter", "Titanic Thrasher"]]
    ],
    "C'Thun DH": [all: [["Cult Neophyte"], ["Frontline Ironborn"]]],
    "Void DH": [all: [["Irida Sinseeker"], ["Solitude"]]],
    "Raza DH": [all: [["Dark Bribe"], ["Glacial Shard", "Press the Advantage"]]],
    "N'Zoth DH": [all: [["Frontline Ironborn"], ["Wormriddled Wriggler"]]],
    "Void C'Thun DH": [all: [["Grim Harvest"], ["Watfin"]]],
    "C'Thun DH": [
      all: [["Frontline Ironborn"], ["Broxigar's Last Stand", "Hungering Cavern"]],
      all: [["Defias Smuggler"], ["Sigil of Hatching"]]
    ],
    "N'Zoth DH": [all: [["Portal Vanguard"], ["Sigil of the Seas"]]],
    "Void Soul DH": [all: [["Sigil of the Seas"], ["Void Soul"]]],
    "Void C'Thun DH": [all: [["Grim Harvest"], ["Sigil of Cinder"]]],
    "Void DH": [all: [["Illidari Studies"], ["Portal Vanguard"]]],
    "Void C'Thun DH": [all: [["Cosmic Manifestations"], ["Sigil of the Seas"]]],
    "N'Zoth DH": [
      all: [["Crystalline Golem"], ["Frontline Ironborn", "Glacial Shard"]]
    ],
    "N'Zoth DH": [
      all: [["Defias Smuggler"], ["Ferocious Felbat"]],
      all: [["Frontline Ironborn"], ["Irida Sinseeker"]]
    ],
    "C'Thun DH": [
      all: [
        ["C'Thun, Eye of the Empire"],
        ["First Portal to Argus", "Glacial Shard"]
      ],
      all: [["Frontline Ironborn"], ["Sigil of Hatching", "Tentacle Lash"]],
      all: [["Cult Neophyte"], ["First Portal to Argus"]]
    ],
    "N'Zoth DH": [all: [["Attentive Tender"], ["Frontline Ironborn"]]],
    "Raza DH": [all: [["First Portal to Argus"], ["Fumigate"]]],
    "C'Thun DH": [all: [["Remnant of Rage"], ["Wyvern's Slumber"]]],
    "Void C'Thun DH": [all: [["Gorishi Stinger"], ["Spawn of C'Thun"]]],
    "N'Zoth DH": [all: [["Ferocious Felbat"], ["Infestation"]]],
    "Void C'Thun DH": [
      all: [["Attentive Tender"], ["Spawn of C'Thun", "Tentacle Lash"]],
      all: [["Cult Neophyte"], ["Kayn Sunfury"]]
    ],
    "C'Thun DH": [
      all: [
        ["Glacial Shard"],
        ["Spawn of C'Thun", "Tentacle Lash", "Wyvern's Slumber"]
      ],
      all: [["Axe of Cenarius"], ["Cult Neophyte"]]
    ],
    "Raza DH": [
      all: [
        ["Glacial Shard"],
        ["Broxigar's Last Stand", "Hungering Cavern", "Remnant of Rage"]
      ]
    ],
    "N'Zoth DH": [all: [["Infestation"], ["Ravenous Felhunter"]]],
    "Void C'Thun DH": [all: [["Wormriddled Wriggler"], ["Wyvern's Slumber"]]],
    "N'Zoth DH": [all: [["Defias Smuggler"], ["Wormriddled Wriggler"]]],
    "Void DH": [
      all: [
        ["Hellraiser"],
        ["Axe of Cenarius", "First Portal to Argus", "Ravenous Felhunter"]
      ]
    ],
    "C'Thun DH": [all: [["First Portal to Argus"], ["Gargantuan Slitherer"]]],
    "C'Thun DH": [all: [["Axe of Cenarius"], ["Gargantuan Slitherer"]]],
    "Void C'Thun DH": [
      all: [
        ["Cult Neophyte"],
        ["Grim Harvest", "Illidari Studies", "Sigil of the Seas", "Wyvern's Slumber"]
      ],
      all: [["Kayn Sunfury"], ["Gargantuan Slitherer", "Tentacle Lash"]],
      all: [["Irida Sinseeker"], ["Wyvern's Slumber"]]
    ],
    "N'Zoth DH": [all: [["Irida Sinseeker"], ["Titanic Thrasher"]]],
    "Void C'Thun DH": [all: [["Cult Neophyte"], ["Infestation"]]],
    "N'Zoth DH": [all: [["Crystalline Golem"], ["Nightmare Lord Xavius"]]],
    "C'Thun DH": [
      all: [
        ["First Portal to Argus"],
        ["Spawn of C'Thun", "Tentacle Lash", "Wyvern's Slumber"]
      ],
      all: [["Axe of Cenarius"], ["Tentacle Lash", "Wyvern's Slumber"]]
    ],
    "Void C'Thun DH": [
      all: [["Nightmare Lord Xavius"], ["Spawn of C'Thun", "Wyvern's Slumber"]]
    ],
    "N'Zoth DH": [all: [["Crystalline Golem"], ["Infestation"]]],
    "Void C'Thun DH": [
      all: [
        ["Wormriddled Wriggler"],
        ["Infestation", "Irida Sinseeker", "Sigil of the Seas"]
      ]
    ],
    "Raza DH": [all: [["Dark Bribe"], ["Infestation"]]],
    "Void C'Thun DH": [
      all: [["Nightmare Lord Xavius"], ["Gargantuan Slitherer", "Tentacle Lash"]],
      all: [["Spawn of C'Thun"], ["Wyvern's Slumber"]]
    ],
    "N'Zoth DH": [
      all: [
        ["First Portal to Argus"],
        ["Nightmare Lord Xavius", "Press the Advantage"]
      ],
      all: [["Crystalline Golem"], ["Ravenous Felhunter"]]
    ],
    "Void C'Thun DH": [
      all: [["Irida Sinseeker"], ["Grim Harvest", "Sigil of the Seas"]]
    ],
    "Void C'Thun DH": [
      all: [
        ["Gargantuan Slitherer"],
        ["Grim Harvest", "Illidari Studies", "Infestation", "Tentacle Lash", "Wyvern's Slumber"]
      ],
      all: [
        ["Tentacle Lash"],
        ["Grim Harvest", "Illidari Studies", "Infestation", "Wyvern's Slumber"]
      ],
      all: [
        ["Spawn of C'Thun"],
        ["Grim Harvest", "Illidari Studies", "Infestation"]
      ],
      all: [["Grim Harvest"], ["Wormriddled Wriggler"]],
      all: [["Illidari Studies"], ["Wyvern's Slumber"]]
    ],
    "N'Zoth DH": [all: [["Grim Harvest"], ["Titanic Thrasher"]]],
    "C'Thun DH": [
      all: [["Sigil of the Seas"], ["Broxigar's Last Stand", "Hungering Cavern"]]
    ],
    "Raza DH": [
      all: [
        ["Broxigar's Last Stand"],
        ["Axe of Cenarius", "First Portal to Argus"]
      ]
    ],
    "Void C'Thun DH": [all: [["Grim Harvest"], ["Wyvern's Slumber"]]],
    "C'Thun DH": [all: [["Grim Harvest"], ["Sigil of Hatching"]]],
    "Void C'Thun DH": [all: [["Nightmare Lord Xavius"], ["Sigil of the Seas"]]],
    "C'Thun DH": [all: [["Frontline Ironborn"], ["Grim Harvest"]]],
    "Void C'Thun DH": [all: [["Illidari Studies"], ["Nightmare Lord Xavius"]]],
    "Raza DH": [all: [["Hungering Cavern"], ["Infestation"]]],
    "C'Thun DH": [
      all: [["Sigil of the Seas"], ["Axe of Cenarius", "First Portal to Argus"]]
    ],
    "Raza DH": [all: [["Axe of Cenarius"], ["Grim Harvest"]]],
    "Void C'Thun DH": [all: [["Infestation"], ["Sigil of the Seas"]]],
    "Void C'Thun DH": [all: [["Grim Harvest"], ["Sigil of the Seas"]]],
    "Void C'Thun DH": [all: [["Grim Harvest"], ["Illidari Studies"]]],
    "Void C'Thun DH": [all: [["Grim Harvest"], ["Infestation"]]],
    "Void C'Thun DH": [all: [["Illidari Studies"], ["Infestation"]]]
  ]
  @wild_config [
    "XL Highlander DH": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Bartend-O-Bot"],
            [
              "Gunslinger Kurtrus",
              "Illidari Studies",
              "Kurtrus, Demon-Render",
              "Spirit of the Team",
              "Zephrys the Great"
            ]
          ],
          all: [
            ["Dangerous Cliffside"],
            ["Gunslinger Kurtrus", "Kurtrus, Demon-Render", "Mana Burn"]
          ],
          all: [
            ["First Portal to Argus"],
            ["Ball Hog", "Felfire Deadeye", "Fossil Fanatic"]
          ],
          all: [["Glide"], ["Fossil Fanatic", "Spirit of the Team"]],
          all: [
            ["Gunslinger Kurtrus"],
            ["Spawning Pool", "Warglaives of Azzinoth"]
          ],
          all: [
            ["Kurtrus, Demon-Render"],
            ["Illidari Studies", "Lorekeeper Polkelt"]
          ],
          all: [["Felfire Deadeye"], ["Spawning Pool"]],
          all: [["Mana Burn"], ["Spirit of the Team"]]
        ]
      ]
    ],
    "XL Il'gynoth DH": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Final Showdown"],
            ["Felscream Blast", "Mo'arg Artificer", "Tentacle Lash", "Unleash Fel"]
          ],
          all: [["Paraglide"], ["Unleash Fel"]]
        ]
      ]
    ],
    "Demon Demon Hunter": {[all: [["Priestess of Fury"], ["Spectral Sight"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Kurtrus, Demon-Render"], ["Mistake"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH": {[all: [["Celestial Projectionist"], ["Final Showdown"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Dangerous Cliffside"], ["Field of Strife"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander DH": {[all: [["Burning Heart"], ["E.T.C., Band Manager"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [["Halveria Darkraven"], ["Sigil of Time"]],
         all: [["Lion's Frenzy"], ["Second Portal to Argus"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Highlander DH": {[all: [["Ball Hog"], ["Gunslinger Kurtrus"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH":
      {[
         all: [
           ["Treasure Distributor"],
           ["Adrenaline Fiend", "Dangerous Cliffside", "Instrument Tech"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Demon Demon Hunter": {[all: [["Netherwalker"], ["Raging Felscreamer"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [["Felosophy"], ["Hungering Cavern"]],
         all: [["Halveria Darkraven"], ["Patches the Pilot"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Adrenaline Fiend"], ["Dispose of Evidence"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [["Feast of Souls"], ["Gaslight Gatekeeper"]],
         all: [["Sigil of Alacrity"], ["Wings of Hate (Rank 1)"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Demon Demon Hunter": {[all: [["Battlefiend"], ["Netherwalker"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [["SECURITY!!"], ["Dispose of Evidence", "Sigil of Silence"]],
         all: [["Dark Bribe"], ["Halveria Darkraven"]],
         all: [["Sigil of Silence"], ["Wings of Hate (Rank 2)"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Field of Strife"], ["Magnifying Glaive"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH": {[all: [["Quick Pick"], ["Wings of Hate (Rank 2)"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Adrenaline Fiend"], ["Dangerous Cliffside"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH": {[all: [["E.T.C., Band Manager"], ["Fierce Outsider"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Il'gynoth DH": {[all: [["Broxigar's Last Stand"], ["Street Trickster"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [
           ["Sigil of Silence"],
           ["Animated Broomstick", "Aranna, Thrill Seeker", "Remnant of Rage", "Zergling"]
         ],
         all: [
           ["Final Showdown"],
           ["SECURITY!!", "Wings of Hate (Rank 2)", "Zergling"]
         ],
         all: [
           ["Wings of Hate (Rank 1)"],
           ["Dispose of Evidence", "Sigil of Time", "Spawning Pool"]
         ],
         all: [["Zergling"], ["Animated Broomstick", "Broxigar"]],
         all: [["Dispose of Evidence"], ["Gaslight Gatekeeper"]],
         all: [["Feast of Souls"], ["Space Pirate"]],
         all: [["Quick Pick"], ["The Ceaseless Expanse"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Adrenaline Fiend"], ["Hozen Roughhouser"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [["E.T.C., Band Manager"], ["Animated Broomstick", "Feast of Souls"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Hozen Roughhouser"], ["Patches the Pilot"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [["Lion's Frenzy"], ["Broxigar's Last Stand", "Gaslight Gatekeeper"]],
         all: [["Remnant of Rage"], ["Zephrys the Great"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Hozen Roughhouser"], ["Treasure Distributor"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH":
      {[
         all: [
           ["Animated Broomstick"],
           [
             "Axe of Cenarius",
             "Broxigar's Last Stand",
             "Dark Bribe",
             "Dispose of Evidence",
             "Feast of Souls",
             "Felosophy",
             "Final Showdown",
             "First Portal to Argus",
             "Irebound Brute",
             "Mana Burn",
             "Patches the Pilot",
             "Prosecutor Mel'tranix",
             "Quick Pick",
             "Sigil of Alacrity",
             "Sigil of Time",
             "Spawning Pool",
             "Zephrys the Great"
           ]
         ],
         all: [
           ["Feast of Souls"],
           [
             "Aranna, Thrill Seeker",
             "Axe of Cenarius",
             "Dark Bribe",
             "Dispose of Evidence",
             "Felosophy",
             "Final Showdown",
             "First Portal to Argus",
             "Glide",
             "Irebound Brute",
             "Mana Burn",
             "Prosecutor Mel'tranix",
             "Remnant of Rage",
             "Sigil of Alacrity",
             "Sigil of Time",
             "Spawning Pool",
             "Zephrys the Great"
           ]
         ],
         all: [
           ["Spawning Pool"],
           [
             "Broxigar's Last Stand",
             "Dark Bribe",
             "Dispose of Evidence",
             "Felosophy",
             "Final Showdown",
             "Gaslight Gatekeeper",
             "Irebound Brute",
             "Paraglide",
             "Patches the Pilot",
             "Remnant of Rage",
             "Sigil of Alacrity",
             "Sigil of Silence",
             "Sigil of Time"
           ]
         ],
         all: [
           ["Remnant of Rage"],
           [
             "Dark Bribe",
             "Dispose of Evidence",
             "Final Showdown",
             "Irebound Brute",
             "Mana Burn",
             "Prosecutor Mel'tranix",
             "Quick Pick",
             "Sigil of Alacrity",
             "Sigil of Time"
           ]
         ],
         all: [
           ["Dispose of Evidence"],
           [
             "Double Jump",
             "Felosophy",
             "Fierce Outsider",
             "Final Showdown",
             "Irebound Brute",
             "Paraglide",
             "Sigil of Time"
           ]
         ],
         all: [
           ["Final Showdown"],
           [
             "Aranna, Thrill Seeker",
             "Axe of Cenarius",
             "Broxigar's Last Stand",
             "Irebound Brute",
             "Patches the Pilot",
             "Prosecutor Mel'tranix"
           ]
         ],
         all: [
           ["Irebound Brute"],
           ["Prosecutor Mel'tranix", "Quick Pick", "Rat Burglar", "Sigil of Time", "Wormriddled Wriggler"]
         ],
         all: [
           ["Felosophy"],
           ["Prosecutor Mel'tranix", "Quick Pick", "Rat Burglar", "Wormriddled Wriggler"]
         ],
         all: [
           ["Fierce Outsider"],
           ["Prosecutor Mel'tranix", "Rat Burglar", "Wormriddled Wriggler"]
         ],
         all: [["Prosecutor Mel'tranix"], ["Patches the Pilot", "Sigil of Time"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Reveler Demon Hunter": {[all: [["Mana Burn"], ["Masked Reveler"]]], [start_of_game: ["Prince Renathal"]]},
    "Pirate DH": {[all: [["Ship's Cannon"], ["Space Pirate"]]], [start_of_game: ["Prince Renathal"]]},
    "Fel DH": {[all: [["Fossil Fanatic"], ["Multi-Strike"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander DH": {[all: [["Far Watch Post"], ["First Portal to Argus"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Starship Demon Hunter": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Felfused Battery"],
            ["Arkonite Defense Crystal", "Shattershard Turret", "Tuskpiercer", "Warp Drive"]
          ],
          all: [["Shattershard Turret"], ["Warp Drive"]]
        ]
      ]
    ],
    "STD Void C'Thun DH":
      {[
         all: [
           ["Sigil of Cinder"],
           ["Cult Neophyte", "Devious Coyote", "Wormriddled Wriggler"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "STD C'Thun DH": {[all: [["Hungering Cavern"], ["Tentacle Lash"]]], [start_of_game: ["Prince Renathal"]]},
    "Other DH":
      {[
         all: [
           ["Grim Harvest"],
           ["Crimson Sigil Runner", "Sigil of Alacrity", "Spectral Sight"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander DH": {[all: [["Gorishi Stinger"], ["Infestation"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander DH": {[all: [["Gunslinger Kurtrus"], ["Zephrys the Great"]]], [start_of_game: ["Prince Renathal"]]},
    "Starship Demon Hunter":
      {[
         all: [
           ["Arkonite Defense Crystal"],
           ["Shattershard Turret", "Tuskpiercer", "Warp Drive"]
         ],
         all: [["Shattershard Turret"], ["Warp Drive"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Token DH": {[all: [["Final Showdown"], ["Quick Pick", "Sigil of Time"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH": {[all: [["Final Showdown"], ["Mana Burn"]]], [start_of_game: ["Prince Renathal"]]},
    "Token DH": {[all: [["Dark Bribe"], ["Final Showdown"]]], [start_of_game: ["Prince Renathal"]]},
    "Fel DH":
      {[
         all: [["Sigil of Alacrity"], ["Air Guitarist", "Spawn of C'Thun"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Token DH": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Broxigar's Last Stand"], ["Final Showdown"]]]
      ]
    ],
    "STD C'Thun DH":
      {[
         all: [["Gargantuan Slitherer"], ["Spawn of C'Thun"]],
         all: [["Sigil of the Seas"], ["Tentacle Lash"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Other DH": {[all: [["Sigil of Cinder"], ["Sigil of the Seas"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander DH": {[all: [["Mana Burn"], ["Prosecutor Mel'tranix"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Fel DH": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Chaos Strike"], ["Fan the Hammer", "Sigil of Cinder"]]]
      ]
    ],
    "Other DH": {[all: [["Crimson Sigil Runner"], ["Spectral Sight"]]], [start_of_game: ["Prince Renathal"]]},
    "Other DH": {[all: [["First Portal to Argus"], ["Sigil of the Seas"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Il'gynoth DH": {[all: [["Dark Bribe"], ["First Portal to Argus"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander DH": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Axe of Cenarius"], ["First Portal to Argus"]]]
      ]
    ],
    "Highlander DH":
      {[
         all: [["Mana Burn"], ["Axe of Cenarius", "First Portal to Argus"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Splendiferous Whizbang": {[all: [["Chaos Strike"], ["Illidari Studies"]]], [start_of_game: ["Prince Renathal"]]},
    "Other DH": {[all: [["Attentive Tender"], ["F3TCH3R"]]], [start_of_game: ["Prince Renathal"]]},
    "Highlander DH": {[all: [["Axe of Cenarius"], ["First Portal to Argus"]]], [start_of_game: ["Prince Renathal"]]}
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DH")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DH")
  end
end
