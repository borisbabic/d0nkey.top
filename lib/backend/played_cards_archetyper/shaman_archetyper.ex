# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  alias Backend.Hearthstone.Card
  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  defp any_non_mugzee_minion?(card_info) do
    Enum.any?(card_info.full_cards, fn c ->
      Card.minion?(c) and Card.name(c) != "Mug'Zee"
    end)
  end

  defp any_spell?(card_info) do
    Enum.any?(card_info.full_cards, fn c ->
      Card.spell?(c)
    end)
  end

  @minion_cthun ["Spawn of C'Thun", "C'Thun, Eye of the Empire", "Gargantuan Slitherer"]

  defp standard_excludes,
    do: %{
      "Harold Shaman" => [{:start_of_game, ["Mug'Zee"]}]
    }

  defp base_standard_config do
    [
      "Quest Shaman": ["Spirit of the Mountain"],
      "Zee Shaman": [
        {:all,
         [
           {:start_of_game, ["Mug'Zee"]},
           &any_non_mugzee_minion?/1
         ]}
      ],
      "Mug Shaman": [
        {:all,
         [
           [{:start_of_game, ["Mug'Zee"]}],
           {:any,
            [
              &any_spell?/1,
              ["Low Security Wing"]
            ]}
         ]}
      ],
      "Harold Shaman": [
        "Al'Akir, Lord of Storms",
        "Avatar Form",
        "Breezling",
        "Crackling Cloudstrider",
        "Deathwing, Worldbreaker",
        "Elise the Navigator",
        "Envoy of the End",
        "Fae Trickster",
        "High King's Hammer",
        "Muradin, High King",
        "Primordial Overseer",
        "Ritual of Power",
        "Static Shock",
        "Blazing Invocation",
        "Sands of Time",
        "Muradin's Last Stand",
        "Twilight Egg",
        "Ultraxion"
      ]
    ]
  end

  @wild_config [
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Bolner Hammerbeak"], ["Living Flame"]],
          all: [["Carry-On Grub"], ["Plague of Murlocs"]],
          all: [["Doctor Holli'dae"], ["Overplanner"]],
          all: [["Eyemaul"], ["Thrall's Gift"]],
          all: [["Far Watch Post"], ["Ice Fishing"]],
          all: [["Investment Opportunity"], ["Turbulus"]]
        ]
      ]
    ],
    "XL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Clownfish"], ["Granite Forgeborn"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Devolving Missiles"], ["Far Watch Post"]],
          all: [["Disguised Detective"], ["Zilliax Deluxe 3000"]],
          all: [["Eyemaul"], ["The Curator"]],
          all: [["Razorscale"], ["Y'Shaarj, Titan Bane"]]
        ]
      ]
    ],
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Marin the Manager"]]]
      ]
    ],
    "XL Questline Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Command the Elements"], ["Triangulate"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Disguised Detective"],
            ["Blademaster Okani", "Golganneth, the Thunderer", "Nightmare Lord Xavius", "Speaker Stomper"]
          ],
          all: [["Devolving Missiles"], ["Razorscale"]],
          all: [["Far Watch Post"], ["Sphere of Sapience"]],
          all: [["Lightning Storm"], ["Toxfin"]]
        ]
      ]
    ],
    "XL LC Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cactus Cutter"], ["Spirit of the Mountain"]]]
      ]
    ],
    "XL Shudderwock Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Healing Rain"], ["Prescience"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Living Flame"], ["Mutanus the Devourer", "Zephrys the Great"]],
          all: [["Ancestral Knowledge"], ["Far Watch Post"]],
          all: [["Eyemaul"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Doctor Holli'dae"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Malted Magma"], ["Primal Dungeoneer", "The Curator"]],
          all: [["Azerite Chain Gang"], ["Doctor Holli'dae"]],
          all: [["Firemancer Flurgl"], ["Primal Dungeoneer"]],
          all: [["Glacial Shard"], ["Murloc Growfin"]],
          all: [["Miracle Salesman"], ["Thrall's Gift"]],
          all: [["Reno Jackson"], ["Schooling"]]
        ]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Backstage Bouncer"], ["Malted Magma"]],
          all: [["Dirty Rat"], ["Eyemaul"]],
          all: [["Elemental Destruction"], ["Firemancer Flurgl"]]
        ]
      ]
    ],
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["The Curator"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Curator"],
            [
              "Far Watch Post",
              "Grumble, Worldshaker",
              "Lightning Storm",
              "Lorekeeper Polkelt",
              "Parrot Sanctuary",
              "Primal Dungeoneer",
              "Sir Finley, Sea Guide",
              "Sphere of Sapience"
            ]
          ],
          all: [
            ["Golakka Crawler"],
            ["Bolner Hammerbeak", "Nightmare Lord Xavius", "Razorscale", "Schooling", "Ysera, Emerald Aspect"]
          ],
          all: [
            ["Miracle Salesman"],
            ["Aftershocks", "Cactus Cutter", "Cold Storage", "Needlerock Totem", "Reno Jackson"]
          ],
          all: [["Revolve"], ["Far Watch Post", "Reno Jackson"]],
          all: [["Loatheb"], ["Plague of Murlocs"]]
        ]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Doctor Holli'dae"], ["Sphere of Sapience", "Twin-fin Fin Twin"]],
          all: [["Razorscale"], ["Toxfin"]],
          all: [["Reno, Lone Ranger"], ["The Curator"]]
        ]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Curator"], ["Timeline Accelerator"]]]
      ]
    ],
    "XL Shudderwock Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Armor Vendor"], ["Glacial Shard", "Triangulate"]]]
      ]
    ],
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Reno Jackson"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Reno Jackson"], ["Astalor Bloodsworn", "Sphere of Sapience"]],
          all: [["Carry-On Grub"], ["Doctor Holli'dae"]],
          all: [["Far Watch Post"], ["Malted Magma"]],
          all: [["Murloc Growfin"], ["Sphere of Sapience"]],
          all: [["Nightmare Lord Xavius"], ["Schooling"]]
        ]
      ]
    ],
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Far Watch Post"],
            [
              "Baking Soda Volcano",
              "Birdwatching",
              "Bolner Hammerbeak",
              "Cold Storage",
              "Devolve",
              "Doctor Holli'dae",
              "Golganneth, the Thunderer",
              "Lorekeeper Polkelt",
              "Nightmare Lord Xavius",
              "Parrot Sanctuary",
              "Reno, Lone Ranger",
              "Snowfall Guardian",
              "Timeline Accelerator",
              "Unnatural Cold",
              "Zephrys the Great",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Doctor Holli'dae"],
            [
              "Aftershocks",
              "Astalor Bloodsworn",
              "Bolner Hammerbeak",
              "Cactus Cutter",
              "Cold Storage",
              "Cult Neophyte",
              "E.T.C., Band Manager",
              "Elemental Destruction",
              "Grumble, Worldshaker",
              "Loatheb",
              "Malted Magma",
              "Razorscale",
              "Shudderwock",
              "Speaker Stomper"
            ]
          ],
          all: [
            ["Razorscale"],
            [
              "Baking Soda Volcano",
              "Fairy Tale Forest",
              "Lorekeeper Polkelt",
              "Pebbly Page",
              "Reno, Lone Ranger",
              "Unnatural Cold"
            ]
          ],
          all: [
            ["Malted Magma"],
            ["Blademaster Okani", "Bolner Hammerbeak", "Cult Neophyte"]
          ],
          all: [["Reno Jackson"], ["E.T.C., Band Manager", "Lorekeeper Polkelt"]],
          all: [["Bolner Hammerbeak"], ["Reno, Lone Ranger"]],
          all: [["Cult Neophyte"], ["Ice Fishing"]]
        ]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno Jackson"], ["Baking Soda Volcano", "Parrot Sanctuary"]]]
      ]
    ],
    "Even Shaman":
      {[
         all: [["Windfury"], ["Ancient Totem", "The Stonewright"]],
         all: [["Flametongue Totem"], ["Zilliax Deluxe 3000"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Zee Shaman": {[all: [["Ashen Elemental"], ["Wailing Vapor"]]], [start_of_game: ["Prince Renathal"]]},
    "Even Shaman": {[all: [["Devolve"], ["Ancient Totem", "The Stonewright"]]], [start_of_game: ["Prince Renathal"]]},
    "Elemental Shaman": {[all: [["Azerite Giant"], ["Wailing Vapor"]]], [start_of_game: ["Prince Renathal"]]},
    "Zee Shaman": {[all: [["Fire Fly"], ["Fire Plume Harbinger"]]], [start_of_game: ["Prince Renathal"]]},
    "Questline Shaman": {[all: [["Command the Elements"], ["Finders Keepers"]]], [start_of_game: ["Prince Renathal"]]},
    "Even Shaman": {[all: [["Jam Session"], ["Splitting Axe"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Shaman": {[all: [["Spirit Claws"], ["Zap!"]]], [start_of_game: ["Prince Renathal"]]},
    "Even Shaman":
      {[
         all: [["Jam Session"], ["Thing from Below", "Totemic Might"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Y'Shaarj Shaman": {[all: [["Ancestral Knowledge"], ["Jazz Bass"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Zee C'Thun Shaman": {[all: [["Holy Eggbearer"], ["Spawn of C'Thun"]]], [start_of_game: ["Prince Renathal"]]},
    "Even Shaman": {[all: [["Carving Chisel"], ["Crackle"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Shaman": {[all: [["Ancestral Spirit"], ["Zap!"]]], [start_of_game: ["Prince Renathal"]]},
    "Even Shaman": {[all: [["Ancient Totem"], ["Totemic Might"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Shaman":
      {[
         all: [["Scalding Geyser"], ["Bracing Cold", "Rockbiter Weapon"]],
         all: [["Windchill"], ["Ancestral Spirit", "Muckmorpher"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Zephrys the Great"], ["Aftershocks", "Cactus Cutter"]]]
      ]
    ],
    "XL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Tour Guide"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Zephrys the Great"],
            [
              "Astalor Bloodsworn",
              "Backstage Bouncer",
              "Bolner Hammerbeak",
              "Boompistol Bully",
              "Brilliant Macaw",
              "Cold Storage",
              "Cult Neophyte",
              "Devolve",
              "Dirty Rat",
              "Elemental Destruction",
              "Framester",
              "Grumble, Worldshaker",
              "Lorekeeper Polkelt",
              "Murloc Growfin",
              "Parrot Sanctuary",
              "Pebbly Page",
              "Primal Dungeoneer",
              "Razorscale",
              "Speaker Stomper",
              "Timeline Accelerator",
              "Turbulus",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Reno, Lone Ranger"],
            [
              "Boompistol Bully",
              "Brilliant Macaw",
              "Cold Storage",
              "Cult Neophyte",
              "Elemental Destruction",
              "Golganneth, the Thunderer",
              "Grumble, Worldshaker",
              "Lorekeeper Polkelt",
              "Murloc Growfin",
              "Parrot Sanctuary",
              "Turbulus",
              "Zilliax Deluxe 3000"
            ]
          ],
          all: [
            ["Murloc Growfin"],
            [
              "Backstage Bouncer",
              "Boompistol Bully",
              "Cold Storage",
              "Cult Neophyte",
              "Elemental Destruction",
              "Framester",
              "Lorekeeper Polkelt",
              "Razorscale",
              "Timeline Accelerator"
            ]
          ],
          all: [
            ["Razorscale"],
            ["Backstage Bouncer", "Cult Neophyte", "E.T.C., Band Manager", "Primal Dungeoneer", "Turbulus"]
          ],
          all: [
            ["Parrot Sanctuary"],
            ["Doctor Holli'dae", "Needlerock Totem", "Primal Dungeoneer"]
          ],
          all: [["Speaker Stomper"], ["Birdwatching", "Zilliax Deluxe 3000"]],
          all: [["Cult Neophyte"], ["Needlerock Totem"]],
          all: [["Lorekeeper Polkelt"], ["Mutanus the Devourer"]]
        ]
      ]
    ],
    "XL Shudderwock Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Elemental Destruction"],
            ["Investment Opportunity", "Scalding Geyser"]
          ],
          all: [["Investment Opportunity"], ["Zilliax Deluxe 3000"]],
          all: [["Scalding Geyser"], ["Ysera, Emerald Aspect"]]
        ]
      ]
    ],
    "SoU Quest Shaman": {[all: [["Cactus Cutter"], ["Corrupt the Waters"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Astalor Bloodsworn", "Cult Neophyte"]]]
      ]
    ],
    "Even Shaman": {[all: [["Totemic Surge"], ["Trusty Companion"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Zee C'Thun Shaman":
      {[
         all: [["Gargantuan Slitherer"], ["Skywall Sentinel", "Wailing Vapor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Cult Neophyte"],
            [
              "Backstage Bouncer",
              "Baking Soda Volcano",
              "Parrot Sanctuary",
              "Sir Finley, Sea Guide",
              "Timeline Accelerator"
            ]
          ]
        ]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Loatheb"], ["Speaker Stomper"]]]
      ]
    ],
    "SoU Quest Shaman": {[all: [["Brilliant Macaw"], ["Corrupt the Waters"]]], [start_of_game: ["Prince Renathal"]]},
    "Shudderwock Shaman": {[all: [["Needlerock Totem"], ["Twin-fin Fin Twin"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Primal Dungeoneer"], ["Turbulus"]]]
      ]
    ],
    "Big Shaman": {[all: [["Ancestor's Call"], ["Unnatural Cold"]]], [start_of_game: ["Prince Renathal"]]},
    "Even Shaman": {[all: [["Carving Chisel"], ["Flametongue Totem"]]], [start_of_game: ["Prince Renathal"]]},
    "Harold Shaman": {[all: [["Envoy of the End"], ["Ritual of Power"]]], [start_of_game: ["Prince Renathal"]]},
    "Zee Shaman": {[all: [["Granite Forgeborn"], ["Kindling Elemental"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Shudderwock Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Missile Pod"]]]
      ]
    ],
    "Ohn'ahra Big Shaman":
      {[
         all: [["Ancestral Knowledge"], ["Jam Session"]],
         all: [["Muckmorpher"], ["Vivid Spores"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Blademaster Okani"], ["Parrot Sanctuary", "Razorscale"]],
          all: [
            ["Bolner Hammerbeak"],
            ["Lightning Storm", "Timeline Accelerator"]
          ],
          all: [["Birdwatching"], ["Dirty Rat"]],
          all: [["Ice Fishing"], ["Sir Finley, Sea Guide"]],
          all: [["Nightmare Lord Xavius"], ["Parrot Sanctuary"]]
        ]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Boompistol Bully"], ["Turbulus"]]]
      ]
    ],
    "XL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Corrupt the Waters"],
            ["Grumble, Worldshaker", "Snowfall Guardian"]
          ]
        ]
      ]
    ],
    "Elemental Shaman":
      {[
         all: [["Fire Fly"], ["Shock Hopper"]],
         all: [["Flame Revenant"], ["Wailing Vapor"]],
         all: [["Minecart Cruiser"], ["Shale Spider"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Devolve"], ["Turbulus"]]]
      ]
    ],
    "XL Shudderwock Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cactus Cutter"], ["Devolving Missiles"]]]
      ]
    ],
    "Ohn'ahra Big Shaman":
      {[
         all: [["Ancestral Knowledge"], ["Muckmorpher"]],
         all: [["Auctionhouse Gavel"], ["Reincarnate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blademaster Okani"], ["Turbulus"]]]
      ]
    ],
    "HL Shudder Shaman":
      {[
         all: [["Lightning Storm"], ["Dirty Rat", "Primal Dungeoneer"]],
         all: [["Reno, Lone Ranger"], ["Blademaster Okani", "Mutanus the Devourer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL SoU Quest Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Corrupt the Waters"], ["Dirty Rat"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Loatheb", "Timeline Accelerator"]]]
      ]
    ],
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Dirty Rat"],
            ["Baking Soda Volcano", "Bolner Hammerbeak", "E.T.C., Band Manager"]
          ],
          all: [["Blademaster Okani"], ["Bolner Hammerbeak"]],
          all: [["Cold Storage"], ["Elemental Destruction"]]
        ]
      ]
    ],
    "Ohn'ahra Big Shaman":
      {[
         all: [["Eureka!"], ["Fairy Tale Forest", "Triangulate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Y'Shaarj Shaman": {[all: [["Scalding Geyser"], ["Windchill"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shudder Shaman": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Devolve"],
            ["Aftershocks", "E.T.C., Band Manager", "Elemental Destruction", "Lightning Storm"]
          ],
          all: [["Baking Soda Volcano"], ["Lightning Storm"]]
        ]
      ]
    ],
    "STD Zee C'Thun Shaman": {[all: [["Fire Fly"], ["Skywall Sentinel"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Shaman": {[all: [["Ancestral Spirit"], ["Lightning Bloom"]]], [start_of_game: ["Prince Renathal"]]},
    "Ohn'ahra Big Shaman":
      {[
         all: [
           ["Triangulate"],
           ["Ancestor's Call", "Auctionhouse Gavel", "Muckmorpher", "Scalding Geyser"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big Shaman":
      {[
         all: [["Ancestor's Call"], ["Ancestral Spirit", "Jam Session"]],
         all: [["Ancestral Spirit"], ["Scalding Geyser"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Ohn'ahra Big Shaman":
      {[
         all: [
           ["Scalding Geyser"],
           ["Ancestor's Call", "Auctionhouse Gavel", "Fairy Tale Forest", "Muckmorpher"]
         ],
         all: [["Devolve"], ["Muckmorpher"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Shudderwock Shaman": {[all: [["Blademaster Okani"], ["Brilliant Macaw"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Shaman": {[all: [["Ancestor's Call"], ["Auctionhouse Gavel"]]], [start_of_game: ["Prince Renathal"]]},
    "Evolve Shaman": {[all: [["Eyemaul"], ["Muradin's Last Stand"]]], [start_of_game: ["Prince Renathal"]]},
    "Ohn'ahra Big Shaman": {[all: [["Fairy Tale Forest"], ["Muckmorpher"]]], [start_of_game: ["Prince Renathal"]]},
    "Yogg Shaman": {[all: [["Auctionhouse Gavel"], ["Fairy Tale Forest"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Shaman": {[all: [["Unnatural Cold"], ["Windchill"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Elemental Shaman": {[all: [["Fire Fly"], ["Wailing Vapor"]]], [start_of_game: ["Prince Renathal"]]},
    "Shudderwock Shaman":
      {[
         all: [["Grumble, Worldshaker"], ["Shudderwock", "Ysera, Emerald Aspect"]]
       ], [start_of_game: ["Prince Renathal"]]}
  ]

  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(base_standard_config(), standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Shaman")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Shaman")
  end
end
