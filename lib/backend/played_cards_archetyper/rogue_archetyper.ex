# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Rogue", ["Lie in Wait"]},
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
    {:"Protoss Rogue",
     ["Photon Cannon", "Blink", "Dark Templar", "Void Ray", "High Templar", "Artanis"]},
    {:"Cycle Rogue",
     [
       "Everburning Phoenix",
       "Playhouse Giant",
       "Eat! The! Imp!",
       "Twisted Webweaver",
       "Wisp",
       "Bloodmage Thalnos",
       "Platysaur"
     ]},
    {:"Fyrakk Rogue",
     [
       "Naralex, Herald of the Flight",
       "Creature of Madness",
       "Shaladrassil",
       "Ashamane",
       "Fyrakk the Blazing",
       "Ysera, Emerald Aspect",
       "Gnomelia, S.A.F.E. Pilot",
       "Nightmare Fuel",
       "Opu the Unseen",
       "Oh, Manager!",
       "SPacerock Collector",
       "Metal Detector",
       "Nightmare Lord Xavius"
     ]},
    {:"Cycle Rogue", ["Incindius", "Moonstone Mauler", "Fan of Knives", "Ethereal Oracle"]},
    {:"Protoss Rogue", ["Sonya Waterdancer"]},
    {:"Starship Rogue", ["Mixologist"]},
    {:"Fyrakk Rogue", ["Sandbox Scoundrel", "Elise the Navigator"]},
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
    {:"Fyrakk Rogue", ["Demolition Renovator", "Dubious Purchase", "Griftah, Trusted Vendor"]},
    {:"Fyrakk Rogue",
     [
       "Preparation",
       "Shadowstep",
       "Raiding Party",
       "Customs Enforcer",
       "Marin the Manager",
       "Foxy Fraud"
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
