# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest DK": ["Reanimate the Terror"],
    "Harold DK": [
      "Staff of the Endbringer",
      "Deathwing, Worldbreaker",
      "Obsessive Technician",
      "Ultraxion",
      "Arisen Onyxia",
      "Envoy of the End",
      "Experimental Animation",
      "Memoriam Manifest",
      "The Curator",
      "Soulrest Ceremony"
    ],
    "Unholy DK": [
      "Grave Strength",
      "Maze Guide",
      "Living Paradox",
      "Talanji's Last Stand"
    ],
    "Unholy DK": ["Shadows of Yesterday"],
    "Harold DK": ["Elise the Navigator"],
    "Harold DK": ["Hematurge", "Morbid Swarm"],
    "Unholy DK": ["Ancient Raptor", "Reluctant Wrangler", "Twilight Egg"],
    "Harold DK": ["Carrier Whelp", "Infested Breath"],
    "Harold DK": ["Chillfallen Baron"]
  ]

  @wild_config []

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other DK")
  end

  def wild(card_info) do
    process_config(@wild_config, card_info, :"Other DK")
  end
end
