# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PriestArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    # auto gen
    "Control Priest": [
      "Ancient of Yore",
      "Atiesh the Greatstaff",
      "Cleansing Cleric",
      "Cultivating Sprite",
      "Devouring Plague",
      "Dirty Rat",
      "Elise the Navigator",
      "Story of Amara",
      "The Black Blood",
      "Ysera, Emerald Aspect"
    ],
    "Quest Priest": [
      "Calia Menethil",
      "Disciple of the Dove",
      "Jailbird",
      "Ritual of Life",
      "Twilight Influence",
      "Vanessa the Ringleader"
    ],
    "Control Priest": ["Flash Heal"],
    "Thief Priest": ["Enthralled Shade"],
    "Control Priest": [
      "Bitterbloom Knight",
      "Cease to Exist",
      "Eternal Firebolt",
      "For All Time",
      "Greater Healing Potion",
      "Holy Nova",
      "Ruby Sanctum"
    ],
    "Thief Priest": ["Azalina Soulsever", "Karov the Broken", "Mind Sweeper", "Psychic Conjurer", "Unshackle Soul"],
    "Quest Priest": ["Hold Them Off!", "Power Word: Shield"],
    "Control Priest": [
      "Gravedawn Sunbloom",
      "Holy Embrace",
      "Intertwined Fate",
      "Kaldorei Priestess",
      "Lunarwing Messenger",
      "Medivh's Triumph",
      "Mend",
      "Moonwell",
      "Nightmare Lord Xavius",
      "Reach Equilibrium",
      "Shadow Word: Ruin",
      "Soothsayer",
      "Undeath Sentence"
    ]
    # {:"Control Priest",
    #  [
    #    "Devouring Plague",
    #    "Fae Trickster",
    #    "Holy Nova",
    #    "Eternal Firebolt",
    #    "Cleansing Cleric",
    #    "The Black Blood",
    #    "Dirty Rat",
    #    "Atiesh the Greatstaff",
    #    "Karazhan the Sanctum",
    #    "Medivh the Hallowed",
    #    "Flash Heal",
    #    "Shadow Word: Ruin",
    #    "Ruby Sanctum",
    #    "Tranquil Treant",
    #    "Reach Equilibrium",
    #    "Intertwined Fate",
    #    "Voodoo Totem",
    #    "Story of Amara",
    #    "Nightmare Lord Xavius",
    #    "For All Time",
    #    "Medivh's Triumph",
    #    "Sands of Time",
    #    "Kaldorei Priestess",
    #    "Ancient of Yore",
    #    "Gravedawn Sunbloom",
    #    "Mend",
    #    "Lunarwing Messenger",
    #    "Greater Healing Potion",
    #    "Cease to Exist",
    #    "Power Word: Shield",
    #    "Ysera, Emerald Aspect",
    #    "Moonwell",
    #    "Bitterbloom Knight",
    #    "Purifying Breath"
    #  ]}
  ]
  @wild_config [
    "Shadow Priest": ["Parachute Brigand"],
    "LC Quest Priest": ["Grave Horror", "Undying Allies"],
    "Shadow Priest": ["Defias Leper", "Treasure Distributor"],
    "Heal Burn Priest": ["Careless Crafter", "Embrace the Shadow"],
    "XL HL Questline Priest": ["Seek Guidance"],
    "XL HL Thief Priest": ["Boompistol Bully", "The Harvester of Envy"],
    "Divine Spirit Priest": ["Shadowfiend"],
    "LC Quest Priest": ["Priestess Valishj"],
    "Mecha'thun Priest": ["Mecha'thun"],
    "XL HL Thief Priest": ["Crystalline Oracle", "Mysterious Visitor"],
    "XL HL Shadow Priest": ["Fanboy"],
    "LC Quest Priest": ["Renew"],
    "XL HL Shadow Priest": ["Magatha, Bane of Music", "Speaker Stomper"],
    "XL Shadow Priest": ["Ethereal Oracle", "Idol's Adoration"],
    "XL HL Thief Priest": ["Mindrender Illucia"],
    "Shadow Priest": ["Voidtouched Attendant"],
    "Protoss Priest": ["Sentry", "Void Ray"],
    "XL HL Shadow Priest": ["Miracle Salesman", "Spawn of Shadows"],
    "XL HL Thief Priest": ["Lorekeeper Polkelt", "Madame Lazul", "Thoughtsteal"],
    "XL HL Thief Priest": ["Astalor Bloodsworn"],
    "LC Quest Priest": ["Handmaiden"],
    "Shadow Priest": ["Twilight Deceptor"],
    "XL HL Thief Priest": ["Deathlord"],
    "XL HL Shadow Priest": ["Cult Neophyte", "Serena Bloodfeather", "Skulking Geist"],
    "Divine Spirit Priest": ["Chrono Boost", "Hallucination"],
    "LC Quest Priest": ["Palm Reading"],
    "Mecha'thun Priest": ["Nazmani Bloodweaver", "Regenerate"],
    "Automaton Priest": ["Gravity Lapse"],
    "Boar Priest": ["Elwynn Boar"],
    "LC Quest Priest": ["Illuminate"],
    "STD Control Priest": ["Flash Heal", "Moonwell"],
    "Shadow Priest": ["Acupuncture"],
    "Splendiferous Whizbang": ["Astral Automaton"],
    "XL HL Thief Priest": ["Deafen", "Identity Theft", "Mass Hysteria", "Psychic Scream", "Spirit Lash"],
    "XL HL LC Quest Priest": ["Elise, Badlands Savior"],
    "XL HL Shadow Priest": ["Shadow Word: Devour", "Smothering Starfish"],
    "Shadow Priest": ["Shadowbomber"],
    "XL Shadow Priest": ["Frenzied Felwing"],
    "XL HL Thief Priest": ["Darkbishop Benedictus", "Shadowreaper Anduin"],
    "XL HL Shadow Priest": ["Spirit of the Kaldorei"],
    "XL HL Thief Priest": ["Najak Hexxen", "Reno Jackson"],
    "XL HL LC Quest Priest": ["Sphere of Sapience"],
    "LC Quest Priest": ["Thrive in the Shadows"],
    "XL HL Thief Priest": ["Mixologist"],
    "XL HL Thief Priest": ["Zephrys the Great"],
    "Shadow Priest": ["Ship's Chirurgeon"],
    "XL HL Shadow Priest": ["Papercraft Angel", "Razorscale"],
    "XL HL Thief Priest": ["Blademaster Okani", "Raza the Chained"],
    "XL HL Thief Priest": ["Far Watch Post"],
    "STD Control Priest": ["Cleansing Cleric"],
    "LC Quest Priest": ["Gravedawn Sunbloom", "Nightshade Tea"],
    "XL HL Shadow Priest": ["Psychic Conjurer"],
    "XL LC Quest Priest": ["Flutterwing Guardian"],
    "XL LC Quest Priest": ["Bitterbloom Knight"],
    "LC Quest Priest": ["Reach Equilibrium"],
    "XL HL Thief Priest": ["Benevolent Banker", "Cathedral of Atonement", "Dirty Rat"]
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
