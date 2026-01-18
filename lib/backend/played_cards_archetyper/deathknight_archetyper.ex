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
    {:"Frost DK", ["Marrow Manipulator"]},
    # 5.5
    {:"Herenn DK",
     [
       "High Cultist Herenn",
       "Wakener of Souls",
       "Mo'arg Forgefiend"
       # "Overplanner",
       # "Astrobiologist",
       # "Bonechill Stegodon"
       # "Travel Security"
     ]},
    {:"Handbuff DK",
     [
       "City Chief Esho",
       "Lesser Spinel Spellstone",
       "Darkthorn Quilter",
       "Nerubian Swarmguard",
       "Amateur Puppeteer",
       # "Nerubian Swarmguard",
       "Blood Tap"
     ]},
    # {:"Amalgam DK", ["Adaptive Amalgam", "Braingill", "Floppy Hydra"]},
    {:"Frost DK", ["Harbinger of Winter"]},
    {:"Control DK",
     [
       "Shaladrassil",
       "Naralex, Herald of the Flights",
       "The Ceaseless Expanse",
       "Griftah, Trusted Vendor",
       "Ysera, Emerald Aspect",
       "Blob of Tar",
       "Exarch Maladaar",
       "Kerrigan, Queen of Blades",
       "Demolition Renovator",
       "Wicked Blightspawn",
       "Hideous Husk"
       # "The Ceaseless Expanse",
       # "Naralex, Herald of the Flights",
       # "Vampiric Blood",
       # "Marin the Manager",
       # "Blob of Tar",
       # "Hideous Husk",
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
       # "Kil'jaeden"
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
    {:"Herenn DK", ["Overplanner", "Bonechill Stegodon", "Giftwrapped Whelp"]},
    # 10.5
    {:"Frost DK", ["Horn of Winter", "Brittlebone Buccaneer"]},
    {:"Control DK",
     [
       "Chillfallen Baron",
       "Stitched Giant",
       "Foamrender",
       "Fyrakk the Blazing",
       "Dreadhound Handler"
     ]},
    {:"Herenn DK",
     [
       "Astrobiologist",
       "Bob the Bartender",
       "Husk, Eternal Reaper",
       "Portal Vanguard",
       "Ancient Raptor",
       "Timestop",
       "Soulrest Ceremony",
       "Ghouls' Night",
       "Troubled Mechanic",
       "Bwonsamdi",
       "Talanji of the Graves",
       "What Befell Zandalar",
       "Ancient of Yore",
       "Mixologist",
       "Frost Strike",
       "Travel Security",
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
       "Infested Breath"
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
