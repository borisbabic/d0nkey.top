# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest DK": ["Reanimate the Terror"],
    "Harold DK": [
      "Deathwing, Worldbreaker",
      "Obsessive Technician",
      "Ultraxion",
      "Arisen Onyxia",
      "Envoy of the End",
      "Experimental Animation"
    ],
    "Egg DK": [
      "Endbringer Umbra",
      "Dissolving Ooze",
      "Holy Eggbearer",
      "The Egg of Khelos"
    ],
    "Aggro DK": [
      "Grave Strength",
      "Reluctant Wrangler",
      "Talanji's Last Stand",
      "Twilight Egg",
      "Murmy",
      "Ancient Raptor",
      "Warden Maiev",
      "Battlefiend Necromancer",
      "Shadows of Yesterday",
      "Monstrous Mosquito"
    ],
    # AUTO GEN 
    #
    "Imbue DK": ["Petal Picker"],
    "Egg DK": ["Defias Smuggler"],
    "Egg DK": ["Portal Vanguard"],
    "Harold DK": ["The Curator"],
    "Other DK": ["Alexandros Mograine"],
    "Harold DK": ["Elise the Navigator"],
    "Rainbow DK": ["Blood Tap"],
    "Imbue DK": ["Bitterbloom Knight", "Finality", "Flutterwing Guardian"],
    "Other DK": ["Wicked Blightspawn"],
    "Egg DK": ["Drink Blood", "Falric", "Glacial Shard"],
    "Harold DK": ["Chillfallen Baron", "Command Claw", "Hematurge", "Husk, Eternal Reaper", "Sanguine Infestation"],
    "Egg DK": [
      "Blood Doctor Thal'ena",
      "Corpse Cannon",
      "Emergency Surgery",
      "Morbid Swarm",
      "Nightmare Lord Xavius",
      "Poison Breath",
      "Reanimated Pterrordax",
      "Remnant of Rage",
      "Sawbones",
      "Soulrest Ceremony",
      "Staff of the Endbringer",
      "Tower of Ghouls"
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

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DK")
  end
end
