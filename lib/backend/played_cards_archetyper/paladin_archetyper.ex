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
       "Dreamwarden",
       "Petal Picker",
       "Goldpetal Drake"
     ]},
    {:"Aggro Paladin",
     [
       "Tortollan Storyteller",
       "Maze Guide",
       "Flash Sale",
       "Beaming Sidekick",
       "Fire Fly",
       "Coconut Cannoneer",
       "Busy-Bot",
       "Mother Duck"
     ]},
    {:"Aura Paladin",
     [
       "Gnomelia, S.A.F.E. Pilot",
       "Fyrakk the Blazing",
       "Creature of Madness",
       "Carnivorous Cubicle",
       "Tankgineer",
       "Spikeridged Steed",
       "Whelp of the Infinite",
       "Ido of the Threshfleet",
       "Dreamplanner Zephrys",
       "Gelbin of Tomorrow",
       "Mekkatorque's Aura",
       "Manifested Timeways",
       "Gnomish Aura",
       "Chronological Aura",
       "Cardboard Golem",
       "Chrono-Lord Deios",
       "Wisp",
       "Oh Manager!"
     ]},
    # 5.5
    {:"Lynessa Paladin",
     [
       "Kobold Geomancer",
       "Rock Skipper",
       "Bloodmage Thalnos",
       "Sharp-Eyed Lookout",
       "Sea Shill",
       "Grillmaster",
       "Bloodmage Thalnost",
       "Doomsayer",
       "Rockskipper",
       "Moonstone Mauler",
       "Snatch and Grab",
       "Petty Theft",
       "Snatch and Grab",
       "Sharp Shipment",
       "Treasure Hunter Eudora",
       "Concierge",
       "Conniving Conman"
     ]},
    {:"Libram Paladin",
     [
       "Orbital Satellite",
       "Libram of Faith",
       "Libram of Divinity",
       "Interstellar Researcher",
       "Interstellar Starslicer",
       "Yrel, Beacon of Hope",
       "Interstellar Wayfarer",
       "Troubled Mechanic"
     ]},
    {:"Drunk Paladin",
     [
       "Sea Shanty",
       "Flickering Lightbot",
       "Libram of Clarity",
       "Lifesaving Aura",
       "Holy Glowsticks",
       "Dragonscale Armaments",
       "Aegis of Light",
       "Story of Galvadon"
     ]},
    {:"Aura Paladin",
     [
       "Resistance Aura",
       "Hardlight Protector",
       "Elise the Navigator",
       "Toreth the Unbreaking",
       "Tigress Plushy",
       "Urisne Maul",
       "Metal Detector",
       "Crusader Aura",
       "Mixologist",
       "Past Gnomeragan"
     ]},
    # 10.5
    # {:"Drunk Paladin",
    #  [
    #    "Libram of Clarity",
    #    "Vacation Planning",
    #    "Story of Galvadon",
    #    "Holy Glowsticks",
    #    "Divine Brew",
    #    "Flash of Light",
    #    "Resistance Aura",
    #    "Metal Detector"
    #  ]},
    {:"Aggro Paladin",
     ["Vicious Siltherspear", "Platysaur", "Muster for Battle", "Violet Treasuregill", "Murmy"]},
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
       "Escape Pod",
       "Prize Vendor",
       "Ready the Fleet"
     ]},
    {:"Aura Paladin",
     [
       "Puppetmaster Dorian"
     ]},
    # {:"Terran Paladin",
    #  [
    #    "Salvage the Bunker",
    #    "Hellbat",
    #    "Holy Eggbearer",
    #    "Dimensional Core",
    #    "The Egg of Khelos",
    #    "Carnivorous Cubicle",
    #    "Lift Off",
    #    "Jim Raynor",
    #    "SCV",
    #    "Arkonite Defense Crystal",
    #    "Ghost",
    #    "Ultra-Capacitor",
    #    "Starport"
    #  ]},
    {:"Whizbang Paladin",
     [
       "Hand of A'dal",
       "Bronze Explorer",
       "Flash of Light",
       "Righteous Protector",
       "Tirion Fordring"
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
