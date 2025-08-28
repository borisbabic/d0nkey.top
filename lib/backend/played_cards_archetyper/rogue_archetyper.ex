# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Rogue"

      any?(card_info, [
        "Scrounging Shipwright",
        "Barrel Roll",
        "Starship Schematic",
        "The Gravitational Displacer",
        "Dimensional Core",
        "Arkonite Defense Crystal",
        "The Exodar"
      ]) ->
        :"Starship Rogue"

      any?(card_info, [
        "Photon Cannon",
        "Blink",
        "Dark Templar",
        "Void Ray",
        "High Templar",
        "Artanis"
      ]) ->
        :"Protoss Rogue"

      any?(card_info, [
        "Everburning Phoenix",
        "Playhouse Giant",
        "Eat! The! Imp!",
        "Twisted Webweaver",
        "Wisp",
        "Bloodmage Thalnos",
        "Platysaur"
      ]) ->
        :"Cycle Rogue"

      any?(card_info, [
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
      ]) ->
        :"Fyrakk Rogue"

      any?(card_info, ["Incindius", "Moonstone Mauler", "Fan of Knives", "Ethereal Oracle"]) ->
        :"Cycle Rogue"

      any?(card_info, ["Sonya Waterdancer"]) ->
        :"Protoss Rogue"

      any?(card_info, ["Mixologist"]) ->
        :"Starship Rogue"

      any?(card_info, ["Sandbox Scoundrel", "Elise the Navigator"]) ->
        :"Fyrakk Rogue"

      any?(card_info, [
        "Underbrush Tracker",
        "Floppy Hydra",
        "Knockback",
        "Adaptive Amalgam",
        "Illusory Greenwing",
        "Interrogation",
        "Merchant of Legend"
      ]) ->
        :"Quest Rogue"

      any?(card_info, ["Demolition Renovator", "Dubious Purchase", "Griftah, Trusted Vendor"]) ->
        :"Fyrakk Rogue"

      any?(card_info, [
        "Preparation",
        "Shadowstep",
        "Raiding Party",
        "Customs Enforcer",
        "Marin the Manager",
        "Foxy Fraud"
      ]) ->
        :"Fyrakk Rogue"

      true ->
        :"Other Rogue"
    end
  end

  def wild(_card_info) do
    nil
  end
end
