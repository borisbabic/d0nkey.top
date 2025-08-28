# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.HunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Hunter"

      any?(card_info, [
        "Bumbling Belhop",
        "Mythical Runebear",
        "Cop o'Muscle",
        "Death Roll",
        "Furious Fowls",
        "Reserved Spot",
        "Range Gilly"
      ]) ->
        :"Handbuff Hunter"

      any?(card_info, ["Pterrowing Ravager"]) ->
        :"Quest Hunter"

      any?(card_info, [
        "Mother Duck",
        "City Chief Esho",
        "Ball of Spiders",
        "Workhorse",
        "Dreambound Raptor",
        "Ancient Raptor",
        "Trusty Fishing Rod",
        "Painted Canvasaur",
        "Catch of the Day"
      ]) ->
        :"Beast Hunter"

      any?(card_info, [
        "Ragnari Scout",
        "Rockskipper",
        "Glacial Shard",
        "Niri of the Crater",
        "Tidepool Pupil",
        "Astral Vigilant",
        "Mixologist",
        "Elise",
        "Griftah",
        "Alien Encounters",
        "Biopod"
      ]) ->
        :"Discover Hunter"

      any?(card_info, [
        "Shepherd's Crook",
        "R.C. Rampage",
        "Remote Control",
        "Jungle Gym",
        "Patchwork Pals",
        "Painted Canvasaur",
        "Fetch!"
      ]) ->
        :"Beast Hunter"

      any?(card_info, ["Scarab Keychain", "Cower in Fear"]) ->
        :"Beast Hunter"

      any?(card_info, ["Sasquawk"]) ->
        :"Discover Hunter"

      any?(card_info, ["King Mukla", "Racasaur Matriarch", "odd Map", "Platysaur"]) ->
        :"Quest Hunter"

      any?(card_info, ["Pet Parrot"]) ->
        :"Beast Hunter"

      true ->
        :"Other Hunter"
    end
  end

  def wild(_card_info) do
    nil
  end
end
