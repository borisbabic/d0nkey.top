# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}
  @standard_config [
    "Tick Tock Warlock": ["Battle at the End Time"],
    "Quest Warlock": ["Escape the Underfel"],
    Rafaamlock: [
      "Tiny Rafaam",
      "Green Rafaam",
      "Murloc Rafaam",
      "Explorer Rafaam",
      "Warchief Rafaam",
      "Calamitous Rafaam",
      "Mindflayer R'faam",
      "Giant Rafaam",
      "Archmage Rafaam",
      "Timethief Rafaam"
    ],
    # auto gen
    Egglock: ["Abusive Sergeant"],
    "Divergence Warlock": ["Divergence"],
    "Wallow Warlock": ["Overgrown Horror"],
    Egglock: ["Holy Eggbearer", "The Egg of Khelos"],
    "Godfrey Warlock": [
      "Ancient of Yore",
      "Bat Mask",
      "Captured Archmage",
      "Chrono-Lord Deios",
      "Tranquil Treant",
      "Ysera, Emerald Aspect"
    ],
    "Wallow Warlock": ["Raptor Herald"],
    Rafaamlock: ["Glacial Shard", "P1CK-P0K3T", "Prize Vendor"],
    "Godfrey Warlock": ["Annihilation"],
    "Animancer Warlock": ["Escape Artist"],
    "Godfrey Warlock": ["Demonic Confinement"],
    Rafaamlock: ["Elise the Navigator", "Possessed Animancer", "RAFAAM LADDER!!"],
    "Godfrey Warlock": [
      "Archwitch Willow",
      "Critter Caretaker",
      "Eldritch Tentacles",
      "Godfrey the Betrayer",
      "Spire of Solitude",
      "Zuramat's Prison"
    ],
    Rafaamlock: [
      "Caged Cranium",
      "Cursed Catacombs",
      "Drain Soul",
      "Fractured Power",
      "Hellfire",
      "Rotheart Dryad",
      "Shadow Rounds",
      "Sheltered Survivor",
      "The Unseen Atlas"
    ]
    # Egglock: ["Abusive Sergeant", "Archdruid of Thorns", "Dissolving Ooze", "Spirit Bomb"],
    # "Wallow Warlock": ["Hopeful Dryad", "Overgrown Horror"],
    # "Divergence Warlock": ["Fae Trickster"],
    # Egglock: ["Endbringer Umbra", "Holy Eggbearer"],
    # "Wallow Warlock": ["Wallow, the Wretched"],
    # "Divergence Warlock": ["Divergence", "Shaladrassil"],
    # "Aggro Warlock": ["Darkscale Broodmother", "Flame Imp"],
    # "Wallow Warlock": [
    #   "Avant-Gardening",
    #   "Creature of Madness",
    #   "Raptor Herald",
    #   "Shadowflame Stalker",
    #   "Treacherous Tormentor"
    # ],
    # Egglock: ["Conflagrate", "Shadowsworn Disciple", "Shrine of Twilight", "The Egg of Khelos", "Ultraxion"],
    # Rafaamlock: [
    #   "Cursed Catacombs",
    #   "Drain Soul",
    #   "Eldritch Tentacles",
    #   "Elise the Navigator",
    #   "Eternal Toil",
    #   "Fractured Power",
    #   "Glacial Shard",
    #   "Hellfire",
    #   "Nightmare Lord Xavius",
    #   "Possessed Animancer",
    #   "Sheltered Survivor"
    # ]
  ]
  @wild_config [
    Discolock: [
      "Boneweb Egg",
      "Chronoclaws",
      "Disposable Acolytes",
      "Duke of Below",
      "Entropic Continuity",
      "Irondeep Trogg",
      "Party Fiend",
      "Platysaur",
      "Silverware Golem",
      "Silverware Golem",
      "Soul Barrage",
      "Walking Dead",
      "Wicked Whispers"
    ],
    "XL HL Tick Tock Warlock": ["Kerrigan, Queen of Blades", "Nydus Worm", "Spawning Pool", "Witchwood Piper"],
    Boarlock: ["Shadowborn"],
    "XL Highlander Warlock": ["Mixologist", "Void Contract"],
    "Fatigue Seedlock": ["Blood Shard Bristleback"],
    "XL Highlander Warlock": ["Deathlord", "Rin, Orchestrator of Doom", "Soul Seeker"],
    "XL HL Tick Tock Warlock": [
      "Battle at the End Time",
      "Speaker Stomper",
      "The Curator",
      "Timeline Accelerator",
      "Ultralisk Cavern"
    ],
    "XL Highlander Warlock": ["Mutanus the Devourer", "Theotar, the Mad Duke"],
    "XL Demon Boarlock": ["Crane Game"],
    "XL Seedlock": ["Tachyon Barrage"],
    Boarlock: ["Eat! The! Imp!", "Elwynn Boar", "Tour Guide"],
    Evenlock: ["Goldshire Gnoll", "Mountain Giant"],
    "Fatigue Seedlock": ["Fanottem, Lord of the Opera"],
    "XL Warlock": ["Messmaker"],
    "XL Highlander Warlock": ["Altar of Fire", "Bygone Doomspeaker", "Dar'Khan Drathir", "Eredar Brute"],
    "XL Seedlock": ["Celestial Projectionist", "Imployee of the Month"],
    Discolock: ["Soulfire"],
    "XL SoU Quest Warlock": ["Supreme Archaeology"],
    "Insanity Warlock": ["Encroaching Insanity"],
    "XL Demon Boarlock": ["Fae Trickster"],
    "XL Seedlock": ["Shadowblade Slinger"],
    "XL Highlander Warlock": ["Far Watch Post", "Zilliax Deluxe 3000"],
    "XL Seedlock": ["Spirit Bomb"],
    "STD Harold Egglock": ["Abusive Sergeant"],
    Seedlock: ["Flesh Giant", "Molten Giant"],
    "XL Highlander Warlock": ["Cataclysm", "Gnomeferatu", "Zilliax Deluxe 3000"],
    Boarlock: ["Rain of Fire"],
    Boarlock: ["Old Murk-Eye"],
    "Other Warlock": ["Treachery"],
    "XL HL Tick Tock Warlock": ["Grimoire of Sacrifice"],
    "Other Warlock": ["Barrens Scavenger"],
    "Fatigue Seedlock": ["Chamber of Viscidus"],
    "STD Harold Egglock": ["Holy Eggbearer"],
    Boarlock: ["Conflagrate"],
    "Insanity Warlock": ["Void Virtuoso"],
    "XL Highlander Warlock": ["Blademaster Okani", "Demonic Project"],
    Boarlock: ["Felstring Harp", "Fracking"],
    Seedlock: ["Healthstone", "Imprisoned Horror"],
    "XL HL Tick Tock Warlock": ["Cult Neophyte", "Plot Twist", "Smothering Starfish"],
    Discolock: ["The Soularium"],
    "XL Highlander Warlock": [
      "Dark Skies",
      "Full-Blown Evil",
      "Nightmare Lord Xavius",
      "Sargeras, the Destroyer",
      "Symphony of Sins",
      "Wing Welding",
      "Zephrys the Great"
    ],
    "XL Warlock": ["Burrow Buster"],
    "XL Warlock": ["Mo'arg Drillfist"],
    Discolock: ["Ocular Occultist"],
    "XL Seedlock": ["The Demon Seed"],
    "Ashtoungue Warlock": ["Mass Production"],
    Boarlock: ["Kobold Librarian"],
    "XL Highlander Warlock": ["Dirty Rat"],
    "Other Warlock": ["\"Health\" Drink"],
    Boarlock: ["Darkbomb", "Darkbomb", "Domino Effect"],
    Discolock: ["Cursed Catacombs"]
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Warlock")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Warlock")
  end
end
