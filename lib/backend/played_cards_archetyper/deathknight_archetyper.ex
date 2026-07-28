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
      "Holy Eggbearer",
      "The Egg of Khelos"
    ],
    "Aggro DK": [
      "Grave Strength",
      "Devious Coyote",
      "Battlefield Necromancer"
    ],
    "Imbue DK": ["Flutterwing Guardian", "Petal Picker"],
    # 5.5
    "Aggro DK": [
      "Cult Neophyte",
      "Talanji's Last Stand",
      "Twilight Egg",
      "Ancient Raptor",
      "Acolyte of Death"
    ],
    "Thal'ena DK": ["Glacial Shard", "Elvent Archer", "Sawbones"],
    # Auto Gen
    "Handbuff DK": ["Hourglass Attendant"],
    "Other DK": ["Ancient of Yore", "Concealing Confection"],
    "Thal'ena DK": ["Chow Down", "Creature of Madness"],
    "Harold DK": ["Hematurge", "Husk, Eternal Reaper"],
    "Imbue DK": ["Jagged Edge of Time"],
    "Rainbow DK": ["Chromatic Broodmother"],
    "Plague DK": ["Disguised Doctor"],
    "Thal'ena DK": ["Elven Archer"],
    "Aggro DK": ["Monstrous Mosquito"],
    "Handbuff DK": ["Blood Tap"],
    "Egg DK": ["Soulrest Ceremony"],
    "Aggro DK": ["Murmy", "Reluctant Wrangler"],
    "Harold DK": ["Chillfallen Baron", "Command Claw", "Infested Breath"],
    "Thal'ena DK": ["Blood Doctor Thal'ena", "Corpse Cannon", "Falric", "Prize Vendor", "Remnant of Rage"],
    #
    "Harold DK": ["Morbid Swarm"]
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
