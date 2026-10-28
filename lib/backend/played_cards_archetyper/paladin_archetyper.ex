# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.Hearthstone.Card

  defp any_neutral?(card_info) do
    Enum.any?(card_info.full_cards, fn c ->
      c.name != "The Coin" and Card.neutral?(c)
    end)
  end

  def standard_excludes do
    %{
      "Pure Paladin" => [&any_neutral?/1]
    }
  end

  defp base_standard_config do
    [
      "Quest Paladin": ["Dive the Golakka Depths"],
      "Ursol Paladin": ["Vigilant Sentry", "Scarlet Bruiser", "Oathbinder's Aura"],
      "Combo Paladin": ["Holy Eggbearer", "Bloodsail Raider"],
      "Imbue Paladin": [
        "Flutterwing Guardian",
        "Resplendent Dreamweaver",
        "Petal Picker",
        "Malorne the Waywatcher",
        "Bitterbloom Knight"
      ],
      "Ursol Paladin": ["Truth Seeker"],
      # 5.5
      "Combo Paladin": ["Endbringer Umbra", "Critter Caretaker"],
      "Ursol Paladin": [
        "Immortalized in Stone",
        "Mastermind Yogg-Saron",
        "Convalescence",
        "Amitut, Keeper of Amitus",
        "Portal Vanguard"
      ],
      "Combo Paladin": ["Hardlight Protector", "Unstable Prototype"],
      "Ursol Paladin": ["Scarlet Recruiter", "Chronological Aura"],
      "Ursol Paladin": ["Humble Judgment", "Ursine Maul"],
      # 10.5
      # auto gen
      "Other Paladin": ["Sheltered Survivor"],
      "Other Paladin": ["Smoldering Strength"],
      "Ursol Paladin": ["Gelbin of Tomorrow"],
      "Other Paladin": ["Fire Fly"],
      "Combo Paladin": ["Cult Neophyte"],
      "Ursol Paladin": [
        "Inspiring Maul",
        "Manifested Timeways",
        "Nozdormu, Bronze Aspect",
        "Rajh",
        "Reinforcement Aura",
        "Scalebreaker Bulwark",
        "Spearheart Sentry",
        "Toreth the Unbreaking"
      ],
      "Other Paladin": ["Brash Battlemaster"],
      "Other Paladin": ["Ancient of Yore"],
      "Other Paladin": ["Grimestreet Outfitter"],
      "Combo Paladin": ["Hand of Infinity", "The Egg of Khelos"],
      "Ursol Paladin": ["Resistance Aura", "Sandfury Aura"],
      "Other Paladin": ["Sizzling Cinder"],
      "Combo Paladin": ["Glacial Shard"],
      "Ursol Paladin": ["Acceleration Aura"],
      "Other Paladin": ["P1CK-P0K3T", "Primordial Wyrm"],
      "Ursol Paladin": [
        "Consecration",
        "Flash of Light",
        "March to War",
        "Mend the Timeline",
        "Sandcrafter",
        "Violet Treasuregill"
      ],
      "Other Paladin": ["Elise the Navigator"],
      "Ursol Paladin": ["Dreamwarden"],
      "Ursol Paladin": ["Holy Bola!"],
      "Ursol Paladin": ["Aegis of Light"],
      "Other Paladin": ["Prize Vendor"],
      "Ursol Paladin": ["Nightmare Lord Xavius", "Sun's Reckoning"],
      "Combo Paladin": ["Doomsayer"],
      "Ursol Paladin": ["Dragonscale Armaments", "Equality", "Righteous Protector"]
    ]
  end

  def wild_excludes, do: %{}

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

  def standard_config, do: add_excludes(base_standard_config(), standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Paladin")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Paladin")
  end
end
