# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PriestArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Egg Priest",
     [
       "Abusive Sergeant",
       "Holy Eggbearer",
       "The Egg of Khelos",
       "Crazed Alchemist",
       "Dissolving Ooze"
     ]},
    {:"Control Priest",
     [
       "Devouring Plague",
       "Fae Trickster",
       "Holy Nova",
       "Eternal Firebolt",
       "Cleansing Cleric",
       "The Black Blood",
       "Dirty Rat",
       "Atiesh the Greatstaff",
       "Karazhan the Sanctum",
       "Medivh the Hallowed",
       "Flash Heal",
       "Shadow Word: Ruin",
       "Ruby Sanctum",
       "Tranquil Treant",
       "Reach Equilibrium",
       "Intertwined Fate",
       "Voodoo Totem",
       "Story of Amara",
       "Nightmare Lord Xavius",
       "For All Time",
       "Medivh's Triumph",
       "Sands of Time",
       "Kaldorei Priestess",
       "Ancient of Yore",
       "Gravedawn Sunbloom",
       "Mend",
       "Lunarwing Messenger",
       "Greater Healing Potion",
       "Cease to Exist",
       "Power Word: Shield",
       "Ysera, Emerald Aspect",
       "Purifying Breath"
     ]}
  ]
  @wild_config []

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Priest")
  end

  def wild(_card_info) do
    nil
  end
end
