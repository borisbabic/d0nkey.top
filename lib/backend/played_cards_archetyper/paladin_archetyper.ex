# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Paladin", ["Dive the Golakka Depths"]},
    {:"Whizbang Paladin",
     [
       "Sir Finley, Sea Guide",
       "Solemn Vigil",
       "Potion of Heroism",
       "Truesilver Champion",
       "Reno Jackson",
       "Elise the Enlightened",
       "Crystalsmith Kangor",
       "Primordial Explorer",
       "Aldor Peacekeeper",
       "Emerald Explorer",
       "Protect the Innocent",
       "Brann Bronzebeard",
       "Reno the Relicologist",
       "Elise Starseeker",
       "Dinotamer Brann",
       "Azure Explorer",
       "Ragnaros, Lightlord",
       "The Amazing Reno",
       "Dragonqueen Alexstrasza",
       "Sir Finley of the Sands",
       "Zephrys the Great"
     ]},
    {:"Imbue Paladin",
     [
       "Malorne the Waywatcher",
       "Resplendent Dreamweaver",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Petal Picker",
       "Barkshield Sentinel",
       "Goldpetal Drake"
     ]},
    {:"Aggro Paladin",
     [
       "Tortollan Storyteller",
       "Maze Guide",
       "Muster for Battle",
       "Fire Fly",
       "Coconut Cannoneer",
       "Busy-Bot",
       "Wisp",
       "Beaming Sidekick",
       "Mother Duck",
       "Murmy",
       "Crusader Aura",
       "Platysaur"
     ]},
    {:"Terran Paladin",
     [
       "Salvage the Bunker",
       "Hellbat",
       "Hellion",
       "Dimensional Core",
       "Lift Off",
       "Jim Raynor",
       "SCV",
       "Starport"
     ]},
    # 5.5
    {:"Libram Paladin",
     [
       "Libram of Divinity",
       "Interstellar Researcher",
       "Interstellar Starslicer",
       "Yrel, Beacon of Hope",
       "Interstellar Wayfarer",
       "Libram of Faith"
     ]},
    {:"Lynessa Paladin",
     [
       "Snatch and Grab",
       "Agency Espionage",
       "Petty Theft",
       "Knickknack Shack",
       "Snatch and Grab",
       "Concierge",
       "Conniving Conman"
     ]},
    {:"Drunk Paladin", ["Sea Shanty", "Flickering Lightbot"]},
    {:"Lynessa OTK Paladin",
     [
       "Kobold Geomancer",
       "Rock Skipper",
       "Bloodmage Thalnos",
       "Sharp-Eyed Lookout",
       "Sea Shill",
       "Bloodmage Thalnost",
       "Moonstone Mauler"
     ]},
    {:"Lynessa Paladin",
     [
       "Celestial Aura",
       "Mark of Ursol"
     ]},
    # 10.5
    {:"Drunk Paladin",
     [
       "Libram of Clarity",
       "Vacation Planning",
       "Story of Galvadon",
       "Holy Glowsticks",
       "Divine Brew",
       "Flash of Light",
       "Resistance Aura",
       "Metal Detector"
     ]},
    {:"Aggro Paladin", ["Vicious Siltherspear"]},
    {:"Imbue Paladin",
     [
       "Equality",
       "The Ceaseless Expanse",
       "Fyrakk the Blazing",
       "Consecration",
       "Anachronos",
       "Elise the Navigator",
       "Dreamplanner Zephyrus",
       "Demolition Renovator",
       "Bob the Bartender"
     ]},
    {:"Quest Paladin",
     [
       "Murloc Warleader",
       "Braingill",
       "Drink Server",
       "Finja, the Flying Star",
       "Grunty",
       "Gnawing Greenfin",
       "Steamfin Thief",
       "Hot Spring Glider",
       "Primalfin Challenger",
       "Tyrannogill",
       "Underlight Angling Rod",
       "Murloc Tidecaller",
       "Plucky Paintfin",
       "Coldlight Seer",
       "Murloc Tidehunter",
       "Adaptive Amalgam",
       "Violet Treasuregill",
       "Escape Pod",
       "Prize Vendor",
       "Ready the Fleet"
     ]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Paladin")
  end

  def wild(_card_info) do
    nil
  end
end
