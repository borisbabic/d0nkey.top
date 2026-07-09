# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}

  @standard_config [
    {:"Quest Paladin", ["Dive the Golakka Depths"]},
    {:"Imbue Paladin",
     [
       "Aegis of Light",
       "Bitterbloom Knight",
       "Dreamwarden",
       "Flutterwing Guardian",
       "Goldpetal Drake",
       "Malorne the Waywatcher",
       "Petal Picker",
       "Resplendent Dreamweaver"
     ]},
    # auto gen
    "Pure Paladin": ["Vigilant Sentry"],
    "End of Turnadin": ["Earthen Drake"],
    "Pure Paladin": ["Scarlet Bruiser"],
    "Aggro Paladin": ["Beaming Sidekick", "Fire Fly"],
    "Pure Paladin": ["Truth Seeker"],
    "Dude Paladin": ["Arator the Redeemer", "Brash Battlemaster", "Emboldening Blade"],
    "Pure Paladin": ["Lightmender"],
    "Egg Paladin": ["Fae Trickster", "Gullible Guard", "Holy Eggbearer", "The Egg of Khelos"],
    "End of Turnadin": ["Sheltered Survivor"],
    "Pure Paladin": [
      "Acceleration Aura",
      "Commander Beatrix",
      "Gelbin of Tomorrow",
      "Gnomish Aura",
      "Manifested Timeways",
      "Reinforcement Aura",
      "Sandfury Aura",
      "Scarlet Recruiter"
    ],
    "Dude Paladin": ["Hatching Ceremony", "Teamwork"],
    "End of Turnadin": [
      "Battle Vicar",
      "Glacial Shard",
      "Inspiring Maul",
      "Nightmare Lord Xavius",
      "Past Gnomeregan",
      "Scalebreaker Bulwark",
      "Sizzling Cinder",
      "Twilight Egg"
    ],
    "Pure Paladin": [
      "Consecration",
      "Convalescence",
      "Nozdormu, Bronze Aspect",
      "Righteous Protector",
      "Spearheart Sentry",
      "Toreth the Unbreaking",
      "Violet Treasuregill"
    ]
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
