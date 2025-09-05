# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.PriestArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_config [
    {:"Quest Priest", ["Reach Equilibrium"]},
    {:"Whizbang Priest",
     [
       "Shadow Word: Pain",
       "Love Everlasting",
       "Crimson Clergy",
       "Celestial Projectionist",
       "Shadow Word: Death",
       "Pip the Potent",
       "Fan Club",
       "Zola the Gorgon",
       "Astral Automaton"
     ]},
    {:"Protoss Priest",
     [
       "Void Ray",
       "Mothership",
       "Photon Cannon",
       "Sentry",
       "Hallucination",
       "Chrono Boost",
       "Artanis"
     ]},
    {:"Wilted Priest",
     [
       "Nexus-Prince Shaffar",
       "Plated Bettle",
       "Tar Slime",
       "Wilted Shadow",
       "Carless Crafter",
       "Annoy-o-Tron",
       "Critter Caretaker",
       "Careless Crafter",
       "Plated Beetle",
       "Rest in Peace"
     ]},
    {:"Imbue Priest",
     [
       "Resplendent Dreamweaver",
       "Sing-Along Buddy",
       "Petal Picker",
       "Flutterwing Guardian",
       "Malorne the Waywatcher"
     ]},
    # 5.5
    {:"Aggro Priest",
     [
       "Menagerie Jug",
       "Brain Masseuse",
       "Workhorse",
       "Ship's Chirurgeon",
       "Archaios",
       "Murmy"
     ]},
    {:"Aviana Priest",
     [
       "Card Grader",
       "Glacial Shard",
       "Mo'arg Forgefiend"
     ]},
    {:"Imbue Priest", ["Bitterbloom Knight"]},
    {:"Aviana Priest",
     [
       "Moonwell",
       "Mixologist",
       "Twilight Medium",
       "Overplanner",
       "Sharp-Eyed Lookout",
       "Marin the Manager",
       "Living Flame",
       "Parrot Sanctuary",
       "Aviana, Elune's Chosen",
       "Doomsayer",
       "Champions of Azeroth",
       "Atlasaurus",
       "Story of Amara"
     ]},
    {:"Imbue Priest", ["Lunarwing Messenger", "Blob of Tar"]},
    # 10.5
    {:"Protoss Priest", ["Catch of the Day"]}
    # {:"Wilted Priest", ["Lightbomb", "Sleepy Resident"]},
    # {:"Wilted Priest", ["Power Word: Shield", "Resuscitate"]},
    # {:"Protoss Priest", ["Trusty Fishing Rod", "Nightmare Xavius"]},
    # {:"Wilted Priest", ["Thrive in the Shadows", "Birdwatching", "Narain Soothfancy"]}
  ]
  @wild_config []

  def standard_config(), do: @standard_config
  def wild_config(), do: @wild_config

  def standard(card_info) do
    process_config(@standard_config, card_info, :"Other Priest")
  end

  def wild(_card_info) do
    nil
  end
end
