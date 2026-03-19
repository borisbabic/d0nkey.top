# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest DK", ["Reanimate the Terror"]},
    {:"Harold DK",
     [
       "Staff of the Endbringer",
       "Deathwing Worldbreaker",
       "Obsessive Technician",
       "Ultraxion",
       "Arisen Onyxia",
       "Envoy of the End",
       "Experimental Animation"
     ]},
    {:"Unholy DK",
     [
       "Grave Strength",
       "Maze Guide",
       "Living Paradox"
     ]},
    {:"Imbue DK",
     [
       "Petal Picker",
       "Bitterbloom Knight",
       "Jagged Edge of Time",
       "Finality",
       "Flutterwing Guardian"
     ]},
    {:"Unholy DK",
     [
       "Nerubian Swarmguard"
     ]},
    # 5.5
    {:"Harold DK",
     [
       "Elise the Navigator"
     ]},
    {:"Unholy DK",
     [
       "Twilight Egg",
       "Murmy",
       "Monstrous Mosquito",
       "Talanji's Last Stand",
       "Shadow of Yesterday"
     ]},
    {:"Harold DK",
     [
       "Victor Nefarius",
       "Whelp of the Infinite",
       "Sanguine Infestation",
       "Infested Breath",
       "Creature of Madness",
       "Morbid Swarm",
       "Chillfallen Baron",
       "Nightmare Lord Xavius"
     ]}
  ]

  @wild_config [
    {:"XL Highlander DK",
     [
       "Reno, Lone Ranger",
       "Tuskarrrr Trawler",
       "Zephrys the Great",
       "Reno Jackson",
       "Customs Enforcer",
       "Space Pirate",
       "Mixologist",
       "Blademaster Okani",
       "Cult Neophyte",
       "Theotar, the Mad Duke",
       "Cold Feet",
       "Runeforging",
       "Quartzite Crusher",
       "Patchwerk",
       "Climactic Necrotic Explosion",
       "Razorscale",
       "Malted Magma",
       "Construct Quarter",
       "Buttons",
       "The Curator",
       "Staff od the Endbringer",
       "Dirty Rat",
       "E.T.C., Band Manager",
       "Frost Strike",
       "Elise the Navigator"
     ]}
  ]

  def standard_excludes(), do: %{}
  def wild_excludes(), do: %{}

  def standard_config(), do: add_excludes(@standard_config, standard_excludes())
  def wild_config(), do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other DK")
  end
end
