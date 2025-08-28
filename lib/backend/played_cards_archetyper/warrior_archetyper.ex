# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarriorArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      any?(card_info, ["Part Scrapper", "Wreck'em and Deck'em", "Boom Wrench", "Testing Dummy"]) ->
        :"Mech Warrior"

      any?(card_info, [
        "Enter the Lost City",
        "The Exodar",
        "Arkonite Defense Crystal",
        "Yamato Cannon",
        "Jim Raynor",
        "Marin the Manager",
        "The Ceaseless Expanse",
        "Ancient of Yore",
        "Sleep Under the Stars",
        "Hostile Invader",
        "New Heights"
      ]) ->
        :"Control Warrior"

      any?(card_info, [
        "Windpeak Wyrm",
        "Clutch of Corruption",
        "Darkrider",
        "Brood Keeper",
        "Giftwrapped Whelp",
        "Illusory Greenwing",
        "Succumb to Madness",
        "Petal Peddler"
      ]) ->
        :"Dragon Warrior"

      any?(card_info, [
        "Carnivorous Cubicle",
        "Endbringer Umbra",
        "Inventor Boom",
        "Nightmare Lord Xavius",
        "Mixologist",
        "Slam",
        "Quality Assurance"
      ]) ->
        :"Mech Warrior"

      any?(card_info, [
        "Blob of Tar",
        "Demolition Renovator",
        "Tortollan Traveler",
        "Brawl",
        "Shellnado",
        "Bulwark of Azzinoth",
        "Hamm, the Hungry"
      ]) ->
        :"Control Warrior"

      any?(card_info, [
        "Cloud Serpent",
        "Dragon Turtle",
        "Creature of Madness",
        "Fyrakk the Blazing",
        "Ysondre",
        "Naralex",
        "Gorgonzormu"
      ]) ->
        :"Dragon Warrior"

      any?(card_info, [
        "Shield Block",
        "Starport",
        "Concussive Shells",
        "Dirty Rat",
        "Hydration Station",
        "Bob the Bartender",
        "Tortolla",
        "Dreamplanner Zephyrs",
        "Griftah, Trusted Vendor",
        "Ysera, Emerald Aspect"
      ]) ->
        :"Control Warrior"

      any?(card_info, ["Shadowflame Suffusion"]) ->
        :"Dragon Warrior"

      any?(card_info, ["All You Can Eat", "Axe of the Forefathers"]) ->
        :"Mech Warrior"

      true ->
        :"Other Warrior"
    end
  end

  def wild(_card_info) do
    nil
  end
end
