# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper.ShamanArchetyper do
  @moduledoc false

  alias Backend.Hearthstone.Card
  import Backend.PlayedCardsArchetyper.ArchetyperHelper

  defp any_non_mugzee_minion?(card_info) do
    Enum.any?(card_info.full_cards, fn c ->
      Card.minion?(c) and Card.name(c) != "Mug'Zee"
    end)
  end

  defp any_spell?(card_info) do
    Enum.any?(card_info.full_cards, fn c ->
      Card.spell?(c)
    end)
  end

  @minion_cthun ["Spawn of C'Thun", "C'Thun, Eye of the Empire", "Gargantuan Slitherer"]

  defp base_standard_config do
    [
      "Quest Shaman": ["Spirit of the Mountain"],
      "Zee Shaman": [
        {:all,
         [
           {:start_of_game, ["Mug'Zee"]},
           &any_non_mugzee_minion?/1
         ]}
      ],
      "Mug Shaman": [
        {:all,
         [
           [{:start_of_game, ["Mug'Zee"]}],
           {:any,
            [
              &any_spell?/1,
              ["Low Security Wing"]
            ]}
         ]}
      ],
      "C'Thun Shaman": {@minion_cthun, [{:start_of_game, ["Mug'Zee"]}]},
      "Harold Shaman": [
        "Envoy of the End",
        "Ultraxion",
        "Deathwing, Worldbreaker",
        "Al'Akir, Lord of Storms"
      ],
      # 5.5
      "Harold Shaman": [
        "Twilight Egg",
        "Sizzling Cinder"
      ],
      "Harold Shaman": ["Avatar Form"],
      "Mug Shaman": ["Mountain Map"],
      "Harold Shaman": ["Elise the Navigator", "Muradin, High King"],
      "C'Thun Shaman": ["Living Flame"],
      "Harold Shaman": ["Wailing Vapor", "Witch's Apprentice"],
      # "Rainbow Shaman": ["Breezling", "Voltaic Burst"],
      "Mug Shaman": ["Low Security Wing"],
      "C'Thun Shaman": ["Flame Shock", "Shadowed Informant"],
      # "Spell Damage Shaman": ["Volcanic Thrasher"],
      "Harold Shaman": ["Unstable Prototype"],
      # "Rainbow Shaman": ["Primordial Overseer"],
      "Harold Shaman": ["Ritual of Power", "Skywall Sentinel"],
      "C'Thun Shaman": ["Elemental of Madness", "Unnatural Cold"],
      "Other Shaman": ["Blazing Invocation", "Watch Over"],
      "C'Thun Shaman": ["Shadow Sculpt"]
    ]
  end

  @wild_config [
    "Even Shaman": [
      "Anchored Totem",
      "Ancient Totem",
      "Carving Chisel",
      "Gigantotem",
      "Hydration Totem",
      "Jukebox Totem",
      "Splitting Axe",
      "The Stonewright",
      "Thing from Below",
      "Totemic Might",
      "Totemic Surge"
    ],
    "Ohn'ahra Big Shaman": ["Nebula"],
    "SoU Quest Shaman": ["Caricature Artist"],
    "XL HL Shudder Shaman": ["For All Time", "Miracle Salesman", "Razorscale", "Revolve", "Sphere of Sapience"],
    "Big Shaman": ["Rockbiter Weapon"],
    "Ohn'ahra Big Shaman": [
      "Ancestor's Call",
      "Auctionhouse Gavel",
      "Jam Session",
      "Muckmorpher",
      "Reincarnate",
      "Scalding Geyser"
    ],
    "STD Harold Shaman": ["Twilight Egg"],
    "XL Questline Shaman": ["Command the Elements"],
    "SoU Quest Shaman": ["Elementary Reaction", "Fire Plume Harbinger"],
    "STD Harold Shaman": ["Treasure Distributor"],
    "XL HL Shudder Shaman": ["Speaker Stomper"],
    "SoU Quest Shaman": ["Gorloc Ravager", "Scargil"],
    "Starship Shaman": ["Starport"],
    "XL HL LC Quest Shaman": ["Spirit of the Mountain"],
    "XL SoU Quest Shaman": ["Chaotic Tendril"],
    "XL HL Shudder Shaman": [
      "Backstage Bouncer",
      "Birdwatching",
      "Bolner Hammerbeak",
      "Boompistol Bully",
      "Cult Neophyte",
      "Doctor Holli'dae",
      "Elemental Destruction",
      "Far Watch Post",
      "Golganneth, the Thunderer",
      "Lorekeeper Polkelt",
      "Marin the Manager",
      "Parrot Sanctuary",
      "Pebbly Page",
      "Prescience",
      "Reno, Lone Ranger",
      "Sir Finley, Sea Guide",
      "Thrall's Gift",
      "Timeline Accelerator",
      "Zephrys the Great"
    ],
    "SoU Quest Shaman": ["Gold Panner", "Needlerock Totem", "Primal Dungeoneer"],
    "XL SoU Quest Shaman": ["Cold Storage", "Sleetbreaker", "Snowfall Guardian", "Ysera, Emerald Aspect"],
    "Elemental Shaman": ["Shale Spider"],
    "STD Harold Shaman": ["Witch's Apprentice"],
    "XL HL Shudder Shaman": ["Dirty Rat"],
    "Splendiferous Whizbang": ["Clownfish"],
    "XL HL Shudder Shaman": ["Turbulus"],
    "XL HL SoU Quest Shaman": ["Corrupt the Waters"],
    "Ohn'ahra Big Shaman": ["Fairy Tale Forest", "Triangulate"]
  ]

  def standard_excludes, do: %{}
  def wild_excludes, do: %{}

  def standard_config, do: add_excludes(base_standard_config(), standard_excludes())
  def wild_config, do: add_excludes(@wild_config, wild_excludes())

  def standard(card_info) do
    process_config(standard_config(), card_info, :"Other Shaman")
  end

  def wild(card_info) do
    process_config(wild_config(), card_info, :"Other Shaman")
  end
end
