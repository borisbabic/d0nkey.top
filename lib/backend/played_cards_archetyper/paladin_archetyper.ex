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
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Garrison Commander"], ["Uther of the Ebon Blade"]]]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Gelbin of Tomorrow"], ["Lightcaller"]]]
      ]
    ],
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Captain's Parrot"], ["Sir Finley of the Sands"]]]
      ]
    ],
    "Clone Mech Paladin": {[all: [["Hellion"], ["The Curator"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Paladin": {[all: [["Cavalry Horn"], ["Knight of Anointment"]]], [start_of_game: ["Prince Renathal"]]},
    "Combo Paladin": {[all: [["Captain's Parrot"], ["Hand of Infinity"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [["P1CK-P0K3T"], ["Busy-Bot", "SN1P-SN4P"]],
         all: [["Zilliax Deluxe 3000"], ["OC91 Chariot", "Power Tiger"]],
         all: [["Bronze Gatekeeper"], ["The Curator"]],
         all: [["Drone Deconstructor"], ["Knight of Anointment"]],
         all: [["Hellion"], ["Sky Claw"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Aldor Attendant"], ["Resistance Aura"]],
         all: [["Rebuke"], ["Sunsapper Lynessa"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [["Busy-Bot"], ["Frequency Oscillator", "Ultra-Capacitor"]],
         all: [["Security Automaton"], ["Commander Beatrix", "SN1P-SN4P"]],
         all: [["Bronze Gatekeeper"], ["Zilliax Deluxe 3000"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin": {[all: [["Crusader Aura"], ["Righteous Protector"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Crabrider"],
            [
              "Chronological Aura",
              "Lightforged Cariel",
              "Nozdormu the Timeless",
              "Theotar, the Mad Duke",
              "Timeline Accelerator"
            ]
          ],
          all: [
            ["Past Gnomeregan"],
            ["Amitus, the Peacekeeper", "Crystology", "E.T.C., Band Manager"]
          ],
          all: [["Gelbin of Tomorrow"], ["Toreth the Unbreaking"]]
        ]
      ]
    ],
    "Lynessa Libram Paladin":
      {[
         all: [["Adaptation"], ["Sir Finley, Sea Guide"]],
         all: [["Chillblade Champion"], ["Sunsapper Lynessa"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Combo Paladin": {[all: [["Bloodsail Raider"], ["Stonetusk Boar"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [["Busy-Bot"], ["Drone Deconstructor", "Security Automaton"]],
         all: [["Power Tiger"], ["Radar Detector", "Sky Claw"]],
         all: [["Hellion"], ["Zilliax Deluxe 3000"]],
         all: [["OC91 Chariot"], ["Radar Detector"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin": {[all: [["Nerub'ar Weblord"], ["Tigress Plushy"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin": {[all: [["Sky Claw"], ["Stonehearth Vindicator"]]], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin": {[all: [["Boogie Down"], ["Hidden Wisdom"]]], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Interstellar Starslicer"], ["Lorewalker Cho"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [["Frequency Oscillator"], ["Stonehearth Vindicator"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin": {[all: [["Myrmidon"], ["Sunsapper Lynessa"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin": {[all: [["Bronze Gatekeeper"], ["P1CK-P0K3T"]]], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin":
      {[
         all: [["Miracle Salesman"], ["Redemption"]],
         all: [["Oh My Yogg!"], ["Trapdoor Spider"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [["Bronze Gatekeeper"], ["Crusader Aura"]],
         all: [["Security Automaton"], ["Zilliax Deluxe 3000"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [
           ["Sunsapper Lynessa"],
           [
             "Adaptation",
             "Aldor Attendant",
             "Crystology",
             "Interstellar Researcher",
             "Interstellar Starslicer",
             "Knight of Anointment",
             "Libram of Clarity",
             "Libram of Divinity",
             "Libram of Wisdom",
             "Lightray"
           ]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Combo Paladin":
      {[
         all: [["Captain's Parrot"], ["Crystology", "Knight of Anointment"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [
           ["Security Automaton"],
           [
             "Bronze Gatekeeper",
             "Bubblebot",
             "Crusader Aura",
             "Drone Deconstructor",
             "Frequency Oscillator",
             "Goldwing",
             "P1CK-P0K3T",
             "Radar Detector",
             "Sky Claw",
             "Ultra-Capacitor",
             "Violet Treasuregill"
           ]
         ],
         all: [
           ["Ultra-Capacitor"],
           ["Bronze Gatekeeper", "Bubblebot", "Frequency Oscillator", "Goldwing", "Sky Claw", "Violet Treasuregill"]
         ],
         all: [
           ["Bronze Gatekeeper"],
           ["Bubblebot", "Frequency Oscillator", "Sky Claw"]
         ],
         all: [["Hellion"], ["Bubblebot", "Radar Detector"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Uther of the Ebon Blade"],
            [
              "Amitus, the Peacekeeper",
              "Cold Feet",
              "Crystology",
              "E.T.C., Band Manager",
              "Grillmaster",
              "Nozdormu the Timeless",
              "Prismatic Beam",
              "Sir Finley, Sea Guide",
              "Spirit of the Badlands",
              "Zephrys the Great"
            ]
          ]
        ]
      ]
    ],
    "Questline Paladin":
      {[all: [["High Abbess Alura"], ["Rise to the Occasion"]]], [start_of_game: ["Prince Renathal"]]},
    "Exodia Paladin": {[all: [["Prize Vendor"], ["Uther of the Ebon Blade"]]], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Showdown!"], ["Interstellar Starslicer", "Libram of Divinity"]],
         all: [["Adaptation"], ["Instrument Tech"]],
         all: [["Lightray"], ["Sir Finley, Sea Guide"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL LC Quest Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dive the Golakka Depths"], ["Steamfin Thief", "Tyrannogill"]]]
      ]
    ],
    "XL Lynessa Libram Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Instrument Tech"], ["Interstellar Starslicer"]]]
      ]
    ],
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Captain's Parrot"], ["Blademaster Okani", "Tigress Plushy"]]]
      ]
    ],
    "XL CtA Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Call to Arms"], ["Oh My Yogg!"]]]
      ]
    ],
    "Combo Paladin": {[all: [["Bloodsail Raider"], ["Knight of Anointment"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Pure Paladin":
      {[
         all: [["Violet Treasuregill"], ["Reinforcement Aura", "Vigilant Sentry"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "LC Quest Paladin":
      {[
         all: [["Dive the Golakka Depths"], ["High Abbess Alura"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin":
      {[
         all: [["Trinket Artist"], ["Nerub'ar Weblord", "Oh My Yogg!"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [
           ["Prismatic Beam"],
           [
             "Aldor Attendant",
             "Chillblade Champion",
             "Interstellar Researcher",
             "Interstellar Starslicer",
             "Libram of Divinity",
             "Lightray",
             "Myrmidon"
           ]
         ],
         all: [
           ["Rebuke"],
           [
             "Aldor Attendant",
             "Chillblade Champion",
             "Interstellar Researcher",
             "Interstellar Starslicer",
             "Libram of Divinity",
             "Libram of Wisdom"
           ]
         ],
         all: [
           ["E.T.C., Band Manager"],
           ["Aldor Attendant", "Interstellar Researcher", "Interstellar Starslicer", "Libram of Wisdom", "Lightray"]
         ],
         all: [
           ["Adaptation"],
           ["Chillblade Champion", "Libram of Divinity", "Myrmidon", "Tigress Plushy"]
         ],
         all: [
           ["Myrmidon"],
           ["Crystology", "Instrument Tech", "Interstellar Researcher"]
         ],
         all: [["Showdown!"], ["Aldor Attendant", "Chillblade Champion"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Cold Feet"], ["Chillblade Champion", "Libram of Divinity"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin":
      {[
         all: [
           ["Miracle Salesman"],
           ["Blood Matriarch Liadrin", "Sword of the Fallen"]
         ],
         all: [["Boogie Down"], ["Oh My Yogg!"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Galloping Savior"], ["Spirit of the Badlands"]]]
      ]
    ],
    "Clone Mech Paladin": {[all: [["Crusader Aura"], ["Radar Detector"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Instrument Tech"], ["Loatheb"]]]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Crusader Aura"]],
          all: [["Crabrider"], ["Spirit of the Badlands"]],
          all: [["Miracle Salesman"], ["Sir Finley of the Sands"]]
        ]
      ]
    ],
    "CtA Paladin": {[all: [["Call to Arms"], ["Tigress Plushy"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone CtA Paladin": {[all: [["Call to Arms"], ["Reinforcement Aura"]]], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin":
      {[
         all: [["Blood Matriarch Liadrin"], ["Righteous Protector"]],
         all: [["Irondeep Trogg"], ["Nerub'ar Weblord"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [
           ["Instrument Tech"],
           ["Aldor Attendant", "Chillblade Champion", "Interstellar Researcher", "Interstellar Starslicer"]
         ],
         all: [["Adaptation"], ["Interstellar Starslicer", "Knight of Anointment"]],
         all: [["Cold Feet"], ["Interstellar Starslicer", "Lightray"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Combo Paladin": {[all: [["Instrument Tech"], ["Prize Vendor"]]], [start_of_game: ["Prince Renathal"]]},
    "Libram Paladin":
      {[
         all: [["Interstellar Wayfarer"], ["Aldor Truthseeker", "Libram of Faith"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [
           ["Lightray"],
           [
             "Chillblade Champion",
             "Crystology",
             "Interstellar Researcher",
             "Interstellar Starslicer",
             "Knight of Anointment",
             "Libram of Divinity"
           ]
         ],
         all: [
           ["Knight of Anointment"],
           ["Aldor Attendant", "Interstellar Researcher", "Libram of Divinity", "Libram of Wisdom"]
         ],
         all: [["Adaptation"], ["Interstellar Researcher"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Myrmidon"], ["Aldor Attendant", "Interstellar Starslicer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin": {[all: [["Crusader Aura"], ["Goldwing"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sphere of Sapience"], ["Violet Treasuregill"]]]
      ]
    ],
    "Exodia Paladin": {[all: [["Crystology"], ["Greedy Partner"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Miracle Salesman"], ["Resistance Aura"]]]
      ]
    ],
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Captain's Parrot"],
            ["Runi, Time Explorer", "Spirit of the Badlands", "The Curator", "Zephrys the Great"]
          ],
          all: [
            ["Grillmaster"],
            ["Hand of Infinity", "Instrument Tech", "Judgment", "Mining Casualties"]
          ],
          all: [
            ["Mining Casualties"],
            ["Hand of Infinity", "Instrument Tech", "The Curator"]
          ],
          all: [["Bloodsail Raider"], ["Runi, Time Explorer"]],
          all: [["Hand of Infinity"], ["Tigress Plushy"]],
          all: [["Instrument Tech"], ["Toreth the Unbreaking"]],
          all: [["Judgment"], ["The Curator"]]
        ]
      ]
    ],
    "Clone Mech Paladin": {[all: [["Drone Deconstructor"], ["Goldwing"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin":
      {[
         all: [["Drone Deconstructor"], ["Sky Claw", "Violet Treasuregill"]],
         all: [["Frequency Oscillator"], ["Sky Claw"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin": {[all: [["Nerub'ar Weblord"], ["Razorscale"]]], [start_of_game: ["Prince Renathal"]]},
    "LC Quest Paladin":
      {[
         all: [["Dive the Golakka Depths"], ["Gnawing Greenfin"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Combo Paladin": {[all: [["Crystology"], ["Hand of Infinity"]]], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Crystology"], ["Aldor Attendant", "Interstellar Starslicer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin":
      {[
         all: [["Call to Arms"], ["Miracle Salesman"]],
         all: [["Righteous Protector"], ["Sword of the Fallen"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin":
      {[
         all: [["Boogie Down"], ["Redemption", "Sword of the Fallen"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin": {[all: [["Blood Matriarch Liadrin"], ["Irondeep Trogg"]]], [start_of_game: ["Prince Renathal"]]},
    "Exodia Paladin":
      {[
         all: [["Coldlight Oracle"], ["Time Out!"]],
         all: [["Miracle Salesman"], ["Prize Vendor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Gelbin of Tomorrow"],
            ["Astalor Bloodsworn", "Crystology", "Miracle Salesman", "Sir Finley of the Sands"]
          ],
          all: [
            ["Chronological Aura"],
            ["Runi, Time Explorer", "Zephrys the Great"]
          ],
          all: [["Miracle Salesman"], ["Astalor Bloodsworn", "Blademaster Okani"]],
          all: [["Crusader Aura"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "CtA Paladin":
      {[
         all: [
           ["Boogie Down"],
           ["Call to Arms", "Crabrider", "Gold Panner", "Nerub'ar Weblord"]
         ],
         all: [["Irondeep Trogg"], ["Call to Arms", "Crabrider", "Showdown!"]],
         all: [["Call to Arms"], ["Righteous Protector"]],
         all: [["Crabrider"], ["Gold Panner"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [
           ["Aldor Attendant"],
           ["Interstellar Researcher", "Interstellar Starslicer", "Libram of Clarity", "Libram of Wisdom"]
         ],
         all: [
           ["Interstellar Researcher"],
           ["Interstellar Starslicer", "Libram of Clarity", "Libram of Wisdom"]
         ],
         all: [
           ["Interstellar Starslicer"],
           ["Libram of Clarity", "Libram of Wisdom"]
         ],
         all: [["Libram of Clarity"], ["Libram of Wisdom"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Gelbin of Tomorrow"], ["Spirit of the Badlands"]]]
      ]
    ],
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Redscale Dragontamer"],
            ["Crystology", "Reno, Lone Ranger", "Sir Finley, Sea Guide"]
          ],
          all: [["Animated Broomstick"], ["Crystology"]],
          all: [["Grillmaster"], ["Nozdormu the Timeless"]]
        ]
      ]
    ],
    "STD Pure Paladin": {[all: [["Reinforcement Aura"], ["Vigilant Sentry"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Aura CtA Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Call to Arms"], ["Razorscale"]]]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Crabrider"], ["Crystology"]]]
      ]
    ],
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Knight of Anointment"], ["Rebuke"]]]
      ]
    ],
    "Exodia Paladin": {[all: [["Dragonscale Armaments"], ["Miracle Salesman"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Resistance Aura"]],
          all: [["Gelbin of Tomorrow"], ["Timeline Accelerator"]]
        ]
      ]
    ],
    "Combo Paladin":
      {[
         all: [["Bloodsail Raider"], ["Hand of Infinity", "Judgment"]],
         all: [["Cold Feet"], ["Knight of Anointment"]],
         all: [["Hand of Infinity"], ["Judgment"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "CtA Paladin": {[all: [["Call to Arms"], ["Oh My Yogg!"]]], [start_of_game: ["Prince Renathal"]]},
    "Clone Mech Paladin": {[all: [["Drone Deconstructor"], ["Radar Detector"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Razorscale"], ["Runi, Time Explorer"]]]
      ]
    ],
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Curator"],
            ["Sir Finley of the Sands", "Timeline Accelerator"]
          ],
          all: [["Instrument Tech"], ["Knight of Anointment"]]
        ]
      ]
    ],
    "XL Highlander Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spirit of the Badlands"], ["The Curator"]]]
      ]
    ],
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Amitus, the Peacekeeper"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "STD Pure Paladin": {[all: [["Acceleration Aura"], ["Righteous Protector"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Nozdormu the Timeless"]]]
      ]
    ],
    "XL Aura CtA Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Order in the Court"], ["Prismatic Beam"]]]
      ]
    ],
    "XL CtA Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Crabrider"], ["Crusader Aura", "Nerub'ar Weblord"]]]
      ]
    ],
    "Exodia Paladin": {[all: [["Dragonscale Armaments"], ["Prize Vendor"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Paladin": {[all: [["Instrument Tech"], ["Service Bell"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Nozdormu the Timeless"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "CtA Paladin": {[all: [["Crusader Aura"], ["Showdown!"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Paladin":
      {[
         all: [["Acceleration Aura"], ["Prismatic Beam"]],
         all: [["Gold Panner"], ["Violet Treasuregill"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno, Lone Ranger"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Highlander Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bob the Bartender"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Lightcaller"], ["Spirit of the Badlands"]]]
      ]
    ],
    "XL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Bloodsail Raider"], ["Hand of Infinity"]]]
      ]
    ],
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spirit of the Badlands"], ["Time Out!"]]]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Razorscale"]],
          all: [["Rebuke"], ["Spirit of the Badlands"]],
          all: [["Sir Finley of the Sands"], ["Tigress Plushy"]]
        ]
      ]
    ],
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Crystology"], ["Prince Renathal"]],
          all: [["Dirty Rat"], ["Sir Finley, Sea Guide"]],
          all: [["Nozdormu the Timeless"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "STD Holy Paladin": {[all: [["Acceleration Aura"], ["Resistance Aura"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Crystology"],
            ["Knight of Anointment", "Runi, Time Explorer", "Sir Finley, Sea Guide"]
          ],
          all: [["Runi, Time Explorer"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prismatic Beam"], ["Runi, Time Explorer"]]]
      ]
    ],
    "Yogg Paladin": {[all: [["Instrument Tech"], ["Prismatic Beam"]]], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin": {[all: [["Crystology"], ["Instrument Tech"]]], [start_of_game: ["Prince Renathal"]]},
    "Lynessa Libram Paladin":
      {[
         all: [["Showdown!"], ["Crystology", "Prismatic Beam"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Exodia Paladin":
      {[
         all: [["Dragonscale Armaments"], ["Knight of Anointment"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Ursol Paladin": {[all: [["Humble Judgment"], ["Sun's Reckoning"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prismatic Beam"], ["Spirit of the Badlands"]]]
      ]
    ],
    "XL HL Infinity Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Aura Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Runi, Time Explorer"], ["Spirit of the Badlands"]]]
      ]
    ],
    "XL Highlander Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spirit of the Badlands"], ["Zephrys the Great"]]]
      ]
    ],
    "Clone CtA Paladin": {[all: [["Oh My Yogg!"], ["Prismatic Beam"]]], [start_of_game: ["Prince Renathal"]]},
    "XL CtA Paladin": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prismatic Beam"], ["Showdown!"]]]
      ]
    ],
    "Odd Paladin": {[all: [["Crystology"], ["Knight of Anointment"]]], [start_of_game: ["Prince Renathal"]]}
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
