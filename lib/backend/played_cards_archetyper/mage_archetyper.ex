# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.MageArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @leyline_package [
    "Crystallized Leyline",
    "Ley Walker",
    "Bursting Leyline",
    "The Arcanomicon",
    "Surge Needle",
    "Mystic Runesaber",
    "Leyline Nexus"
  ]
  @standard_excludes %{}
  @standard_config [
    {:"Quest Mage", ["The Forbidden Sequence"]},
    {:"Imbue Mage",
     [
       "Aessina",
       "Bitterbloom Knight",
       "Divination",
       "Flutterwing Guardian",
       "Malorne the Waywatcher",
       "Petal Picker",
       "Resplendent Dreamweaver",
       "Spirit Gatherer",
       "Wisprider"
     ]},
    {:"Leyline Mage", @leyline_package},
    {:"Burn Mage",
     [
       "Archmage Kalec",
       "Arcane Barrage",
       "Bloodmage Thalnos",
       "Conjured Bookkeeper",
       "Contraband Wands",
       "Fireball",
       "First Flame",
       "Frostbolt",
       "Living Flame",
       "Raincaller",
       "Runed Orb",
       "Sands of Time",
       "Scorching Winds",
       "Sizzling Cinder",
       "Sleet Storm",
       "Spark of Life",
       "Spellweaver's Brilliance",
       "Storage Scuffle",
       "Time-Twisted Seer",
       "Tunneling Geomancer",
       "Unstable Spellcaster",
       "Violet Spellwing",
       "Vulcanos"
     ]}
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
