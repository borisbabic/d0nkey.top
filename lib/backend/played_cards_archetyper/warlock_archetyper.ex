# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Warlock", ["Escape the Underfel"]},
    {:"Wallow Warlock",
     [
       "Raptor Herald",
       "Overgrown Horror",
       "Treacherous Tormentor",
       "Wallow, the Wretched",
       "Creature of Madness",
       "Avant-Gardening",
       "Shadowflame Stalker"
     ]},
    {:"Mill Warlock", ["Adaptive Amalgam", "Archdruid of Thorns", "Escape Pod"]},
    {:"Starship Warlock",
     ["Heart of the Legion", "Felfire Thrusters", "The Exodar", "Arkonite Defense Crystal"]},
    {:"Mill Warlock",
     ["Gnomelia, S.A.F.E. Pilot", "Prize Vendor", "Frostbitten Freebooter", "Plated Beetle"]},
    {:"Deckless Warlock",
     [
       "Clearance Promoter",
       "Youthful Brewmaster",
       "Wheel of DEATH!!!",
       "Kil'jaeden",
       "Dirty Rat",
       "Sleepy Resident",
       "The Ceaseless Expanse",
       "Cursed Campaign"
     ]},
    {:"Dorian Warlock",
     [
       "Shaladrassil",
       "Puppetmaster Dorian",
       "Agamaggan",
       "Naralex, Herald of the Flight",
       "Fyrakk the Blazing",
       "Kerrigan, Queen of Blades",
       "Fractured Power"
     ]}
  ]

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warlock")
  end

  def wild(_card_info) do
    nil
  end
end
