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
  ]
  @wild_config [
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Card Grader"], ["Font of Power"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Luna's Pocket Galaxy"], ["Reno Jackson"]]]
      ]
    ],
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["Wisprider"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ashen Elemental"], ["Reverberations"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Font of Power"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Arcane Flakmage"], ["Kabal Crystal Runner"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Luna's Pocket Galaxy"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "Elemental Mage": {[all: [["Flame Revenant"], ["Tar Slime"]]], [start_of_game: ["Prince Renathal"]]},
    "Secret Mage": {[all: [["Kirin Tor Mage"], ["Objection!"]]], [start_of_game: ["Prince Renathal"]]},
    "JtU Quest Mage": {[all: [["Alter Time"], ["Contraband Wands"]]], [start_of_game: ["Prince Renathal"]]},
    "Secret Mage": {[all: [["Arcane Flakmage"], ["Mad Scientist"]]], [start_of_game: ["Prince Renathal"]]},
    "JtU Quest Mage":
      {[
         all: [["Arcane Giant"], ["Volume Up"]],
         all: [["Conjurer's Calling"], ["Wisdom of Norgannon"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Imbue Mage": {[all: [["Petal Picker"], ["Ancient Mysteries", "Ice Block"]]], [start_of_game: ["Prince Renathal"]]},
    "JtU Quest Mage": {[all: [["Open the Waygate"], ["Stargazing"]]], [start_of_game: ["Prince Renathal"]]},
    "Secret Mage":
      {[
         all: [["Ancient Mysteries"], ["Contract Conjurer"]],
         all: [["Explosive Runes"], ["Rigged Faire Game"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Mage": {[all: [["Audio Splitter"], ["Flurry (Rank 3)"]]], [start_of_game: ["Prince Renathal"]]},
    "Elemental Mage": {[all: [["Blazing Accretion"], ["Solar Flare"]]], [start_of_game: ["Prince Renathal"]]},
    "Imbue Mage": {[all: [["Bitterbloom Knight"], ["Petal Picker"]]], [start_of_game: ["Prince Renathal"]]},
    "Questline Mage": {[all: [["Ignite"], ["Sorcerer's Gambit"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Mage":
      {[
         all: [["Costumed Singer"], ["Flurry (Rank 2)"]],
         all: [["Ignite"], ["Prize Vendor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Imbue Mage":
      {[
         all: [["Brann Bronzebeard"], ["Seabreeze Chalice"]],
         all: [["Shooting Star"], ["Spirit Gatherer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "JtU Quest Mage": {[all: [["Magister's Apprentice"], ["Open the Waygate"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Mage": {[all: [["Freezing Potion"], ["Potion of Illusion"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Buy One, Get One Freeze"],
            ["Alter Time", "Lorekeeper Polkelt", "Prismatic Elemental", "Winterspring Whelp"]
          ],
          all: [["Lorekeeper Polkelt"], ["Reverberations"]]
        ]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cosmic Springs"], ["Ethereal Oracle"]]]
      ]
    ],
    "Imbue Mage":
      {[
         all: [
           ["Wisprider"],
           ["Ancient Mysteries", "Sing-Along Buddy", "Smoldering Grove"]
         ],
         all: [["Brann Bronzebeard"], ["Flutterwing Guardian"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Hostage Mage":
      {[
         all: [
           ["Audio Splitter"],
           [
             "Card Grader",
             "Grey Sage Parrot",
             "Ignite",
             "Lorekeeper Polkelt",
             "Magister Dawngrasp",
             "Potion of Illusion",
             "Shield Battery",
             "Sir Finley, Sea Guide",
             "Stargazing",
             "The Galactic Projection Orb",
             "Watercolor Artist",
             "Wildfire"
           ]
         ],
         all: [
           ["Card Grader"],
           [
             "Costumed Singer",
             "Grey Sage Parrot",
             "Lorekeeper Polkelt",
             "Magister Dawngrasp",
             "Potion of Illusion",
             "Stargazing",
             "The Galactic Projection Orb",
             "Watercolor Artist",
             "Wildfire"
           ]
         ],
         all: [
           ["Ignite"],
           [
             "Costumed Singer",
             "Grey Sage Parrot",
             "Magister Dawngrasp",
             "Potion of Illusion",
             "Shield Battery",
             "Stargazing",
             "The Galactic Projection Orb",
             "Tidepool Pupil",
             "Watercolor Artist"
           ]
         ],
         all: [
           ["Lorekeeper Polkelt"],
           ["Commander Sivara", "Rewind", "Shield Battery", "Tidepool Pupil", "Watercolor Artist"]
         ],
         all: [
           ["Stargazing"],
           ["Ancient Mysteries", "Prize Vendor", "Shield Battery", "Tidepool Pupil", "Watercolor Artist"]
         ],
         all: [
           ["Grey Sage Parrot"],
           ["Ancient Mysteries", "Rewind", "Tidepool Pupil"]
         ],
         all: [["Magister Dawngrasp"], ["Ancient Mysteries", "Tidepool Pupil"]],
         all: [["Prize Vendor"], ["Devolving Missiles", "Watercolor Artist"]],
         all: [["The Galactic Projection Orb"], ["Rewind", "Tidepool Pupil"]],
         all: [["Shield Battery"], ["Starscryer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Prismatic Elemental"],
            ["Card Grader", "Freezing Potion", "Jaina's Gift", "Reverberations"]
          ],
          all: [
            ["Sands of Time"],
            ["Freezing Potion", "Heat Wave", "Reverberations", "Wisdom of Norgannon"]
          ],
          all: [
            ["First Flame"],
            ["Card Grader", "The Forbidden Sequence", "The Forbidden Sequence"]
          ],
          all: [["Alter Time"], ["Freezing Potion"]],
          all: [["Reverberations"], ["Winterspring Whelp"]]
        ]
      ]
    ],
    "Secret Mage": {[all: [["Anonymous Informant"], ["Contract Conjurer"]]], [start_of_game: ["Prince Renathal"]]},
    "Elemental Mage":
      {[
         all: [["Blazing Accretion"], ["Fire Fly", "Shale Spider"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eredar Brute"], ["Reverberations"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Lorekeeper Polkelt"], ["Sands of Time"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Luna's Pocket Galaxy"], ["Zephrys the Great"]]]
      ]
    ],
    "Imbue Mage": {[all: [["Holotechnician"], ["Wisprider"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Alter Time"], ["Jaina's Gift"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Ashen Elemental"], ["Research Project", "Volume Up"]],
          all: [["Eredar Brute"], ["The Forbidden Sequence"]]
        ]
      ]
    ],
    "Other Mage": {[all: [["Spirit Gatherer"], ["Tidepool Pupil"]]], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Coldlight Oracle"], ["Tae'thelan Bloodwatcher"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Coldlight Oracle"], ["Reverberations"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Lorekeeper Polkelt"], ["Alter Time", "Jaina's Gift"]],
          all: [["Prismatic Elemental"], ["The Forbidden Sequence"]]
        ]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Open the Waygate"], ["Prize Vendor"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prize Vendor"], ["Knickknack Shack", "Sleepy Resident"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Contract Conjurer"], ["Kirin Tor Mage"]],
          all: [["Counterspell"], ["Far Watch Post"]]
        ]
      ]
    ],
    "JtU Quest Mage": {[all: [["Conjure Mana Biscuit"], ["Open the Waygate"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Buy One, Get One Freeze"], ["The Skeleton Key"]],
          all: [["Freezing Potion"], ["Winterspring Whelp"]],
          all: [["Inquisitive Creation"], ["Sands of Time"]]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Lorekeeper Polkelt"], ["Wisdom of Norgannon"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Knickknack Shack"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jaina's Gift"], ["Murozond, Unbounded"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Kabal Crystal Runner"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Lorekeeper Polkelt"], ["Primordial Glyph"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Coldlight Oracle"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Forbidden Sequence"],
            ["Buy One, Get One Freeze", "Font of Power", "Zephrys the Great"]
          ]
        ]
      ]
    ],
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reckless Apprentice"], ["Wisprider"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Coldlight Oracle"], ["Dryscale Deputy"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Open the Waygate"], ["Freezing Potion", "Kil'jaeden"]],
          all: [["Arrival of the Titans"], ["Knickknack Shack"]],
          all: [["Shield Battery"], ["Tae'thelan Bloodwatcher"]]
        ]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reverberations"], ["Shield Battery"]]]
      ]
    ],
    "JtU Quest Mage": {[all: [["Flamewaker"], ["Open the Waygate"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Forbidden Sequence"], ["Wisdom of Norgannon"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Fae Trickster"], ["Shield Battery"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Card Grader"], ["Winterspring Whelp"]],
          all: [["Reno Jackson"], ["The Forbidden Sequence"]]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Lorekeeper Polkelt"], ["The Forbidden Sequence"]],
          all: [["Nightmare Lord Xavius"], ["Winterspring Whelp"]]
        ]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Forbidden Sequence"],
            ["Commander Sivara", "Research Project"]
          ]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Winterspring Whelp"], ["Jaina's Gift", "Tidepool Pupil"]],
          all: [["Heat Wave"], ["The Forbidden Sequence"]]
        ]
      ]
    ],
    "Elemental Mage":
      {[
         all: [
           ["Fire Fly"],
           ["Aqua Archivist", "Flame Revenant", "Overflow Surger", "Shale Spider", "Solar Flare", "Tainted Remnant"]
         ],
         all: [
           ["Shale Spider"],
           ["Glacial Shard", "Sizzling Cinder", "Tainted Remnant"]
         ],
         all: [["Aqua Archivist"], ["Glacial Shard", "Tainted Remnant"]],
         all: [["Flame Revenant"], ["Tainted Remnant"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["First Flame"], ["Open the Waygate"]]]
      ]
    ],
    "Hostage Mage": {[all: [["Frost Nova"], ["Knickknack Shack"]]], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Aluneth"], ["Vast Wisdom"]],
          all: [["Coldlight Oracle"], ["Open the Waygate"]],
          all: [["Energy Shaper"], ["Potion of Polymorph"]]
        ]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Research Project"], ["Yogg-Saron, Hope's End"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sands of Time"], ["Card Grader", "Smoldering Grove"]]]
      ]
    ],
    "Secret Mage": {[all: [["Costumed Singer"], ["Flame Ward"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Contract Conjurer"],
            ["Observer of Mysteries", "Orion, Mansion Manager"]
          ]
        ]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Miracle Salesman"], ["Tidepool Pupil"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Sands of Time"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Coldlight Oracle"], ["Potion of Polymorph"]],
          all: [["Shield Battery"], ["Starscryer"]]
        ]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Arcane Brilliance"], ["Inconspicuous Rider"]],
          all: [["Blizzard"], ["Sphere of Sapience"]]
        ]
      ]
    ],
    "JtU Quest Mage": {[all: [["Open the Waygate"], ["Rewind"]]], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cold Snap"], ["Energy Shaper"]]]
      ]
    ],
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Divination"], ["Holotechnician"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Jaina's Gift"], ["Open the Waygate"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Hidden Objects"], ["Jaina's Gift"]],
          all: [["The Skeleton Key"], ["Winterspring Whelp"]]
        ]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shield Battery"], ["The Forbidden Sequence"]]]
      ]
    ],
    "Questline Mage": {[all: [["Ice Block"], ["Sorcerer's Gambit"]]], [start_of_game: ["Prince Renathal"]]},
    "Protoss Mage": {[all: [["Photon Cannon"], ["Shield Battery"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Card Grader"], ["Infinitize the Maxitude", "The Skeleton Key"]],
          all: [["Reno, Lone Ranger"], ["The Forbidden Sequence"]]
        ]
      ]
    ],
    "Imbue Mage":
      {[
         all: [
           ["Wisprider"],
           ["Bitterbloom Knight", "Divination", "Flutterwing Guardian", "Spirit Gatherer", "Wildfire"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Secret Mage":
      {[
         all: [["Counterspell"], ["Anonymous Informant", "Costumed Singer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Research Project"],
            ["Energy Shaper", "Open the Waygate", "Primordial Glyph"]
          ],
          all: [["Shield Battery"], ["Murozond, Unbounded", "Open the Waygate"]]
        ]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eredar Brute"], ["Tide Pools"]]]
      ]
    ],
    "HL Exodia Mage": {[all: [["Rising Waves"], ["The Forbidden Sequence"]]], [start_of_game: ["Prince Renathal"]]},
    "Imbue Mage":
      {[
         all: [["Flutterwing Guardian"], ["Ancient Mysteries", "Tour Guide"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cosmic Springs"], ["Lorekeeper Polkelt"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Luna's Pocket Galaxy"], ["Theotar, the Mad Duke"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Coldlight Oracle"], ["Metal Detector"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Inquisitive Creation"], ["The Forbidden Sequence"]],
          all: [["Nightmare Lord Xavius"], ["Primordial Glyph"]]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Infinitize the Maxitude"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["The Forbidden Sequence"],
            ["Magister Dawngrasp", "Potion of Illusion"]
          ]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Freezing Potion"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Contract Conjurer"]]]
      ]
    ],
    "Other Mage": {[all: [["Arcane Wyrm"], ["Ice Block"]]], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Energy Shaper"], ["Seabreeze Chalice"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Stargazing"], ["Shield Battery", "Tidepool Pupil"]],
          all: [["Ethereal Oracle"], ["Robocaller"]]
        ]
      ]
    ],
    "Exodia Mage": {[all: [["Discovery of Magic"], ["Sands of Time"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Bitterbloom Knight"], ["Wisprider"]],
          all: [["Divination"], ["Flutterwing Guardian"]]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Discovery of Magic"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Forbidden Sequence"], ["Volume Up"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["Rune of the Archmage"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Card Grader"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Smoldering Grove"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Contract Conjurer"], ["Objection!"]]]
      ]
    ],
    "XL Questline Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Magic Trick"], ["Sorcerer's Gambit"]]]
      ]
    ],
    "JtU Quest Mage": {[all: [["Burndown"], ["Open the Waygate"]]], [start_of_game: ["Prince Renathal"]]},
    "Imbue Mage": {[all: [["Seabreeze Chalice"], ["Spirit Gatherer"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Overplanner"]]]
      ]
    ],
    "XL HL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Open the Waygate"], ["Petty Theft"]]]
      ]
    ],
    "Secret Mage": {[all: [["Anonymous Informant"], ["Objection!"]]], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Energy Shaper"],
            ["Ancient Mysteries", "Frost Nova", "Ice Block", "Solid Alibi", "The Skeleton Key", "Vast Wisdom"]
          ]
        ]
      ]
    ],
    "Imbue Mage":
      {[
         all: [["Bitterbloom Knight"], ["Objection!", "Seabreeze Chalice"]],
         all: [["Flutterwing Guardian"], ["Spirit Gatherer", "Wildfire"]],
         all: [["Objection!"], ["Spirit Gatherer"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Alter Time"], ["Ice Block"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ethereal Oracle"], ["Sphere of Sapience"]]]
      ]
    ],
    "XL HL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Conjured Bookkeeper"], ["Potion of Illusion"]],
          all: [["Griftah, Trusted Vendor"], ["Nightmare Lord Xavius"]]
        ]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Coldlight Oracle"], ["Knickknack Shack"]],
          all: [["Sleepy Resident"], ["Wildfire"]]
        ]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Costumed Singer"], ["Orion, Mansion Manager"]]]
      ]
    ],
    "JtU Quest Mage":
      {[
         all: [["Open the Waygate"], ["Heat Wave", "Ice Block", "Violet Spellwing"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Hidden Objects"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Alter Time"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Forbidden Sequence"], ["Vast Wisdom"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Primordial Glyph"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Flutterwing Guardian"], ["Holotechnician"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Deck of Lunacy"]]]
      ]
    ],
    "Hostage Mage":
      {[
         all: [["Shield Battery"], ["Prize Vendor", "Tidepool Pupil", "Wildfire"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Questline Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Contraband Wands"], ["Sorcerer's Gambit"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eternal Firebolt"], ["Nightcloak Sanctum"]]]
      ]
    ],
    "XL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Heat Wave"], ["Siphon Mana"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Forbidden Sequence"], ["Winterspring Whelp"]]]
      ]
    ],
    "HL Hostage Mage": {[all: [["Eredar Brute"], ["Ice Block"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["King Tide"]]]
      ]
    ],
    "JtU Quest Mage": {[all: [["Open the Waygate"], ["Smoldering Grove"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Metal Detector"], ["Wildfire"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Luna's Pocket Galaxy"], ["Objection!"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Ethereal Oracle"],
            ["Knickknack Shack", "Shield Battery", "Tidepool Pupil"]
          ],
          all: [
            ["Frost Nova"],
            ["Grey Sage Parrot", "The Galactic Projection Orb"]
          ],
          all: [["Grey Sage Parrot"], ["Solid Alibi"]]
        ]
      ]
    ],
    "XL HL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mask of C'Thun"], ["The Curator"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["First Flame"], ["Primordial Glyph"]]]
      ]
    ],
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Ancient Mysteries"], ["Spirit Gatherer"]],
          all: [["Bitterbloom Knight"], ["Objection!"]]
        ]
      ]
    ],
    "Other Mage": {[all: [["Reckless Apprentice"], ["Rewind"]]], [start_of_game: ["Prince Renathal"]]},
    "Imbue Mage":
      {[
         all: [
           ["Bitterbloom Knight"],
           ["Holotechnician", "Reckless Apprentice", "Sing-Along Buddy", "Spirit Gatherer", "Wildfire"]
         ],
         all: [["Reckless Apprentice"], ["Smoldering Grove", "Wildfire"]],
         all: [["Spirit Gatherer"], ["Wildfire"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Open the Waygate"], ["Cosmic Springs", "Knickknack Shack"]],
          all: [["Seabreeze Chalice"], ["Vast Wisdom"]]
        ]
      ]
    ],
    "Exodia Mage": {[all: [["Jaina's Gift"], ["The Forbidden Sequence"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shield Battery"], ["Wildfire"]]]
      ]
    ],
    "XL Imbue Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Spirit Gatherer"], ["Wildfire"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Anonymous Informant"], ["Costumed Singer"]]]
      ]
    ],
    "XL HL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reno, Lone Ranger"], ["The Galactic Projection Orb"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Open the Waygate"], ["Runed Orb"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["First Flame"], ["Vast Wisdom"]]]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Robocaller"], ["Star Power"]]]
      ]
    ],
    "Other Mage": {[all: [["Cosmic Springs"], ["Discs of Norgannon"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sands of Time"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Forbidden Sequence"], ["Rewind", "Solid Alibi"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Cosmic Springs"], ["Costumed Singer"]],
          all: [["Metal Detector"], ["Solid Alibi"]]
        ]
      ]
    ],
    "Hostage Mage": {[all: [["Ice Block"], ["Shield Battery"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Anonymous Informant"], ["Objection!"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Energy Shaper"], ["Deck of Lunacy", "Open the Waygate"]]]
      ]
    ],
    "Imbue Mage": {[all: [["Wildfire"], ["Objection!", "Smoldering Grove"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Costumed Singer"], ["Counterspell"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Timeline Accelerator"], ["Tsunami"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Jaina's Gift"], ["Tide Pools"]],
          all: [["Research Project"], ["The Skeleton Key"]]
        ]
      ]
    ],
    "HL Exodia Mage":
      {[all: [["The Forbidden Sequence"], ["Zephrys the Great"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Conjure Mana Biscuit"], ["Open the Waygate"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Open the Waygate"], ["Vast Wisdom"]],
          all: [["Research Project"], ["Sphere of Sapience"]]
        ]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Vast Wisdom"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Open the Waygate"], ["Flame Ward", "The Curator"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Hidden Objects"], ["Vast Wisdom"]]]
      ]
    ],
    "XL HL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Open the Waygate"], ["Costumed Singer", "Zephrys the Great"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Open the Waygate"],
            ["Cold Snap", "Frost Nova", "Primordial Glyph", "Solid Alibi", "Tidepool Pupil"]
          ],
          all: [["Deck of Lunacy"], ["Sir Finley, Sea Guide"]]
        ]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Zephrys the Great"],
            ["Blademaster Okani", "Theotar, the Mad Duke"]
          ]
        ]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Arcane Brilliance"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Prize Vendor"]]]
      ]
    ],
    "Exodia Mage":
      {[all: [["E.T.C., Band Manager"], ["The Forbidden Sequence"]]], [start_of_game: ["Prince Renathal"]]},
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Open the Waygate"], ["Dirty Rat", "Volume Up"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Deck of Lunacy"], ["Open the Waygate"]]]
      ]
    ],
    "Hostage Mage": {[all: [["Ice Block"], ["Watercolor Artist"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Mage": {[all: [["Leyline Nexus"], ["Rewind"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Highlander Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Eternal Firebolt"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Zephrys the Great"], ["The Skeleton Key", "Tide Pools"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Knickknack Shack"], ["Costumed Singer", "Metal Detector"]],
          all: [["Potion of Illusion"], ["Sphere of Sapience"]]
        ]
      ]
    ],
    "Ashtongue Mage": {[all: [["Celestial Ink Set"], ["Instrument Tech"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Questline Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ignite"], ["Sorcerer's Gambit"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Flame Ward"], ["Mad Scientist"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["The Forbidden Sequence"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Open the Waygate"]]]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Arcane Brilliance"], ["Devolving Missiles"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["Razorscale"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Open the Waygate"]]]
      ]
    ],
    "Exodia Mage": {[all: [["The Forbidden Sequence"], ["Vast Wisdom"]]], [start_of_game: ["Prince Renathal"]]},
    "HL LPG Mage": {[all: [["Stargazing"], ["The Galactic Projection Orb"]]], [start_of_game: ["Prince Renathal"]]},
    "Hostage Mage": {[all: [["Costumed Singer"], ["Wildfire"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["The Forbidden Sequence"], ["Tide Pools"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Knickknack Shack"], ["Solid Alibi"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Frost Nova"], ["Knickknack Shack"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shield Battery"], ["Tide Pools"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Coldlight Oracle"], ["Research Project"]]]
      ]
    ],
    "XL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Arcane Brilliance"], ["Objection!"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "XL HL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Celestial Ink Set"], ["Ice Block"]]]
      ]
    ],
    "STD Leyline Mage": {[all: [["Leyline Nexus"], ["Mystic Runesaber"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Hidden Objects"], ["Rewind"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Reno Jackson"], ["Sir Finley, Sea Guide", "Sleet Skater"]],
          all: [["Nightmare Lord Xavius"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Hostage Mage": {[all: [["Ice Block"], ["Costumed Singer", "Wildfire"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["The Galactic Projection Orb"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Zephrys the Great"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Costumed Singer"], ["Shield Battery"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Volume Up"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Shield Battery"]]]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Tsunami"], ["E.T.C., Band Manager", "Ice Block"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Prismatic Elemental"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Costumed Singer"], ["Dirty Rat"]]]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Robocaller"], ["Timeline Accelerator"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["Shield Battery"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["Volume Up"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Infinitize the Maxitude"], ["Objection!"]]]
      ]
    ],
    "XL Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Infinitize the Maxitude"], ["Smoldering Grove"]]]
      ]
    ],
    "XL JtU Quest Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Shield Battery"], ["Volume Up"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Frost Nova"], ["Shield Battery", "Sphere of Sapience"]],
          all: [["Shield Battery"], ["Sleet Skater"]]
        ]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Shield Battery"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Sir Finley, Sea Guide"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["The Skeleton Key"]]]
      ]
    ],
    "Exodia Mage": {[all: [["Ice Block"], ["The Forbidden Sequence"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Ice Block"], ["Coldlight Oracle", "Potion of Illusion"]],
          all: [["Potion of Illusion"], ["Varden Dawngrasp"]]
        ]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Costumed Singer"], ["Objection!"]]]
      ]
    ],
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Objection!"], ["Varden Dawngrasp"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Devolving Missiles"], ["Zephrys the Great"]]]
      ]
    ],
    "Secret Mage": {[all: [["Ancient Mysteries"], ["Objection!"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL LPG Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Devolving Missiles"], ["Objection!"]]]
      ]
    ],
    "XL HL Big Spell Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["E.T.C., Band Manager"], ["Ice Block"]],
          all: [["King Tide"], ["Sunset Volley"]]
        ]
      ]
    ],
    "XL HL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Watercolor Artist"]]]
      ]
    ],
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Frost Nova"], ["Tidepool Pupil"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Frost Nova"], ["Rewind"]]]
      ]
    ],
    "Other Mage": {[all: [["Ancient Mysteries"], ["Ice Block"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Tide Pools"]]]
      ]
    ],
    "XL Hostage Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ice Block"], ["Solid Alibi"]]]
      ]
    ],
    "XL Secret Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Objection!"]]]
      ]
    ],
    "XL HL Exodia Mage": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Ancient Mysteries"], ["Ice Block"]]]
      ]
    ]
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
