# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DemonHunterArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Paladin", ["Dive the Golakka Depths"]},
    {:"Armor DH",
     [
       "Arkonite Defense Crystal",
       "The Exodar",
       "Dimensional Core",
       "Felfused Battery",
       "Shattershard Turret"
     ]},
    {:"Cliff Dive DH",
     ["Cliff Dive", "Colifero the Artist", "Illidari Inquisitor", "Magtheridon, Unreleased"]},
    {:"Aggro Demon Hunter",
     [
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
     ]},
    {:"Armor DH",
     [
       "Dissolving Ooze",
       "Carnivorous Cube",
       "Mixologist",
       "Ferocious Felbat",
       "Nightmare Lord Xavius",
       "The Ceaseless Expanse",
       "Fumigate",
       "Return Policy",
       "Inflitrate"
     ]},
    {:"Cliff Dive DH", ["Blob of Tar", "Ravenous Felhunter", "Wyvern's Slumber"]},
    {:"Aggro Demon Hunter",
     [
       "Bloodmage Thalnos",
       "Dreamplanner Zephyrus",
       "Observer of Mysteries",
       "Royal Librarian",
       "Rockspitter",
       "Chaos Strike"
     ]},
    {:"Cliff Dive DH", ["Illidari Studies"]},
    {:"Armor DH", ["Tuskpiercer"]},
    {:"Aggro Demon Hunter", ["Insect Claw", "Infestation", "Dangerous Cliffside"]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DH")
  end

  def wild(_card_info) do
    nil
  end
end
