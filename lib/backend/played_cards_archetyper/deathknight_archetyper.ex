# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.Hearthstone.RuneCost

  defp any_non_blood?(card_info) do
    any_with_rune?(card_info, [:frost, :unholy])
  end

  defp any_with_rune?(card_info, runes) when is_list(runes) do
    Enum.any?(card_info.full_cards, fn
      %{rune_cost: %RuneCost{} = rc} -> Enum.any?(runes, &RuneCost.has_rune?(rc, &1))
      _ -> false
    end)
  end

  defp any_with_rune?(card_info, rune), do: any_with_rune?(card_info, [rune])

  def standard_excludes do
    %{}
  end

  defp base_standard_config,
    do: [
      "Quest DK": ["Reanimate the Terror"],
      "Blood DK": ["Grafted Knight", "Bloodfiend", "Alexandros Mograine", "G'huun"],
      "Vyranoth DK": [
        {:all,
         [
           ["Sheltered Survivor"],
           [
             "Fleshshape",
             "Titanic Thrasher",
             "Nerubian Swarmguard",
             "Y'Shaarj, Titan Bane",
             "Command Claw",
             "Nightmare Lord Xavius",
             "Emergency Survivor",
             "Command Claw",
             "Elise the Navigator",
             "Infested Breath"
           ]
         ]},
        {:all,
         [
           ["Briarspawn Drake"],
           [
             "Blood Doctor Thal'ena",
             "Morbid Swarm",
             "Infested Breath",
             "Elise the Navigator",
             "Fleshshape",
             "Nightmare Lord Xavius",
             "Nerubian Swarmguard"
           ]
         ]},
        {:all,
         [
           ["Vyranoth"],
           [
             "Emergency Surgery",
             "Command Claw",
             "Morbid Swarm"
           ]
         ]},
        {:all,
         [
           ["Gnome Muncher"],
           [
             "Command Claw"
           ]
         ]}
      ],
      "Aggro DK": [
        {:all,
         [
           ["Shadows of Yesterday"],
           [
             "Murmy",
             "Monstrous Mosquito"
           ]
         ]}
      ],
      "Harold DK": [
        {:all,
         [
           ["Arisen Onyxia"],
           ["Morbid Swarm", "Emergency Surgery"]
         ]},
        {:all,
         [
           ["Morbid Swarm"],
           ["Envoy of the End"]
         ]}
      ],
      # 5.5 !
      "Blood DK": [
        {:all,
         [
           ["Death Metal Knight"],
           [
             "Ultraxion",
             "Elise the Navigator",
             "Concealing Confection",
             "Staff of the Endbringer",
             "Obessive Technician",
             "Blood Draw",
             "Chillfallen Baron",
             "Reanimated Pterrodax",
             "Scion of Insight"
           ]
         ]}
      ],
      "Unholy N'Zoth DK": [
        {:all,
         [
           ["Loot Hoarder"],
           ["Corpse Cannon"]
         ]},
        {:all,
         [
           ["Grave Strength"],
           [
             "N'Zoth, Dream's End",
             "The Egg of Khelos",
             "Holy Eggbearer",
             "Bloodmage Thalnos"
           ]
         ]},
        {:all,
         [
           ["Bloodmage Thalnos"],
           [
             "N'Zoth, Dream's End",
             "The Egg of Khelos",
             "Holy Eggbearer",
             "Glacial Shard",
             "Reanimated Pterrodax",
             "Soulrest Ceremony",
             "Sawbones",
             "Unstable Prototype"
           ]
         ]}
      ],
      "Vyranoth DK": [
        {:all,
         [
           ["Titanic Thrasher"],
           [
             "Chillfallen Baron",
             "Chromatic Broodmother",
             "Emergency Surgery",
             "Fleshshape",
             "Gnome Muncher",
             "Nerubian Swarmguard"
           ]
         ]},
        {:all,
         [
           ["Elise the Navigator"],
           [
             "Nerubian Swarmguard",
             "Chromatic Broodmother",
             "Fleshshape"
           ]
         ]},
        {:all,
         [
           ["Vyranoth"],
           [
             "Fleshshape",
             "Titanic Thrasher",
             "Scion of Insight"
           ]
         ]}
      ],
      "Blood DK": [
        {:all,
         [
           ["Elise the Navigator"],
           [
             "Concealing Confection",
             "Blood Draw",
             "Sanguine Infestation",
             "Hideous Husk"
           ]
         ]},
        {:all,
         [
           ["Sanguine Infestation"],
           [
             "Concealing Confection",
             "Dirty Rat",
             "Hideous Husk"
           ]
         ]},
        {:all,
         [
           ["Hideous Husk"],
           [
             "Concealing Confection",
             "Dirty Rat",
             "Scion of Insight",
             "Chillfallen Baron",
             "Staff of the Endbringer"
           ]
         ]}
      ],
      "Handbuff DK": [
        {:all,
         [
           ["Nerubian Swarmguard"],
           [
             "Sawbones",
             "Holy Eggbearer",
             "Soulrest Ceremony"
           ]
         ]}
      ],
      # 10.5
      "Harold DK": [
        {:all,
         [
           ["Morbid Swarm"],
           [
             "Experimental Animation",
             "Obsessive Technician",
             "Soulrest Ceremony"
           ]
         ]}
      ],
      "Aggro DK": [
        {:all,
         [
           ["Battlefield Necromancer"],
           [
             "Murmy",
             "Twilight Egg",
             "Talanji's Last Stand",
             "Tower of Ghouls"
           ]
         ]},
        {:all,
         [
           ["Grave Strengh"],
           [
             "Tower of Ghouls"
           ]
         ]}
      ],
      "Blood DK":
        {[
           {:all,
            [
              ["Concealing Confection"],
              [
                "Blood Draw",
                "Infested Breath",
                "Hematurge",
                "Nightmare Lord Xavius"
              ]
            ]},
           {:all,
            [
              ["Obsessive Technician"],
              [
                "Elise the Navigator",
                "Body Bagger",
                "Blood Draw"
              ]
            ]},
           {:all,
            [
              ["Elise the Navigator"],
              [
                "Ultraxion",
                "Experimental Animation",
                "Dirty Dat"
              ]
            ]}
         ], &any_non_blood?/1},
      "Unholy N'Zoth DK": [
        {:all,
         [
           ["Talanji's Last Stand"],
           [
             "Holy Egg Bearer",
             "The Egg of Kehlos"
           ]
         ]},
        {:all,
         [
           ["Twilight Egg"],
           [
             "The Egg of Khelos",
             "Nightmare Lord Xavius",
             "Glacial Shard"
           ]
         ]},
        {:all,
         [
           ["Reluctant Wrangler"],
           [
             "The Egg of Khelos",
             "Glacial Shard"
           ]
         ]}
      ],
      "Blood DK": {
        [
          {:all,
           [
             ["Obsessive Technician"],
             [
               "Infested Breath",
               "Nightmare Lord Xavius",
               "Hematurge"
             ]
           ]},
          {:all,
           [
             ["Hematurge"],
             [
               "Dirty Rat",
               "Infested Breath",
               "Scion of Insight"
             ]
           ]}
        ],
        &any_non_blood?/1
      },
      # 15.5
      "Handbuff DK": [
        {:all,
         [
           ["Unstable Prototype"],
           ["Chromatic Broodmother", "Fleshshape", "Gruesome Nightmare"]
         ]}
      ],
      "Vyranoth DK": [
        {:all,
         [
           ["Chromatic Broodmother"],
           ["Fleshshape", "Scion of Insight"]
         ]},
        {:all,
         [
           ["Nerubian Swarmguard"],
           ["Fleshshape", "Scion of Insight"]
         ]}
      ],
      "Aggro DK": [
        {:all,
         [
           ["Monstrous Mosquito"],
           [
             "Acolyte of Death",
             "Corpse Cannon",
             "Murmy",
             "Reanimated Pterrordax",
             "Reluctant Wrangler",
             "Talanji's Last Stand",
             "Tower of Ghouls",
             "Twilight Egg"
           ]
         ]},
        {:all,
         [
           ["Murmy"],
           [
             "Acolyte of Death",
             "Corpse Cannon",
             "Grave Strength",
             "Reluctant Wrangler",
             "Talanji's Last Stand",
             "Tower of Ghouls",
             "Twilight Egg"
           ]
         ]},
        {:all,
         [
           ["Body Bagger"],
           [
             "Acolyte of Death",
             "Corpse Cannon",
             "Reluctant Wrangler",
             "Talanji's Last Stand",
             "Tower of Ghouls",
             "Twilight Egg"
           ]
         ]},
        {:all,
         [
           ["Tower of Ghouls"],
           ["Acolyte of Death", "Grave Strength", "Reluctant Wrangler", "Talanji's Last Stand", "Twilight Egg"]
         ]},
        {:all,
         [
           ["Acolyte of Death"],
           ["Corpse Cannon", "Talanji's Last Stand", "Twilight Egg"]
         ]},
        {:all,
         [
           ["Falric"],
           ["Grave Strength"]
         ]}
      ],
      "Harold DK": [
        {:all,
         [
           ["Emergency Surgery"],
           [
             "Concealing Confection",
             "Dirty Rat",
             "Envoy of the End",
             "Experimental Animation",
             "Husk, Eternal Reaper",
             "Obsessive Technician"
           ]
         ]},
        {:all,
         [
           ["Obsessive Technician"],
           ["Command Claw", "Hematurge", "Infested Breath"]
         ]},
        {:all,
         [
           ["Command Claw"],
           ["Hematurge"]
         ]}
      ],
      "Blood DK": [
        {:all,
         [
           ["Murmy"],
           [
             "Arrival of the Old Gods",
             "Chillfallen Baron",
             "Dirty Rat",
             "Obsessive Technician",
             "Reanimated Pterrordax",
             "Scion of Insight"
           ]
         ]},
        {:all,
         [
           ["Dirty Rat"],
           ["Elise the Navigator", "Infested Breath"]
         ]},
        {:all,
         [
           ["Experimental Animation"],
           ["Infested Breath"]
         ]}
      ],
      # 20.5
      "Unholy N'Zoth DK": [
        {:all,
         [
           ["Corpse Cannon"],
           ["Reluctant Wrangler", "Twilight Egg", "Unstable Prototype"]
         ]},
        {:all,
         [
           ["Holy Eggbearer"],
           ["Reluctant Wrangler", "Twilight Egg"]
         ]},
        {:all,
         [
           ["Talanji's Last Stand"],
           ["Twilight Egg", "Unstable Prototype"]
         ]}
      ],
      "Blood DK": [
        {:all,
         [
           ["Obsessive Technician"],
           [
             "Arrival of the Old Gods",
             "Chillfallen Baron",
             "Concealing Confection",
             "Experimental Animation",
             "Remnant of Rage",
             "Scion of Insight",
             "Staff of the Endbringer",
             "Ultraxion"
           ]
         ]},
        {:all,
         [
           ["Scion of Insight"],
           ["Blood Draw", "Experimental Animation", "Sanguine Infestation", "Ultraxion"]
         ]},
        {:all,
         [
           ["Infested Breath"],
           ["Elise the Navigator", "Envoy of the End"]
         ]},
        {:all,
         [
           ["Blood Draw"],
           ["Chillfallen Baron"]
         ]},
        {:all,
         [
           ["Concealing Confection"],
           ["Remnant of Rage"]
         ]}
      ],
      "Egg DK": [
        {:all,
         [
           ["The Egg of Khelos"],
           [
             "Blood Doctor Thal'ena",
             "Corpse Cannon",
             "Defias Smuggler",
             "Morbid Swarm",
             "Reanimated Pterrordax",
             "Remnant of Rage",
             "Sawbones"
           ]
         ]},
        {:all,
         [
           ["Corpse Cannon"],
           ["Reanimated Pterrordax", "Remnant of Rage", "Sawbones"]
         ]},
        {:all,
         [
           ["Holy Eggbearer"],
           ["Blood Doctor Thal'ena", "Reanimated Pterrordax", "Remnant of Rage"]
         ]}
      ],
      "Vyranoth DK": [
        {:all,
         [
           ["Command Claw"],
           ["Fleshshape", "Scion of Insight"]
         ]},
        {:all,
         [
           ["Blood Doctor Thal'ena"],
           ["Scion of Insight"]
         ]}
      ],
      "N'Zoth DK": [
        {:all,
         [
           ["Loot Hoarder"],
           [
             "Arrival of the Old Gods",
             "Reanimated Pterrordax",
             "Reluctant Wrangler",
             "Remnant of Rage",
             "Unstable Prototype"
           ]
         ]},
        {:all,
         [
           ["Crystalline Golem"],
           ["Chillfallen Baron", "Reanimated Pterrordax", "Reluctant Wrangler"]
         ]},
        {:all,
         [
           ["Blackwing Experiment"],
           ["Arrival of the Old Gods", "Reanimated Pterrordax"]
         ]},
        {:all,
         [
           ["Reluctant Wrangler"],
           ["Remnant of Rage"]
         ]}
      ],
      # 25.5
      "Blood DK": [
        {:all,
         [
           ["Dirty Rat"],
           ["Concealing Confection", "Nightmare Lord Xavius", "Scion of Insight", "Staff of the Endbringer"]
         ]},
        {:all,
         [
           ["Scion of Insight"],
           ["Concealing Confection", "Elise the Navigator", "Infested Breath"]
         ]},
        {:all,
         [
           ["Chillfallen Baron"],
           ["Elise the Navigator", "Experimental Animation"]
         ]},
        {:all,
         [
           ["Infested Breath"],
           ["Staff of the Endbringer"]
         ]}
      ],
      "Blood DK": [
        {:all,
         [
           ["Staff of the Endbringer"],
           ["Arrival of the Old Gods", "Chillfallen Baron", "Concealing Confection", "Scion of Insight"]
         ]},
        {:all,
         [
           ["Arrival of the Old Gods"],
           ["Envoy of the End", "Scion of Insight"]
         ]},
        {:all,
         [
           ["Chillfallen Baron"],
           ["Infested Breath", "Scion of Insight"]
         ]}
      ],
      "Blood DK": [
        "Whelp of the Infinite",
        "Obsessive Technician",
        "Hideous Husk",
        "Death Metal Knight",
        "Sanguine Infestation",
        "Blood Draw",
        "Concealing Confection",
        "Dirty Rat",
        "Infested Breath",
        "Experimental Animation",
        "Hematurge",
        "Envoy of the End"
      ],
      "Unholy N'Zoth DK": [
        "Holy Eggbearer",
        "The Egg of Khelos"
      ],
      "Vyranoth DK": [
        "Titanic Thrasher"
      ],
      # 30.5
      "N'Zoth DK": [
        "Cryofrozen Champion",
        "Deathchiller"
      ],
      "Handbuff DK": [
        "Flutterwing Guardian",
        "Blood Tap"
      ],
      "Blood DK": [
        "Scion of Insight",
        "Elise the Navigator",
        "Husk, Eternal Reaper"
      ],
      "Vyranoth DK": [
        "Chromatic Broodmother"
      ],
      "Unholy N'Zoth DK": [
        "Unstable Prototype",
        "Corpse Cannon",
        "Twilight Egg"
      ],
      # 35.5
      "Vyranoth DK": [
        "Command Claw",
        "Fleshshape",
        "Blood Doctor Thal'ena"
      ],
      "Blood DK": [
        "Chillfallen Baron",
        "Staff of the Endbringer",
        "Nightmare Lord Xavius",
        "Body Bagger"
      ]
    ]

  @wild_config [
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Bone Breaker"], ["Miracle Salesman", "The Living Plague"]],
          all: [["Dread Raptor"], ["Malted Magma"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Alexandros Mograine"], ["Malted Magma"]],
          all: [["Grafted Knight"], ["Trapdoor Spider"]],
          all: [["The 8 Hands From Beyond"], ["Ysera, Emerald Aspect"]]
        ]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Disguised Doctor"], ["Dread Raptor"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Acolyte of Pain"], ["Arrival of the Old Gods", "Patchwerk"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Far Watch Post"], ["Quartzite Crusher"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Deathbringer Saurfang"], ["Razorscale"]],
          all: [["Mining Casualties"], ["Skulking Geist"]]
        ]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blademaster Okani"], ["Defrost"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno, Lone Ranger"], ["Deathbringer Saurfang", "G'huun"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bone Breaker"], ["Cult Neophyte"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Consumption"], ["Reno, Lone Ranger", "The 8 Hands From Beyond"]],
          all: [["Bloodfiend"], ["Trapdoor Spider"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Emperor Thaurissan"], ["Scion of Insight"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Quartzite Crusher"], ["Morbid Swarm", "Speaker Stomper"]],
          all: [["Wave of Tar"], ["Disguised Doctor", "Spawning Pool"]]
        ]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Distressed Kvaldir"], ["The Curator"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Drakkari Enchanter"], ["Vampiric Blood"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Quartzite Crusher"], ["Runes of Darkness"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Distressed Kvaldir"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Chained Guardian"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Cattle Rustler"]],
          all: [["Deathbringer Saurfang"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Defrost"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Alexandros Mograine"], ["Razorscale", "Reno, Lone Ranger"]],
          all: [["Zephrys the Great"], ["Bloodfiend", "Grafted Knight"]],
          all: [["Trapdoor Spider"], ["Vampiric Blood"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Reno, Lone Ranger"],
            ["Bloodfiend", "Grafted Knight", "Vampiric Blood"]
          ]
        ]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Miracle Salesman"], ["Rainbow Seamstress"]]]
      ]
    ],
    "Plague DK":
      {[
         all: [["Chained Guardian"], ["Chillfallen Baron", "Staff of the Primus"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "STD Handbuff DK":
      {[
         all: [["Remnant of Rage"], ["Blood Tap", "Glacial Shard"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Rainbow DK":
      {[
         all: [["Miracle Salesman"], ["Arrival of the Old Gods", "Undertaker"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "STD Unholy DK": {[all: [["Murmy"], ["Tower of Ghouls"]]], [start_of_game: ["Prince Renathal"]]},
    "Blood DK": {[all: [["Obsessive Technician"], ["Vampiric Blood"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Blood DK": {[all: [["Scion of Insight"], ["Whelp of the Infinite"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Vampiric Blood"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Malted Magma"], ["Rainbow Seamstress"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Consumption"], ["Far Watch Post", "Zephrys the Great"]],
          all: [["Far Watch Post"], ["G'huun"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Helm of Humiliation"], ["Sanguine Infestation"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Defrost"], ["Infested Breath"]],
          all: [["Helya"], ["Quartzite Crusher"]],
          all: [["Malted Magma"], ["Reska, the Pit Boss"]]
        ]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spawning Pool"], ["Vyranoth"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno Jackson"], ["Bloodfiend", "Vampiric Blood"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blood Boil"], ["Bloodfiend"]],
          all: [["Experimental Animation"], ["Vampiric Blood"]]
        ]
      ]
    ],
    "Plague DK": {[all: [["Distressed Kvaldir"], ["Down with the Ship"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Unholy DK":
      {[
         all: [
           ["Twilight Egg"],
           ["Acolyte of Death", "Battlefield Necromancer", "Body Bagger", "Corpse Cannon"]
         ],
         all: [["Corpse Cannon"], ["Monstrous Mosquito", "Murmy"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Airlock Breach"], ["Construct Quarter"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Audio Amplifier"],
            ["Arrival of the Old Gods", "Grafted Knight", "Vampiric Blood"]
          ]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Far Watch Post"],
            ["Grafted Knight", "Sphere of Sapience", "Vampiric Blood"]
          ],
          all: [
            ["Sanguine Infestation"],
            ["Malted Magma", "Razorscale", "Runeforging"]
          ],
          all: [["Fae Trickster"], ["Arrival of the Old Gods", "Runeforging"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bloodfiend"], ["Obsessive Technician", "Reanimated Pterrordax"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Construct Quarter"], ["Sanguine Infestation"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bloodfiend"], ["Soulstealer"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Down with the Ship"], ["Falric"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ethereal Oracle"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Gorgonzormu"], ["Helya"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cold Feet"], ["Distressed Kvaldir"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reska, the Pit Boss"], ["Runeforging"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Consumption"],
            ["Dirty Rat", "Disguised Doctor", "Runes of Darkness"]
          ]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Hideous Husk"], ["Bloodfiend", "Grafted Knight"]],
          all: [["Obsessive Technician"], ["Vampiric Blood"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Buttons"], ["Grafted Knight"]],
          all: [["Cold Feet"], ["Sphere of Sapience"]]
        ]
      ]
    ],
    "Even Death Knight":
      {[
         all: [["Dreadhound Handler"], ["Grafted Knight", "Vampiric Blood"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nydus Worm"], ["Vampiric Blood"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cold Feet"], ["Maw and Paw"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sanguine Infestation"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Cult Neophyte"], ["Falric"]],
          all: [["Mojomaster Zihi"], ["Staff of the Endbringer"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Deathbringer Saurfang"], ["Hematurge"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Helya"], ["Miracle Salesman"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Staff of the Primus"], ["Trapdoor Spider"]]]
      ]
    ],
    "STD Harold Blood DK":
      {[
         all: [["Arrival of the Old Gods"], ["Experimental Animation"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blademaster Okani"], ["Grafted Knight"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blood Boil"], ["Vampiric Blood"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Miracle Salesman"]],
          all: [["Elise the Navigator"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nydus Worm"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Construct Quarter"], ["Rainbow Seamstress"]],
          all: [["Reska, the Pit Boss"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Zerg Death Knight":
      {[
         all: [["Baneling Barrage"], ["Hive Queen", "Spawning Pool"]],
         all: [["Hive Queen"], ["Spawning Pool"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Construct Quarter"], ["Grafted Knight"]],
          all: [["Hematurge"], ["Sphere of Sapience"]],
          all: [["Sanguine Infestation"], ["Spawning Pool"]]
        ]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dreadhound Handler"], ["Elise the Navigator"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Infested Breath"], ["Obsessive Technician"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Hematurge"], ["Buttons", "Malted Magma", "Zephrys the Great"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Miracle Salesman"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Blood DK": {[all: [["Spawning Pool"], ["Zergling"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Arrival of the Old Gods"], ["G'huun"]],
          all: [["Bloodfiend"], ["Threads of Despair"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Staff of the Endbringer"], ["Vampiric Blood"]]]
      ]
    ],
    "XL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Scion of Insight"], ["Remnant of Rage", "Sawbones"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Grafted Knight"], ["Runes of Darkness"]]]
      ]
    ],
    "STD Blood DK":
      {[
         all: [["Elise the Navigator"], ["Grafted Knight", "Scion of Insight"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Plague Strike"], ["Scion of Insight"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Rainbow Seamstress"],
            ["Infested Breath", "Reanimated Pterrordax", "Zephrys the Great"]
          ]
        ]
      ]
    ],
    "XL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Distressed Kvaldir"], ["Down with the Ship"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Down with the Ship"], ["Staff of the Primus"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Chillfallen Baron"], ["Sanguine Infestation"]],
          all: [["Hematurge"], ["Hideous Husk"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Runeforging"], ["Sphere of Sapience"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cold Feet"], ["Gorgonzormu"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Grafted Knight"], ["Infested Breath", "Sanguine Infestation"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Grafted Knight"], ["Scion of Insight"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Plague Strike"], ["Instrument Tech", "Staff of the Primus"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Kerrigan, Queen of Blades"], ["Plague Strike"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Cattle Rustler"], ["Patchwerk"]],
          all: [["Dirty Rat"], ["Vampiric Blood"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dreadhound Handler"], ["Vampiric Blood"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ethereal Oracle"], ["Malted Magma"]]]
      ]
    ],
    "Blood DK": {[all: [["Hematurge"], ["Sanguine Infestation"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Blood DK": {[all: [["Sanguine Infestation"], ["Scion of Insight"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Disguised Doctor"], ["Plague Strike"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Chillfallen Baron"], ["Razorscale"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Staff of the Primus"], ["The Curator"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Down with the Ship"],
            ["Reanimated Pterrordax", "Runeforging", "The Curator"]
          ],
          all: [["Loatheb"], ["The Curator"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Hematurge"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bloodfiend"], ["Spawning Pool"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cattle Rustler"], ["The 8 Hands From Beyond"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dreadhound Handler"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Infested Breath"]]]
      ]
    ],
    "STD Harold Blood DK":
      {[
         all: [["Obsessive Technician"], ["Reanimated Pterrordax"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Helya"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Blood Doctor Thal'ena"],
            ["Dreadhound Handler", "Zephrys the Great"]
          ],
          all: [["The Curator"], ["Helya", "Runeforging"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Scion of Insight"], ["Far Watch Post", "Zephrys the Great"]],
          all: [["Dirty Rat"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Plague DK": {[all: [["Helya"], ["Staff of the Primus"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dreadhound Handler"], ["Runeforging"]]]
      ]
    ],
    "XL HL Plague DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Runeforging"], ["Staff of the Primus"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Hematurge"], ["Spawning Pool"]],
          all: [["Infested Breath"], ["The Curator"]],
          all: [["Malted Magma"], ["Mining Casualties"]],
          all: [["Scion of Insight"], ["Staff of the Endbringer"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Hideous Husk"], ["Infested Breath"]]]
      ]
    ],
    "Other DK":
      {[
         all: [["Dreadhound Handler"], ["Construct Quarter", "Fleshshape"]],
         all: [["E.T.C., Band Manager"], ["Infested Breath"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Cult Neophyte"], ["Spawning Pool"]],
          all: [["Infested Breath"], ["Nydus Worm"]]
        ]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Far Watch Post"], ["Helya"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Runes of Darkness"]],
          all: [["Hematurge"], ["Mining Casualties"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Infested Breath"], ["Hematurge", "Sanguine Infestation"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Infested Breath"], ["Malted Magma"]],
          all: [["Patchwerk"], ["Runes of Darkness"]]
        ]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Razorscale"]],
          all: [["Disguised Doctor"], ["Helya"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Disguised Doctor"],
            ["Sir Finley, Sea Guide", "Zephrys the Great"]
          ],
          all: [["Infested Breath"], ["Scion of Insight", "Spawning Pool"]],
          all: [["Dirty Rat"], ["Scion of Insight"]],
          all: [["E.T.C., Band Manager"], ["Far Watch Post"]],
          all: [["Mining Casualties"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "STD Harold Blood DK": {[all: [["Grafted Knight"], ["Scion of Insight"]]], [start_of_game: ["Prince Renathal"]]},
    "Blood DK": {[all: [["Hematurge"], ["Grafted Knight", "Hideous Husk"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Kerrigan, Queen of Blades"],
            ["Construct Quarter", "Nydus Worm"]
          ],
          all: [["Spawning Pool"], ["Malted Magma", "Nydus Worm"]],
          all: [["Arrival of the Old Gods"], ["Helya"]]
        ]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Spawning Pool"]]]
      ]
    ],
    "XL HL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Runeforging"], ["Staff of the Endbringer"]]]
      ]
    ],
    "XL HL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Arrival of the Old Gods"], ["Dreadhound Handler"]],
          all: [["Infested Breath"], ["Mining Casualties"]]
        ]
      ]
    ],
    "XL Blood DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cold Feet"], ["Mining Casualties"]]]
      ]
    ],
    "XL Highlander Death Knight": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Buttons"], ["Cold Feet"]]]
      ]
    ],
    "Even Death Knight":
      {[
         all: [["Infested Breath"], ["Dreadhound Handler", "Hideous Husk"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Rainbow DK": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dreadhound Handler"], ["Mining Casualties"]]]
      ]
    ],
    "Other DK": {[all: [["Chillfallen Baron"], ["Mining Casualties"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Handbuff DK": {[all: [["Chillfallen Baron"], ["Scion of Insight"]]], [start_of_game: ["Prince Renathal"]]}
  ]

  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(base_standard_config(), standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DK")
  end
end
