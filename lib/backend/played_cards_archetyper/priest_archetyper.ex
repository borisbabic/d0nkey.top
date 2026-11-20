# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PriestArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Thief Priest": [{:start_of_game, ["Azalina Soulsever"]}],
    # auto gen
    "Quest Priest": ["Ritual of Life"],
    "Other Priest": ["Holy Eggbearer"],
    "C'Thun Priest": ["C'Thun, Eye of the Empire", "Gargantuan Slitherer", "Spawn of C'Thun"],
    "Control Priest": ["Greater Healing Potion", "Karazhan the Sanctum", "Rat Burglar", "Togwaggle, Smuggler King"],
    "Quest Priest": ["Power Word: Shield"],
    "Other Priest": ["Crystalsmith Cultist"],
    "Control Priest": ["Medivh the Hallowed", "The Black Blood"],
    "Quest Priest": ["Disciple of the Dove"],
    "C'Thun Priest": ["Bloodmage Thalnos"],
    "Control Priest": ["Atiesh the Greatstaff"],
    "Quest Priest": ["Chrono-Lord Deios", "M.O.T.H.E.R.", "Raith Van Geist", "Torga"],
    "Thief Priest": ["Obsessive Technician"],
    "Control Priest": ["Ruby Sanctum"],
    "Other Priest": ["The Egg of Khelos"],
    "Quest Priest": ["Gravedawn Sunbloom", "Mend"],
    "Control Priest": ["Steamcleaner"],
    "Other Priest": ["Twilight Influence"],
    "C'Thun Priest": ["Dark Deacon"],
    "Control Priest": ["Elise the Navigator", "Karov the Broken", "Moonwell", "Y'Shaarj, Titan Bane"],
    "Quest Priest": ["Endbringer Umbra", "Lingering Spirit"],
    "Quest Priest": ["Specter Specialist"],
    "Control Priest": ["Devouring Plague"],
    "Other Priest": ["Holy Smite"],
    "Control Priest": ["Eternal Firebolt", "Ysera, Emerald Aspect"],
    "Quest Priest": ["Holy Embrace"],
    "Control Priest": ["Dirty Rat"],
    "C'Thun Priest": ["Calia Menethil"],
    "Other Priest": ["Bitterbloom Knight", "Follow the Ghosts", "Shadewing"],
    "C'Thun Priest": ["Blade of The Black Empire", "Elder Word: Manifest"],
    "Quest Priest": ["Cleansing Cleric", "Haunt"],
    "C'Thun Priest": ["Entropic Rift"],
    "Control Priest": [
      "Elder Word: Foresight",
      "Intertwined Fate",
      "Kaldorei Priestess",
      "Lunarwing Messenger",
      "Medivh's Triumph",
      "Reach Equilibrium",
      "Shadow Word: Ruin",
      "Slime 'em!"
    ]
  ]
  @wild_config [
    "XL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Frenzied Felwing"],
            [
              "Acupuncture",
              "Elder Word: Flay",
              "Ethereal Oracle",
              "Mind Sear",
              "Prince Renathal",
              "Shadowbomber",
              "Shadowcloth Needle",
              "Ship's Chirurgeon",
              "Spirit of the Kaldorei",
              "Twilight Deceptor"
            ]
          ],
          all: [
            ["Shadowbomber"],
            ["Acupuncture", "Brain Masseuse", "Cathedral of Atonement", "Papercraft Angel", "Twilight Deceptor"]
          ],
          all: [["Ship's Chirurgeon"], ["Twilight Deceptor"]]
        ]
      ]
    ],
    "XL JtU Quest Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Awaken the Makers"],
            ["Arkonite Defense Crystal", "Birdwatching", "Pendant of Earth"]
          ]
        ]
      ]
    ],
    "Shadow Priest":
      {[
         all: [
           ["Treasure Distributor"],
           ["Brain Masseuse", "Frenzied Felwing", "Mind Sear"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big LC Quest Priest": {[all: [["Barnes"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest":
      {[
         all: [["Seek Guidance"], ["The Harvester of Envy"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Barnes"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest":
      {[
         all: [["Frenzied Felwing"], ["Potion of Madness"]],
         all: [["Raise Dead"], ["Shadowbomber"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest":
      {[
         all: [["Follow the Ghosts"], ["Darkbishop Benedictus", "Shadowbomber"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest": {[all: [["Follow the Ghosts"], ["Spirit of the Kaldorei"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest":
      {[all: [["Mysterious Visitor"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest":
      {[
         all: [
           ["Shadowcloth Needle"],
           ["Frenzied Felwing", "Shadowbomber", "Voidtouched Attendant"]
         ],
         all: [["Acupuncture"], ["Follow the Ghosts"]],
         all: [["Elder Word: Foresight"], ["Frenzied Felwing"]],
         all: [["Potion of Madness"], ["Voidtouched Attendant"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Nazmani Priest":
      {[
         all: [
           ["Nazmani Bloodweaver"],
           ["Acupuncture", "Ethereal Oracle", "Resurrect"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest":
      {[
         all: [["Follow the Ghosts"], ["Papercraft Angel"]],
         all: [["Shadowcloth Needle"], ["Ship's Chirurgeon"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["Psychic Conjurer"], ["Benevolent Banker", "Potion of Madness"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Miracle Salesman"], ["Psychic Conjurer"]]]
      ]
    ],
    "XL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Acupuncture"],
            [
              "Brain Masseuse",
              "Dark Deacon",
              "Elder Word: Flay",
              "Ethereal Oracle",
              "Mind Blast",
              "Mind Sear",
              "Miracle Salesman",
              "Papercraft Angel",
              "Ship's Chirurgeon",
              "Spirit of the Kaldorei",
              "Twilight Deceptor",
              "Voidtouched Attendant"
            ]
          ],
          all: [
            ["Mind Sear"],
            [
              "Brain Masseuse",
              "Cathedral of Atonement",
              "Elder Word: Flay",
              "Ethereal Oracle",
              "Mind Blast",
              "Miracle Salesman",
              "Papercraft Angel",
              "Shadowcloth Needle",
              "Ship's Chirurgeon",
              "Twilight Deceptor",
              "Voidtouched Attendant"
            ]
          ],
          all: [
            ["Mind Blast"],
            [
              "Brain Masseuse",
              "Dark Deacon",
              "Elder Word: Flay",
              "Ethereal Oracle",
              "Miracle Salesman",
              "Papercraft Angel",
              "Ship's Chirurgeon",
              "Twilight Deceptor",
              "Voidtouched Attendant"
            ]
          ],
          all: [
            ["Brain Masseuse"],
            [
              "Dark Deacon",
              "Elder Word: Flay",
              "Elder Word: Foresight",
              "Ethereal Oracle",
              "Miracle Salesman",
              "Papercraft Angel",
              "Voidtouched Attendant"
            ]
          ],
          all: [
            ["Ethereal Oracle"],
            [
              "Elder Word: Flay",
              "Miracle Salesman",
              "Papercraft Angel",
              "Ship's Chirurgeon",
              "Spirit of the Kaldorei",
              "Voidtouched Attendant"
            ]
          ],
          all: [
            ["Elder Word: Flay"],
            ["Miracle Salesman", "Ship's Chirurgeon", "Twilight Deceptor", "Voidtouched Attendant"]
          ],
          all: [["Miracle Salesman"], ["Ship's Chirurgeon"]]
        ]
      ]
    ],
    "Shadow Priest":
      {[
         all: [["Cult Neophyte"], ["Frenzied Felwing"]],
         all: [["Elder Word: Foresight"], ["Shadowbomber"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": {[all: [["Identity Theft"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest":
      {[
         all: [
           ["Shadowbomber"],
           [
             "Acupuncture",
             "Ashen Elemental",
             "Dark Deacon",
             "Elder Word: Flay",
             "Ethereal Oracle",
             "Frenzied Felwing",
             "Frenzied Felwing",
             "Mind Blast",
             "Mind Sear",
             "Mind Sear",
             "Papercraft Angel",
             "Twilight Deceptor",
             "Voidtouched Attendant",
             "Voidtouched Attendant"
           ]
         ],
         all: [
           ["Papercraft Angel"],
           [
             "Acupuncture",
             "Dark Deacon",
             "Elder Word: Flay",
             "Elder Word: Foresight",
             "Ethereal Oracle",
             "Frenzied Felwing",
             "Mind Blast",
             "Mind Sear",
             "Raise Dead",
             "Shadowcloth Needle",
             "Voidtouched Attendant"
           ]
         ],
         all: [
           ["Voidtouched Attendant"],
           [
             "Acupuncture",
             "Dark Deacon",
             "Elder Word: Flay",
             "Elder Word: Foresight",
             "Ethereal Oracle",
             "Frenzied Felwing",
             "Mind Blast",
             "Mind Sear",
             "Miracle Salesman",
             "Raise Dead"
           ]
         ],
         all: [
           ["Acupuncture"],
           [
             "Ashen Elemental",
             "Cult Neophyte",
             "Dark Deacon",
             "Darkbishop Benedictus",
             "Frenzied Felwing",
             "Miracle Salesman",
             "Raise Dead",
             "Twilight Deceptor"
           ]
         ],
         all: [
           ["Miracle Salesman"],
           [
             "Elder Word: Flay",
             "Elder Word: Foresight",
             "Ethereal Oracle",
             "Mind Blast",
             "Mind Sear",
             "Raise Dead",
             "Shadowcloth Needle"
           ]
         ],
         all: [
           ["Frenzied Felwing"],
           ["Dark Deacon", "Elder Word: Flay", "Ethereal Oracle", "Mind Blast", "Mind Sear", "Raise Dead"]
         ],
         all: [["Dark Deacon"], ["Ethereal Oracle", "Mind Blast", "Mind Sear"]],
         all: [["Ashen Elemental"], ["Brain Masseuse", "Elder Word: Flay"]],
         all: [["Elder Word: Foresight"], ["Brain Masseuse", "Ship's Chirurgeon"]],
         all: [["Mind Blast"], ["Raise Dead", "Shadowcloth Needle"]],
         all: [["Mind Sear"], ["Darkbishop Benedictus", "Raise Dead"]],
         all: [["Cult Neophyte"], ["Ethereal Oracle"]],
         all: [["Shadowcloth Needle"], ["Twilight Deceptor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big JtU Quest Priest": {[all: [["Awaken the Makers"], ["Barnes"]]], [start_of_game: ["Prince Renathal"]]},
    "Heal Burn Priest": {[all: [["Careless Crafter"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "XL LC Quest Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reach Equilibrium"], ["Thrive in the Shadows"]]]
      ]
    ],
    "Nazmani Priest": {[all: [["Funnel Cake"], ["Shadowcloth Needle"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Azalina Soulsever"], ["Seek Guidance"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Miracle Salesman"],
            [
              "Blademaster Okani",
              "E.T.C., Band Manager",
              "Elise the Navigator",
              "Fanboy",
              "Far Watch Post",
              "Hysteria",
              "Identity Theft",
              "Mixologist",
              "Najak Hexxen",
              "Potion of Madness",
              "Prince Renathal",
              "Raza the Chained",
              "Reno, Lone Ranger",
              "Shadow Word: Devour",
              "Shadowreaper Anduin",
              "Sir Finley, Sea Guide",
              "Zephrys the Great"
            ]
          ],
          all: [["Fanboy"], ["Cult Neophyte", "Najak Hexxen", "Papercraft Angel"]],
          all: [["Psychic Conjurer"], ["Spirit of the Kaldorei"]]
        ]
      ]
    ],
    "Big Questline Priest": {[all: [["Nightshade Tea"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Nazmani Priest": {[all: [["Hot Coals"], ["Thrive in the Shadows"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [
           ["Seek Guidance"],
           ["C'Thun, Eye of the Empire", "Smoldering Ascent"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Divine Questline Priest": {[all: [["Chrono Boost"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Reno, Lone Ranger"], ["Thoughtsteal"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [
           ["Seek Guidance"],
           ["Gravedawn Sunbloom", "Love Everlasting", "Pendant of Earth", "Shadow Word: Devour"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Divine Spirit Priest":
      {[
         all: [
           ["Shadowfiend"],
           ["Birdwatching", "Circle of Healing", "Crimson Clergy"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Seek Guidance"],
            ["Arkonite Defense Crystal", "Twilight's Call"]
          ]
        ]
      ]
    ],
    "HL Thief Priest": {[all: [["Sir Finley, Sea Guide"], ["Thoughtsteal"]]], [start_of_game: ["Prince Renathal"]]},
    "Nazmani Priest": {[all: [["Funnel Cake"], ["Resurrect"]]], [start_of_game: ["Prince Renathal"]]},
    "Big LC Quest Priest": {[all: [["Pendant of Earth"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "LC Quest Priest": {[all: [["Reach Equilibrium"], ["Holy Nova", "Renew"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Cloning Device"], ["Slime 'em!"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": {[all: [["Birdwatching"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Palm Reading"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [
           ["Seek Guidance"],
           ["Rest in Peace", "Shadow Essence", "Sphere of Sapience", "Thrive in the Shadows"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": {[all: [["Intertwined Fate"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Big LC Quest Priest":
      {[all: [["Potion of Madness"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["Benevolent Banker"], ["Identity Theft", "Mysterious Visitor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest":
      {[
         all: [
           ["Cloning Device"],
           ["Birdwatching", "Creation Protocol", "Mysterious Visitor"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL LC Quest Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Reach Equilibrium"], ["Renew", "Shadow Visions"]]]
      ]
    ],
    "HL Thief Priest":
      {[
         all: [["Puppet Theatre"], ["Dirty Rat", "Thoughtsteal"]],
         all: [["Raise Dead"], ["Reno, Lone Ranger"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Birdwatching"], ["Slime 'em!"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Masked Reveler"], ["Elder Word: Foresight", "Gift of Luminance"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Najak Hexxen"]]]
      ]
    ],
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Far Watch Post"], ["Mindrender Illucia"]]]
      ]
    ],
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Cloning Device"],
            ["Azalina Soulsever", "Birdwatching", "Illuminate"]
          ],
          all: [["Azalina Soulsever"], ["Birdwatching"]],
          all: [["Mysterious Visitor"], ["Slime 'em!"]]
        ]
      ]
    ],
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Azalina Soulsever"], ["Puppet Theatre"]]]
      ]
    ],
    "Thief Priest":
      {[
         all: [["Birdwatching"], ["Creation Protocol", "Sphere of Sapience"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["Identity Theft"], ["Psychic Conjurer", "Reno, Lone Ranger"]],
         all: [["Puppet Theatre"], ["Sir Finley, Sea Guide"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Nazmani Priest": {[all: [["Ethereal Oracle"], ["Palm Reading"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Seek Guidance"], ["Sleepy Resident"]]]
      ]
    ],
    "Mecha'thun Priest": {[all: [["Gift of Luminance"], ["Regenerate"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest":
      {[
         all: [
           ["Birdwatching"],
           ["Illuminate", "Intertwined Fate", "Mysterious Visitor"]
         ],
         all: [["Brann Bronzebeard"], ["Medivh's Triumph"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Papercraft Angel"], ["Speaker Stomper"]]]
      ]
    ],
    "HL Thief Priest": {[all: [["Raise Dead"], ["Thoughtsteal"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Taelan Fordring"]]]
      ]
    ],
    "Big Questline Priest": {[all: [["Seek Guidance"], ["Shadow Visions"]]], [start_of_game: ["Prince Renathal"]]},
    "Big LC Quest Priest":
      {[all: [["Gift of Luminance"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Mixologist"],
            ["Papercraft Angel", "Psychic Conjurer", "Spirit of the Kaldorei"]
          ],
          all: [["Far Watch Post"], ["Psychic Conjurer"]],
          all: [["Shadow Word: Devour"], ["Spirit of the Kaldorei"]]
        ]
      ]
    ],
    "Tog Priest": {[all: [["Funnel Cake"], ["Gift of the Naaru"]]], [start_of_game: ["Prince Renathal"]]},
    "Protoss Priest": {[all: [["Birdwatching"], ["Sentry"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Rest in Peace"], ["Smoldering Ascent"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[all: [["Potion of Madness"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mysterious Visitor"], ["Seek Guidance"]]]
      ]
    ],
    "LC Quest Priest": {[all: [["Idol of Y'Shaarj"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Mysterious Visitor"],
            ["Birdwatching", "Creation Protocol", "Illuminate"]
          ]
        ]
      ]
    ],
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Mysterious Visitor"],
            ["Benevolent Banker", "Reno, Lone Ranger"]
          ]
        ]
      ]
    ],
    "XL JtU Quest Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Awaken the Makers"], ["Shadow Visions"]]]
      ]
    ],
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Seek Guidance"],
            ["Nightmare Lord Xavius", "Sphere of Sapience"]
          ]
        ]
      ]
    ],
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Astalor Bloodsworn"], ["Mixologist"]],
          all: [["Blademaster Okani"], ["Seance"]]
        ]
      ]
    ],
    "Thief Priest":
      {[
         all: [
           ["Creation Protocol"],
           ["Identity Theft", "Intertwined Fate", "Mysterious Visitor"]
         ],
         all: [["Illuminate"], ["Mysterious Visitor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["Potion of Madness"], ["Identity Theft", "Mysterious Visitor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Nazmani Priest": {[all: [["Creation Protocol"], ["Mind Sear"]]], [start_of_game: ["Prince Renathal"]]},
    "Divine Spirit Priest":
      {[all: [["Chrono Boost"], ["Elder Word: Foresight"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["E.T.C., Band Manager"], ["Sir Finley, Sea Guide"]],
         all: [["Identity Theft"], ["Puppet Theatre"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Cloning Device"], ["Intertwined Fate"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cloning Device"], ["Seek Guidance"]]]
      ]
    ],
    "Big SoU Quest Priest": {[all: [["Activate the Obelisk"], ["Barnes"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Thief Priest": {[all: [["Lunarwing Messenger"], ["Unshackle Soul"]]], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest": {[all: [["Acupuncture"], ["Mind Sear"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Barnes"], ["Smoldering Ascent"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Seek Guidance"]]]
      ]
    ],
    "XL Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Madame Lazul"], ["Seek Guidance"]]]
      ]
    ],
    "Thief Priest": {[all: [["Mysterious Visitor"], ["Sphere of Sapience"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Blademaster Okani"], ["Mysterious Visitor"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Papercraft Angel"], ["Thoughtsteal"]],
          all: [["Raza the Chained"], ["The Harvester of Envy"]]
        ]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Papercraft Angel"],
            ["Cult Neophyte", "Far Watch Post", "Razorscale"]
          ],
          all: [["Spirit of the Kaldorei"], ["Cult Neophyte", "Far Watch Post"]]
        ]
      ]
    ],
    "Thief Priest": {[all: [["Chillin' Vol'jin"], ["Identity Theft"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Illuminate"], ["Smoldering Ascent"]],
         all: [["Nightshade Tea"], ["Potion of Madness"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Seek Guidance"], ["Far Watch Post", "Najak Hexxen"]]]
      ]
    ],
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Far Watch Post"], ["Nightshade Tea", "Puppet Theatre"]]]
      ]
    ],
    "LC Quest Priest": {[all: [["Nightshade Tea"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest":
      {[
         all: [["E.T.C., Band Manager"], ["Seek Guidance"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[all: [["E.T.C., Band Manager"], ["Mindrender Illucia"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Puppet Theatre"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Illuminate"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Barnes"], ["Creation Protocol", "Elder Word: Foresight"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Mysterious Visitor"], ["Puppet Theatre", "Thoughtsteal"]]]
      ]
    ],
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Intertwined Fate"], ["Mysterious Visitor"]]]
      ]
    ],
    "Nazmani Priest": {[all: [["Creation Protocol"], ["Nazmani Bloodweaver"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Mysterious Visitor"], ["Psychic Conjurer"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Aman'Thul"], ["E.T.C., Band Manager"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest":
      {[
         all: [
           ["Mysterious Visitor"],
           ["Intertwined Fate", "Lunarwing Messenger", "Medivh's Triumph"]
         ],
         all: [["Identity Theft"], ["Birdwatching", "Medivh's Triumph"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["Mysterious Visitor"], ["Elder Word: Foresight", "Thoughtsteal"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "STD Quest Priest": {[all: [["Reach Equilibrium"], ["Ritual of Life"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aviana, Elune's Chosen"], ["Mixologist"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Raza the Chained"], ["Shadowcloth Needle"]]]
      ]
    ],
    "Shadow Priest": {[all: [["Acupuncture"], ["Elder Word: Flay"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Holy Nova"], ["Palm Reading"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Papercraft Angel"], ["Shadow Word: Devour"]]]
      ]
    ],
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Power Chord: Synchronize"], ["Seek Guidance"]]]
      ]
    ],
    "XL Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Seek Guidance"],
            ["Loatheb", "Nightshade Tea", "Shadow Word: Devour"]
          ]
        ]
      ]
    ],
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Mindrender Illucia"],
            ["Elder Word: Foresight", "Zephrys the Great"]
          ]
        ]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Raza the Chained"],
            ["Papercraft Angel", "Spirit of the Kaldorei"]
          ],
          all: [["Spirit of the Kaldorei"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "HL Thief Priest": {[all: [["Mysterious Visitor"], ["Raise Dead"]]], [start_of_game: ["Prince Renathal"]]},
    "Big JtU Quest Priest": {[all: [["Awaken the Makers"], ["Shadow Visions"]]], [start_of_game: ["Prince Renathal"]]},
    "LC Quest Priest":
      {[all: [["Elder Word: Foresight"], ["Reach Equilibrium"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Priest": {[all: [["Illuminate"], ["Lunarwing Messenger"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Shattered Reflections"], ["Thrive in the Shadows"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big LC Quest Priest":
      {[
         all: [
           ["Reach Equilibrium"],
           ["Gravedawn Sunbloom", "Medivh's Triumph", "Sphere of Sapience", "Thrive in the Shadows"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Illuminate"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Shadow Word: Devour"]]]
      ]
    ],
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Seek Guidance"], ["Lunarwing Messenger", "Reno Jackson"]]]
      ]
    ],
    "Big Questline Priest": {[all: [["Medivh's Triumph"], ["Vivid Nightmare"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Benevolent Banker"], ["Bob the Bartender"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Benevolent Banker"], ["Papercraft Angel"]],
          all: [["Cult Neophyte"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Shadow Priest":
      {[
         all: [["Elder Word: Flay"], ["Ethereal Oracle", "Mind Sear"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Eternal Firebolt"], ["Illuminate"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Elder Word: Foresight"], ["Eternal Servitude"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["E.T.C., Band Manager"], ["The Harvester of Envy"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big LC Quest Priest":
      {[
         all: [["Reach Equilibrium"], ["Illuminate", "Shadow Visions"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Thoughtsteal"], ["Raza the Chained", "Zephrys the Great"]],
          all: [["Blademaster Okani"], ["Shadowreaper Anduin"]]
        ]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Psychic Conjurer"],
            ["Cathedral of Atonement", "Raza the Chained"]
          ],
          all: [["Najak Hexxen"], ["Raza the Chained"]]
        ]
      ]
    ],
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Thoughtsteal"],
            ["Aman'Thul", "Psychic Conjurer", "Puppet Theatre"]
          ]
        ]
      ]
    ],
    "XL LC Quest Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Intertwined Fate"], ["Reach Equilibrium"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Najak Hexxen"], ["Potion of Madness"]]]
      ]
    ],
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Seek Guidance"], ["Dirty Rat", "Zephrys the Great"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Nightshade Tea"], ["Rest in Peace"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Mixologist"],
            ["Aman'Thul", "Elder Word: Foresight", "Identity Theft", "Raza the Chained"]
          ],
          all: [
            ["Raza the Chained"],
            ["Aviana, Elune's Chosen", "Cathedral of Atonement"]
          ],
          all: [["Aman'Thul"], ["Far Watch Post"]],
          all: [["Dirty Rat"], ["Mass Hysteria"]]
        ]
      ]
    ],
    "Shadow Priest": {[all: [["Miracle Salesman"], ["Papercraft Angel"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[all: [["Gravedawn Sunbloom"], ["Vivid Nightmare"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": {[all: [["Creation Protocol"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [["Sphere of Sapience"], ["Gravedawn Sunbloom", "Vivid Nightmare"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [
           ["C'Thun, Eye of the Empire"],
           ["Gravedawn Sunbloom", "Love Everlasting"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [["Gift of Luminance"], ["Sphere of Sapience"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Barnes"], ["Nightshade Tea"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest":
      {[
         all: [["Identity Theft"], ["Illuminate", "Intertwined Fate"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Razorscale"], ["Far Watch Post", "Theotar, the Mad Duke"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Elder Word: Foresight"], ["Shadow Essence"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Elder Word: Foresight"], ["Pendant of Earth"]]], [start_of_game: ["Prince Renathal"]]},
    "STD Thief Priest": {[all: [["Elder Word: Foresight"], ["Soothsayer"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest":
      {[
         all: [["E.T.C., Band Manager"], ["Identity Theft"]],
         all: [["Mindrender Illucia"], ["The Harvester of Envy"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Seek Guidance"], ["Slime 'em!"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Raza the Chained"]],
          all: [["Hysteria"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "Divine Spirit Priest": {[all: [["Palm Reading"], ["Power Word: Shield"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Benevolent Banker"], ["Shadow Word: Devour"]]]
      ]
    ],
    "Thief Priest": {[all: [["Mysterious Visitor"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [
           ["Sphere of Sapience"],
           ["Pendant of Earth", "Thrive in the Shadows"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Identity Theft"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [
           ["Masked Reveler"],
           ["Illuminate", "Love Everlasting", "Shadow Visions"]
         ]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Razorscale"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Identity Theft"], ["Zephrys the Great"]]]
      ]
    ],
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Mindrender Illucia"]]]
      ]
    ],
    "Automaton Priest": {[all: [["Animate Dead"], ["Raise Dead"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Papercraft Angel"], ["Spirit of the Kaldorei"]]]
      ]
    ],
    "HL Thief Priest":
      {[all: [["Mysterious Visitor"], ["Sir Finley, Sea Guide"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Aman'Thul"], ["Barnes"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Benevolent Banker"], ["Seek Guidance"]]]
      ]
    ],
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Creation Protocol"], ["Identity Theft"]]]
      ]
    ],
    "Thief Priest": {[all: [["Birdwatching"], ["Medivh's Triumph"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL JtU Quest Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Awaken the Makers"], ["Medivh's Triumph"]]]
      ]
    ],
    "Shadow Priest": {[all: [["Dark Deacon"], ["Elder Word: Flay"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Birdwatching"], ["The Harvester of Envy"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Benevolent Banker"], ["Cathedral of Atonement"]],
          all: [["Dirty Rat"], ["Theotar, the Mad Duke"]]
        ]
      ]
    ],
    "Protoss Priest": {[all: [["Photon Cannon"], ["Sentry"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest":
      {[
         all: [["Creation Protocol"], ["Medivh's Triumph"]],
         all: [["Identity Theft"], ["Mysterious Visitor"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Mysterious Visitor"], ["Puppet Theatre"]]], [start_of_game: ["Prince Renathal"]]},
    "Nazmani Priest":
      {[
         all: [["Creation Protocol"], ["Elder Word: Foresight", "Palm Reading"]],
         all: [["Elder Word: Flay"], ["Palm Reading"]],
         all: [["Illuminate"], ["Shadowcloth Needle"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Shadow Priest": {[all: [["Elder Word: Flay"], ["Elder Word: Foresight"]]], [start_of_game: ["Prince Renathal"]]},
    "Divine Spirit Priest": {[all: [["Chrono Boost"], ["Hallucination"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["The Harvester of Envy"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Shadow Essence"], ["Shard of the Naaru"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Mindrender Illucia"], ["Mysterious Visitor"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Identity Theft"], ["Mysterious Visitor"]]]
      ]
    ],
    "Big Questline Priest": {[all: [["Barnes"], ["Sphere of Sapience"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Pendant of Earth"], ["Seek Guidance"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Gift of Luminance"], ["Potion of Madness"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Illuminate"], ["Intertwined Fate"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Hysteria"]]]
      ]
    ],
    "Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Birdwatching"], ["Intertwined Fate"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Eternal Servitude"], ["Shard of the Naaru"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [
           ["Barnes"],
           [
             "Gravedawn Sunbloom",
             "Medivh's Triumph",
             "Shadow Word: Devour",
             "Shard of the Naaru",
             "Thrive in the Shadows"
           ]
         ],
         all: [["Gravedawn Sunbloom"], ["Pendant of Earth"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Barnes"], ["Vivid Nightmare"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Birdwatching"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Potion of Madness"], ["Barnes", "Pendant of Earth"]],
         all: [["Eternal Servitude"], ["Slime 'em!"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Far Watch Post"], ["Raise Dead"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Cult Neophyte"], ["Razorscale"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blademaster Okani"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Kaldorei Priestess"], ["Seek Guidance"]]]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [
            ["Blademaster Okani"],
            ["Cathedral of Atonement", "Elder Word: Foresight"]
          ],
          all: [["Cathedral of Atonement"], ["Potion of Madness"]],
          all: [["Dirty Rat"], ["Shadow Word: Devour"]],
          all: [["E.T.C., Band Manager"], ["Zephrys the Great"]],
          all: [["Raise Dead"], ["Razorscale"]]
        ]
      ]
    ],
    "Shadow Priest": {[all: [["Brain Masseuse"], ["Ship's Chirurgeon"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": {[all: [["Dirty Rat"], ["Psychic Conjurer"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Medivh's Triumph"], ["Seek Guidance"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Barnes"], ["Love Everlasting", "Pendant of Earth"]],
         all: [["Palm Reading"], ["Potion of Madness", "Sphere of Sapience"]],
         all: [["Pendant of Earth"], ["Rest in Peace"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Pendant of Earth"], ["Shadow Essence"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Intertwined Fate"], ["The Harvester of Envy"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Shadow Essence"], ["Slime 'em!"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Barnes"], ["Shadow Essence"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Palm Reading"], ["Barnes", "Rest in Peace"]],
         all: [["Illuminate"], ["Nightshade Tea"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Raza the Chained"], ["Zephrys the Great"]]]
      ]
    ],
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [
          all: [["Dirty Rat"], ["Identity Theft"]],
          all: [["Elder Word: Foresight"], ["Zephrys the Great"]]
        ]
      ]
    ],
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Benevolent Banker"], ["Potion of Madness"]]]
      ]
    ],
    "Shadow Priest": {[all: [["Elder Word: Foresight"], ["Shadowcloth Needle"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Pendant of Earth"], ["Love Everlasting", "Medivh's Triumph"]],
         all: [["Barnes"], ["Shadow Visions"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Palm Reading"], ["Pendant of Earth"]]], [start_of_game: ["Prince Renathal"]]},
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Puppet Theatre"], ["Reno, Lone Ranger"]]]
      ]
    ],
    "HL Thief Priest": {[all: [["E.T.C., Band Manager"], ["Illuminate"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Identity Theft"], ["Seek Guidance"]]]
      ]
    ],
    "HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Identity Theft"]]]
      ]
    ],
    "Big Questline Priest": {[all: [["Gravedawn Sunbloom"], ["Shadow Essence"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Palm Reading"], ["Shard of the Naaru"]]], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Intertwined Fate"], ["Medivh's Triumph"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [["Elder Word: Foresight"], ["Love Everlasting"]],
         all: [["Shadow Essence"], ["Shadow Visions"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Love Everlasting"], ["Shadow Essence"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Gravedawn Sunbloom"], ["Love Everlasting"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Prince Renathal"], ["Seek Guidance"]]]
      ]
    ],
    "Thief Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["E.T.C., Band Manager"], ["Seek Guidance"]]]
      ]
    ],
    "Thief Priest": {[all: [["E.T.C., Band Manager"], ["Mysterious Visitor"]]], [start_of_game: ["Prince Renathal"]]},
    "XL N'Zoth Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Power Chord: Synchronize"], ["Twilight's Call"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Palm Reading"], ["Slime 'em!"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Love Everlasting"], ["Palm Reading"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Love Everlasting"], ["Shadow Visions"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Dirty Rat"], ["Sir Finley, Sea Guide"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Pendant of Earth"], ["Thrive in the Shadows"]]], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest":
      {[
         all: [["Illuminate"], ["Sphere of Sapience"]],
         all: [["Medivh's Triumph"], ["Palm Reading"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest":
      {[
         all: [
           ["Palm Reading"],
           ["Gravedawn Sunbloom", "Illuminate", "Shadow Visions"]
         ],
         all: [["Illuminate"], ["Shadow Essence"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Thief Priest": {[all: [["Creation Protocol"], ["Illuminate"]]], [start_of_game: ["Prince Renathal"]]},
    "XL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Elder Word: Foresight"], ["Seek Guidance"]]]
      ]
    ],
    "XL HL Questline Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Seek Guidance"], ["Medivh's Triumph", "Shadow Visions"]]]
      ]
    ],
    "C'Thun Priest":
      {[
         all: [["Illuminate"], ["Shadow Visions"]],
         all: [["Palm Reading"], ["Thrive in the Shadows"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "Big Questline Priest": {[all: [["Shadow Visions"], ["Sphere of Sapience"]]], [start_of_game: ["Prince Renathal"]]},
    "Other Priest": {[all: [["Elder Word: Foresight"], ["Shadow Visions"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Aman'Thul"], ["Prince Renathal"]]]
      ]
    ],
    "LC Quest Priest":
      {[
         all: [["Intertwined Fate"], ["Kaldorei Priestess", "Lunarwing Messenger"]]
       ], [start_of_game: ["Prince Renathal"]]},
    "XL Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Elder Word: Foresight"], ["Shadow Visions"]]]
      ]
    ],
    "C'Thun Priest": {[all: [["Illuminate"], ["Pendant of Earth"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Shadow Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Blade of The Black Empire"], ["Instrument Tech"]]]
      ]
    ],
    "Other Priest": {[all: [["Kaldorei Priestess"], ["Lunarwing Messenger"]]], [start_of_game: ["Prince Renathal"]]},
    "C'Thun Priest": {[all: [["Illuminate"], ["Thrive in the Shadows"]]], [start_of_game: ["Prince Renathal"]]},
    "XL HL Thief Priest": [
      all: [
        [start_of_game: ["Prince Renathal"]],
        [all: [["Elder Word: Foresight"], ["Raise Dead"]]]
      ]
    ],
    "Big Questline Priest":
      {[
         all: [["Shadow Visions"], ["Thrive in the Shadows"]]
       ], [start_of_game: ["Prince Renathal"]]}
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Priest")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Priest")
  end
end
