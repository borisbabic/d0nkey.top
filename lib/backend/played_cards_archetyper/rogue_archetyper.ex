# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.RogueArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    "Quest Rogue": ["Lie in Wait"],
    "Harold Rogue": [
      "Maniacal Follower",
      "Ultraxion",
      "Envoy of the End",
      "Sinestra",
      "Deathwing, Worldbreaker"
    ],
    "Harold Rogue": [
      "Deja Vu",
      "Elise the Navigator",
      "Flutterwing Guardian",
      "Glacial Shard",
      "Naralex, Herald of the Flights",
      "Nightmare Fuel",
      "Nightmare Lord Xavius",
      "Resplendent Dreamweaver",
      "Shaladrassil",
      "Twilight Mistress"
    ],
    "Burn Rogue": ["Chrono Daggers", "Morchie", "Prize Vendor", "Rockskipper", "Tunneling Geomancer"],
    "Harold Rogue": [
      "Agent of the Old Ones",
      "Backstab",
      "Bitterbloom Knight",
      "Cultist Map",
      "Eventuality",
      "Jagged Edge of Time",
      "Opu the Unseen",
      "Preparation",
      "Rite of Twilight",
      "Sands of Time",
      "Spymistress",
      "The Kingslayers",
      "Vanessa the Ringleader"
    ]
  ]
  @wild_config []

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Rogue")
  end

  def wild(_card_info) do
    nil
  end
end
