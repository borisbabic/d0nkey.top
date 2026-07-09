# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    # auto gen
    "Zee Shaman": ["Beaming Sidekick", "Endbringer Umbra"],
    "Zee Shaman": ["Beanstalk Brute"],
    "Mug Shaman": ["Instant Multiverse"],
    "Zee Shaman": [
      "Bralma Searstone",
      "Fire Fly",
      "Hexmarshal",
      "Portal Vanguard",
      "Shadowed Informant",
      "Sizzling Cinder"
    ],
    "Mug Shaman": ["Stormfury", "Zuramat's Prison"],
    "Zee Shaman": ["Prescient Slitherdrake"],
    "Harold Shaman": ["Flight of the Firehawk"],
    "Mug Shaman": ["Blazing Invocation", "Frostshatter", "Molten Gold", "Mountain Map"],
    "Zee Shaman": ["Darkscale Broodmother", "Emberscarred Whelp", "Primalfin Challenger", "Slagclaw", "Torga"],
    "Harold Shaman": ["Avatar Form", "Muradin, High King", "Primordial Overseer"],
    "Mug Shaman": ["Sands of Time", "Thunderquake"],
    "Zee Shaman": [
      "Carrier Whelp",
      "Cinderfin",
      "Elise the Navigator",
      "Envoy of the End",
      "Gallagio Goon",
      "Getaway Hogdriver",
      "Glacial Shard",
      "Hijacked Securitybot",
      "Holy Eggbearer",
      "Nightmare Lord Xavius",
      "Skywall Sentinel",
      "Tiny Pal",
      "Ultraxion",
      "Vanessa the Ringleader",
      "Wailing Vapor",
      "Warden Maiev",
      "Witch's Apprentice"
    ],
    "Mug Shaman": ["Low Security Wing", "Ritual of Power"]
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
