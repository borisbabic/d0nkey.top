# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}

  @standard_config [
    "Quest Paladin": ["Dive the Golakka Depths"],
    "Pure Paladin": ["Vigilant Sentry"],
    "Aggro Paladin": ["Elven Archer", "Abusive Sergeant", "Beaming Sidekick", "Concealing Confection", "Fire Fly"],
    # auto-gen
    "Imbue Paladin": ["Resplendent Dreamweaver"],
    "Egg Paladin": ["Fae Trickster"],
    "Mill Paladin": ["Annoy-o-Tron"],
    "Pure Paladin": ["Scarlet Bruiser", "Truth Seeker"],
    "Imbue Paladin": ["Flutterwing Guardian", "Petal Picker"],
    "Pure Paladin": [
      "Gnomish Aura",
      "Inspiring Maul",
      "Mekkatorque's Aura",
      "Scalebreaker Bulwark",
      "Scarlet Recruiter",
      "Spearheart Sentry"
    ],
    "Mill Paladin": ["Endbringer Umbra"],
    "Egg Paladin": ["Loot Hoarder"],
    "Dude Paladin": ["Arator the Redeemer", "Emboldening Blade"],
    "Dude Paladin": ["Resilient Savior"],
    "Aggro Paladin": ["Murmy"],
    "Egg Paladin": ["Escape Artist"],
    "Pure Paladin": ["Gelbin of Tomorrow", "Nozdormu, Bronze Aspect", "Sandfury Aura", "Toreth the Unbreaking"],
    "Mill Paladin": ["Sands of Time", "Spikeridged Steed"],
    "Egg Paladin": ["Prize Vendor"],
    "Mill Paladin": ["Critter Caretaker", "Hardlight Protector", "Wild Pyromancer"],
    "Pure Paladin": ["Lightmender", "Reinforcement Aura"],
    "Dude Paladin": ["Teamwork"],
    "Imbue Paladin": ["Aegis of Light"],
    "Pure Paladin": ["Manifested Timeways"],
    "Egg Paladin": ["Hand of Infinity", "Holy Eggbearer", "Worgen Infiltrator"],
    "Dude Paladin": ["Muster for Battle"],
    "Pure Paladin": ["Convalescence", "Violet Treasuregill"],
    "Pure Paladin": ["Past Gnomeregan"],
    "Imbue Paladin": ["Bitterbloom Knight", "Goldpetal Drake"],
    "Aggro Paladin": ["Carrier Whelp", "Sizzling Cinder"],
    "Mill Paladin": ["Doomsayer", "Dragonscale Armaments", "Dreamwarden"],
    "Pure Paladin": ["Acceleration Aura", "Chronological Aura", "Righteous Protector"]
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
