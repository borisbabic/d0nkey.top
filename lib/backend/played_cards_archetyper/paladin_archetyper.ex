# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PaladinArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Paladin"

      any?(card_info, [
        "Malorne the Waywatcher",
        "Resplendent Dreamweaver",
        "Bitterbloom Knight",
        "Flutterwing Guardian",
        "Petal Picker",
        "Goldpetal Drake"
      ]) ->
        :"Imbue Paladin"

      any?(card_info, [
        "Murloc Warleader",
        "Braingill",
        "Drink Server",
        "Finja, the Flying Star",
        "Redgill Razorjaw"
      ]) ->
        :"Quest Paladin"

      any?(card_info, [
        "Tortollan Storyteller",
        "Maze Guide",
        "Muster for Battle",
        "Fire Fly",
        "Coconut Cannoneer",
        "Busy-Bot",
        "Flash Sale",
        "Trinket Artist",
        "Wisp",
        "Beaming Sidekick",
        "Mother Duck",
        "Platysaur"
      ]) ->
        :"Aggro Paladin"

      any?(card_info, ["Sea Shanty", "Lifesaving Aura", "Flickering Lightbot"]) ->
        :"Drunk Paladin"

      any?(card_info, [
        "Illusory Greenwing",
        "Gnomelia, S.A.F.E. Pilot",
        "Ancient of Yore",
        "Renewing Flames",
        "Ursol"
      ]) ->
        :"Imbue Paladin"

      any?(card_info, ["Vicious Siltherspear"]) ->
        :"Aggro Paladin"

      any?(card_info, [
        "Overplanner",
        "Kobold Geomancer",
        "Sizzling Cinder",
        "Sharp-Eyed Lookout",
        "Sea Shill",
        "Bloodmage Thalnost",
        "Tidepool Pupil",
        "Moonstone Mauler",
        "Space Pirate",
        "Glacial Shard",
        "Mixologist",
        "Griftah, Trusted Vendor"
      ]) ->
        :"Lynessa OTK Paladin"

      any?(card_info, [
        "Libram of Clarity",
        "Vacation Planning",
        "Story of Galvadon",
        "Holy Glowsticks",
        "Divine Brew",
        "Flash of Light",
        "Resistance Aura",
        "Metal Detector"
      ]) ->
        :"Drunk PAladin"

      any?(card_info, [
        "Equality",
        "The Ceaseless Expanse",
        "Fyrakk the Blazing",
        "Consecration",
        "Anachronos",
        "Elise the Navigator",
        "Dreamplanner Zephyrus",
        "Demolition Renovator",
        "Bob the Bartender"
      ]) ->
        :"Imbue Paladin"

      any?(card_info, [
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
        "Violet Treasuregill",
        "Escape Pod",
        "Prize Vendor",
        "Ready the Fleet"
      ]) ->
        :"Quest Paladin"

      any?(card_info, ["Aegis of Light", "Dragonscale Armaments"]) ->
        :"Drunk Paladin"

      any?(card_info, ["Redscale Dragontamer"]) ->
        :"Imbue Paladin"

      true ->
        :"Other Paladin"
    end
  end

  def wild(_card_info) do
    nil
  end
end
