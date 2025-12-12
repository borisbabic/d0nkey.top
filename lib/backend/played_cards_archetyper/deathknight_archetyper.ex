# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DK", ["Reanimate the Terror"]},
    {:"Whizbang DK",
     [
       "Thrive in the Shadows",
       "Wild Growth",
       "Elemental Inspiration",
       "Spore Hallucination",
       "Multicaster",
       "Bash",
       "Hipster",
       "Primordial Glyph",
       "Patchwork Pals",
       "Coral Keeper",
       "Chaos Strike",
       "Hellfire",
       "Consecration"
     ]},
    {:"Bot? DK",
     [
       "Stormwind Champion",
       "Life Drinker",
       "Sen'jin Shieldmasta",
       "Dire Wolf Alpha",
       "Annoy-o-Tron",
       "Murloc Tidehunter"
     ]},
    {:"Starship DK",
     [
       "Guiding Figure",
       "Soulbound Spire",
       "Arkonite Defense Crystal",
       "The Spirit's Passage",
       "The Exodar",
       "Dimensional Core"
     ]},
    {:"Herenn DK",
     [
       "High Cultist Herenn",
       "Wakener of Souls",
       "Petal Peddler",
       "Giftwrapped Whelp",
       "Bonechill Stegodon",
       "Slippery Slope",
       "Travel Security"
     ]},
    # 5.5
    {:"Handbuff DK",
     [
       "City Chief Esho",
       "Lesser Spinel Spellstone",
       "Darkthorn Quilter",
       "Amateur Puppeteer",
       # "Nerubian Swarmguard",
       "Blood Tap"
     ]},
    {:"Amalgam DK", ["Adaptive Amalgam", "Braingill", "Floppy Hydra"]},
    {:"Control DK",
     [
       "The Ceaseless Expanse",
       # "Naralex, Herald of the Flights",
       "Vampiric Blood",
       "Marin the Manager",
       "Bob the Bartender",
       "Blob of Tar",
       "Hideous Husk",
       # "Griftah, Trusted Vendor",
       # "Hideous Husk",
       # "Stitched Giant",
       # "Shaladrassil",
       # "Reanimated Pterrodax",
       # "Fyrakk the Blazing",
       # "Dreamplanner Zephyrus",
       # "Ysera, Emerald Aspect",
       # "Exarch Maladaar",
       # "Zilliax Deluxe 3000",
       # "Frosty Decor",
       # "Blob of Tar",
       # "Mister Clocksworth",
       # "Dreamplanner Zephrys",
       # "Reanimated Pterrordax",
       # "Rustrot Viper",
       # "Royal Librarian",
       # "Airlock Breach",
       # "Bob the Bartender",
       # "Marin the Manager",
       "Kil'jaeden"
       # "Corpse Explosion",
       # "Infested Breath",
       # "Sanguine Infestation",
       # "Morbid Swarm",
       # "Dreadhound Handler"
       # "Elise the Navigator",
       # "Chillfallen Baron",
       # "Dirty Rat",
       # "Creature of Madness",
       # "Nightmare Lord Xavius",
       # "Scarab Keychain",
       # "Foamrender",
       # "Demolition Renovator",
       # "Grotesque Runeblade",
       # "Steamcleaner",
       # "Headless Horseman",
       # "The 8 Hands from Beyond",
       # "The Headless Horseman"
     ]},
    {:"Herenn DK",
     [
       "Overplanner",
       "Astrobiologist",
       "Mo'arg Forgefiend"
     ]},
    {:"Frost DK",
     ["Marrow Manipulator", "Dread Raptor", "Harbinger of Winter", "Storm the Gates"]},
    # 10.5
    {:"Control DK",
     [
       "The Egg of Khelos",
       "Frosty Décor",
       "Chillfallen Baron",
       "Stitched Giant",
       "Naralex, Herald of the Flights",
       "Ysera, Emerald Aspect",
       "Foamrender",
       "Fyrakk the Blazing",
       "Shaladrassil",
       "Dreadhound Handler",
       "Prize Vendor",
       "Griftah, Trusted Vendor"
     ]},
    {:"Herenn DK",
     [
       "Portal Vanguard",
       "Ancient Raptor",
       "Timestop",
       "Soulrest Ceremony",
       "Ghouls' Night",
       "Troubled Mechanic",
       "Whelp of the Infinite",
       "Bwonsamdi",
       "Horn of Winter",
       "Talanji of the Graves",
       "What Befell Zandalar",
       "Ancient of Yore",
       "Mixologist",
       "Frost Strike",
       "Zergling",
       "Crypt Map"
     ]},
    {:"Control DK",
     [
       "Morbid Swarm",
       "Reanimated Pterrodax",
       "Creature of Madness",
       "Demolition Renovator",
       "Elise the Navigator",
       "Steamcleaner",
       "Infested Breath",
       "Nightmare Lord Xavius",
       "Dirty Rat"
     ]},
    {:"Herenn DK",
     [
       "Poison Breath",
       "Corpse Explosion",
       "Dreamplanner Zephyrs",
       "Sanguine Infestation",
       "Scarab Keychain"
     ]},
    {:"Frost DK",
     [
       "Murmy",
       "Monstrous Mosquito",
       "Brittlebone Buccaneer"
     ]},
    # 15.5
    {:"Starship DK", ["Suffocate"]}
  ]

  @wild_config [
    {:"XL Highlander DK",
     [
       "Reno, Lone Ranger",
       "Tuskarrrr Trawler",
       "Zephrys the Great",
       "Reno Jackson",
       "Customs Enforcer",
       "Space Pirate",
       "Mixologist",
       "Blademaster Okani",
       "Cult Neophyte",
       "Theotar, the Mad Duke",
       "Cold Feet",
       "Runeforging",
       "Quartzite Crusher",
       "Patchwerk",
       "Climactic Necrotic Explosion",
       "Razorscale",
       "Malted Magma",
       "Construct Quarter",
       "Buttons",
       "The Curator",
       "Staff od the Endbringer",
       "Dirty Rat",
       "E.T.C., Band Manager",
       "Frost Strike",
       "Elise the Navigator"
     ]}
  ]

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other DK")
  end
end
