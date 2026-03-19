# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{}
  @standard_config [
    {:"Tick Tock Warlock", ["Battle at the End Time"]},
    {:Rafaamlock,
     [
       "Tiny Rafaam",
       "Green Rafaam",
       "Murloc Rafaam",
       "Explorer Rafaam",
       "Warchief Rafaam",
       "Calamitous Rafaam",
       "Mindflayer R'faam",
       "Giant Rafaam",
       "Archmage Rafaam",
       "Timethief Rafaam"
     ]},
    {:"Harold DK",
     [
       "Envoy of the End",
       "Ultraxion",
       "Shrine of Twilight",
       "Shadowsworn Disciple",
       "Deathwing, Worldbreaker"
     ]},
    {:"Wallow Warlock",
     [
       "Overgrown Horror",
       "Avant-Gardening",
       "Treacherous Tormentor",
       "Creature of Madness",
       "Shadowflame Stalker",
       "Wallow, the Wretched"
     ]},
    {:"Harold DK",
     [
       "Spirit Bomb",
       "The Egg of Khelos",
       "Holy Eggbearer",
       "Cursed Chains",
       "Eldritch Tentacles",
       "Archdruid of Thorns",
       "Hellfire",
       "Drain Soul",
       "Conflagrate",
       "Abusive Sergeant",
       "Eternal Toil",
       "Cursed Catacombs",
       "Mortal Coil"
     ]},
    {:"Aggro Warlock",
     [
       "Flame Imp",
       "Acolyte of Infinity",
       "Sizzling Cinder",
       "Entropic Continuity",
       "Darkscale Broodmother",
       "Ruinous Velocidrake",
       "Prescient Slitherdrake",
       "Ocular Occultist",
       "Fatebreaker",
       "Twilight Timehopper",
       "Tachyon Barrage",
       "Petal Peddler",
       "Twilight Egg",
       "Carrier Whelp"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: @standard_excludes
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Warlock")
  end

  def wild(_card_info) do
    nil
  end
end
