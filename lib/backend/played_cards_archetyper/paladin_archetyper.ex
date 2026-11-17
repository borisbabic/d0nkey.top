# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.Hearthstone.Card

  defp any_neutral?(card_info) do
    Enum.any?(card_info.full_cards, fn c ->
      c.name != "The Coin" and Card.neutral?(c)
    end)
  end

  def standard_excludes do
    %{
      "Pure Paladin" => [&any_neutral?/1]
    }
  end

  defp base_standard_config do
    [
      "Quest Paladin": ["Dive the Golakka Depths"],
      "Combo Paladin": [
        {:all,
         [
           ["Holy Eggbearer"],
           [
             "Bloodsail Raider",
             "Brutish Endmaw",
             "Dragonscale Armaments",
             "Equality",
             "Glacial Shard",
             "Hand of Infinity",
             "Hardlight Protector",
             "Holy Bola!",
             "Humble Judgment",
             "Judgment",
             "Prize Vendor",
             "Righteous Protector",
             "Sun's Reckoning",
             "Wild Pyromancer"
           ]
         ]},
        {:all,
         [
           ["Bloodsail Raider"],
           [
             "Brutish Endmaw",
             "Crystalline Golem",
             "Doomsayer",
             "Glacial Shard",
             "Hardlight Protector",
             "Holy Bola!",
             "The Egg of Khelos",
             "Unstable Prototype",
             "Wild Pyromancer"
           ]
         ]},
        {:all,
         [
           ["Endbringer Umbra"],
           [
             "Crystalline Golem",
             "Doomsayer",
             "Glacial Shard",
             "Hardlight Protector",
             "Judgment",
             "N'Zoth, Dream's End",
             "The Fins Beyond Time",
             "Unstable Prototype",
             "Wild Pyromancer"
           ]
         ]},
        {:all,
         [
           ["Brutish Endmaw"],
           ["Glacial Shard", "Hardlight Protector", "Judgment", "Prize Vendor", "The Egg of Khelos", "Wild Pyromancer"]
         ]},
        {:all,
         [
           ["Hand of Infinity"],
           ["Crystalline Golem", "Doomsayer", "Glacial Shard", "Hardlight Protector", "The Egg of Khelos"]
         ]},
        {:all,
         [
           ["The Egg of Khelos"],
           ["Hardlight Protector", "Holy Bola!", "Humble Judgment", "Prize Vendor"]
         ]}
      ],
      # 2.5
      "Ursol Paladin": [
        {:all,
         [
           ["Vigilant Sentry"],
           [
             "Amitut, Keeper of Amitus",
             "Chronological Aura",
             "Commander Beatrix",
             "Equality",
             "Humble Judgment",
             "Manifested Timeways",
             "Nozdormu, Bronze Aspect",
             "Rajh",
             "Reinforcement Aura",
             "Resistance Aura",
             "Scarlet Recruiter",
             "Sun's Reckoning",
             "Twilight Timereaver",
             "Ursol"
           ]
         ]}
      ],
      "Ursol Paladin": [
        {:all,
         [
           ["Convalescence"],
           [
             "Acceleration Aura",
             "Amitut, Keeper of Amitus",
             "Chronological Aura",
             "Consecration",
             "Dragonscale Armaments",
             "Equality",
             "Halls of Origination",
             "Humble Judgment",
             "Lightcaller",
             "Manifested Timeways",
             "Mastermind Yogg-Saron",
             "Nightmare Lord Xavius",
             "Oathbinder's Aura",
             "Resistance Aura",
             "Sun's Reckoning",
             "Ursine Maul",
             "Ursol"
           ]
         ]},
        {:all,
         [
           ["Oathbinder's Aura"],
           [
             "Acceleration Aura",
             "Amitut, Keeper of Amitus",
             "Chronological Aura",
             "Consecration",
             "Dragonscale Armaments",
             "Equality",
             "Halls of Origination",
             "Humble Judgment",
             "Manifested Timeways",
             "March to War",
             "Mastermind Yogg-Saron",
             "Nightmare Lord Xavius",
             "Resistance Aura",
             "Sun's Reckoning",
             "Ursine Maul",
             "Ursol"
           ]
         ]},
        {:all,
         [
           ["Ursine Maul"],
           [
             "Acceleration Aura",
             "Amitut, Keeper of Amitus",
             "Chronological Aura",
             "Consecration",
             "Dragonscale Armaments",
             "Equality",
             "Halls of Origination",
             "Humble Judgment",
             "Manifested Timeways",
             "Mastermind Yogg-Saron",
             "Nightmare Lord Xavius",
             "Resistance Aura",
             "Sun's Reckoning",
             "Ursol"
           ]
         ]},
        {:all,
         [
           ["Mastermind Yogg-Saron"],
           [
             "Amitut, Keeper of Amitus",
             "Chronological Aura",
             "Consecration",
             "Equality",
             "Halls of Origination",
             "Humble Judgment",
             "Manifested Timeways",
             "Nightmare Lord Xavius",
             "Resistance Aura"
           ]
         ]}
      ],
      "Ursol Paladin": [
        "Scarlet Bruiser",
        "Vigilant Sentry"
      ],
      # 5.5
      "Combo Paladin": [
        {:all,
         [
           ["Bloatray"],
           [
             "Bitterbloom Knight",
             "Doomsayer",
             "Hardlight Protector",
             "Rajh",
             "Twilight Timereaver",
             "Unstable Prototype"
           ]
         ]},
        {:all,
         [
           ["Critter Caretaker"],
           ["Sun's Reckoning"]
         ]},
        {:all,
         [
           ["Cult Neophyte"],
           ["Hardlight Protector"]
         ]},
        {:all,
         [
           ["Endbringer Umbra"],
           ["Scarlet Recruiter"]
         ]}
      ],
      "Ursol Paladin": [
        {:all,
         [
           ["Amitut, Keeper of Amitus"],
           ["Nozdormu, Bronze Aspect"]
         ]}
      ],
      "N'Zoth Paladin": [
        {:all,
         [
           ["Tyrannogill"],
           [
             "Acceleration Aura",
             "Crystalline Golem",
             "Dragonscale Armaments",
             "Equality",
             "Manifested Timeways",
             "Reinforcement Aura",
             "Sun's Reckoning"
           ]
         ]},
        {:all,
         [
           ["Elise the Navigator"],
           ["Chronological Aura", "Plated Beetle"]
         ]}
      ],
      # 8.5
      "Ursol Paladin": [
        {:all,
         [
           ["Portal Vanguard"],
           [
             "Acceleration Aura",
             "Amitut, Keeper of Amitus",
             "Chronological Aura",
             "Consecration",
             "Dragonscale Armaments",
             "Equality",
             "March to War",
             "Nightmare Lord Xavius",
             "Sun's Reckoning",
             "Ursol"
           ]
         ]},
        {:all,
         [
           ["Humble Judgment"],
           ["Amitut, Keeper of Amitus", "Chronological Aura", "Nozdormu, Bronze Aspect", "Resistance Aura"]
         ]},
        {:all,
         [
           ["Scarlet Recruiter"],
           ["Chronological Aura", "March to War", "Nozdormu, Bronze Aspect", "Resistance Aura"]
         ]},
        {:all,
         [
           ["Chronological Aura"],
           ["March to War"]
         ]}
      ],
      # 9.5
      "Combo Paladin": [
        {:all,
         [
           ["Bitterbloom Knight"],
           ["Crystalline Golem", "Doomsayer", "Glacial Shard", "Unstable Prototype"]
         ]},
        {:all,
         [
           ["Hardlight Protector"],
           ["Holy Bola!", "Lightcaller", "Prize Vendor", "Rajh"]
         ]},
        {:all,
         [
           ["Glacial Shard"],
           ["Holy Bola!", "Humble Judgment"]
         ]},
        {:all,
         [
           ["Acceleration Aura"],
           ["The Egg of Khelos"]
         ]},
        {:all,
         [
           ["Consecration"],
           ["Cult Neophyte"]
         ]},
        {:all,
         [
           ["Prize Vendor"],
           ["Wild Pyromancer"]
         ]}
      ],
      # 10.5
      "Imbue Paladin": [
        {:all,
         [
           ["Flutterwing Guardian"],
           [
             "Acceleration Aura",
             "Aegis of Light",
             "Bitterbloom Knight",
             "Dragonscale Armaments",
             "Dreamwarden",
             "Equality",
             "Goldpetal Drake",
             "Humble Judgment",
             "Sun's Reckoning"
           ]
         ]},
        {:all,
         [
           ["Bitterbloom Knight"],
           ["Dreamwarden"]
         ]}
      ],
      # 11.5
      "Combo Paladin": [
        {:all,
         [
           ["Hand of Infinity"],
           [
             "Acceleration Aura",
             "Bloodsail Raider",
             "Dragonscale Armaments",
             "Judgment",
             "Righteous Protector",
             "Sun's Reckoning"
           ]
         ]},
        {:all,
         [
           ["Bloodsail Raider"],
           ["Acceleration Aura", "Judgment", "Righteous Protector", "Sun's Reckoning"]
         ]}
      ],
      # 12.5
      "Ursol Paladin": [
        {:all,
         [
           ["Chronological Aura"],
           ["Consecration", "Holy Bola!", "Resistance Aura"]
         ]},
        {:all,
         [
           ["Amitut, Keeper of Amitus"],
           ["Holy Bola!", "Nightmare Lord Xavius"]
         ]},
        {:all,
         [
           ["Nozdormu, Bronze Aspect"],
           ["Reinforcement Aura", "Resistance Aura"]
         ]},
        {:all,
         [
           ["Holy Bola!"],
           ["Rajh"]
         ]},
        {:all,
         [
           ["Nightmare Lord Xavius"],
           ["Resistance Aura"]
         ]}
      ],
      # 13.5
      "Combo Paladin": [
        {:all,
         [
           ["Hardlight Protector"],
           [
             "Crystalline Golem",
             "Dirty Rat",
             "Doomsayer",
             "Dragonscale Armaments",
             "Equality",
             "Glacial Shard",
             "Judgment",
             "Resistance Aura",
             "Righteous Protector",
             "Sun's Reckoning",
             "Unstable Prototype",
             "Wild Pyromancer"
           ]
         ]},
        {:all,
         [
           ["Doomsayer"],
           ["Amitut, Keeper of Amitus", "Dreamwarden", "Halls of Origination", "Reinforcement Aura"]
         ]},
        {:all,
         [
           ["Cult Neophyte"],
           ["Glacial Shard", "Sun's Reckoning", "Unstable Prototype"]
         ]},
        {:all,
         [
           ["Dreamwarden"],
           ["Glacial Shard", "Wild Pyromancer"]
         ]},
        {:all,
         [
           ["The Egg of Khelos"],
           ["Unstable Prototype"]
         ]}
      ],
      # 14.5
      "N'Zoth Paladin": [
        {:all,
         [
           ["Shaladrassil"],
           [
             "Crystalline Golem",
             "Doomsayer",
             "Dragonscale Armaments",
             "Equality",
             "Glacial Shard",
             "Judgment",
             "Resistance Aura",
             "Righteous Protector",
             "Smoldering Strength",
             "Sun's Reckoning",
             "Unstable Prototype"
           ]
         ]},
        {:all,
         [
           ["Plated Beetle"],
           ["Amitut, Keeper of Amitus", "Chronological Aura", "Manifested Timeways", "Reinforcement Aura", "Ursol"]
         ]},
        {:all,
         [
           ["Gemstone Hoarder"],
           ["Smoldering Strength", "Wild Pyromancer"]
         ]},
        {:all,
         [
           ["Chronological Aura"],
           ["Crystalline Golem"]
         ]}
      ],
      # 15.5
      "Ursol Paladin": [
        {:all,
         [
           ["March to War"],
           ["Humble Judgment", "Nightmare Lord Xavius"]
         ]},
        {:all,
         [
           ["Reinforcement Aura"],
           ["Chronological Aura", "Toreth the Unbreaking"]
         ]},
        {:all,
         [
           ["Scarlet Recruiter"],
           ["Amitut, Keeper of Amitus", "Violet Treasuregill"]
         ]},
        {:all,
         [
           ["Consecration"],
           ["Toreth the Unbreaking"]
         ]}
      ],
      # 16.5
      "Ursol Paladin": [
        {:all,
         [
           ["Chronological Aura"],
           [
             "Amitut, Keeper of Amitus",
             "Dragonscale Armaments",
             "Equality",
             "Nightmare Lord Xavius",
             "Sun's Reckoning",
             "Ursol"
           ]
         ]},
        {:all,
         [
           ["Amitut, Keeper of Amitus"],
           ["Consecration", "Manifested Timeways", "March to War"]
         ]},
        {:all,
         [
           ["Consecration"],
           ["Manifested Timeways", "March to War"]
         ]},
        {:all,
         [
           ["March to War"],
           ["Resistance Aura"]
         ]},
        {:all,
         [
           ["Nightmare Lord Xavius"],
           ["Ursol"]
         ]}
      ],
      # 17.5
      "Combo Paladin": [
        {:all,
         [
           ["Acceleration Aura"],
           ["Doomsayer", "Glacial Shard", "Wild Pyromancer"]
         ]},
        {:all,
         [
           ["Dirty Rat"],
           ["Glacial Shard"]
         ]},
        {:all,
         [
           ["Holy Bola!"],
           ["Righteous Protector"]
         ]}
      ],
      # 18.5
      "Ursol Paladin": [
        {:all,
         [
           ["Scarlet Recruiter"],
           [
             "Acceleration Aura",
             "Dragonscale Armaments",
             "Manifested Timeways",
             "Rajh",
             "Reinforcement Aura",
             "Righteous Protector",
             "Sun's Reckoning",
             "Ursol"
           ]
         ]},
        {:all,
         [
           ["Humble Judgment"],
           ["Acceleration Aura", "Consecration", "Manifested Timeways", "Ursol"]
         ]},
        {:all,
         [
           ["Amitut, Keeper of Amitus"],
           ["Acceleration Aura", "Dragonscale Armaments", "Reinforcement Aura"]
         ]},
        {:all,
         [
           ["Manifested Timeways"],
           ["Halls of Origination", "Reinforcement Aura"]
         ]}
      ],
      # 19.5
      "Combo Paladin": [
        "The Egg of Khelos"
      ],
      # 20.5
      "Ursol Paladin": [
        {:all,
         [
           ["Acceleration Aura"],
           ["Nightmare Lord Xavius"]
         ]}
      ],
      "Combo Paladin": [
        {:all,
         [
           ["Plated Beetle"],
           [
             "Crystalline Golem",
             "Dragonscale Armaments",
             "Glacial Shard",
             "N'Zoth, Dream's End",
             "Righteous Protector",
             "Sun's Reckoning",
             "Unstable Prototype",
             "Wild Pyromancer"
           ]
         ]},
        {:all,
         [
           ["Lightcaller"],
           ["Doomsayer", "Glacial Shard", "Righteous Protector", "Unstable Prototype"]
         ]},
        {:all,
         [
           ["Twilight Timereaver"],
           ["Crystalline Golem", "Glacial Shard", "Righteous Protector"]
         ]},
        {:all,
         [
           ["Rajh"],
           ["Doomsayer", "Glacial Shard"]
         ]}
      ],
      # 22.5
      "Ursol Paladin": [
        "Reinforcement Aura"
      ],
      "Combo Paladin": [
        "Doomsayer",
        "Wild Pyromancer",
        "Unstable Prototype",
        "Glacial Shard",
        "Crystalline Golem"
      ],
      # 24.5
      "Ursol Paladin": [
        {:all,
         [
           ["Consecration"],
           ["Acceleration Aura", "Dragonscale Armaments", "Sun's Reckoning"]
         ]},
        {:all,
         [
           ["Sun's Reckoning"],
           ["Manifested Timeways", "Resistance Aura"]
         ]},
        {:all,
         [
           ["Acceleration Aura"],
           ["Commander Beatrix"]
         ]}
      ],
      # 25.5
      "Ursol Paladin": [
        "Nightmare Lord Xavius",
        "Scarlet Recruiter",
        "Resistance Aura",
        "Acceleration Aura",
        "Manifested Timeways",
        "Humble Judgment",
        "Chronological Aura",
        "Consecration",
        "Truth Seeker",
        "Halls of Origination",
        "Oathbinder's Aura",
        "Ursine Maul",
        "Amitut, Keeper of Amitus",
        "Mekkatorque's Aura",
        "Ursol",
        "Convalescence",
        "Gnomish Aura"
      ],
      "Combo Paladin": [
        {:all,
         [
           ["Righteous Protector"],
           ["Dragonscale Armaments", "Sun's Reckoning"]
         ]}
      ],
      "Ursol Paladin": [
        {:all,
         [
           ["Righteous Protector"],
           ["Inspiring Maul", "Spearheart Sentry"]
         ]},
        {:all,
         [
           ["Nozdormu, Bronze Aspect"],
           ["Violet Treasuregill"]
         ]},
        {:all,
         [
           ["Rajh"],
           ["Sun's Reckoning"]
         ]}
      ],
      # 28.5
      "Ursol Paladin": [
        {:all,
         [
           ["Dragonscale Armaments"],
           ["Equality", "Sun's Reckoning"]
         ]},
        {:all,
         [
           ["Equality"],
           ["Sun's Reckoning"]
         ]}
      ]
    ]
  end

  def wild_excludes, do: %{}

  @wild_config [
    "Lynessa Libram Paladin": ["Adaptation", "Libram of Wisdom", "Lightray", "Myrmidon", "Sunsapper Lynessa"],
    "Mech Paladin": ["Click-Clocker", "Glow-Tron", "Security Automaton", "Skaterbot"],
    "CtA Paladin": ["Flash Sale"],
    "LC Quest Paladin": ["Braingill"],
    "CtA Paladin": ["Irondeep Trogg"],
    "STD Imbue Paladin": ["Ancient of Yore"],
    "LC Quest Paladin": ["Lushwater Scout"],
    "XL HL Aura Paladin": ["Speaker Stomper"],
    "LC Quest Paladin": ["Gnawing Greenfin", "Murloc Tidehunter"],
    "XL HL Aura Paladin": ["Gelbin of Tomorrow"],
    "CtA Paladin": ["Boogie Down"],
    "XL CtA Paladin": ["Explodineer", "Galloping Savior", "Trapdoor Spider"],
    "Lynessa Libram Paladin": ["Aldor Attendant"],
    "XL HL Exodia Paladin": ["Lorekeeper Polkelt"],
    "LC Quest Paladin": ["Amalgam of the Deep", "Imprisoned Sungill", "Twin-fin Fin Twin"],
    "CtA Paladin": ["Blood Matriarch Liadrin", "Call to Arms", "Nerub'ar Weblord"],
    "Lynessa Libram Paladin": ["Interstellar Starslicer"],
    "Lynessa Libram Paladin": ["Interstellar Researcher"],
    "XL HL Aura Paladin": ["Smothering Starfish"],
    "STD Dude Paladin": ["Sizzling Cinder"],
    "LC Quest Paladin": ["Dive the Golakka Depths"],
    "Odd Paladin": ["Murmy"],
    "Exodia Paladin": ["Order in the Court"],
    "XL HL Exodia Paladin": ["Garrison Commander", "Sing-Along Buddy", "Uther of the Ebon Blade"],
    "XL HL Aura Paladin": [
      "Astalor Bloodsworn",
      "Blademaster Okani",
      "Razorscale",
      "Sir Finley of the Sands",
      "Skulking Geist"
    ],
    "Questline Paladin": ["Desperate Measures", "Rise to the Occasion"],
    "CtA Paladin": ["Sword of the Fallen"],
    "XL HL Aura Paladin": ["Resistance Aura"],
    "STD Imbue Paladin": ["Consecration"],
    "Lynessa Libram Paladin": ["Instrument Tech"],
    "XL HL Aura Paladin": ["Miracle Salesman"],
    "XL Paladin": ["Aegis of Light", "Alliance Bannerman", "Dreamwarden"],
    "XL HL Aura Paladin": ["Mining Casualties"],
    "XL HL Aura Paladin": ["Runi, Time Explorer"],
    "XL HL Aura Paladin": ["Zephrys the Great"],
    "Lynessa Libram Paladin": ["Showdown!"],
    "Odd Paladin": ["Knight of Anointment", "Lost in the Jungle"],
    "Lynessa Libram Paladin": ["Crystology"]
  ]

  def standard_config, do: add_excludes(base_standard_config(), standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Paladin")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Paladin")
  end
end
