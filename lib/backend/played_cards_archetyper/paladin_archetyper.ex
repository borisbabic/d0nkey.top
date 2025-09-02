# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Paladin", ["Dive the Golakka Depths"]},
    {:"Imbue Paladin",
     [
       "Malorne the Waywatcher",
       "Resplendent Dreamweaver",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Petal Picker",
       "Goldpetal Drake"
     ]},
    {:"Quest Paladin",
     [
       "Murloc Warleader",
       "Braingill",
       "Drink Server",
       "Finja, the Flying Star",
       "Redgill Razorjaw"
     ]},
    {:"Aggro Paladin",
     [
       "Tortollan Storyteller",
       "Maze Guide",
       "Muster for Battle",
       "Fire Fly",
       "Coconut Cannoneer",
       "Busy-Bot",
       "Flash Sale",
       "Trinket Artist",
       "Wisp",
       "Beaming Sidekick",
       "Mother Duck",
       "Platysaur"
     ]},
    {:"Drunk Paladin", ["Sea Shanty", "Lifesaving Aura", "Flickering Lightbot"]},
    {:"Imbue Paladin",
     [
       "Illusory Greenwing",
       "Gnomelia, S.A.F.E. Pilot",
       "Ancient of Yore",
       "Renewing Flames",
       "Ursol"
     ]},
    {:"Aggro Paladin", ["Vicious Siltherspear"]},
    {:"Lynessa OTK Paladin",
     [
       "Overplanner",
       "Kobold Geomancer",
       "Sizzling Cinder",
       "Sharp-Eyed Lookout",
       "Sea Shill",
       "Bloodmage Thalnost",
       "Tidepool Pupil",
       "Moonstone Mauler",
       "Space Pirate",
       "Glacial Shard",
       "Mixologist",
       "Griftah, Trusted Vendor"
     ]},
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
     ]},
    {:"Drunk Paladin", ["Aegis of Light", "Dragonscale Armaments"]},
    {:"Imbue Paladin", ["Redscale Dragontamer"]}
  ]

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Paladin")
  end

  def wild(_card_info) do
    nil
  end
end
