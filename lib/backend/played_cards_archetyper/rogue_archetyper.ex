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
    {:"Protoss Rogue", ["Blink", "Dark Templar", "Void Ray", "High Templar"]},
    {:"Fyrakk Rogue",
     [
       "Creature of Madness",
       "Shaladrassil",
       "Ashamane",
       "Ysera, Emerald Aspect",
       "Opu the Unseen",
       "Customs Enforcer",
       "Observer of Mysteries"
     ]},
    # 5.5
    {:"Incindius Rogue", ["Twisted Webweaver", "Everburning Phoenix", "Ethereal Oracle"]},
    {:"Weapon Rogue",
     ["Sharp Shipment", "The Black Knight", "Naralex, Herald of the Flights", "Eviscerate"]},
    {:"Incindius Rogue",
     [
       "Eat! The! Imp!",
       "Quasar",
       "Incindius",
       "Fae Trickster",
       "Chrono-Lord Deios",
       "Fan of Knives"
     ]},
    {:"Shaffar Rogue",
     [
       "Nexus-Prince Shaffar",
       "Troubled Double",
       "Lucky Comet",
       "Bargain Bin Buccaneer"
     ]},
    {:"Weapon Rogue",
     [
       "Griftah, Trusted Vendor",
       "Swarthy Swordshiner",
       "Flashback",
       "Foxy Fraud",
       "Raiding Party"
     ]},
    # 10.5
    {:"Incindius Rogue", ["Crystal Tusk"]},
    {:"Fyrakk Rogue",
     [
       "Nightmare Lord Xavius",
       "Elise the Navigator",
       "Metal Detector"
     ]},
    {:"Incindius Rogue",
     [
       "Backstab",
       "Cultist Map",
       "Oh, Manager!"
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
    {:"Fyrakk Rogue", ["Demolition Renovator", "Dubious Purchase"]},
    {:"Fyrakk Rogue",
     [
       "Preparation",
       "Shadowstep",
       "Raiding Party",
       "Marin the Manager",
       "Foxy Fraud"
     ]},
    {:"Whizbang Rogue",
     [
       "Sonya Waterdancer",
       "Waterdancer",
       "Hench-Clan Burglar",
       "Deadly Poison",
       "Swashburglar",
       "Dig for Treasure"
     ]},
    {:"Protoss Rogue", ["Photon Cannon", "Artanis"]}
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
