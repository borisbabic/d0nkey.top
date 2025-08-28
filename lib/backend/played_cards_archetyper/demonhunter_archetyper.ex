# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest DH"

      any?(card_info, [
        "Arkonite Defense Crystal",
        "The Exodar",
        "Dimensional Core",
        "Felfused Battery",
        "Shattershard Turret"
      ]) ->
        :"Armor DH"

      any?(card_info, [
        "Cliff Dive",
        "Colifero the Artist",
        "Illidari Inquisitor",
        "Magtheridon, Unreleased"
      ]) ->
        :"Cliff Dive DH"

      any?(card_info, [
        "Sock Puppet Slitherspear",
        "Brain Masseuse",
        "King Mukla",
        "Acupuncture",
        "Battlefiend",
        "Spirit of the Team",
        "Tortollan Storyteller",
        "Customs Enforcer",
        "sizzling Cinder",
        "Customs Enforcer"
      ]) ->
        :"Aggro Demon Hunter"

      any?(card_info, [
        "Dissolving Ooze",
        "Carnivorous Cube",
        "Mixologist",
        "Ferocious Felbat",
        "Nightmare Lord Xavius",
        "The Ceaseless Expanse",
        "Fumigate",
        "Return Policy",
        "Inflitrate"
      ]) ->
        :"Armor DH"

      any?(card_info, ["Blob of Tar", "Ravenous Felhunter", "Wyvern's Slumber"]) ->
        :"Cliff Dive DH"

      any?(card_info, [
        "Bloodmage Thalnos",
        "Dreamplanner Zephyrus",
        "Observer of Mysteries",
        "Royal Librarian",
        "Rockspitter",
        "Chaos Strike"
      ]) ->
        :"Aggro Demon Hunter"

      any?(card_info, ["Illidari Studies"]) ->
        :"Cliff Dive DH"

      any?(card_info, ["Tuskpiercer"]) ->
        :"Armor DH"

      any?(card_info, ["Insect Claw", "Infestation", "Dangerous Cliffside"]) ->
        :"Aggro Demon Hunter"

      true ->
        :"Other DH"
    end
  end

  def wild(_card_info) do
    nil
  end
end
