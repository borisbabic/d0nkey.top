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
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mastermind Yogg-Saron"], ["Ultimate Infestation"]]]
      ]
    ],
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Cursed Disciple"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dew Process"], ["Glacial Shard"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Elise the Enlightened"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Champions of Azeroth"], ["Survival of the Fittest"]]]
      ]
    ],
    "Old Aggro Druid":
      {[
         all: [["Crooked Cook"], ["Thorngrowth Sentries"]],
         all: [["Mark of the Wild"], ["Vicious Slitherspear"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Construct Pylons"], ["Mistah Vistah"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid": {[all: [["Life from Death"], ["Reforestation"]]], [start_of_game: ["Prince Renathal"]]},
    "Barnes Druid": {[all: [["Moonbeam"], ["Starfire"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid": {[all: [["Efflorescence"], ["Mecha'thun"]]], [start_of_game: ["Prince Renathal"]]},
    "Linecracker Druid":
      {[
         all: [["Linecracker"], ["Black Market Auctioneer", "Innervate"]],
         all: [["Kil'jaeden"], ["Lightning Bloom"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid":
      {[
         all: [["Fungal Fortunes"], ["Wrath"]],
         all: [["Lady Anacondra"], ["Sphere of Sapience"]],
         all: [["Lightning Bloom"], ["Twig of the World Tree"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Go with the Flow"], ["Moonbeam"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Selfish Shellfish"], ["Steamcleaner"]]]
      ]
    ],
    "Tog Druid": {[all: [["BEEEES!!!"], ["King Togwaggle"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid": {[all: [["Lady Anacondra"], ["Mecha'thun"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid":
      {[
         all: [
           ["Go with the Flow"],
           [
             "Aquatic Form",
             "Biology Project",
             "Black Market Auctioneer",
             "Capture Coldtooth Mine",
             "Construct Pylons",
             "Ethereal Augmerchant",
             "Innervate",
             "Lifebinder's Gift",
             "Lightning Bloom",
             "Moonfire",
             "Photon Cannon",
             "Waveshaping"
           ]
         ],
         all: [
           ["Ethereal Augmerchant"],
           [
             "Black Market Auctioneer",
             "Capture Coldtooth Mine",
             "Construct Pylons",
             "Innervate",
             "Lifebinder's Gift",
             "Lightning Bloom",
             "Photon Cannon",
             "Waveshaping"
           ]
         ],
         all: [
           ["Photon Cannon"],
           ["Black Market Auctioneer", "Innervate", "Lifebinder's Gift", "Lightning Bloom", "Living Roots"]
         ],
         all: [["Construct Pylons"], ["Innervate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Animated Broomstick"], ["Kun the Forgotten King"]]]
      ]
    ],
    "Mecha'thun Druid":
      {[
         all: [
           ["Fungal Fortunes"],
           [
             "Aquatic Form",
             "Biology Project",
             "Frost Lotus Seedling",
             "Germination",
             "Heartroot Stones",
             "Invigorate",
             "Lady Anacondra",
             "Lightning Bloom",
             "Nourish",
             "Pendant of Earth",
             "Reforestation",
             "Solar Eclipse",
             "Waveshaping"
           ]
         ],
         all: [
           ["Germination"],
           [
             "Aquatic Form",
             "Biology Project",
             "Frost Lotus Seedling",
             "Heartroot Stones",
             "Invigorate",
             "Lady Anacondra",
             "Lightning Bloom",
             "Nourish",
             "Pendant of Earth",
             "Reforestation",
             "Solar Eclipse",
             "Waveshaping"
           ]
         ],
         all: [
           ["Lady Anacondra"],
           [
             "Aquatic Form",
             "Biology Project",
             "Frost Lotus Seedling",
             "Heartroot Stones",
             "Invigorate",
             "Lightning Bloom",
             "Nourish",
             "Pendant of Earth",
             "Reforestation",
             "Solar Eclipse",
             "Waveshaping"
           ]
         ],
         all: [
           ["Reforestation"],
           ["Frost Lotus Seedling", "Pendant of Earth", "Solar Eclipse"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Champions of Azeroth"], ["Ultimate Infestation"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Elise the Enlightened"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Kun the Forgotten King"],
            ["Chrono-Lord Deios", "Innervate", "Jepetto Joybuzz"]
          ]
        ]
      ]
    ],
    "Champions Druid": {[all: [["Barnes"], ["Invigorate"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Reno Jackson"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dew Process"], ["Floop's Glorious Gloop"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Selfish Shellfish"], ["Sleepy Resident"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Acceleration Aura", "Rheastrasza"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Tortollan Traveler"],
            ["Brann Bronzebeard", "Cult Neophyte", "Speaker Stomper"]
          ]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Splish-Splash Whelp"],
            ["Reno Jackson", "Rheastrasza", "Zephrys the Great"]
          ]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dew Process"], ["Sleepy Resident"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Skulking Geist"]]]
      ]
    ],
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cursed Disciple"], ["Jungle Giants"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Desert Nestmatron"], ["Efflorescence"]],
          all: [["Speaker Stomper"], ["Summer Flowerchild"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Selfish Shellfish"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ysiel Windsinger"], ["Aviana", "Champions of Azeroth"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aviana"], ["Jepetto Joybuzz"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Chrono-Lord Deios"], ["Skulking Geist"]]]
      ]
    ],
    "XL Yogg Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Murozond, Unbounded"], ["Summer Flowerchild"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Aquatic Form"], ["Photon Cannon"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Tortollan Traveler"]]]
      ]
    ],
    "Barnes Druid": {[all: [["Magical Dollhouse"], ["Moonlit Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno, Lone Ranger"], ["Splish-Splash Whelp"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amirdrassil"], ["Chrono-Lord Deios"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dew Process"], ["Branching Paths", "Rising Waves"]]]
      ]
    ],
    "Deios Druid":
      {[
         all: [
           ["Sheltered Survivor"],
           [
             "Chrono-Lord Deios",
             "E.T.C., Band Manager",
             "Jepetto Joybuzz",
             "Juicy Psychmelon",
             "Kun the Forgotten King",
             "Nourish",
             "Overgrowth"
           ]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jepetto Joybuzz"], ["Pendant of Earth", "Solar Eclipse"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Rheastrasza"], ["Tortollan Traveler"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ultimate Infestation"], ["Ysiel Windsinger"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Splish-Splash Whelp"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Summer Flowerchild"], ["Ysera the Dreamer"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Selfish Shellfish"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Animated Broomstick"], ["Astalor Bloodsworn"]]]
      ]
    ],
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jungle Giants"], ["Eredar Brute", "Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Brann Bronzebeard"], ["Skulking Geist"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Floop's Glorious Gloop"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Eredar Brute"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eredar Brute"], ["Desert Nestmatron", "Splish-Splash Whelp"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dew Process"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Amirdrassil"], ["Brann Bronzebeard"]],
          all: [["Astalor Bloodsworn"], ["Speaker Stomper"]],
          all: [["Loatheb"], ["Tortollan Traveler"]]
        ]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Ysiel Windsinger"]]]
      ]
    ],
    "XL Therazane Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Therazane"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amirdrassil"], ["Breath of Dreams"]]]
      ]
    ],
    "Linecracker Druid":
      {[
         all: [
           ["Animated Broomstick"],
           [
             "Black Market Auctioneer",
             "Capture Coldtooth Mine",
             "Floop's Glorious Gloop",
             "Innervate",
             "Lifebinder's Gift",
             "Lightning Bloom",
             "Living Roots"
           ]
         ],
         all: [["Wildheart Guff"], ["Black Market Auctioneer", "Lifebinder's Gift"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amirdrassil"], ["Astalor Bloodsworn"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Splish-Splash Whelp"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Razorscale"], ["Tortollan Traveler"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dew Process"], ["Theotar, the Mad Duke"]],
          all: [["Naturalize"], ["Rising Waves"]]
        ]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Summer Flowerchild"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Amirdrassil"], ["Skulking Geist"]],
          all: [["Blademaster Okani"], ["Chrono-Lord Deios"]]
        ]
      ]
    ],
    "Token Druid": {[all: [["Aquatic Form"], ["Blood Treant"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Champions of Azeroth"],
            ["New Heights", "Sleep Under the Stars"]
          ]
        ]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Nightshade Bud"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Eredar Brute"],
            ["Acceleration Aura", "Razorscale", "Ysera the Dreamer", "Ysera, Emerald Aspect"]
          ],
          all: [["Desert Nestmatron"], ["Malfurion's Gift"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Splish-Splash Whelp"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Splish-Splash Whelp"], ["Summer Flowerchild"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Black Market Auctioneer"], ["Construct Pylons"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Brann Bronzebeard"], ["Acceleration Aura", "Blademaster Okani"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Dew Process"],
            ["Biology Project", "Heartroot Stones", "Invigorate"]
          ]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Kun the Forgotten King"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Capture Coldtooth Mine"], ["Innervate"]]], [start_of_game: ["Prince Renathal"]]},
    "Old Aggro Druid": {[all: [["Druid of the Reef"], ["Herald of Nature"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Poison Seeds"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Ysera the Dreamer"],
            ["Acceleration Aura", "Malfurion's Gift", "Zephrys the Great"]
          ],
          all: [["Breath of Dreams"], ["Branching Paths", "Trogg Gemtosser"]],
          all: [["Acceleration Aura"], ["The Curator"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Glacial Shard"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Handle with Bear"], ["Jungle Giants"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Animated Broomstick"], ["Juicy Psychmelon"]],
          all: [["Astalor Bloodsworn"], ["Solar Eclipse"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Amirdrassil"],
            [
              "Acceleration Aura",
              "Blademaster Okani",
              "Loatheb",
              "New Heights",
              "Pendant of Earth",
              "Tortollan Traveler"
            ]
          ],
          all: [
            ["Chrono-Lord Deios"],
            ["Razorscale", "Reno, Lone Ranger", "Rheastrasza", "Zephrys the Great"]
          ],
          all: [
            ["Rheastrasza"],
            ["Naturalize", "Pendant of Earth", "Skulking Geist"]
          ],
          all: [
            ["Speaker Stomper"],
            ["Acceleration Aura", "New Heights", "Pendant of Earth"]
          ],
          all: [["Astalor Bloodsworn"], ["Blademaster Okani", "Reno Jackson"]],
          all: [["Heartroot Stones"], ["Smothering Starfish"]],
          all: [["Reno Jackson"], ["Tortollan Traveler"]]
        ]
      ]
    ],
    "XL Dungar Druid": {[all: [["Moonbeam"], ["Wild Growth"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Breath of Dreams"],
            ["Rheastrasza", "Theotar, the Mad Duke", "Zephrys the Great"]
          ]
        ]
      ]
    ],
    "Astral Druid": {[all: [["Aquatic Form"], ["Astral Communion"]]], [start_of_game: ["Prince Renathal"]]},
    "Deios Druid":
      {[
         all: [["Aviana"], ["Jepetto Joybuzz", "Kun the Forgotten King"]],
         all: [["Chrono-Lord Deios"], ["Innervate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Spreading Plague"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Curator"], ["Wild Growth"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Rising Waves"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overflow"], ["Waveshaping", "Wild Growth"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Naturalize"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Juicy Psychmelon"], ["Naturalize"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Juicy Psychmelon"], ["Ysera, Emerald Aspect"]]]
      ]
    ],
    "XL Therazane Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Therazane"],
            ["Death Blossom Whomper", "Invigorate", "Moonlit Guidance"]
          ],
          all: [["Bouldering Buddy"], ["Moonlit Guidance"]]
        ]
      ]
    ],
    "Champions Druid":
      {[
         all: [
           ["Champions of Azeroth"],
           ["Sleep Under the Stars", "Ysiel Windsinger"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid": {[all: [["Reforestation"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Capture Coldtooth Mine"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Tortollan Traveler"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Poison Seeds"], ["Rheastrasza"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eredar Brute"], ["Biology Project", "Zephrys the Great"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Loatheb"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Ysera, Emerald Aspect"],
            ["Reno, Lone Ranger", "Zephrys the Great"]
          ],
          all: [["Death Beetle"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Summer Flowerchild"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Astalor Bloodsworn"], ["Reno, Lone Ranger"]],
          all: [["Brann Bronzebeard"], ["Theotar, the Mad Duke"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Malfurion's Gift"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Naturalize"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Splish-Splash Whelp"], ["Ysera the Dreamer"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Juicy Psychmelon"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Rheastrasza"]],
          all: [["Skulking Geist"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["New Heights"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Animated Broomstick"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Tortollan Traveler"],
            ["Biology Project", "Malfurion's Gift", "Sleepy Resident"]
          ],
          all: [["Blademaster Okani"], ["Acceleration Aura", "Zephrys the Great"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Chrono-Lord Deios"], ["Solar Eclipse"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Reno Jackson"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Speaker Stomper"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Splish-Splash Whelp"], ["Wild Growth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Skulking Geist"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jungle Giants"], ["Moonlit Guidance"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Juicy Psychmelon"], ["Solar Eclipse"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Desert Nestmatron"], ["Wild Growth"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Wild Growth"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Zilliax Deluxe 3000"]]]
      ]
    ],
    "XL Dungar Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Travelmaster Dungar"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nightshade Bud"], ["Overgrowth"]]]
      ]
    ],
    "XL Yogg Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Mastermind Yogg-Saron"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Nightshade Bud"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blademaster Okani"], ["New Heights", "Theotar, the Mad Duke"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Innervate"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Heartroot Stones"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Juicy Psychmelon"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Death Beetle"], ["Malfurion's Gift"]],
          all: [["Eredar Brute"], ["Juicy Psychmelon"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Juicy Psychmelon"], ["Pendant of Earth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Astalor Bloodsworn"], ["New Heights"]],
          all: [["Brann Bronzebeard"], ["Wild Growth"]],
          all: [["Poison Seeds"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Tortollan Traveler"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Branching Paths"], ["Solar Eclipse"]],
          all: [["Naturalize"], ["Theotar, the Mad Duke"]]
        ]
      ]
    ],
    "Deios Druid":
      {[all: [["Juicy Psychmelon"], ["Heartroot Stones", "Nourish"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Druid": {[all: [["Heartroot Stones"], ["New Heights"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Dirty Rat"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Breath of Dreams"], ["Death Beetle", "Shattered Reflections"]],
          all: [["Shattered Reflections"], ["Splish-Splash Whelp"]]
        ]
      ]
    ],
    "Miracle Druid":
      {[
         all: [
           ["Capture Coldtooth Mine"],
           ["Biology Project", "Living Roots", "Moonfire"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Heartroot Stones"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Juicy Psychmelon"], ["Razorscale"]],
          all: [["Trogg Gemtosser"], ["Waveshaping"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amirdrassil"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Naturalize"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Naturalize"], ["Nourish"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Capture Coldtooth Mine"], ["Lifebinder's Gift"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sleep Under the Stars"], ["Solar Eclipse"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blademaster Okani"], ["Moonlit Guidance"]]]
      ]
    ],
    "Old Aggro Druid": {[all: [["Aquatic Form"], ["Sow the Soil"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid": {[all: [["Efflorescence"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid": {[all: [["Frost Lotus Seedling"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Dungar Druid": {[all: [["Malfurion's Gift"], ["Swipe"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Dragon Druid":
      {[
         all: [["Wildheart Guff"], ["Breath of Dreams", "Desert Nestmatron"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Branching Paths"], ["Nourish"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Floop's Glorious Gloop"], ["Poison Seeds"]]]
      ]
    ],
    "Miracle Druid":
      {[
         all: [["Aquatic Form"], ["Capture Coldtooth Mine", "Mistah Vistah"]],
         all: [["Waveshaping"], ["Black Market Auctioneer", "Mistah Vistah"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Living Roots"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid":
      {[
         all: [["Biology Project"], ["Black Market Auctioneer"]],
         all: [["Lifebinder's Gift"], ["Waveshaping"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Incorporeal Corporal"], ["Jungle Giants"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["The Curator"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Pendant of Earth"], ["Loatheb", "Razorscale"]],
          all: [["Dirty Rat"], ["Zephrys the Great"]],
          all: [["New Heights"], ["Reno Jackson"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Rising Waves"], ["Solar Eclipse"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Rising Waves"], ["Heartroot Stones", "Poison Seeds"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amirdrassil"], ["Wild Growth"]]]
      ]
    ],
    "Dragon Druid":
      {[
         all: [["Desert Nestmatron"], ["Breath of Dreams", "Splish-Splash Whelp"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Naturalize"], ["Shattered Reflections"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Naturalize"], ["Pendant of Earth", "Wild Growth"]],
          all: [["Aquatic Form"], ["Chrono-Lord Deios"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Naturalize"], ["Solar Eclipse"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Champions of Azeroth"], ["Invigorate"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Solar Eclipse"], ["Spreading Plague"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Sleep Under the Stars"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Smothering Starfish"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Loatheb"], ["Zilliax Deluxe 3000"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Juicy Psychmelon"], ["Rheastrasza"]],
          all: [["Splish-Splash Whelp"], ["Wildheart Guff"]]
        ]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Splish-Splash Whelp"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Juicy Psychmelon"], ["Wild Growth"]]]
      ]
    ],
    "Deios Druid":
      {[all: [["Juicy Psychmelon"], ["Aquatic Form", "Wild Growth"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aquatic Form"], ["Brann Bronzebeard"]],
          all: [["Frost Lotus Seedling"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Mecha'thun Druid":
      {[
         all: [["Pendant of Earth"], ["Heartroot Stones", "Naturalize"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Naturalize"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Acceleration Aura"],
            ["Astalor Bloodsworn", "Zilliax Deluxe 3000"]
          ]
        ]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Swipe"]]]
      ]
    ],
    "XL HL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jungle Giants"], ["Rhythm and Roots"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Sleep Under the Stars"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Eredar Brute"], ["Invigorate", "Waveshaping", "Wild Growth"]],
          all: [["Aquatic Form"], ["Capture Coldtooth Mine"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aquatic Form"], ["Juicy Psychmelon"]],
          all: [["Nourish"], ["Spreading Plague"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amirdrassil"], ["Malfurion's Gift"]]]
      ]
    ],
    "XL Yogg Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Glacial Shard"], ["Waveshaping"]]]
      ]
    ],
    "Star Grazer Druid": {[all: [["Hedge Maze"], ["Moonlit Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Aquatic Form"], ["Living Roots"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Wildheart Guff"], ["Death Beetle", "Ysera, Emerald Aspect"]],
          all: [["Biology Project"], ["Desert Nestmatron"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Rheastrasza"], ["Sleepy Resident"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Desert Nestmatron"],
            ["Breath of Dreams", "Invigorate", "Razorscale"]
          ]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Breath of Dreams"], ["Razorscale"]],
          all: [["Moonlit Guidance"], ["Splish-Splash Whelp"]]
        ]
      ]
    ],
    "XL Dungar Druid":
      {[all: [["Nightshade Bud"], ["Invigorate", "Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Branching Paths"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Moonlit Guidance"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Rising Waves"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Breath of Dreams"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Splish-Splash Whelp"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Speaker Stomper"], ["Waveshaping"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Pendant of Earth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["New Heights"],
            ["Razorscale", "Reno, Lone Ranger", "Zephrys the Great"]
          ],
          all: [["Reno, Lone Ranger"], ["Sleepy Resident"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Juicy Psychmelon"], ["Nourish"]],
          all: [["Sleepy Resident"], ["Solar Eclipse"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Razorscale"], ["Prince Renathal", "Reno, Lone Ranger"]],
          all: [["Loatheb"], ["Theotar, the Mad Duke"]]
        ]
      ]
    ],
    "Miracle Druid": {[all: [["Photon Cannon"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Acceleration Aura"], ["Sir Finley, Sea Guide"]],
          all: [["New Heights"], ["Rheastrasza"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Branching Paths"], ["Moonlit Guidance"]],
          all: [["Heartroot Stones"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Nourish"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Tortollan Traveler"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Poison Seeds"]]]
      ]
    ],
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Jungle Giants"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Loatheb", "Poison Seeds"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Glacial Shard"], ["Invigorate"]],
          all: [["New Heights"], ["Spreading Plague"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Spreading Plague"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Malfurion's Gift"]],
          all: [["Pendant of Earth"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    "Deios Druid": {[all: [["Heartroot Stones"], ["Wild Growth"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid":
      {[
         all: [["Heartroot Stones"], ["Aquatic Form", "Invigorate", "Waveshaping"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Waveshaping", "Wild Growth"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Solar Eclipse"], ["New Heights", "Swipe"]],
          all: [["Pendant of Earth"], ["Swipe"]]
        ]
      ]
    ],
    "XL Protoss Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Artanis"], ["Wild Growth"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Loatheb"], ["Wild Growth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Astalor Bloodsworn"], ["Nourish"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno Jackson"], ["Sleepy Resident"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Reno Jackson"]]]
      ]
    ],
    "Other Druid": {[all: [["Innervate"], ["New Heights"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Mistah Vistah"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Innervate"], ["Overgrowth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Acceleration Aura"], ["New Heights"]],
          all: [["Malfurion's Gift"], ["Rheastrasza"]]
        ]
      ]
    ],
    "Miracle Druid": {[all: [["Aquatic Form"], ["Black Market Auctioneer"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Solar Eclipse"], ["Wild Growth"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Rheastrasza"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Invigorate"]],
          all: [["Nourish"], ["Reno Jackson"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno Jackson"], ["Malfurion's Gift", "Wildheart Guff"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nourish"], ["Summer Flowerchild"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Loatheb"], ["Waveshaping"]],
          all: [["Rheastrasza"], ["Wild Growth"]]
        ]
      ]
    ],
    "Old Aggro Druid": {[all: [["Irondeep Trogg"], ["Jerry Rig Carpenter"]]], [start_of_game: ["Prince Renathal"]]},
    "Barnes Druid": {[all: [["Biology Project"], ["Ultimate Infestation"]]], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Moonfire"], ["Aquatic Form", "Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Razorscale"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Razorscale"], ["Moonlit Guidance", "Sir Finley, Sea Guide"]],
          all: [["Astalor Bloodsworn"], ["Malfurion's Gift"]],
          all: [["Dirty Rat"], ["Wild Growth"]],
          all: [["New Heights"], ["Poison Seeds"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Razorscale"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Moonlit Guidance"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Acceleration Aura"], ["Reno, Lone Ranger"]],
          all: [["Theotar, the Mad Duke"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Juicy Psychmelon"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Reno, Lone Ranger"], ["Biology Project", "Moonlit Guidance"]],
          all: [["Sleepy Resident"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Zephrys the Great"],
            ["Nourish", "Sir Finley, Sea Guide", "Wild Growth"]
          ],
          all: [["Malfurion's Gift"], ["Reno, Lone Ranger"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bob the Bartender"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Overgrowth"], ["Reno, Lone Ranger"]],
          all: [["Wildheart Guff"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Zephrys the Great"], ["Overgrowth", "Waveshaping"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Naturalize"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Breath of Dreams"], ["Invigorate"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Swipe"], ["Nourish", "Wildheart Guff"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nourish"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Nourish"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nourish"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Aquatic Form"], ["Lifebinder's Gift"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Zephrys the Great"]]]
      ]
    ],
    "XL JtU Quest Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jungle Giants"], ["Scourge Rager"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aquatic Form"], ["Astalor Bloodsworn"]],
          all: [["Spreading Plague"], ["Waveshaping"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Sleepy Resident"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Pendant of Earth"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Capture Coldtooth Mine"], ["Photon Cannon"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Juicy Psychmelon"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Spreading Plague"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bob the Bartender"], ["Pendant of Earth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "Deios Druid": {[all: [["Innervate"], ["Nourish"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Shattered Reflections"]]]
      ]
    ],
    "Mecha'thun Druid": {[all: [["Invigorate"], ["Pendant of Earth"]]], [start_of_game: ["Prince Renathal"]]},
    "Star Grazer Druid": {[all: [["Aquatic Form"], ["Trail Mix"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nourish"], ["Solar Eclipse"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Aquatic Form"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Poison Seeds"], ["Wildheart Guff"]],
          all: [["Sir Finley, Sea Guide"], ["Wild Growth"]]
        ]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Invigorate"], ["Razorscale"]],
          all: [["Theotar, the Mad Duke"], ["Wild Growth"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Theotar, the Mad Duke"], ["Waveshaping"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Overgrowth", "Wild Growth"]]]
      ]
    ],
    "XL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Efflorescence"], ["Invigorate"]]]
      ]
    ],
    "Miracle Druid": {[all: [["Biology Project"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Pendant of Earth"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Sleepy Resident"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Heartroot Stones"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Acceleration Aura"], ["Malfurion's Gift"]],
          all: [["Invigorate"], ["Theotar, the Mad Duke"]]
        ]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Solar Eclipse"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Waveshaping"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Wildheart Guff"]]]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Swipe"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Poison Seeds"]]]
      ]
    ],
    "Linecracker Druid":
      {[
         all: [["Aquatic Form"], ["Naturalize", "Wildheart Guff"]],
         all: [["Moonlit Guidance"], ["Naturalize"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Miracle Druid": {[all: [["Aquatic Form"], ["Biology Project"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Razorscale"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Sleepy Resident"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Bob the Bartender"], ["Malfurion's Gift", "Sleepy Resident"]],
          all: [["Acceleration Aura"], ["Biology Project"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Moonlit Guidance"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acceleration Aura"], ["Invigorate"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["New Heights"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heartroot Stones"], ["Invigorate"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Sleepy Resident"], ["Biology Project", "Invigorate"]],
          all: [["Aquatic Form"], ["Pendant of Earth"]]
        ]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Pendant of Earth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Poison Seeds"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Sleepy Resident"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Bob the Bartender"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bob the Bartender"], ["Wildheart Guff"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sir Finley, Sea Guide"], ["Waveshaping"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Solar Eclipse"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aquatic Form"], ["Sir Finley, Sea Guide"]],
          all: [["Biology Project"], ["E.T.C., Band Manager"]]
        ]
      ]
    ],
    "Deios Druid": {[all: [["Biology Project"], ["Overgrowth"]]], [start_of_game: ["Prince Renathal"]]},
    "Mecha'thun Druid":
      {[
         all: [["Biology Project"], ["Pendant of Earth"]],
         all: [["Invigorate"], ["Waveshaping"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["E.T.C., Band Manager"], ["Wild Growth"]],
          all: [["Frost Lotus Seedling"], ["Wildheart Guff"]],
          all: [["Malfurion's Gift"], ["Pendant of Earth"]]
        ]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Wildheart Guff"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Overgrowth"], ["Pendant of Earth"]],
          all: [["Waveshaping"], ["Wild Growth"]]
        ]
      ]
    ],
    "XL Champions Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Wild Growth"]]]
      ]
    ],
    "Other Druid": {[all: [["New Heights"], ["Wild Growth"]]], [start_of_game: ["Prince Renathal"]]},
    "Token Druid": {[all: [["Innervate"], ["Moonlit Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malfurion's Gift"], ["Wildheart Guff"]]]
      ]
    ],
    "Mecha'thun Druid":
      {[
         all: [["Aquatic Form"], ["Invigorate"]],
         all: [["Pendant of Earth"], ["Waveshaping"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Solar Eclipse"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Waveshaping"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aquatic Form"], ["Frost Lotus Seedling", "Sleepy Resident"]],
          all: [["Bob the Bartender"], ["Invigorate"]],
          all: [["Malfurion's Gift"], ["Waveshaping"]],
          all: [["Nourish"], ["Prince Renathal"]]
        ]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Prince Renathal"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Prince Renathal"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["New Heights"], ["Waveshaping", "Wildheart Guff"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Waveshaping"], ["Wildheart Guff"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Prince Renathal"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Wild Growth"],
            ["Aquatic Form", "Invigorate", "Moonlit Guidance", "Overgrowth"]
          ],
          all: [["Invigorate"], ["Malfurion's Gift"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nourish"], ["Wild Growth"]]]
      ]
    ],
    "Mecha'thun Druid": {[all: [["Biology Project"], ["Nourish"]]], [start_of_game: ["Prince Renathal"]]},
    "Deios Druid": {[all: [["Overgrowth"], ["Wild Growth"]]], [start_of_game: ["Prince Renathal"]]},
    "JtU Quest Druid": {[all: [["Aquatic Form"], ["Moonlit Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Barnes Druid": {[all: [["Moonlit Guidance"], ["Waveshaping"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aquatic Form"], ["Moonlit Guidance"]],
          all: [["Malfurion's Gift"], ["Overgrowth"]]
        ]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Malfurion's Gift", "New Heights"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Wildheart Guff"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Wildheart Guff"], ["Biology Project", "Moonlit Guidance"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Overgrowth"], ["Wildheart Guff"]]]
      ]
    ],
    "XL HL Dragon Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nourish"], ["Biology Project", "Overgrowth"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Overgrowth"]]]
      ]
    ],
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aquatic Form"], ["Overgrowth"]]]
      ]
    ],
    "XL Deios Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Invigorate"], ["Nourish", "Overgrowth", "Waveshaping"]]]
      ]
    ],
    "XL Highlander Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Moonlit Guidance"], ["Invigorate", "Waveshaping"]]]
      ]
    ],
    "Mecha'thun Druid": {[all: [["Invigorate"], ["Nourish"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Mill Druid": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Biology Project"], ["Overgrowth"]]]
      ]
    ]
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
