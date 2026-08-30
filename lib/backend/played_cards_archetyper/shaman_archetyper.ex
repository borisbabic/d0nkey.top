# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Zee Shaman": [
      "Beaming Sidekick",
      "Carrier Whelp",
      "Cult Neophyte",
      "Dreambound Raptor",
      "Fire Fly",
      "Gallagio Goon",
      "Getaway Hogdriver",
      "Glacial Shard",
      "Hexmarshal",
      "Hijacked Securitybot",
      "Holy Eggbearer",
      "Platysaur",
      "Portal Vanguard",
      "Prize Vendor",
      "Rockskipper",
      "Shadowed Informant",
      "Slagclaw",
      "The Black Knight",
      "The Curator",
      "Warden Maiev"
    ],
    "Harold Shaman": [
      "Al'Akir, Lord of Storms",
      "Avatar Form",
      "Elise the Navigator",
      "Flight of the Firehawk",
      "High King's Hammer",
      "Muradin, High King",
      "Primordial Overseer",
      "Twilight Egg",
      "Ultraxion"
    ],
    "Mug Shaman": [
      "Ascendance",
      "Blazing Invocation",
      "Fire Breath",
      "Frostshatter",
      "Hex",
      "Low Security Wing",
      "Molten Gold",
      "Mountain Map",
      "Mug'Zee",
      "Ritual of Power",
      "Sands of Time",
      "Static Shock",
      "Stormfury",
      "Thunderquake",
      "Tiny Pal",
      "Wanted Poster"
    ]
  ]
  @wild_config [
    "Even Shaman": [
      "Anchored Totem",
      "Ancient Totem",
      "Carving Chisel",
      "Gigantotem",
      "Hydration Totem",
      "Jukebox Totem",
      "Splitting Axe",
      "The Stonewright",
      "Thing from Below",
      "Totemic Might",
      "Totemic Surge"
    ],
    "Ohn'ahra Big Shaman": ["Nebula"],
    "SoU Quest Shaman": ["Caricature Artist"],
    "XL HL Shudder Shaman": ["For All Time", "Miracle Salesman", "Razorscale", "Revolve", "Sphere of Sapience"],
    "Big Shaman": ["Rockbiter Weapon"],
    "Ohn'ahra Big Shaman": [
      "Ancestor's Call",
      "Auctionhouse Gavel",
      "Jam Session",
      "Muckmorpher",
      "Reincarnate",
      "Scalding Geyser"
    ],
    "STD Harold Shaman": ["Twilight Egg"],
    "XL Questline Shaman": ["Command the Elements"],
    "SoU Quest Shaman": ["Elementary Reaction", "Fire Plume Harbinger"],
    "STD Harold Shaman": ["Treasure Distributor"],
    "XL HL Shudder Shaman": ["Speaker Stomper"],
    "SoU Quest Shaman": ["Gorloc Ravager", "Scargil"],
    "Starship Shaman": ["Starport"],
    "XL HL LC Quest Shaman": ["Spirit of the Mountain"],
    "XL SoU Quest Shaman": ["Chaotic Tendril"],
    "XL HL Shudder Shaman": [
      "Backstage Bouncer",
      "Birdwatching",
      "Bolner Hammerbeak",
      "Boompistol Bully",
      "Cult Neophyte",
      "Doctor Holli'dae",
      "Elemental Destruction",
      "Far Watch Post",
      "Golganneth, the Thunderer",
      "Lorekeeper Polkelt",
      "Marin the Manager",
      "Parrot Sanctuary",
      "Pebbly Page",
      "Prescience",
      "Reno, Lone Ranger",
      "Sir Finley, Sea Guide",
      "Thrall's Gift",
      "Timeline Accelerator",
      "Zephrys the Great"
    ],
    "SoU Quest Shaman": ["Gold Panner", "Needlerock Totem", "Primal Dungeoneer"],
    "XL SoU Quest Shaman": ["Cold Storage", "Sleetbreaker", "Snowfall Guardian", "Ysera, Emerald Aspect"],
    "Elemental Shaman": ["Shale Spider"],
    "STD Harold Shaman": ["Witch's Apprentice"],
    "XL HL Shudder Shaman": ["Dirty Rat"],
    "Splendiferous Whizbang": ["Clownfish"],
    "XL HL Shudder Shaman": ["Turbulus"],
    "XL HL SoU Quest Shaman": ["Corrupt the Waters"],
    "Ohn'ahra Big Shaman": ["Fairy Tale Forest", "Triangulate"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Shaman")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Shaman")
  end
end
