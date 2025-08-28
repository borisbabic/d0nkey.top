# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PriestArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Priest"

      any?(card_info, [
        "Void Ray",
        "Mothership",
        "Photon Cannon",
        "Sentry",
        "Hallucination",
        "Chrono Boost",
        "Artanis"
      ]) ->
        :"Protoss Priest"

      any?(card_info, [
        "Nexus-Prince Shaffar",
        "Plated Bettle",
        "Tar Slime",
        "Wilted Shadow",
        "Carless Crafter",
        "Annoy-o-Tron",
        "Critter Caretaker",
        "Rest in Peace"
      ]) ->
        :"Wilted Priest"

      any?(card_info, [
        "Mo'arg Forgefiend",
        "Overplanner",
        "Living Flame",
        "Sharp-Eyed Lookout",
        "Mixologist",
        "Twilight Medium",
        "Aviana, Elune's Chosen",
        "Story of Imara"
      ]) ->
        :"Aviana Priest"

      any?(card_info, [
        "Sasquawk",
        "Enderbringer Umbra",
        "Trusty Fishy Rod",
        "Orbital Halo",
        "Catch of the Day"
      ]) ->
        :"Protoss Priest"

      any?(card_info, ["Lightbomb", "Sleepy Resident"]) ->
        :"Wilted Priest"

      any?(card_info, ["Power Word: Shield", "Resuscitate"]) ->
        :"Wilted Priest"

      any?(card_info, ["Trusty Fishing Rod", "Nightmare Xavius"]) ->
        :"Protoss Priest"

      any?(card_info, ["Thrive in the Shadows", "Birdwatching", "Narain Soothfancy"]) ->
        :"Wilted Priest"

      true ->
        :"Other Priest"
    end
  end

  def wild(_card_info) do
    nil
  end
end
