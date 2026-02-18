# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{
    :"Libram Paladin" => [
      "Gnomish Aura",
      "Gelbin of Tomorrow",
      "Cardboard Golem",
      "Mekkatorque's Aura",
      "Manifested Timeways"
    ]
  }

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
       "Elise, Badlands Savior",
       "Gunslinger Kurtrus",
       "Theldurin the Lost",
       "Doctor Holli'dae",
       "Deepminer Brann",
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
    {:"Imbue Paladin",
     [
       "Malorne the Waywatcher",
       "Resplendent Dreamweaver",
       "Bitterbloom Knight",
       "Flutterwing Guardian",
       "Dreamwarden",
       "Petal Picker",
       "Warmaster Blackhorn"

       # "Goldpetal Drake"
     ]},
    {:"Aura Paladin",
     [
       "Puppetmaster Dorian",
       # "Gnomelia, S.A.F.E. Pilot",
       "Fyrakk the Blazing",
       "Crafter's Aura",
       "Carnivorous Cubicle",
       "Tankgineer",
       # "Dreamplanner Zephrys",
       "Gelbin of Tomorrow",
       "Mekkatorque's Aura",
       "Manifested Timeways",
       # "Anachronos",
       "Gnomish Aura",
       "Chronological Aura",
       "Cardboard Golem"
       # "Chrono-Lord Deios",
       # "Wisp",
     ]},
    # 5.5
    {:"Libram Paladin",
     [
       "Starlight Wanderer",
       "Past Gnomeregan",
       "Orbital Satellite",
       "Libram of Divinity",
       "Libram of Faith",
       "Libram of Clarity",
       "Interestellar Wayfarer",
       "Astral Vigilant"
     ]},
    {:"Splendiferous Whizbang",
     [
       "Equality",
       "Consecration",
       "Beaming Sidekick"
     ]},
    {:"Lynessa Paladin",
     [
       "Kobold Geomancer",
       "Rock Skipper",
       "Bloodmage Thalnos",
       "Sharp-Eyed Lookout",
       "Sea Shill",
       "Bloodmage Thalnost",
       "Moonstone Mauler",
       "Snatch and Grab",
       "Snatch and Grab",
       "Sharp Shipment",
       "Treasure Hunter Eudora",
       "Concierge",
       "Conniving Conman"
     ]},
    {:"Libram Paladin",
     [
       "Libram of Faith",
       "Libram of Divinity",
       "Interstellar Researcher",
       "Interstellar Starslicer",
       "Yrel, Beacon of Hope",
       "Interstellar Wayfarer",
       "Troubled Mechanic"
     ]},
    {:"Aura Paladin",
     [
       "Elise the Navigator",
       "Toreth the Unbreaking",
       "Tigress Plushy",
       "Urisne Maul",
       "Crusader Aura",
       "Violet Treasuregill",
       "Past Gnomeragan"
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
    {:"Aggro Paladin", ["Vicious Siltherspear", "Platysaur", "Muster for Battle", "Murmy"]},
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

  def standard_excludes(), do: @standard_excludes
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, @standard_excludes)
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Paladin")
  end

  def wild(_card_info) do
    nil
  end
end
