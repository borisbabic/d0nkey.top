# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.DeathKnightArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  def standard(card_info) do
    cond do
      quest?(card_info) ->
        :"Quest DK"

      any?(card_info, [
        "Guiding Figure",
        "Soulbound Spire",
        "Arkonite Defense Crystal",
        "The Spirit's Passage",
        "The Exodar",
        "Suffocate",
        "Dimensional Core"
      ]) ->
        :"Starship DK"

      any?(card_info, [
        "City Chief Esho",
        "Lesser Spinel Spellstone",
        "Darkthorn Quilter",
        "Amateur Puppeteer",
        "Blood Tap"
      ]) ->
        :"Handbuff DK"

      any?(card_info, ["Menagerie Mug", "Fire Fly", "Menagerie Jug", "Murmy"]) ->
        :"Menagerie DK"

      any?(card_info, [
        "Bonechill Stegodon",
        "Overplanner",
        "Travel Security",
        "Ancient Raptor",
        "Endbringer Umbra",
        "Wakener of Souls",
        "Eternal Layover",
        "Ancient Raptor"
      ]) ->
        :"Herren DK"

      any?(card_info, [
        "Fyrakk the Blazing",
        "Griftah, Trusted Vendor",
        "Frosty Decor",
        "Threads of Despair",
        "Staff of the Endbringer",
        "Hematurge",
        "Dirty Rat",
        "Blob of Tar",
        "Airlock Breach",
        "Bob the Bartender",
        "Marin the Manager",
        "Kil'jaeden",
        "Corpse Explosion",
        "Reluctant Wrangler",
        "Steamcleaner",
        "Staff of the Enderbringer",
        "Hideous Husk",
        "Infested Breath",
        "Sanguine Infestation",
        "Morbid Swarm",
        "Dreadhound Handler",
        "Elise the Navigator",
        "Chillfallen Baron",
        "Ancient of Yore",
        "Zilliax Deluxe 3000",
        "Dirty Rat",
        "The Headless Horseman",
        "Creature of Madness",
        "Nightmare Lord Xavius",
        "Ysera, Emerald Aspect",
        "The Ceaseless Expanse",
        "Exarch Maladaar",
        "Scarab Keychain",
        "Orbital Moon",
        "Foamrender",
        "Vampiric Blood",
        "Poison Breath",
        "Reluctant Wrangler",
        "Shaladrassil",
        "Demolition Renovator",
        "Gnomelia, S.A.F.E. Pilot"
      ]) ->
        :"Control DK"

      any?(card_info, [
        "Horn of Winter",
        "Frost Strike",
        "Slippery Slope",
        "Crypt Map",
        "Rambunctious Stuffy",
        "Glacial Shard",
        "Mixologist",
        "Auchenai Death-Speaker",
        "Troubled Mechanic",
        "High Cultist Herenn",
        "Ghouls' Night"
      ]) ->
        :"Herren DK"

      any?(card_info, ["Brittlebone Buccaneer", "Silk Stitching", "Wild Pyromancer"]) ->
        :"Starship DK"

      any?(card_info, [
        "Toysnatching Geist",
        "Rainbow Seamstress",
        "Reanimated Pterrordax",
        "Nerubian Swarmguard",
        "Gnome Muncher",
        "Shambling Zombietank"
      ]) ->
        :"Handbuff DK"

      any?(card_info, ["Monstrous Mosquito", "Harbringer of Winter", "Menagerie DK"]) ->
        :"Menagerie DK"

      any?(card_info, [
        "Buttons",
        "Zergling",
        "Dreamplanner Zephryus",
        "Rite of Atrocity",
        "Prize Vendor",
        "Wisp",
        "Adaptive Amalgam",
        "Kerrigan, Queen of Blades",
        "Ursoc",
        "Plucky Paintfin",
        "Floppy Hydra",
        "Death Strike"
      ]) ->
        :"Control DK"

      any?(card_info, ["Malted Magma", "Asphyxiate"]) ->
        :"Herren DK"

      true ->
        :"Other DK"
    end
  end

  def wild(_card_info) do
    nil
  end
end
