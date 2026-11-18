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
    "Token Broxigar DH": [
      "Broxigar's Last Stand",
      "Dispose of Evidence",
      "Felosophy",
      "Final Showdown",
      "Irebound Brute",
      "Patches the Pilot"
    ],
    "XL Highlander DH": ["Gunslinger Kurtrus", "Snake Eyes"],
    "XL Fel DH": ["Illidan's Gift"],
    "STD Quest DH": ["Questing Assistant"],
    "LC Quest DH": ["Unleash the Colossus"],
    "Fel DH": ["Fel Barrage", "Scorchreaver", "Unleash Fel"],
    "STD Demon Hunter": ["Chaos Strike"]
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
