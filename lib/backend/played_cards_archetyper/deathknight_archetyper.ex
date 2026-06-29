# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest DK": ["Reanimate the Terror"],
    "Harold DK": [
      "Staff of the Endbringer",
      "Deathwing, Worldbreaker",
      "Obsessive Technician",
      "Ultraxion",
      "Arisen Onyxia",
      "Envoy of the End",
      "Experimental Animation",
      "Memoriam Manifest",
      "The Curator",
      "Soulrest Ceremony"
    ],
    "Unholy DK": [
      "Grave Strength",
      "Maze Guide",
      "Living Paradox",
      "Talanji's Last Stand"
    ],
    "Unholy DK": ["Shadows of Yesterday"],
    "Harold DK": ["Elise the Navigator"],
    "Harold DK": ["Hematurge", "Morbid Swarm"],
    "Unholy DK": ["Ancient Raptor", "Reluctant Wrangler", "Twilight Egg"],
    "Harold DK": ["Carrier Whelp", "Infested Breath"],
    "Harold DK": ["Chillfallen Baron"]
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
