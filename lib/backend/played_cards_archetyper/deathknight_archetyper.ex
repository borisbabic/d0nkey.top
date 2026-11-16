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
    "Aggro DK": [
      "Creature of Madness",
      "Fire Fly",
      "Malignant Horror",
      "Menagerie Jug",
      "Menagerie Mug",
      "Monstrous Mosquito",
      "Nozdormu the Eternal",
      "Observer of Mysteries",
      "Rite of Atrocity"
    ],
    "Highlander DK": ["Bone Breaker"],
    "XL Plague DK": ["Pen Flinger"],
    "Highlander DK": ["Quartzite Crusher", "Rainbow Seamstress"],
    "Splendiferous Whizbang": ["Primordial Glyph", "Thrive in the Shadows", "Wild Growth"],
    "Plague DK": ["Harth Stonebrew"],
    "XL HL Plague DK": ["Instrument Tech"],
    "XL Plague DK": ["Astrobiologist"],
    "XL LC Quest Death Knight": ["Suffocate"],
    "Highlander DK": ["Foamrender", "High Cultist Herenn", "Rivendare, Warrider", "The 8 Hands From Beyond"],
    "Plague DK": ["Chained Guardian", "Death Growl"],
    "Highlander DK": ["Reska, the Pit Boss"],
    "XL HL Plague DK": ["Ashen Elemental", "Magatha, Bane of Music"],
    "XL Blood DK": ["Soulstealer"],
    "Highlander DK": ["Blood Boil", "Defrost", "Mixologist"],
    "XL Plague DK": ["Overplanner"],
    "XL Blood DK": ["Vampiric Blood"],
    "XL HL Plague DK": ["Far Watch Post"],
    "Highlander DK": ["Timeline Accelerator", "Zephrys the Great"],
    "Plague DK": ["Augmented Elekk"],
    "Highlander DK": ["Reno, Lone Ranger"],
    "XL LC Quest Death Knight": ["Reanimate the Terror"],
    "Buttons DK": ["Pile of Bones"],
    "Aggro Plague DK": ["Battlefield Necromancer", "Murmy"],
    "Highlander DK": [
      "Blademaster Okani",
      "Buttons",
      "Construct Quarter",
      "Cult Neophyte",
      "Gorgonzormu",
      "Loatheb",
      "Smothering Starfish",
      "Spawning Pool",
      "Theotar, the Mad Duke"
    ],
    "XL Plague DK": ["Soul Searching"],
    "XL Harold Death Knight": ["Airlock Breach", "Carrier Whelp"],
    "Even Death Knight": ["Horizon's Edge"],
    "Plague DK": ["Distressed Kvaldir", "Staff of the Primus"],
    "Highlander DK": ["Dirty Rat", "Helya", "Runes of Darkness"],
    "STD Harold DK": ["Morbid Swarm"],
    "XL Blood DK": [
      "Body Bagger",
      "Envoy of the End",
      "Experimental Animation",
      "Hematurge",
      "Hideous Husk",
      "Infested Breath",
      "Obsessive Technician",
      "Prince Renathal",
      "Sanguine Infestation"
    ]
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
