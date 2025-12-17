# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Rogue", ["Lie in Wait"]},
    {:"Whizbang Rogue",
     [
       "Book of the Dead",
       "Vampiric Fangs",
       "Bubba",
       "Wax Rager",
       "Pirate Admiral Hooktusk",
       "Annoy-o Horn",
       "Pure Cold",
       "Grimmer Patron",
       "Necrotic Poison",
       "Filletfighter",
       "Patches the Pirate",
       "Hyperblaster",
       "Kaja'mite Creation",
       "Breakdance",
       "Crusty the Crustacean",
       "Beastly Beauty",
       "The Exorcisor",
       "Looming Presence",
       "Quick Pick",
       "Mutating Injection",
       "Hilt of Quel'Delar",
       "Dr. Boom's Boombox",
       "Gnomish Army Knife",
       "Canopic Jars",
       "Puzzle Box",
       "Banana Split",
       "Blade of Quel'Delar",
       "Clockwork Assistant",
       "Spyglass",
       "Staff of Scales"
     ]},
    {:"Protoss Rogue",
     [
       "Blink",
       "Dark Templar",
       "Void Ray",
       "High Templar",
       "Artanis",
       "Warp Gate",
       "Photon Cannon",
       "Blink",
       "Chrono Boost"
     ]},
    {:"Starship Rogue",
     [
       "Scrounging Shipwright",
       "Barrel Roll",
       "Starship Schematic",
       "The Gravitational Displacer",
       "Dimensional Core",
       "Arkonite Defense Crystal",
       "The Exodar"
     ]},
    {:"Cycle Rogue",
     [
       "Everything Must Go!",
       "Eat! The! Imp!",
       "Playhouse Giant",
       "Twisted Webweaver",
       "Everburning Phoenix",
       "Wisp",
       "Incindius",
       "Moonstone Mauler"
     ]},
    # 5.5
    {:"Maestra Rogue",
     [
       "Assassinate",
       "Sea Shill",
       "Tess Greymane",
       "Snatch and Grab",
       "Dread Corsair",
       "Maestra, Mask Merchant",
       "Prize Vendor",
       "Mimicry"
     ]},
    {:"Fyrakk Rogue",
     [
       "Ashamane",
       "Time Adm'ral Hooktail",
       "Gnomelia, S.A.F.E. Pilot",
       "Dethrone",
       "Naralex, Herald of the Flights",
       "Fyrakk the Blazing",
       "Ysera, Emerald Aspect"
     ]},
    {:"Shaffar Rogue",
     [
       "Nexus-Prince Shaffar",
       "Troubled Double",
       "Bargain Bin Buccaneer"
     ]},
    {:"Quasar Rogue",
     [
       "Fae Trickster",
       "Quasar",
       "Knickknack Shack",
       "Ethereal Oracle"
     ]},
    # 10.5
    {:"Fyrakk Rogue",
     [
       "Customs Enforcer",
       "Metal Detector",
       "Shaladrassil",
       "Observer of Mysteries",
       "Nightmare Lord Xavius",
       "Opu the Unseen",
       "Creature of Madness",
       "Elise the Navigator"
       # "Fyrakk the Blazing",
       # "Naralex, Herald of the Flights"
     ]},
    {:"Starship Rogue", ["Mixologist"]},
    {:"Quest Rogue",
     [
       "Underbrush Tracker",
       "Floppy Hydra",
       "Knockback",
       "Adaptive Amalgam",
       "Illusory Greenwing",
       "Interrogation",
       "Merchant of Legend"
     ]},
    {:"Whizbang Rogue",
     [
       "Sonya Waterdancer",
       "Waterdancer",
       "Hench-Clan Burglar",
       "Deadly Poison",
       "Swashburglar",
       "Dig for Treasure"
     ]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Rogue")
  end

  def wild(_card_info) do
    nil
  end
end
