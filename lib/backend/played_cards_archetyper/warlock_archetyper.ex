# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.WarlockArchetyper do
  @moduledoc false

  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  @standard_excludes %{
    "Zoo Warlock" => [{:start_of_game, ["Godfrey the Betrayer"]}]
  }
  @standard_config [
    "Tick Tock Warlock": ["Battle at the End Time"],
    "Quest Warlock": ["Escape the Underfel"],
    Rafaamlock: [
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
    ],
    Zoolock: [
      "Vaultkeeper",
      "Platysaur",
      "Twilight Egg",
      "Entropic Continuity",
      "Blasphemy"
    ],
    "Wallow Warlock": [
      "Wallow, the Wretched",
      "Raptor Herald",
      "Overgrown Horror",
      "Treacherous Tormentor",
      "Avant-Gardening",
      "Creator of Madness"
    ],
    # 5.5
    "C'Thun Warlock": [
      "C'Thun, Eye of the Empire",
      "Ultraxion",
      "Deathwing, Worldbreaker"
    ],
    "C'Thun Warlock": [
      "Gargantuan Slitherer",
      "Spawn of C'Thun"
    ],
    Zoolock: [
      "Floating Lessons",
      "Twilight Timehopper",
      "Ruinous Velocidrake",
      "Mawman Cultist",
      "Cult Neophyte"
    ],
    # auto gen
    # Egglock: ["The Egg of Khelos"],
    "C'Thun Warlock": ["Cho'gall, Mastermind", "Sands of Time"],
    # "Drake Warlock": ["Earthen Drake"],
    # "Impformant Warlock": ["Kabal Conspirator"],
    "C'Thun Warlock": ["Frame Job", "Shrine of Twilight"],
    # "Demon Warlock": ["Archwitch Willow", "Endbringer Umbra"],
    # "Drake Warlock": ["M.O.T.H.E.R."],
    "C'Thun Warlock": ["Ancient Augur", "Annihilation", "Kith'ix"],
    Rafaamlock: ["Elise the Navigator"],
    "C'Thun Warlock": [
      "Crystalline Golem",
      "Cursed Chains",
      "Hellfire",
      "Imp Gang Stooge",
      "Ritual of C'Thun",
      "Ritual of Summoning",
      "Shadowsworn Disciple",
      "Spire of Solitude",
      "The Unseen Atlas",
      "Treasure Fiend"
    ],
    Rafaamlock: ["Godfather Kazakus"]
  ]
  @wild_config [
    Discolock: [
      "Boneweb Egg",
      "Chronoclaws",
      "Disposable Acolytes",
      "Duke of Below",
      "Entropic Continuity",
      "Irondeep Trogg",
      "Party Fiend",
      "Platysaur",
      "Silverware Golem",
      "Silverware Golem",
      "Soul Barrage",
      "Walking Dead",
      "Wicked Whispers"
    ],
    "XL HL Tick Tock Warlock": ["Kerrigan, Queen of Blades", "Nydus Worm", "Spawning Pool", "Witchwood Piper"],
    Boarlock: ["Shadowborn"],
    "XL Highlander Warlock": ["Mixologist", "Void Contract"],
    "Fatigue Seedlock": ["Blood Shard Bristleback"],
    "XL Highlander Warlock": ["Deathlord", "Rin, Orchestrator of Doom", "Soul Seeker"],
    "XL HL Tick Tock Warlock": [
      "Battle at the End Time",
      "Speaker Stomper",
      "The Curator",
      "Timeline Accelerator",
      "Ultralisk Cavern"
    ],
    "XL Highlander Warlock": ["Mutanus the Devourer", "Theotar, the Mad Duke"],
    "XL Demon Boarlock": ["Crane Game"],
    "XL Seedlock": ["Tachyon Barrage"],
    Boarlock: ["Eat! The! Imp!", "Elwynn Boar", "Tour Guide"],
    Evenlock: ["Goldshire Gnoll", "Mountain Giant"],
    "Fatigue Seedlock": ["Fanottem, Lord of the Opera"],
    "XL Warlock": ["Messmaker"],
    "XL Highlander Warlock": ["Altar of Fire", "Bygone Doomspeaker", "Dar'Khan Drathir", "Eredar Brute"],
    "XL Seedlock": ["Celestial Projectionist", "Imployee of the Month"],
    Discolock: ["Soulfire"],
    "XL SoU Quest Warlock": ["Supreme Archaeology"],
    "Insanity Warlock": ["Encroaching Insanity"],
    "XL Demon Boarlock": ["Fae Trickster"],
    "XL Seedlock": ["Shadowblade Slinger"],
    "XL Highlander Warlock": ["Far Watch Post", "Zilliax Deluxe 3000"],
    "XL Seedlock": ["Spirit Bomb"],
    "STD Harold Egglock": ["Abusive Sergeant"],
    Seedlock: ["Flesh Giant", "Molten Giant"],
    "XL Highlander Warlock": ["Cataclysm", "Gnomeferatu", "Zilliax Deluxe 3000"],
    Boarlock: ["Rain of Fire"],
    Boarlock: ["Old Murk-Eye"],
    "Other Warlock": ["Treachery"],
    "XL HL Tick Tock Warlock": ["Grimoire of Sacrifice"],
    "Other Warlock": ["Barrens Scavenger"],
    "Fatigue Seedlock": ["Chamber of Viscidus"],
    "STD Harold Egglock": ["Holy Eggbearer"],
    Boarlock: ["Conflagrate"],
    "Insanity Warlock": ["Void Virtuoso"],
    "XL Highlander Warlock": ["Blademaster Okani", "Demonic Project"],
    Boarlock: ["Felstring Harp", "Fracking"],
    Seedlock: ["Healthstone", "Imprisoned Horror"],
    "XL HL Tick Tock Warlock": ["Cult Neophyte", "Plot Twist", "Smothering Starfish"],
    Discolock: ["The Soularium"],
    "XL Highlander Warlock": [
      "Dark Skies",
      "Full-Blown Evil",
      "Nightmare Lord Xavius",
      "Sargeras, the Destroyer",
      "Symphony of Sins",
      "Wing Welding",
      "Zephrys the Great"
    ],
    "XL Warlock": ["Burrow Buster"],
    "XL Warlock": ["Mo'arg Drillfist"],
    Discolock: ["Ocular Occultist"],
    "XL Seedlock": ["The Demon Seed"],
    "Ashtongue Warlock": ["Mass Production"],
    Boarlock: ["Kobold Librarian"],
    "XL Highlander Warlock": ["Dirty Rat"],
    "Other Warlock": ["\"Health\" Drink"],
    Boarlock: ["Darkbomb", "Darkbomb", "Domino Effect"],
    Discolock: ["Cursed Catacombs"]
  ]

  def standard_excludes, do: @standard_excludes
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(@standard_config, standard_excludes())
  def wild_config, do: add_excludes(@wild_config, standard_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Warlock")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Warlock")
  end
end
