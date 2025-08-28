# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest Shaman"

      any?(card_info, [
        "Arkonite Defense Crystal",
        "Lift Off",
        "Jim Raynor",
        "The Exodar",
        "SCV",
        "Ghost"
      ]) ->
        :"Terran Shaman"

      any?(card_info, [
        "Flutterwing Guardian",
        "Bitterbloom Knight",
        "Petal Picker",
        "Living Garden"
      ]) ->
        :"Imbue Shaman"

      any?(card_info, [
        "Ethereal Oracle",
        "Moonstone Mauler",
        "Ultraviolet Breaker",
        "Novice Zapper",
        "Bloodmage Thalnost",
        "Bolide Behemoth"
      ]) ->
        :"Asteroid Shaman"

      any?(card_info, [
        "Wailing Vapor",
        "Sizzling Cinder",
        "Slagmaw",
        "Fire Fly",
        "Menacing Nimbus",
        "Tar Slime"
      ]) ->
        :"Elemental Shaman"

      any?(card_info, ["Bumbling Belhop", "Al'Akir the Windlord", "Nebula", "With Upon a Star"]) ->
        :"Nebula Shaman"

      any?(card_info, ["Matching Outfits"]) ->
        :"Imbue Shaman"

      any?(card_info, [
        "Cabaret Headliner",
        "Hagatha the Fabled",
        "Parrot Sanctuary",
        "Frosty Décor",
        "Elise the Navigator",
        "Fyrakk the Blazing",
        "The Ceaseless Expanse",
        "Farseer Nobundo",
        "Flight of the Firehawk"
      ]) ->
        :"Nebula Shaman"

      any?(card_info, ["Aspect's Embrace"]) ->
        :"Imbue Shaman"

      any?(card_info, ["Sizzling Swarm", "Volcanic Thrasher", "Lava Flow"]) ->
        :"Elemental Shaman"

      any?(card_info, ["Starport", "Lock On", "Marin the Manager", "Dirty Rat"]) ->
        :"Terran Shaman"

      any?(card_info, [
        "Murloc Growfin",
        "Pop-Up Book",
        "Hex",
        "Baking Soda Volcano",
        "Shudderblock",
        "Cosmonaut",
        "Living Flame",
        "Birdwatching",
        "Far Sight"
      ]) ->
        :"Nebula Shaman"

      true ->
        :"Other Shaman"
    end
  end

  def wild(_card_info) do
    nil
  end
end
