# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DruidArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Druid": ["Restore the Wild"],
    # "Imbue Druid": [
    #   "Bitterbloom Knight",
    #   "Charred Chameleon",
    #   "Dreambound Disciple",
    #   "Flutterwing Guardian",
    #   "Hamuul Runetotem",
    #   "Malorne the Waywatcher",
    #   "Petal Picker",
    #   "Resplendent Dreamweaver"
    # ],
    "Chef Druid": [
      {:start_of_game, ["Chef Neth'rek"]},
      "Chef Neth'rek"
    ],
    "Chef Druid": [
      "Spiteful Chef"
    ],
    "Imbue Druid": [
      {:start_of_game, ["Hamuul Runetotem"]}
    ],
    "Imbue Druid": [
      ["Hamuul Runetotem"]
    ],
    # 5.5
    # auto gen
    "Deathrattle Druid": [
      all: [["Defias Smuggler"], ["Mo'arg Forgefiend"]],
      all: [["Lethal Recipe"], ["Taelan Fordring"]]
    ],
    "Beast Druid": [all: [["Bloatray"], ["Titan Sized"]]],
    "Deathrattle Druid": [
      all: [
        ["Blob of Tar"],
        [
          "Azshara's Triumph",
          "Bashana Runetotem",
          "Dirty Rat",
          "Endangered Dodo",
          "Lethal Recipe",
          "Lifebloom",
          "Mo'arg Forgefiend",
          "Tranquil Treant",
          "Whelp of the Infinite"
        ]
      ],
      all: [
        ["Gemstone Hoarder"],
        ["Azshara's Triumph", "Horn of Plenty", "Press the Advantage", "Shaladrassil"]
      ],
      all: [
        ["Taelan Fordring"],
        ["Deathblossom", "N'Zoth, Dream's End", "Twilight Timereaver"]
      ],
      all: [["Endbringer Umbra"], ["Deathblossom", "Meadowstrider"]],
      all: [["Illusory Greenwing"], ["N'Zoth, Dream's End", "Story of Barnabus"]],
      all: [["Acceleration Aura"], ["Cairne Bloodhoof"]],
      all: [["Ammunae"], ["Wrath"]],
      all: [["Meadowstrider"], ["Tranquil Treant"]],
      all: [["Mo'arg Forgefiend"], ["Whelp of the Infinite"]]
    ],
    "C'Thun Druid": [
      all: [
        ["C'Thun, Eye of the Empire"],
        ["The Well of Eternity", "Welcome Home!"]
      ],
      all: [["Gargantuan Slitherer"], ["The Well of Eternity"]]
    ],
    "Deathrattle Druid": [all: [["Blob of Tar"], ["Story of Barnabus"]]],
    "Beast Druid": [all: [["Freya, Emerald Architect"], ["Titan Sized"]]],
    "Deathrattle Druid": [
      all: [["Ammunae"], ["Illusory Greenwing", "Lifebloom"]],
      all: [["N'Zoth, Dream's End"], ["Azshara's Triumph", "Story of Barnabus"]],
      all: [["Krona, Keeper of Eons"], ["Meadowstrider"]]
    ],
    "Merithra Druid": [
      all: [
        ["Darkscale Broodmother"],
        ["Merithra of the Dream", "Y'Shaarj, Titan Bane"]
      ]
    ],
    "Deathrattle Druid": [
      all: [
        ["Whelp of the Infinite"],
        ["Ammunae", "Crystalline Golem", "Deathblossom"]
      ],
      all: [["Staff of Trickery"], ["Mo'arg Forgefiend", "N'Zoth, Dream's End"]],
      all: [["Ammunae"], ["Shaladrassil"]]
    ],
    "Deathrattle Druid": [all: [["Efflorescence"], ["Mo'arg Forgefiend"]]],
    "Merithra Druid": [
      all: [
        ["Darkscale Broodmother"],
        ["Aetherial Kindling", "Nightmare Lord Xavius", "Shaladrassil"]
      ],
      all: [["Broodwatcher"], ["Rustrot Viper"]]
    ],
    "Attack Druid": [all: [["Infest the Scullery"], ["Shaladrassil"]]],
    "C'Thun Druid": [all: [["C'Thun, Eye of the Empire"], ["Horn of Plenty"]]],
    "Deathrattle Druid": [
      all: [
        ["Ammunae"],
        ["Aetherial Kindling", "Defias Smuggler", "Staff of Trickery", "Titanic Thrasher"]
      ],
      all: [
        ["Mo'arg Forgefiend"],
        ["Aetherial Kindling", "Ebb and Flow", "Press the Advantage"]
      ],
      all: [["Defias Smuggler"], ["Elise the Navigator", "Underking"]],
      all: [["Blob of Tar"], ["Nightmare Lord Xavius"]],
      all: [["Elise the Navigator"], ["Gemstone Hoarder"]]
    ],
    "C'Thun Druid": [all: [["Heartroot Stones"], ["Spawn of C'Thun"]]],
    "Beast Druid": [all: [["Freya, Emerald Architect"], ["Spiderling"]]],
    "Deathrattle Druid": [all: [["Ammunae"], ["Press the Advantage"]]],
    "Merithra Druid": [
      all: [["Broodwatcher"], ["Shaladrassil"]],
      all: [["Darkscale Broodmother"], ["Wickerfang"]]
    ],
    "C'Thun Druid": [
      all: [["C'Thun, Eye of the Empire"], ["Nightmare Lord Xavius"]],
      all: [["Gargantuan Slitherer"], ["Horn of Plenty"]]
    ],
    "Deathrattle Druid": [
      all: [["Ammunae"], ["Elise the Navigator"]],
      all: [["Blob of Tar"], ["Heartroot Stones"]],
      all: [["Crystalline Golem"], ["Illusory Greenwing"]]
    ],
    "Deathrattle Druid": [all: [["Ammunae"], ["Bashana Runetotem"]]],
    "Merithra Druid": [all: [["Broodwatcher"], ["Wickerfang"]]],
    "Beast Druid": [all: [["Primordial Bear"], ["Y'Shaarj, Titan Bane"]]],
    "Deathrattle Druid": [all: [["Crystalline Golem"], ["Mo'arg Forgefiend"]]],
    "C'Thun Druid": [
      all: [
        ["Zin-Azshari"],
        ["C'Thun, Eye of the Empire", "Gargantuan Slitherer", "Spawn of C'Thun"]
      ],
      all: [["Gargantuan Slitherer"], ["Nightmare Lord Xavius"]]
    ],
    "C'Thun Druid": [all: [["Lady Azshara"], ["Spawn of C'Thun"]]],
    "Merithra Druid": [all: [["Broodwatcher"], ["Merithra of the Dream"]]],
    "Attack Druid": [all: [["Infest the Scullery"], ["Wickerfang"]]],
    "Deathrattle Druid": [
      all: [["Ammunae"], ["Azshara's Triumph"]],
      all: [["Deathblossom"], ["Meadowstrider"]]
    ],
    "Deathrattle Druid": [
      all: [["Ammunae"], ["Oaken Summons"]],
      all: [["N'Zoth, Dream's End"], ["Ysera, Emerald Aspect"]]
    ],
    "Merithra Druid": [all: [["Darkscale Broodmother"], ["Elise the Navigator"]]],
    "Merithra Druid": [all: [["Broodwatcher"], ["Horn of Plenty"]]],
    "Krona Druid": [all: [["Krona, Keeper of Eons"], ["Murozond, Unbounded"]]],
    "Merithra Druid": [all: [["Darkscale Broodmother"], ["Fyrakk the Blazing"]]],
    "Azshara Druid": [all: [["Heartroot Stones"], ["Welcome Home!"]]],
    "C'Thun Druid": [all: [["Amirdrassil"], ["Gargantuan Slitherer"]]],
    "Merithra Druid": [all: [["Bashana Runetotem"], ["Darkscale Broodmother"]]],
    "Deathrattle Druid": [all: [["Blob of Tar"], ["Ebb and Flow"]]],
    "Beast Druid": [all: [["Power Tiger"], ["Spiderling"]]],
    "Beast Druid": [all: [["Power Tiger"], ["Primordial Bear"]]],
    "Deathrattle Druid": [all: [["Crystalline Golem"], ["Deathblossom"]]],
    "Merithra Druid": [all: [["Press the Advantage"], ["Treant"]]],
    "C'Thun Druid": [
      all: [["Spawn of C'Thun"], ["Amirdrassil", "Horn of Plenty"]]
    ],
    "Merithra Druid": [all: [["Darkscale Broodmother"], ["Horn of Plenty"]]],
    "Beast Druid": [all: [["Raptor Herald"], ["Titan Sized"]]],
    "Deathrattle Druid": [all: [["Ammunae"], ["Deathblossom"]]],
    "Deathrattle Druid": [
      all: [["Ammunae"], ["Efflorescence"]],
      all: [["Ebb and Flow"], ["N'Zoth, Dream's End"]]
    ],
    "Merithra Druid": [all: [["Broodwatcher"], ["Press the Advantage"]]],
    "Deathrattle Druid": [
      all: [["Aetherial Kindling"], ["Krona, Keeper of Eons"]]
    ],
    "Beast Druid": [all: [["Foraging Slyvern"], ["Primordial Bear"]]],
    "Attack Druid": [all: [["Bashana Runetotem"], ["Infest the Scullery"]]],
    "Merithra Druid": [all: [["Merithra of the Dream"], ["Y'Shaarj, Titan Bane"]]],
    "Deathrattle Druid": [all: [["Ammunae"], ["Dirty Rat"]]],
    "Merithra Druid": [all: [["Darkscale Broodmother"], ["Waveshaping"]]],
    "Deathrattle Druid": [
      all: [["Blob of Tar"], ["Acceleration Aura", "Seismopod"]],
      all: [["Mo'arg Forgefiend"], ["Waveshaping"]]
    ],
    "Beast Druid": [all: [["Power Tiger"], ["Titan Sized"]]],
    "C'Thun Druid": [all: [["Gargantuan Slitherer"], ["Waveshaping"]]],
    "Deathrattle Druid": [
      all: [
        ["Ammunae"],
        ["Crystalline Golem", "Heartroot Stones", "Horn of Plenty"]
      ],
      all: [["Deathblossom"], ["Krona, Keeper of Eons", "Story of Barnabus"]],
      all: [["Meadowstrider"], ["Crystalline Golem", "Staff of Trickery"]]
    ],
    "Deathrattle Druid": [
      all: [
        ["Gemstone Hoarder"],
        ["Amirdrassil", "Crystalline Golem", "Heartroot Stones", "Innervate", "Nightmare Lord Xavius", "Waveshaping"]
      ]
    ],
    "Merithra Druid": [all: [["Acceleration Aura"], ["Darkscale Broodmother"]]],
    "Attack Druid": [all: [["Infest the Scullery"], ["Ysera, Emerald Aspect"]]],
    "Azshara Druid": [all: [["Escape Artist"], ["Oaken Summons"]]],
    "Attack Druid": [all: [["Ebb and Flow"], ["Infest the Scullery"]]],
    "C'Thun Druid": [all: [["Spawn of C'Thun"], ["Waveshaping"]]],
    "Beast Druid": [all: [["Evergreen Stag"], ["Primordial Bear"]]],
    "Merithra Druid": [all: [["Deathblossom"], ["Fyrakk the Blazing"]]],
    "Beast Druid": [all: [["Endangered Dodo"], ["Titan Sized"]]],
    "Deathrattle Druid": [all: [["Azshara's Triumph"], ["Deathblossom"]]],
    "Deathrattle Druid": [all: [["Deathblossom"], ["Underking"]]],
    "Merithra Druid": [
      all: [["Broodwatcher"], ["Staff of Trickery"]],
      all: [["Horn of Plenty"], ["Merithra of the Dream"]]
    ],
    "Deathrattle Druid": [all: [["Azshara's Triumph"], ["Crystalline Golem"]]],
    "Azshara Druid": [all: [["Briarspawn Drake"], ["Welcome Home!"]]],
    "Merithra Druid": [
      all: [["Broodwatcher"], ["Naralex, Herald of the Flights"]]
    ],
    "Merithra Druid": [all: [["Dirty Rat"], ["Fyrakk the Blazing"]]],
    "Beast Druid": [
      all: [
        ["Spiderling"],
        ["Curious Grimlynx", "Evergreen Stag", "Foraging Slyvern", "Titan Sized"]
      ]
    ],
    "Attack Druid": [all: [["Felwood Treant"], ["Infest the Scullery"]]],
    "Beast Druid": [all: [["Curious Grimlynx"], ["Steward of the Vale"]]],
    "Deathrattle Druid": [
      all: [["Crystalline Golem"], ["Aetherial Kindling", "Story of Barnabus"]],
      all: [["Ammunae"], ["Story of Barnabus"]]
    ],
    "Beast Druid": [all: [["Foraging Slyvern"], ["Titan Sized"]]],
    "Deathrattle Druid": [
      all: [["Acceleration Aura"], ["Illusory Greenwing", "Mo'arg Forgefiend"]],
      all: [["Felwood Treant"], ["Illusory Greenwing"]]
    ],
    "Merithra Druid": [all: [["Horn of Plenty"], ["Rustrot Viper"]]],
    "Attack Druid": [all: [["Shaladrassil"], ["Spiderling"]]],
    "Deathrattle Druid": [
      all: [["Deathblossom"], ["Seismopod"]],
      all: [["Felwood Treant"], ["Taelan Fordring"]]
    ],
    "Beast Druid": [all: [["Curious Grimlynx"], ["Nightmare Lord Xavius"]]],
    "Deathrattle Druid": [
      all: [["Meadowstrider"], ["Innervate", "Underking"]],
      all: [["Amirdrassil"], ["Deathblossom"]]
    ],
    "Azshara Druid": [all: [["Lifebloom"], ["Zin-Azshari"]]],
    "Beast Druid": [all: [["Primordial Bear"], ["Staff of Trickery"]]],
    "Deathrattle Druid": [all: [["Aetherial Kindling"], ["Seismopod"]]],
    "Merithra Druid": [all: [["Broodwatcher"], ["Elise the Navigator"]]],
    "Deathrattle Druid": [
      all: [
        ["Crystalline Golem"],
        ["Contingency", "Krona, Keeper of Eons", "Seismopod"]
      ],
      all: [["Ammunae"], ["Amirdrassil", "Ebb and Flow"]],
      all: [["Deathblossom"], ["Twilight Timereaver"]]
    ],
    "Merithra Druid": [all: [["Crystalline Golem"], ["Y'Shaarj, Titan Bane"]]],
    "Beast Druid": [all: [["Acceleration Aura"], ["Power Tiger"]]],
    "Deathrattle Druid": [all: [["Aetherial Kindling"], ["Deathblossom"]]],
    "Attack Druid": [all: [["Spider Rider"], ["Widow's Bite"]]],
    "C'Thun Druid": [all: [["Innervate"], ["Spawn of C'Thun"]]],
    "Merithra Druid": [
      all: [["Aetherial Kindling"], ["Horn of Plenty"]],
      all: [["Broodwatcher"], ["Ebb and Flow"]],
      all: [["Shaladrassil"], ["Wickerfang"]]
    ],
    "Beast Druid": [all: [["Innervate"], ["Titan Sized"]]],
    "Deathrattle Druid": [
      all: [["Ammunae"], ["Acceleration Aura", "Nightmare Lord Xavius"]]
    ],
    "Azshara Druid": [all: [["Felwood Treant"], ["Zin-Azshari"]]],
    "Deathrattle Druid": [all: [["Heartroot Stones"], ["Seismopod"]]],
    "Merithra Druid": [all: [["Broodwatcher"], ["Felwood Treant"]]],
    "Deathrattle Druid": [
      all: [["Deathblossom"], ["Heartroot Stones", "Staff of Trickery"]],
      all: [["Dirty Rat"], ["Underking"]]
    ],
    "Merithra Druid": [all: [["Fyrakk the Blazing"], ["Horn of Plenty"]]],
    "Deathrattle Druid": [all: [["Deathblossom"], ["Nightmare Lord Xavius"]]],
    "Beast Druid": [all: [["Primordial Bear"], ["Waveshaping"]]],
    "Deathrattle Druid": [
      all: [
        ["Deathblossom"],
        ["Acceleration Aura", "Felwood Treant", "Waveshaping"]
      ],
      all: [
        ["Seismopod"],
        ["Elise the Navigator", "Twilight Timereaver", "Underking"]
      ],
      all: [["Horn of Plenty"], ["Oaken Summons"]]
    ],
    "Azshara Druid": [all: [["Efflorescence"], ["Lady Azshara"]]],
    "Merithra Druid": [
      all: [["Dirty Rat"], ["Wickerfang"]],
      all: [["Elise the Navigator"], ["Horn of Plenty"]]
    ],
    "Deathrattle Druid": [all: [["Azshara's Triumph"], ["Twilight Timereaver"]]],
    "Merithra Druid": [all: [["Twilight Timereaver"], ["Wickerfang"]]],
    "Beast Druid": [all: [["Acceleration Aura"], ["Curious Grimlynx"]]],
    "Deathrattle Druid": [
      all: [
        ["Crystalline Golem"],
        ["Amirdrassil", "Nightmare Lord Xavius", "Waveshaping"]
      ],
      all: [["Seismopod"], ["Press the Advantage", "Staff of Trickery"]],
      all: [["Azshara's Triumph"], ["Staff of Trickery"]],
      all: [["Felwood Treant"], ["Lethal Recipe"]]
    ],
    "Deathrattle Druid": [
      all: [["Crystalline Golem"], ["Acceleration Aura", "Staff of Trickery"]]
    ],
    "Deathrattle Druid": [all: [["Crystalline Golem"], ["Felwood Treant"]]],
    "Merithra Druid": [all: [["Dirty Rat"], ["Horn of Plenty"]]],
    "Krona Druid": [all: [["Heartroot Stones"], ["Krona, Keeper of Eons"]]],
    "Beast Druid": [
      all: [["Freya, Emerald Architect"], ["Nightmare Lord Xavius"]]
    ],
    "Deathrattle Druid": [
      all: [["Story of Barnabus"], ["Heartroot Stones", "Staff of Trickery"]],
      all: [["Nightmare Lord Xavius"], ["Seismopod"]]
    ],
    "Merithra Druid": [
      all: [
        ["Horn of Plenty"],
        ["Bashana Runetotem", "Naralex, Herald of the Flights", "Wickerfang"]
      ],
      all: [["Nightmare Lord Xavius"], ["Fyrakk the Blazing", "Wickerfang"]]
    ],
    "Deathrattle Druid": [
      all: [
        ["Story of Barnabus"],
        ["Ebb and Flow", "Felwood Treant", "Nightmare Lord Xavius", "Waveshaping"]
      ],
      all: [["Heartroot Stones"], ["Nightmare Lord Xavius", "Staff of Trickery"]],
      all: [["Staff of Trickery"], ["Underking"]]
    ],
    "Deathrattle Druid": [
      all: [["Underking"], ["Nightmare Lord Xavius", "Twilight Timereaver"]]
    ],
    "Attack Druid": [
      all: [["Ysera, Emerald Aspect"], ["Spider Rider", "Spiderling"]]
    ],
    "Merithra Druid": [
      all: [
        ["Naralex, Herald of the Flights"],
        ["Elise the Navigator", "Wickerfang"]
      ],
      all: [["Felwood Treant"], ["Merithra of the Dream"]]
    ],
    "Attack Druid": [all: [["Acceleration Aura"], ["Spider Rider"]]],
    "Deathrattle Druid": [
      all: [
        ["Underking"],
        ["Acceleration Aura", "Heartroot Stones", "Waveshaping"]
      ]
    ],
    "Attack Druid": [all: [["Elise the Navigator"], ["Spiderling"]]],
    "Deathrattle Druid": [all: [["Aetherial Kindling"], ["Staff of Trickery"]]],
    "Merithra Druid": [
      all: [["Elise the Navigator"], ["Wickerfang"]],
      all: [["Horn of Plenty"], ["Staff of Trickery"]]
    ],
    "Attack Druid": [
      all: [["Amirdrassil"], ["Secret Ingredient"]],
      all: [["Ebb and Flow"], ["Spiderling"]]
    ],
    "Merithra Druid": [all: [["Bashana Runetotem"], ["Wickerfang"]]],
    "Deathrattle Druid": [all: [["Nightmare Lord Xavius"], ["Staff of Trickery"]]],
    "Merithra Druid": [
      all: [["Fyrakk the Blazing"], ["Naralex, Herald of the Flights"]]
    ],
    "Deathrattle Druid": [all: [["Felwood Treant"], ["Heartroot Stones"]]],
    "Deathrattle Druid": [all: [["Efflorescence"], ["Felwood Treant"]]],
    "Deathrattle Druid": [all: [["Heartroot Stones"], ["Waveshaping"]]],
    "Beast Druid": [
      all: [["Acceleration Aura"], ["Steward of the Vale"]],
      all: [["Foraging Slyvern"], ["Waveshaping"]]
    ],
    "Deathrattle Druid": [all: [["Acceleration Aura"], ["Seismopod"]]],
    "Merithra Druid": [all: [["Amirdrassil"], ["Horn of Plenty"]]],
    "Deathrattle Druid": [
      all: [["Amirdrassil"], ["Nightmare Lord Xavius", "Waveshaping"]]
    ],
    "Deathrattle Druid": [all: [["Aetherial Kindling"], ["Waveshaping"]]],
    "Attack Druid": [all: [["Press the Advantage"], ["Secret Ingredient"]]],
    "Merithra Druid": [all: [["Staff of Trickery"], ["Wickerfang"]]],
    "Deathrattle Druid": [
      all: [["Acceleration Aura"], ["Amirdrassil", "Staff of Trickery"]],
      all: [["Twilight Timereaver"], ["Staff of Trickery", "Waveshaping"]]
    ],
    "Loh-cky Druid": [all: [["Contingency"], ["Innervate"]]],
    "Merithra Druid": [all: [["Horn of Plenty"], ["Press the Advantage"]]],
    "Merithra Druid": [all: [["Ebb and Flow"], ["Horn of Plenty"]]],
    "Beast Druid": [all: [["Freya, Emerald Architect"], ["Waveshaping"]]],
    "Deathrattle Druid": [
      all: [["Nightmare Lord Xavius"], ["Ebb and Flow", "Waveshaping"]],
      all: [["Acceleration Aura"], ["Azshara's Triumph"]]
    ],
    "Deathrattle Druid": [all: [["Felwood Treant"], ["Nightmare Lord Xavius"]]],
    "Merithra Druid": [all: [["Acceleration Aura"], ["Wickerfang"]]],
    "Deathrattle Druid": [
      all: [["Acceleration Aura"], ["Waveshaping"]],
      all: [["Amirdrassil"], ["Innervate"]]
    ],
    "Deathrattle Druid": [
      all: [["Felwood Treant"], ["Innervate", "Staff of Trickery", "Waveshaping"]],
      all: [["Ebb and Flow"], ["Elise the Navigator", "Waveshaping"]],
      all: [["Staff of Trickery"], ["Innervate", "Waveshaping"]],
      all: [["Acceleration Aura"], ["Press the Advantage"]]
    ],
    "Deathrattle Druid": [all: [["Acceleration Aura"], ["Felwood Treant"]]]
  ]
  @wild_config [
    "Barnes Druid": ["Starfire"],
    "Mill Druid": ["Dew Process", "Selfish Shellfish"],
    "Mecha'thun Druid": ["Mecha'thun"],
    "Token Druid": ["Aeroponics"],
    "Highlander Druid": ["Alexstrasza", "Rheastrasza", "The Curator", "Warmaster Blackhorn"],
    "Dragon Druid": ["Razormane Battleguard"],
    "Linecracker Druid": ["Linecracker"],
    "XL Dragon Druid": ["Tormented Dreadwing", "Ysera the Dreamer"],
    "XL Deios Druid": ["Jepetto Joybuzz", "Kun the Forgotten King"],
    "Barnes Druid": ["Magical Dollhouse"],
    "Champions Druid": ["Barnes"],
    "XL HL Tog Druid": ["Azalina Soulthief", "King Togwaggle"],
    "XL Dragon Druid": ["Summer Flowerchild"],
    "Highlander Druid": ["Trogg Gemtosser", "Twilight Timereaver"],
    "Mill Druid": ["Branching Paths", "Rising Waves"],
    "Highlander Druid": ["Smothering Starfish"],
    "Mecha'thun Druid": ["Germination"],
    "Astral Druid": ["Astral Communion"],
    "Highlander Druid": ["Loatheb"],
    "XL HL Tog Druid": ["Blademaster Okani"],
    "Linecracker Druid": ["Moonfire"],
    "Highlander Druid": ["Razorscale"],
    "Boar OTK Druid": ["Stormpike Quartermaster"],
    "Mill Druid": ["Floop's Glorious Gloop", "Mistah Vistah"],
    "XL Dragon Druid": ["Whelp of the Infinite"],
    "Highlander Druid": ["Death Beetle"],
    "XL HL Tog Druid": ["Tortollan Traveler"],
    "OTK Druid": ["Nightshade Bud"],
    "XL Therazane Druid": ["Stone Drake"],
    "XL Deios Druid": ["Chrono-Lord Deios"],
    "Highlander Druid": [
      "Brann Bronzebeard",
      "Breath of Dreams",
      "Desert Nestmatron",
      "Dirty Rat",
      "Reno Jackson",
      "Reno, Lone Ranger",
      "Splish-Splash Whelp",
      "Zephrys the Great"
    ],
    "Splendiferous Whizbang": ["Moment of Discovery"],
    "Old Aggro Druid": [
      "Herald of Nature",
      "Irondeep Trogg",
      "Jerry Rig Carpenter",
      "Mark of the Wild",
      "Peasant",
      "Planted Evidence",
      "Vicious Slitherspear"
    ],
    "Token Druid": ["Sow the Soil"],
    "Mill Druid": ["Naturalize", "Poison Seeds"],
    "OTK Druid": ["Overflow"],
    "Champions Druid": ["Champions of Azeroth"],
    "STD Merithra Druid": ["Darkscale Broodmother", "Ebb and Flow"],
    "Mecha'thun Druid": ["Wrath"],
    "Star Grazer Druid": ["Death Blossom Whomper"],
    "Questline Druid": ["Lost in the Park"],
    "XL Deios Druid": ["Astalor Bloodsworn"],
    "XL HL Tog Druid": ["Amirdrassil", "Skulking Geist"],
    "Mill Druid": ["Theotar, the Mad Duke"],
    "XL Deios Druid": ["Juicy Psychmelon"],
    "Mill Druid": ["Spreading Plague"],
    "OTK Druid": ["Ultimate Infestation"],
    "Champions Druid": ["Swipe"],
    "Linecracker Druid": ["Capture Coldtooth Mine", "Lifebinder's Gift"],
    "Mill Druid": ["Bob the Bartender", "Heartroot Stones", "Sleepy Resident"],
    "Highlander Druid": ["Jungle Giants"],
    "Star Grazer Druid": ["Hedge Maze"],
    "Highlander Druid": ["Acceleration Aura"],
    "Mill Druid": ["Frost Lotus Seedling"],
    "Barnes Druid": ["Bottomless Toy Chest"],
    "Mecha'thun Druid": ["Trail Mix"],
    "Mill Druid": ["E.T.C., Band Manager", "Moonlit Guidance", "New Heights", "Sir Finley, Sea Guide"],
    "Champions Druid": ["Pendant of Earth", "Solar Eclipse"],
    "Highlander Druid": [
      "Malfurion's Gift",
      "Nourish",
      "Overgrowth",
      "Prince Renathal",
      "Wild Growth",
      "Wildheart Guff"
    ],
    "Mill Druid": ["Invigorate"],
    "Highlander Druid": ["Dark Peddler", "Darkbomb", "Forgotten Torch", "Shadow Word: Pain"],
    "Mill Druid": ["Aquatic Form"],
    "Highlander Druid": ["Waveshaping"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Druid")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Druid")
  end
end
