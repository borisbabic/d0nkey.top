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
    "Boar Hunter": ["Elwynn Boar"],
    "Secret Hunter": ["Eversong Portal"],
    "Amalgam Hunter": ["Adaptive Amalgam"],
    "XL Highlander Hunter": ["Mojomaster Zihi"],
    "Highlander Hunter": ["Trusty Fishing Rod"],
    "Beast Hunter": ["Painted Canvasaur"],
    "XL Highlander Hunter": ["Astalor Bloodsworn", "Boompistol Bully", "Irondeep Trogg", "Misdirection"],
    "STD No Hand Hunter": ["Arrow Retriever", "Sizzling Cinder"],
    "STD Companion Hunter": ["Critter Caretaker"],
    "XL HL Leoroxx Hunter": ["Hydralodon"],
    "XL Hunter": ["Sing-Along Buddy"],
    "XL Highlander Hunter": ["Kerrigan, Queen of Blades"],
    "Secret Hunter": ["Starstrung Bow"],
    "LC Quest Hunter": ["The Food Chain"],
    "Leoroxx Hunter": ["Ten Gallon Hat"],
    "XL HL Leoroxx Hunter": ["Beastmaster Leoroxx", "Elise the Navigator"],
    "XL Highlander Hunter": ["Far Watch Post", "Spawning Pool"],
    "STD No Hand Hunter": ["Quel'dorei Fletcher"],
    "Boar Hunter": ["Bola Shot"],
    "XL Hunter": ["Bitterbloom Knight", "Flutterwing Guardian", "Umbraclaw"],
    "XL HL Leoroxx Hunter": ["Tundra Rhino"],
    "Dragon Hunter": ["Petal Peddler"],
    "Highlander Hunter": ["Dreamplanner Zephrys"],
    "XL Highlander Hunter": ["Beaststalker Tavish", "Observer of Myths", "Sneaky Snakes", "ZOMBEEEES!!!"],
    "Secret Hunter": ["Wandering Monster"],
    "Boar Hunter": ["Selective Breeder"],
    "XL HL Leoroxx Hunter": ["Hope of Quel'Thalas"],
    "Beast Hunter": ["Pet Collector"],
    "Questline Hunter": ["Defend the Dwarven District", "Platysaur"],
    "XL Secret Hunter": ["Trueaim Crescent"],
    "XL HL Leoroxx Hunter": ["Miracle Salesman", "Razorscale", "Troubled Mechanic", "Wild Spirits"],
    "Highlander Hunter": ["Theldurin the Lost"],
    "STD Companion Hunter": ["Migrating Elekk", "Talya Earthstrider"],
    "Boar Hunter": ["Rangari Scout"]
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
