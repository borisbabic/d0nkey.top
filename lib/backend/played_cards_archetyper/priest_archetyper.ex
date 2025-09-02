# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PriestArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Priest", ["Reach Equilibrium"]},
    {[
       "Void Ray",
       "Mothership",
       "Photon Cannon",
       "Sentry",
       "Hallucination",
       "Chrono Boost",
       "Artanis"
     ], :"Protoss Priest"},
    {[
       "Nexus-Prince Shaffar",
       "Plated Bettle",
       "Tar Slime",
       "Wilted Shadow",
       "Carless Crafter",
       "Annoy-o-Tron",
       "Critter Caretaker",
       "Rest in Peace"
     ], :"Wilted Priest"},
    {[
       "Mo'arg Forgefiend",
       "Overplanner",
       "Living Flame",
       "Sharp-Eyed Lookout",
       "Mixologist",
       "Twilight Medium",
       "Aviana, Elune's Chosen",
       "Story of Imara"
     ], :"Aviana Priest"},
    {["Sasquawk", "Enderbringer Umbra", "Trusty Fishy Rod", "Orbital Halo", "Catch of the Day"],
     :"Protoss Priest"},
    {["Lightbomb", "Sleepy Resident"], :"Wilted Priest"},
    {["Power Word: Shield", "Resuscitate"], :"Wilted Priest"},
    {["Trusty Fishing Rod", "Nightmare Xavius"], :"Protoss Priest"},
    {["Thrive in the Shadows", "Birdwatching", "Narain Soothfancy"], :"Wilted Priest"}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Priest")
  end

  def wild(_card_info) do
    nil
  end
end
