# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.Hearthstone.RuneCost

  defp any_non_blood?(card_info) do
    any_with_rune?(card_info, [:frost, :unholy])
  end

  defp any_with_rune?(card_info, runes) when is_list(runes) do
    Enum.any?(card_info.full_cards, fn
      %{rune_cost: %RuneCost{} = rc} -> Enum.any?(runes, &RuneCost.has_rune?(rc, &1))
      _ -> false
    end)
  end

  defp any_with_rune?(card_info, rune), do: any_with_rune?(card_info, [rune])

  def standard_excludes do
    %{}
  end

  defp base_standard_config,
    do: [
      "Quest DK": ["Reanimate the Terror"],
      "Blood DK": ["Grafted Knight", "Bloodfiend", "Alexandros Mograine", "G'huun"],
      "Vyranoth DK": ["Sheltered Survivor", "Vyranoth"],
      "Aggro DK": ["Shadows of Yesterday", "Battlefield Necromancer"],
      "Handbuff DK": ["Gruesome Nightmare"],
      # 5.5
      "Blood DK": {["Sanguine Infestation", "Hideous Husk", "Concealing Confection"], &any_non_blood?/1},
      "Vyranoth DK": ["Titanic Thrasher"],
      "Handbuff DK": ["Blood Tap", "Nerubian Swarmguard"],
      "Blood DK": {["Death Metal Knight"], &any_non_blood?/1},
      "Blood DK": {["Elise the Navigator"], &any_non_blood?/1},
      # 10.5
      "Other DK": ["Swamp Leech", "Worgen Infiltrator"],
      "Other DK": ["Bloodmage Thalnos"],
      "Rainbow DK": ["Uldir Quarantine"],
      "Harold DK": ["Critter Caretaker"],
      "Aggro DK": ["Acolyte of Death", "Warden Maiev"],
      "Egg DK": ["Sizzling Cinder"],
      "Harold DK": ["Memoriam Manifest", "Naralex, Herald of the Flights", "Sanguine Infestation"],
      "Blood DK": ["Dirty Rat"],
      "Aggro DK": ["Tower of Ghouls"],
      # "Unholy N'Zoth DK": ["Corpse Cannon", "Grave Strength", "Talanji's Last Stand"],
      "Blood DK": ["Body Bagger"],
      "Vyranoth DK": ["Gnome Muncher"],
      "Egg DK": ["The Egg of Khelos"],
      "N'Zoth DK": ["Loot Hoarder", "N'Zoth, Dream's End"],
      "Blood DK": ["Whelp of the Infinite"],
      "Harold DK": ["Emergency Surgery"],
      "Blood DK": [
        "Experimental Animation",
        "Hematurge",
        "Infested Breath",
        "Obsessive Technician",
        "Scion of Insight",
        "Ultraxion",
        "Wild Pyromancer"
      ],
      "Vyranoth DK": ["Elise the Navigator"],
      "Handbuff DK": ["Chromatic Broodmother", "Fleshshape", "Glacial Shard", "Holy Eggbearer", "Prize Vendor"],
      "N'Zoth DK": ["Blackwing Experiment"],
      "Aggro DK": ["Murmy"],
      "N'Zoth DK": ["Remnant of Rage"],
      "Blood DK": ["Chillfallen Baron", "Nightmare Lord Xavius", "Staff of the Endbringer"],
      "N'Zoth DK": ["Reluctant Wrangler"],
      "Handbuff DK": ["Unstable Prototype"]
    ]

  @wild_config [
    "Aggro DK": [
      "Creature of Madness",
      "Fire Fly",
      "Malignant Horror",
      "Menagerie Jug",
      "Menagerie Mug",
      "Monstrous Mosquito",
      "Nozdormu the Eternal",
      "Observer of Mysteries",
      "Rite of Atrocity"
    ],
    "Highlander DK": ["Bone Breaker"],
    "XL Plague DK": ["Pen Flinger"],
    "Highlander DK": ["Quartzite Crusher", "Rainbow Seamstress"],
    "Splendiferous Whizbang": ["Primordial Glyph", "Thrive in the Shadows", "Wild Growth"],
    "Plague DK": ["Harth Stonebrew"],
    "XL HL Plague DK": ["Instrument Tech"],
    "XL Plague DK": ["Astrobiologist"],
    "XL LC Quest Death Knight": ["Suffocate"],
    "Highlander DK": ["Foamrender", "High Cultist Herenn", "Rivendare, Warrider", "The 8 Hands From Beyond"],
    "Plague DK": ["Chained Guardian", "Death Growl"],
    "Highlander DK": ["Reska, the Pit Boss"],
    "XL HL Plague DK": ["Ashen Elemental", "Magatha, Bane of Music"],
    "XL Blood DK": ["Soulstealer"],
    "Highlander DK": ["Blood Boil", "Defrost", "Mixologist"],
    "XL Plague DK": ["Overplanner"],
    "XL Blood DK": ["Vampiric Blood"],
    "XL HL Plague DK": ["Far Watch Post"],
    "Highlander DK": ["Timeline Accelerator", "Zephrys the Great"],
    "Plague DK": ["Augmented Elekk"],
    "Highlander DK": ["Reno, Lone Ranger"],
    "XL LC Quest Death Knight": ["Reanimate the Terror"],
    "Buttons DK": ["Pile of Bones"],
    "Aggro Plague DK": ["Battlefield Necromancer", "Murmy"],
    "Highlander DK": [
      "Blademaster Okani",
      "Buttons",
      "Construct Quarter",
      "Cult Neophyte",
      "Gorgonzormu",
      "Loatheb",
      "Smothering Starfish",
      "Spawning Pool",
      "Theotar, the Mad Duke"
    ],
    "XL Plague DK": ["Soul Searching"],
    "XL Harold Death Knight": ["Airlock Breach", "Carrier Whelp"],
    "Even Death Knight": ["Horizon's Edge"],
    "Plague DK": ["Distressed Kvaldir", "Staff of the Primus"],
    "Highlander DK": ["Dirty Rat", "Helya", "Runes of Darkness"],
    "STD Harold DK": ["Morbid Swarm"],
    "XL Blood DK": [
      "Body Bagger",
      "Envoy of the End",
      "Experimental Animation",
      "Hematurge",
      "Hideous Husk",
      "Infested Breath",
      "Obsessive Technician",
      "Prince Renathal",
      "Sanguine Infestation"
    ]
  ]

  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(base_standard_config(), standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other DK")
  end
end
