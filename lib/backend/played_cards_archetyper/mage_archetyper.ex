# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @leyline_package [
    "Bursting Leyline",
    "Crystallized Leyline",
    "Ley Walker",
    "Leyline Nexus",
    "Mystic Runesaber",
    "Surge Needle",
    "The Arcanomicon"
  ]
  @standard_excludes %{}
  @standard_config [
    "Quest Mage": ["The Forbidden Sequence"],
    "Leyline Mage": [
      all: [["Ley Walker"], ["Breakout Architect", "Thaw From Ice"]],
      all: [["Mystic Runesaber"], ["Astral Rain", "Sizzling Cinder"]],
      all: [["Archmage Kalec"], ["Surge Needle"]]
    ],
    "Burn Mage": [
      all: [["Arcane Flow"], ["Cosmic Springs"]],
      all: [["Raincaller"], ["Time-Twisted Seer"]]
    ],
    "Leyline Mage": [all: [["Surge Needle"], ["The Skeleton Key"]]],
    "Burn Mage": [all: [["Scorching Winds"], ["Sizzling Cinder"]]],
    "Leyline Mage": [all: [["Discs of Norgannon"], ["Mystic Runesaber"]]],
    "Burn Mage": [
      all: [["Sizzling Cinder"], ["Archmage Kalec", "Frostbolt"]],
      all: [["Arcane Missiles"], ["Time-Twisted Seer"]],
      all: [["Second Flame"], ["Violet Spellwing"]]
    ],
    "Leyline Mage": [
      all: [["Bloodmage Thalnos"], ["Bursting Leyline", "Crystallized Leyline"]],
      all: [["Sands of Time"], ["Ley Walker", "Surge Needle"]],
      all: [["Smoldering Grove"], ["Bursting Leyline", "The Arcanomicon"]]
    ],
    "Burn Mage": [
      all: [["Living Flame"], ["Spellweaver's Brilliance", "Time-Twisted Seer"]],
      all: [["Bloodmage Thalnos"], ["Scorching Winds"]]
    ],
    "Leyline Mage": [
      all: [["Tricksy Improviser"], ["Surge Needle", "The Arcanomicon"]]
    ],
    "Burn Mage": [
      all: [
        ["Story of the Waygate"],
        [
          "Arcane Barrage",
          "Archmage Kalec",
          "Arrival of the Titans",
          "Bloodmage Thalnos",
          "Contraband Wands",
          "Cosmic Springs",
          "Fireball",
          "First Flame",
          "Frostbolt",
          "Icebelt Magi",
          "Scorching Winds",
          "Sleet Storm",
          "Smoldering Grove",
          "Spellweaver's Brilliance",
          "Time-Twisted Seer",
          "Tricksy Improviser",
          "Tunneling Geomancer",
          "Violet Spellwing"
        ]
      ],
      all: [
        ["Time-Twisted Seer"],
        [
          "Arcane Barrage",
          "Archmage Kalec",
          "Arrival of the Titans",
          "Bloodmage Thalnos",
          "Contraband Wands",
          "Cosmic Springs",
          "Fireball",
          "First Flame",
          "Icebelt Magi",
          "Scorching Winds",
          "Sleet Storm",
          "Smoldering Grove",
          "Spellweaver's Brilliance",
          "Tricksy Improviser",
          "Tunneling Geomancer",
          "Violet Spellwing"
        ]
      ],
      all: [
        ["Scorching Winds"],
        [
          "Arcane Barrage",
          "Archmage Kalec",
          "Arrival of the Titans",
          "Contraband Wands",
          "Cosmic Springs",
          "First Flame",
          "Frostbolt",
          "Icebelt Magi",
          "Sleet Storm",
          "Smoldering Grove",
          "Spellweaver's Brilliance",
          "Tricksy Improviser",
          "Tunneling Geomancer",
          "Violet Spellwing"
        ]
      ],
      all: [
        ["Tunneling Geomancer"],
        [
          "Arcane Barrage",
          "Archmage Kalec",
          "Arrival of the Titans",
          "Bloodmage Thalnos",
          "Contraband Wands",
          "Cosmic Springs",
          "First Flame",
          "Icebelt Magi",
          "Sleet Storm",
          "Smoldering Grove",
          "Spellweaver's Brilliance",
          "Tricksy Improviser",
          "Violet Spellwing"
        ]
      ],
      all: [
        ["Violet Spellwing"],
        [
          "Arcane Barrage",
          "Archmage Kalec",
          "Contraband Wands",
          "Cosmic Springs",
          "First Flame",
          "Icebelt Magi",
          "Sleet Storm",
          "Smoldering Grove",
          "Spellweaver's Brilliance"
        ]
      ],
      all: [
        ["Contraband Wands"],
        [
          "Arcane Barrage",
          "Archmage Kalec",
          "Bloodmage Thalnos",
          "Smoldering Grove",
          "Spellweaver's Brilliance",
          "Tricksy Improviser"
        ]
      ],
      all: [["Bloodmage Thalnos"], ["Spellweaver's Brilliance"]],
      all: [["Icebelt Magi"], ["Smoldering Grove"]]
    ],
    "Leyline Mage": [all: [["Ley Walker"], ["Dirty Rat", "First Flame"]]],
    "Imbue Mage": [
      all: [["Spirit Gatherer"], ["Malorne the Waywatcher", "Merry Moonkin"]],
      all: [["Aessina"], ["Resplendent Dreamweaver"]]
    ],
    "Leyline Mage": [all: [["Frostbolt"], ["Ley Walker"]]],
    "Quest Mage": [
      all: [["The Origin Stone"], ["Scrappy Scavenger", "Shadowed Informant"]]
    ],
    "Big Spell Mage": [
      all: [["Cult Neophyte"], ["Spire Security"]],
      all: [["Elise the Navigator"], ["Watfin"]]
    ],
    "Leyline Mage": [
      all: [
        ["Cosmic Springs"],
        ["Bursting Leyline", "Ley Walker", "Surge Needle"]
      ],
      all: [["Ley Walker"], ["Arcane Barrage", "The Skeleton Key"]],
      all: [["Surge Needle"], ["Coilbearer", "Thaw From Ice"]],
      all: [["Mystic Runesaber"], ["The Skeleton Key"]]
    ],
    "Imbue Mage": [all: [["Flutterwing Guardian"], ["Runed Orb"]]],
    "Leyline Mage": [
      all: [
        ["Mystic Runesaber"],
        ["Archmage Kalec", "Jailhouse Manastorm", "Tricksy Improviser"]
      ]
    ],
    "Summoner Mage": [
      all: [
        ["Khadgar"],
        [
          "Astral Rain",
          "Constellar's Calling",
          "Cosmic Springs",
          "Isiset",
          "Jailhouse Manastorm",
          "Sands of Time",
          "The Skeleton Key"
        ]
      ],
      all: [
        ["Constellar's Calling"],
        ["Code Violet", "Icebelt Magi", "Spellweaver's Brilliance", "Tribute Dance"]
      ],
      all: [["Code Violet"], ["Icebelt Magi"]]
    ],
    "Imbue Mage": [all: [["Flutterwing Guardian"], ["Winterspring Whelp"]]],
    "Leyline Mage": [
      all: [
        ["Mystic Runesaber"],
        ["First Flame", "Nightmare Lord Xavius", "Sleet Storm"]
      ],
      all: [["Ley Walker"], ["Runed Orb", "Sleet Storm"]],
      all: [["Surge Needle"], ["First Flame", "Sleet Storm"]],
      all: [["Bursting Leyline"], ["Runed Orb"]]
    ],
    "Imbue Mage": [all: [["Spirit Gatherer"], ["Wisprider"]]],
    "Big Spell Mage": [all: [["Nightmare Lord Xavius"], ["Violet Spellwing"]]],
    "Leyline Mage": [
      all: [["Leyline Nexus"], ["Ley Walker", "Mystic Runesaber", "Surge Needle"]]
    ],
    "Summoner Mage": [
      all: [
        ["Constellar's Calling"],
        ["Isiset", "Mastermind Yogg-Saron", "Tricksy Improviser"]
      ],
      all: [["Code Violet"], ["Isiset"]],
      all: [["Mirror Dimension"], ["Thaw From Ice"]]
    ],
    "Leyline Mage": [
      all: [["Ley Walker"], ["Mystic Runesaber", "Surge Needle"]],
      all: [["Mystic Runesaber"], ["Surge Needle"]]
    ],
    "Summoner Mage": [all: [["Icebelt Magi"], ["Isiset"]]],
    "Big Spell Mage": [all: [["Conjured Bookkeeper"], ["Spire Security"]]],
    "Toki Mage": [all: [["Portal Vanguard"], ["Timelooper Toki"]]],
    "Summoner Mage": [
      all: [
        ["Code Violet"],
        ["Cosmic Springs", "Foreboding Freeze", "Mastermind Yogg-Saron", "Spellweaver's Brilliance"]
      ],
      all: [["Constellar's Calling"], ["Sands of Time", "Thaw From Ice"]]
    ],
    "Toki Mage": [
      all: [
        ["Timelooper Toki"],
        ["Sands of Time", "Spark of Life", "Storage Scuffle"]
      ],
      all: [["Ysera, Emerald Aspect"], ["Nightmare Lord Xavius", "Sleet Storm"]]
    ],
    "Summoner Mage": [
      all: [
        ["Isiset"],
        [
          "Cold Snap",
          "Fireball",
          "Frostbolt",
          "Mastermind Yogg-Saron",
          "Relic of Kings",
          "Spellweaver's Brilliance",
          "Thaw From Ice",
          "The Skeleton Key"
        ]
      ],
      all: [
        ["Constellar's Calling"],
        ["Foreboding Freeze", "Sleet Storm", "The Skeleton Key"]
      ],
      all: [["Icebelt Magi"], ["Cold Snap", "Foreboding Freeze", "Thaw From Ice"]],
      all: [
        ["Portal Vanguard"],
        ["Discs of Norgannon", "Storage Scuffle", "Thaw From Ice"]
      ],
      all: [["Mastermind Yogg-Saron"], ["Relic of Kings"]]
    ],
    "Burn Mage": [all: [["Archmage Kalec"], ["Icebelt Magi"]]],
    "Toki Mage": [all: [["Runed Orb"], ["Timelooper Toki"]]],
    "Summoner Mage": [all: [["Astral Rain"], ["Code Violet"]]],
    "Burn Mage": [
      all: [
        ["Archmage Kalec"],
        ["Smoldering Grove", "Tricksy Improviser", "Winterspring Whelp"]
      ]
    ],
    "Summoner Mage": [
      all: [["Arrival of the Titans"], ["Thaw From Ice"]],
      all: [["Mastermind Yogg-Saron"], ["Tricksy Improviser"]]
    ],
    "Toki Mage": [
      all: [["Semi-Stable Portal"], ["Cold Snap", "Jailhouse Manastorm"]]
    ],
    "Burn Mage": [all: [["Contraband Wands"], ["Cosmic Springs"]]],
    "Summoner Mage": [
      all: [
        ["Thaw From Ice"],
        [
          "Astral Rain",
          "Code Violet",
          "Cold Snap",
          "Cosmic Springs",
          "First Flame",
          "Foreboding Freeze",
          "Jailhouse Manastorm",
          "Sleet Storm",
          "Tricksy Improviser"
        ]
      ],
      all: [
        ["Tricksy Improviser"],
        ["Alter Time", "Astral Rain", "Cold Snap", "Relic of Kings", "Storage Scuffle"]
      ],
      all: [["Foreboding Freeze"], ["Isiset", "Relic of Kings"]],
      all: [["Discs of Norgannon"], ["Isiset"]],
      all: [["Portal Vanguard"], ["Sands of Time"]]
    ],
    "Burn Mage": [
      all: [
        ["Tricksy Improviser"],
        ["Smoldering Grove", "Spellweaver's Brilliance"]
      ]
    ],
    "Summoner Mage": [all: [["Code Violet"], ["First Flame"]]],
    "Burn Mage": [
      all: [["Arcane Barrage"], ["Tricksy Improviser"]],
      all: [["Cosmic Springs"], ["Smoldering Grove"]]
    ],
    "Summoner Mage": [
      all: [
        ["Cosmic Springs"],
        ["Bitter End", "Cold Snap", "Discs of Norgannon", "Jailhouse Manastorm"]
      ]
    ],
    "Burn Mage": [
      all: [["Archmage Kalec"], ["Cosmic Springs", "First Flame"]],
      all: [["Arcane Barrage"], ["Cosmic Springs"]]
    ],
    "Burn Mage": [all: [["Cosmic Springs"], ["Tricksy Improviser"]]],
    "Big Spell Mage": [all: [["Arrival of the Titans"], ["Isiset"]]],
    "Summoner Mage": [
      all: [["First Flame"], ["Foreboding Freeze"]],
      all: [["Relic of Kings"], ["The Skeleton Key"]]
    ],
    "Toki Mage": [all: [["Dirty Rat"], ["Jailhouse Manastorm"]]],
    "Quest Mage": [all: [["Coilbearer"], ["Storage Scuffle"]]],
    "Toki Mage": [all: [["Blizzard"], ["Storage Scuffle"]]],
    "Summoner Mage": [all: [["Alter Time"], ["Blizzard"]]],
    "Summoner Mage": [
      all: [
        ["Astral Rain"],
        [
          "Blizzard",
          "Cold Snap",
          "Eternal Firebolt",
          "First Flame",
          "Foreboding Freeze",
          "Jailhouse Manastorm",
          "Sleet Storm"
        ]
      ],
      all: [["Eternal Firebolt"], ["Blizzard", "Relic of Kings"]],
      all: [["Arrival of the Titans"], ["Cold Snap"]],
      all: [["Foreboding Freeze"], ["The Skeleton Key"]]
    ],
    "Burn Mage": [all: [["Cosmic Springs"], ["First Flame"]]],
    "Burn Mage": [all: [["Arcane Barrage"], ["Sleet Storm"]]],
    "Summoner Mage": [
      all: [
        ["Nightmare Lord Xavius"],
        ["Arrival of the Titans", "Eternal Firebolt", "Jailhouse Manastorm"]
      ],
      all: [["Foreboding Freeze"], ["Jailhouse Manastorm", "Sleet Storm"]]
    ],
    "Summoner Mage": [all: [["Eternal Firebolt"], ["Jailhouse Manastorm"]]],
    "Summoner Mage": [all: [["First Flame"], ["Jailhouse Manastorm"]]],
    "Big Spell Mage": [
      all: [["Winterspring Whelp"], ["Tricksy Improviser", "Violet Spellwing"]]
    ],
    "Burn Mage": [all: [["First Flame"], ["Sleet Storm"]]],
    "Other Mage": [all: [["Spark of Life"], ["Runed Orb", "Sands of Time"]]],
    "Burn Mage": [all: [["Runed Orb"], ["Sleet Storm"]]]
    # "Leyline Mage": @leyline_package,
    # "Imbue Mage": [
    #   "Bitterbloom Knight",
    #   "Divination",
    #   "Flutterwing Guardian",
    #   # "Malorne the Waywatcher",
    #   "Petal Picker",
    #   "Resplendent Dreamweaver",
    #   "Spirit Gatherer",
    #   "Wisprider"
    # ],
    # "Burn Mage": [
    #   "Story of the Waygate",
    #   "Time-Twisted Seer",
    #   "Scorching Winds",
    #   "Tunneling Geomancer",
    #   "Bloodmage Thalnos",
    #   "Unstable Spellcaster"
    # ],
    # "Summoner Mage": ["Constellar's Calling", "Khadgar"],
    # "Burn Mage": [
    #   "Contraband Wands",
    #   "Archmage Kalec",
    #   "Violet Spellwing"
    # ],
    # "Summoner Mage": [
    #   "Icebelt Magi",
    #   "Code Violet",
    #   "Isiset",
    #   "Thaw From Ice",
    #   "Cosmic Springs"
    # ],
    # # auto gen
    # "Summoner Mage": [
    #   "Arrival of the Titans",
    #   "Astral Rain",
    #   "Bitter End",
    #   "Blizzard",
    #   "Cold Snap",
    #   "Discs of Norgannon",
    #   "Eternal Firebolt",
    #   "First Flame",
    #   "Foreboding Freeze",
    #   "Jailhouse Manastorm",
    #   "Portal Vanguard",
    #   "Relic of Kings"
    # ],
    # "Burn Mage": ["Winterspring Whelp"]
  ]
  @wild_config [
    "Other Mage": ["Dire Wolf Alpha", "Evasive Wyrm", "Faerie Dragon", "Imposing Anubisath", "Raid Leader"],
    "Elemental Mage": ["Tar Slime"],
    "XL HL Exodia Mage": ["Font of Power"],
    "JtU Quest Mage": ["Sorcerer's Apprentice"],
    "XL HL Exodia Mage": ["Prismatic Elemental"],
    "Imbue Mage": ["Tour Guide"],
    "XL JtU Quest Mage": ["Energy Shaper"],
    "XL HL Exodia Mage": ["Sands of Time"],
    "XL Secret Mage": ["Kirin Tor Mage"],
    "Secret Mage": ["Kabal Lackey"],
    "XL JtU Quest Mage": ["Murozond, Unbounded", "Tae'thelan Bloodwatcher"],
    "XL HL Exodia Mage": ["Inquisitive Creation"],
    "Elemental Mage": ["Shale Spider"],
    "XL Secret Mage": ["Arcane Flakmage"],
    "JtU Quest Mage": ["Magister's Apprentice"],
    "XL HL Exodia Mage": ["Alter Time", "Buy One, Get One Freeze", "Card Grader"],
    "Imbue Mage": ["Wisprider"],
    "XL JtU Quest Mage": ["Open the Waygate"],
    "Small Spell Mage": ["Vicious Slitherspear"],
    "XL HL Exodia Mage": ["Infinitize the Maxitude"],
    "Giants Mage": ["Desk Imp", "Target Dummy"],
    "XL HL Big Spell Mage": ["Arcane Brilliance"],
    "XL Hostage Mage": ["Ethereal Oracle"],
    "Small Spell Mage": ["Mantle Shaper"],
    "Hostage Mage": ["Frostweave Dungeoneer"],
    "XL Exodia Mage": ["Jaina's Gift"],
    "Elemental Mage": ["Spontaneous Combustion"],
    "STD Burn Mage": ["Fireball"],
    "XL Secret Mage": ["Chatty Bartender"],
    "XL Hostage Mage": ["Knickknack Shack"],
    "Small Spell Mage": ["Flamewaker"],
    "XL HL Exodia Mage": ["Vast Wisdom"],
    "Questline Mage": ["Refreshing Spring Water"],
    "XL HL Exodia Mage": ["Wisdom of Norgannon"],
    "Elemental Mage": ["Flame Revenant"],
    "Imbue Mage": ["Flutterwing Guardian", "Petal Picker"],
    "STD Leyline Mage": ["Time-Twisted Seer"],
    "XL HL LPG Mage": ["Loatheb"],
    "STD Leyline Mage": ["Spellweaver's Brilliance"],
    "XL HL Exodia Mage": ["Hidden Objects", "Primordial Glyph"],
    "Other Mage": ["Portal Vanguard"],
    "XL HL Big Spell Mage": ["Tsunami"],
    "Secret Mage": ["Anonymous Informant", "Contract Conjurer", "Kabal Crystal Runner", "Rigged Faire Game"],
    "XL HL LPG Mage": ["Inconspicuous Rider", "Puzzlemaster Khadgar"],
    "XL LPG Mage": ["Luna's Pocket Galaxy"],
    "XL Deios Mage": ["Blastmage Miner"],
    "XL HL Big Spell Mage": ["Sunset Volley"],
    "XL Exodia Mage": ["The Forbidden Sequence", "Tide Pools"],
    "XL HL Hostage Mage": ["Coldarra Drake", "Reno Jackson"],
    "Hostage Mage": ["Mask of C'Thun"],
    "XL Hostage Mage": ["Metal Detector", "Portalmancer Skyla"],
    "Other Mage": ["Audio Splitter"],
    "Small Spell Mage": ["Mana Wyrm"],
    "Elemental Mage": ["Aqua Archivist"],
    "STD Leyline Mage": ["Runed Orb", "Winterspring Whelp"],
    "Hostage Mage": ["Cone of Cold", "Dryscale Deputy"],
    "XL Mage": ["Audio Amplifier"],
    "Other Mage": ["Living Flame", "Trench Surveyor"],
    "Imbue Mage": [
      "Bitterbloom Knight",
      "Divination",
      "Holotechnician",
      "Reckless Apprentice",
      "Seabreeze Chalice",
      "Sing-Along Buddy",
      "Spirit Gatherer"
    ],
    "XL Hostage Mage": ["Fae Trickster"],
    "Hostage Mage": ["Grey Sage Parrot", "Starscryer"],
    "XL HL Hostage Mage": ["Reno, Lone Ranger"],
    "XL Mage": ["Freezing Potion"],
    "XL Hostage Mage": ["Mes'Adune the Fractured", "Miracle Salesman", "Robocaller", "Watercolor Artist"],
    "Other Mage": ["Eternal Firebolt"],
    "XL LPG Mage": ["Research Project"],
    "XL JtU Quest Mage": ["Brann Bronzebeard", "Coldlight Oracle", "Prize Vendor", "Rewind", "Volume Up"],
    "STD Leyline Mage": ["Ley Walker"],
    "XL Hostage Mage": ["Frost Nova", "Potion of Illusion", "Shield Battery", "Sleet Skater", "Solid Alibi", "Wildfire"],
    "XL HL Exodia Mage": ["Darkbomb"],
    "XL Secret Mage": ["Objection!"],
    "XL Hostage Mage": ["Dirty Rat"]
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Mage")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Mage")
  end
end
