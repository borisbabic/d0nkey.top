# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.HunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Hunter": ["The Food Chain"],
    "Tick Tock Hunter": ["Battle at the End Time"],
    # auto gen
    "N'Zoth Mech Hunter": [
      "Bombardment",
      "Flamespitter",
      "Mimiron",
      "N'Zoth, Dream's End",
      "Overdrive",
      "Tank Regiment",
      "Tinker",
      "Vaultkeeper"
    ],
    "Imbue Hunter": ["Magma Hound"],
    "Face Hunter": ["Slumbering Sprite"],
    "Companion Hunter": ["Call of the Wild", "Roam Free", "Spiritspeaker", "Talya Earthstrider"],
    "Imbue Hunter": ["Bitterbloom Knight", "Flutterwing Guardian"],
    "N'Zoth Hunter": ["Loot Hoarder"],
    # "Dragon Hunter": ["Carrier Whelp", "Shadowed Informant"],
    "N'Zoth Hunter": ["Confront the Tol'vir", "Gemstone Hoarder", "Twilight Egg", "Untimely Death"],
    "N'Zoth Mech Hunter": ["Unstable Prototype"],
    "Face Hunter": ["Reinforcement Rallier"],
    "N'Zoth Hunter": ["Crystalline Golem"],
    "N'Zoth Mech Hunter": ["Mechacycle", "Sizzling Cinder"],
    "N'Zoth Hunter": ["Amphibian's Spirit", "Stranglevine", "The Egg of Khelos"],
    "N'Zoth Mech Hunter": ["Guard Dog", "Ranger Captain Alleria", "Raptor-Nest Nurse"],
    "Face Hunter": ["Arcane Tripwire", "Smuggled Shovel", "Sylvanas's Triumph"],
    "N'Zoth Mech Hunter": ["Underbelly Network"]
  ]
  @wild_config [
    "Boar Hunter": ["Elwynn Boar"],
    "Secret Hunter": ["Eversong Portal"],
    "Amalgam Hunter": ["Adaptive Amalgam"],
    "XL Highlander Hunter": ["Mojomaster Zihi"],
    "Highlander Hunter": ["Trusty Fishing Rod"],
    "Beast Hunter": ["Painted Canvasaur"],
    "XL Highlander Hunter": ["Astalor Bloodsworn", "Boompistol Bully", "Irondeep Trogg", "Misdirection"],
    "STD No Hand Hunter": ["Arrow Retriever", "Sizzling Cinder"],
    "STD Companion Hunter": ["Critter Caretaker"],
    "XL HL Leoroxx Hunter": ["Hydralodon"],
    "XL Hunter": ["Sing-Along Buddy"],
    "XL Highlander Hunter": ["Kerrigan, Queen of Blades"],
    "Secret Hunter": ["Starstrung Bow"],
    "LC Quest Hunter": ["The Food Chain"],
    "Leoroxx Hunter": ["Ten Gallon Hat"],
    "XL HL Leoroxx Hunter": ["Beastmaster Leoroxx", "Elise the Navigator"],
    "XL Highlander Hunter": ["Far Watch Post", "Spawning Pool"],
    "STD No Hand Hunter": ["Quel'dorei Fletcher"],
    "Boar Hunter": ["Bola Shot"],
    "XL Hunter": ["Bitterbloom Knight", "Flutterwing Guardian", "Umbraclaw"],
    "XL HL Leoroxx Hunter": ["Tundra Rhino"],
    "Dragon Hunter": ["Petal Peddler"],
    "Highlander Hunter": ["Dreamplanner Zephrys"],
    "XL Highlander Hunter": ["Beaststalker Tavish", "Observer of Myths", "Sneaky Snakes", "ZOMBEEEES!!!"],
    "Secret Hunter": ["Wandering Monster"],
    "Boar Hunter": ["Selective Breeder"],
    "XL HL Leoroxx Hunter": ["Hope of Quel'Thalas"],
    "Beast Hunter": ["Pet Collector"],
    "Questline Hunter": ["Defend the Dwarven District", "Platysaur"],
    "XL Secret Hunter": ["Trueaim Crescent"],
    "XL HL Leoroxx Hunter": ["Miracle Salesman", "Razorscale", "Troubled Mechanic", "Wild Spirits"],
    "Highlander Hunter": ["Theldurin the Lost"],
    "STD Companion Hunter": ["Migrating Elekk", "Talya Earthstrider"],
    "Boar Hunter": ["Rangari Scout"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Hunter")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Hunter")
  end
end
