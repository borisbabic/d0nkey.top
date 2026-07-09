# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Rogue": ["Lie in Wait"],
    "Harold Rogue": [
      "Maniacal Follower",
      "Ultraxion",
      "Envoy of the End",
      "Sinestra",
      "Deathwing, Worldbreaker"
    ],
    # auto gen
    #
    "Harold Rogue": ["Elise the Navigator"],
    "Two-Bit Rogue": ["Shadowed Informant"],
    # "AYAYA Rogue": ["Aya, Lotus Kingpin", "Defias Wannabe", "Time Adm'ral Hooktail"],
    "Two-Bit Rogue": [
      "Agent of the Old Ones",
      "Bitterbloom Knight",
      "Blackpaw's Whip",
      "Cultist Map",
      "Eventuality",
      "Flashback",
      "Foxy Fraud",
      "Frantic Forger",
      "Garona Halforcen",
      "Jade Guardians",
      "Lotus Bookie",
      "Lotus Troublemaker",
      "Nab",
      "Picklock",
      "Preparation",
      "Prize Vendor",
      "Rite of Twilight",
      "The Kingslayers",
      "Thief's Tools",
      "Vanessa the Ringleader"
    ]
  ]
  @wild_config [
    "Quasar Rogue": ["Shiv"],
    "Alex Rogue": ["Darkscale Broodmother"],
    "Quasar Rogue": ["Knickknack Shack", "Mimic Pod", "Quasar", "Shadow of Death", "Street Trickster"],
    "Miracle Rogue": ["Scribbling Stenographer"],
    "XL Mill Rogue": ["Vanndar Stormpike"],
    "777 Miracle Rogue": ["Arcane Giant", "Everything Must Go!", "Triple Sevens"],
    "JtU Quest Rogue": ["The Caverns Below"],
    "Pirate Rogue": ["Swordfish"],
    "Hostage Rogue": ["Jade Telegram"],
    "Kingsbane Rogue": ["Blade Flurry"],
    "Kingslayer Pirate Rogue": ["Sailboat Captain"],
    "XL Velarok Rogue": ["Wildpaw Gnoll"],
    "Alex Rogue": ["Foxy Fraud", "Shadowcaster"],
    "XL Mill Rogue": ["Armor Vendor", "Scabbs Cutterbutter", "The Curator", "War'loc"],
    "Hostage Rogue": ["Garrote"],
    "XL HL Thief Rogue": ["Reno, Lone Ranger"],
    "XL Velarok Rogue": ["Petty Theft", "Space Pirate"],
    "Deathrattle Rogue": ["Smokescreen"],
    "XL LC Quest Rogue": ["Moonstone Mauler"],
    "Well Rogue": ["Wishing Well"],
    "XL HL Thief Rogue": ["Reno Jackson"],
    "Kingsbane Rogue": ["Kingsbane"],
    "XL Velarok Rogue": ["Cutting Class"],
    "Kingslayer Pirate Rogue": ["Hozen Roughhouser", "Treasure Distributor"],
    "STD Harold Rogue": ["Spymistress"],
    "HL Velarok Rogue": ["Cold Blood", "Southsea Deckhand"],
    "Hostage Rogue": ["Chrono Daggers", "Cloak of Shadows"],
    "XL HL Thief Rogue": ["Mixologist", "Robocaller"],
    "Quasar Rogue": ["Mic Drop"],
    "777 Miracle Rogue": ["Blackwater Cutlass", "Smothering Starfish"],
    "XL LC Quest Rogue": ["Augmented Elekk"],
    "HL Velarok Rogue": ["Swarthy Swordshiner"],
    "Well Rogue": ["Oh, Manager!"],
    "Miracle Rogue": ["Greedy Partner"],
    "Quasar Rogue": ["Fan of Knives", "Ghostly Strike"],
    "Alex Rogue": ["Shroud of Concealment"],
    "XL HL Thief Rogue": ["Party Fiend"],
    "XL Velarok Rogue": ["Deadly Poison"],
    "HL Velarok Rogue": ["Filletfighter", "Jolly Roger"],
    "777 Miracle Rogue": ["Cult Neophyte", "Shaladrassil"],
    "XL HL Thief Rogue": ["Zephrys the Great"],
    "STD Harold Rogue": ["Flashback"],
    "XL Imbue Rogue": ["Adaptive Amalgam"],
    "XL Mill Rogue": ["Pit Stop"],
    "Quasar Rogue": ["Quick Pick"],
    "XL Velarok Rogue": [
      "Parrrley",
      "Queen Azshara",
      "Savory Deviate Delight",
      "Shadowed Informant",
      "Spore Hallucination"
    ],
    "XL Imbue Rogue": ["Lotus Agents"],
    "XL LC Quest Rogue": ["Lie in Wait"],
    "777 Miracle Rogue": ["Agent of the Old Ones"],
    "XL Velarok Rogue": ["Sinestra"],
    "Quasar Rogue": ["Ethereal Oracle"],
    "Hostage Rogue": ["Potion of Illusion"],
    "XL Imbue Rogue": ["Envoy of the End"],
    "XL HL Thief Rogue": ["Underbelly Fence"],
    "XL Velarok Rogue": ["Agency Espionage", "Rite of Twilight", "Spectral Cutlass"],
    "XL HL Thief Rogue": ["Wand Thief"],
    "Velarok Rogue": ["Kobold Miner"],
    "XL HL Thief Rogue": ["Kaja'mite Creation"],
    "XL Mill Rogue": ["Spirit of the Shark"],
    "STD Harold Rogue": ["Darkbomb", "Shadow Word: Pain"],
    "XL Mill Rogue": ["Coldlight Oracle"],
    "STD Harold Rogue": ["Mad Scientist"],
    "Mill Rogue": ["Necrium Blade"],
    "Quasar Rogue": ["Swindle"],
    "777 Miracle Rogue": ["Gear Shift", "Gone Fishin'"],
    "Hostage Rogue": ["Dig for Treasure"],
    "XL Imbue Rogue": ["Flutterwing Guardian"],
    "XL Velarok Rogue": ["Treasure Hunter Eudora"],
    "XL HL Thief Rogue": ["Iso'rath"],
    "Deathrattle Rogue": ["Door of Shadows"],
    "XL Velarok Rogue": ["Stick Up"],
    "XL HL Thief Rogue": ["Maestra, Mask Merchant"],
    "Quasar Rogue": ["Cultist Map"],
    "STD Harold Rogue": ["Dirty Rat"],
    "XL Velarok Rogue": ["Bitterbloom Knight", "Deja Vu", "Nightmare Fuel"],
    "Velarok Rogue": ["Counterfeit Coin", "Preparation"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Rogue")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Rogue")
  end
end
