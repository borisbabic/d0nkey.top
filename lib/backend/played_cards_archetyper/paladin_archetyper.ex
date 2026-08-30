# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}

  @standard_config [
    "Quest Paladin": ["Dive the Golakka Depths"],
    "Pure Paladin": ["Vigilant Sentry"],
    # Auto Gen
    "Imbue Paladin": ["Resplendent Dreamweaver"],
    "Aggro Paladin": ["Abusive Sergeant", "Beaming Sidekick", "Fire Fly"],
    "Egg Paladin": ["Fae Trickster"],
    "Imbue Paladin": ["Flutterwing Guardian", "Petal Picker"],
    "Pure Paladin": ["Scarlet Bruiser", "Scarlet Recruiter", "Truth Seeker"],
    "End of Turnadin": ["Earthen Drake"],
    "Mill Paladin": ["Endbringer Umbra", "Wild Pyromancer"],
    "End of Turnadin": ["Sheltered Survivor"],
    "Pure Paladin": ["Reinforcement Aura"],
    "Imbue Paladin": ["Cultivating Sprite"],
    "Aggro Paladin": ["Concealing Confection"],
    "Dude Paladin": ["Emboldening Blade", "Hatching Ceremony"],
    "Aggro Paladin": ["Carrier Whelp"],
    "End of Turnadin": ["Hourglass Attendant"],
    "Imbue Paladin": ["Bitterbloom Knight"],
    "Dude Paladin": ["Resilient Savior"],
    "End of Turnadin": ["Twilight Egg"],
    "Pure Paladin": [
      "Chronological Aura",
      "Gelbin of Tomorrow",
      "Inspiring Maul",
      "Manifested Timeways",
      "Nozdormu, Bronze Aspect",
      "Scalebreaker Bulwark",
      "Spearheart Sentry",
      "Toreth the Unbreaking"
    ],
    "Mill Paladin": ["Dirty Rat", "Mark of Ursol"],
    "Imbue Paladin": ["Goldpetal Drake"],
    "Egg Paladin": ["Escape Artist", "Prize Vendor", "The Egg of Khelos"],
    "Mill Paladin": ["Critter Caretaker", "Doomsayer", "Hardlight Protector"],
    "Aggro Paladin": ["Murmy"],
    "Pure Paladin": ["Acceleration Aura", "Past Gnomeregan"],
    "Aggro Paladin": ["Platysaur"],
    "Pure Paladin": ["Violet Treasuregill"],
    "Other Paladin": ["Teamwork"],
    "Pure Paladin": ["Convalescence", "Righteous Protector"],
    "Other Paladin": ["Consecration"]
  ]
  @wild_config [
    "Lynessa Libram Paladin": ["Adaptation", "Libram of Wisdom", "Lightray", "Myrmidon", "Sunsapper Lynessa"],
    "Mech Paladin": ["Click-Clocker", "Glow-Tron", "Security Automaton", "Skaterbot"],
    "CtA Paladin": ["Flash Sale"],
    "LC Quest Paladin": ["Braingill"],
    "CtA Paladin": ["Irondeep Trogg"],
    "STD Imbue Paladin": ["Ancient of Yore"],
    "LC Quest Paladin": ["Lushwater Scout"],
    "XL HL Aura Paladin": ["Speaker Stomper"],
    "LC Quest Paladin": ["Gnawing Greenfin", "Murloc Tidehunter"],
    "XL HL Aura Paladin": ["Gelbin of Tomorrow"],
    "CtA Paladin": ["Boogie Down"],
    "XL CtA Paladin": ["Explodineer", "Galloping Savior", "Trapdoor Spider"],
    "Lynessa Libram Paladin": ["Aldor Attendant"],
    "XL HL Exodia Paladin": ["Lorekeeper Polkelt"],
    "LC Quest Paladin": ["Amalgam of the Deep", "Imprisoned Sungill", "Twin-fin Fin Twin"],
    "CtA Paladin": ["Blood Matriarch Liadrin", "Call to Arms", "Nerub'ar Weblord"],
    "Lynessa Libram Paladin": ["Interstellar Starslicer"],
    "Lynessa Libram Paladin": ["Interstellar Researcher"],
    "XL HL Aura Paladin": ["Smothering Starfish"],
    "STD Dude Paladin": ["Sizzling Cinder"],
    "LC Quest Paladin": ["Dive the Golakka Depths"],
    "Odd Paladin": ["Murmy"],
    "Exodia Paladin": ["Order in the Court"],
    "XL HL Exodia Paladin": ["Garrison Commander", "Sing-Along Buddy", "Uther of the Ebon Blade"],
    "XL HL Aura Paladin": [
      "Astalor Bloodsworn",
      "Blademaster Okani",
      "Razorscale",
      "Sir Finley of the Sands",
      "Skulking Geist"
    ],
    "Questline Paladin": ["Desperate Measures", "Rise to the Occasion"],
    "CtA Paladin": ["Sword of the Fallen"],
    "XL HL Aura Paladin": ["Resistance Aura"],
    "STD Imbue Paladin": ["Consecration"],
    "Lynessa Libram Paladin": ["Instrument Tech"],
    "XL HL Aura Paladin": ["Miracle Salesman"],
    "XL Paladin": ["Aegis of Light", "Alliance Bannerman", "Dreamwarden"],
    "XL HL Aura Paladin": ["Mining Casualties"],
    "XL HL Aura Paladin": ["Runi, Time Explorer"],
    "XL HL Aura Paladin": ["Zephrys the Great"],
    "Lynessa Libram Paladin": ["Showdown!"],
    "Odd Paladin": ["Knight of Anointment", "Lost in the Jungle"],
    "Lynessa Libram Paladin": ["Crystology"]
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Paladin")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Paladin")
  end
end
