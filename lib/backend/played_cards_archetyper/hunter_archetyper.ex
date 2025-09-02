# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.HunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Hunter", ["The Food Chain"]},
    {:"Handbuff Hunter",
     [
       "Bumbling Belhop",
       "Mythical Runebear",
       "Cop o'Muscle",
       "Death Roll",
       "Furious Fowls",
       "Reserved Spot",
       "Range Gilly"
     ]},
    {:"Quest Hunter", ["Pterrowing Ravager"]},
    {:"Beast Hunter",
     [
       "Mother Duck",
       "City Chief Esho",
       "Ball of Spiders",
       "Workhorse",
       "Dreambound Raptor",
       "Ancient Raptor",
       "Trusty Fishing Rod",
       "Painted Canvasaur",
       "Catch of the Day"
     ]},
    {:"Discover Hunter",
     [
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
     ]},
    {:"Beast Hunter",
     [
       "Shepherd's Crook",
       "R.C. Rampage",
       "Remote Control",
       "Jungle Gym",
       "Patchwork Pals",
       "Painted Canvasaur",
       "Fetch!"
     ]},
    {:"Beast Hunter", ["Scarab Keychain", "Cower in Fear"]},
    {:"Discover Hunter", ["Sasquawk"]},
    {:"Quest Hunter", ["King Mukla", "Racasaur Matriarch", "odd Map", "Platysaur"]},
    {:"Beast Hunter", ["Pet Parrot"]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Hunter")
  end

  def wild(_card_info) do
    nil
  end
end
