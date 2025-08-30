# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Warlock"

      any?(card_info, [
        "Hologram Operator",
        "Questing Assistant",
        "Sweetened Snowflurry",
        "Spelunker",
        "Tidepool Pupil",
        "Mass Production",
        "The Solarium",
        "Clumsy Steward",
        "Bloodpetal Biome",
        "Sketch Artist",
        "Tunnel Terror"
      ]) ->
        :"Quest Warlock"

      any?(card_info, [
        "Raptor Herald",
        "Overgrown Horror",
        "Treacherous Tormentor",
        "Wallow, the Wretched",
        "Creature of Madness",
        "Avant-Gardening",
        "Shadowflame Stalker"
      ]) ->
        :"Wallow Warlock"

      any?(card_info, [
        "Heart of the Legion",
        "Felfire Thrusters",
        "The Exodar",
        "Arkonite Defense Crystal"
      ]) ->
        :"Starship Warlock"

      any?(card_info, [
        "Gnomelia, S.A.F.E. Pilot",
        "Adaptive Amalgam",
        "Archdruid of Thorns",
        "Prize Vendor",
        "Frostbitten Freebooter"
      ]) ->
        :"Mill Warlock"

      any?(card_info, [
        "Corpsicle",
        "Horizon's Edge",
        "Sizzling Cinder",
        "Dreamplanner Zephyrs",
        "Wisp",
        "Healthstone",
        "Elven Archer",
        "Platysaur",
        "Helfire",
        "Glacial Shard",
        "Cursed Catacombs",
        "The Solarium",
        "Conflagrate",
        "Hellfire"
      ]) ->
        :"Quest Warlock"

      any?(card_info, ["Ysera, Emerald Aspect", "Plated Beetle", "Drain Soul", "Sleepy Resident"]) ->
        :"Mill Warlock"

      any?(card_info, [
        "Ultralisk Cavern",
        "Consume",
        "Table Flip",
        "Ancient of Yore",
        "Eternal Layover",
        "Cursed Campaign",
        "Elise the Navigator",
        "Bob the Bartender",
        "Slithery Slope",
        "Kil'jaeden",
        "The Ceaseless Expanse",
        "Wheel of DEATH!!!"
      ]) ->
        :"Starship Warlock"

      any?(card_info, ["Kerrigan, Queen of Blades"]) ->
        :"Quest Warlock"

      true ->
        :"Other Warlock"
    end
  end

  def wild(_card_info) do
    nil
  end
end
