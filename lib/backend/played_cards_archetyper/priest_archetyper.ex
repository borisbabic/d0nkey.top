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
       "Wilted Shadow",
       "Carless Crafter",
       "Annoy-o-Tron",
       "Careless Crafter",
       "Rest in Peace"
     ]},
    {:"Zarimi Priest",
     [
       "Timewinder Zarimi",
       "Petal Peddler",
       "Fly Off the Shelves",
       "Giftwrapped Whelp",
       "Tormented Dreadwing",
       "Scale Replica"
     ]},
    # 5.5
    {:"Aviana Priest",
     [
       "XB-931 Housekeeper",
       "Tidepool Pupil",
       "Twilight Medium",
       "Overplanner",
       "Sharp-Eyed Lookout",
       "Parrot Sanctuary",
       "Aviana, Elune's Chosen",
       "Champions of Azeroth",
       "Story of Amara",
       "Mo'arg Forgefiend",
       "Atlasaurus",
       "Incindius",
       "Chrono-Lord Deios",
       "Lightspeed",
       "Sleepy Resident",
       "The Ceaseless Expanse",
       "Ysera, Emerald Aspect",
       "Repackage",
       "Narain Soothfancy",
       "Bob the Bartender",
       "Marin the Manager",
       "Intertwined Fate",
       "Ancient of Yore",
       "Gravity Lapse",
       "Nightshade Tea",
       "Ritual of Life",
       "Dirty Rat",
       "Pupet Theatre",
       "Steamcleaner",
       "Greater Healing Potion",
       "Atiesh the Greatstaff",
       "Medivh the Hallowed",
       "Karazhan the Sanctum",
       "Tyrande",
       "Birdwatching",
       "Scarab Keychain",
       "Fyrakk the Blazing",
       "Creature of Madness",
       "Chillin' Vol'jin",
       "Envoy of Prosperity",
       "Elise the Navigator",
       "Zilliax Deluxe 3000",
       "Puppet Theatre",
       "Kaldorei Priestess"
     ]},
    {:"Wilted Priest",
     [
       "Hourglass Attendant",
       "Tar Slime"
     ]},
    {:"Aggro Priest",
     [
       "Menagerie Jug",
       "Brain Masseuse",
       "Workhorse",
       "Acupuncture",
       "Pet Parrot",
       "Overzealous Healer",
       "Archaios",
       "Murmy"
     ]},
    # 10.5
    {:"Zarimi Priest", ["Ship's Chirurgen"]}
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
