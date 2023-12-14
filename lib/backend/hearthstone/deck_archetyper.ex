# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.Hearthstone.DeckArchetyper do
  @moduledoc "Determines the archetype of a deck"
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Card

  @type card_info :: %{card_names: [String.t()], full_cards: [Card.t()]}
  @spec archetype(integer(), [integer()], String.t()) :: atom() | nil
  def archetype(format, cards, class),
    do: archetype(%{format: format, cards: cards, class: class})

  @type deck :: Deck.t() | %{format: integer(), cards: [integer()], class: String.t()}
  @spec archetype(deck() | String.t()) :: atom() | nil
  def archetype(deck = %{class: nil, hero: hero}) do
    case Backend.Hearthstone.class(hero) do
      nil -> nil
      class -> deck |> Map.put(:class, class) |> archetype()
    end
  end

  @neutral_excavate ["Kobold Miner", "Burrow Buster"]
  def archetype(%{format: 2, cards: c, class: "DEATHKNIGHT"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander DK"

      burn_dk?(card_info) ->
        :"Burn DK"

      handbuff_dk?(card_info) ->
        :"Handbuff DK"

      plague_dk?(card_info) ->
        :"Plague DK"

      excavate_dk?(card_info) ->
        :"Excavate DK"

      aggro_dk?(card_info) ->
        :"Aggro DK"

      menagerie?(card_info) ->
        :"Menagerie DK"

      boar?(card_info) ->
        :"Boar DK"

      quest?(card_info) || questline?(card_info) ->
        :"Quest DK"

      murloc?(card_info) ->
        :"Murloc DK"

      true ->
        fallbacks(card_info, "DK", ignore_types: ["Undead", "undead", "UNDEAD"])
    end
  end

  def excavate_dk?(ci) do
    min_count?(ci, 4, [
      "Pile of Bones",
      "Reap What You Sow",
      "Skeleton Crew",
      "Harrowing Ox" | @neutral_excavate
    ])
  end

  def plague_dk?(ci),
    do:
      min_count?(ci, 3, [
        "Staff of the Primus",
        "Distressed Kvaldir",
        "Down with the Ship",
        "Helya",
        "Tomb Traitor",
        "Chained Guardian"
      ])

  def burn_dk?(c),
    do: min_count?(c, 2, ["Bloodmage Thalnos", "Talented Arcanist", "Guild Trader"])

  def aggro_dk?(c),
    do:
      min_count?(c, 4, [
        "Body Bagger",
        "Hawkstrider Rancher",
        "Irondeep Trogg",
        "Incorporeal Corporal",
        "Peasant"
      ])

  def handbuff_dk?(c),
    do:
      min_count?(c, 3, [
        "Blood Tap",
        "Darkfallen Neophyte",
        "Vicious Bloodworm",
        "Overlord Runthak",
        "Ram Commander",
        "Encumbered Pack Mule"
      ])

  def archetype(%{format: 2, cards: c, class: "DEMONHUNTER"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander DH"

      boar?(card_info) ->
        :"Boar Demon Hunter"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Demon Hunter"

      deathrattle_dh?(card_info) ->
        :"Deathrattle DH"

      clean_slate_dh?(card_info) ->
        :"Clean Slate DH"

      big_dh?(card_info) ->
        :"Big Demon Hunter"

      murloc?(card_info) ->
        :"Murloc Demon Hunter"

      fel_dh?(card_info) && spell_dh?(card_info) && relic_dh?(card_info) ->
        :"Spffellic Demon Hunter"

      spell_dh?(card_info) && fel_dh?(card_info) ->
        :"Spffell Demon Hunter"

      spell_dh?(card_info) && relic_dh?(card_info) ->
        :"Spellic Demon Hunter"

      fel_dh?(card_info) && relic_dh?(card_info) ->
        :"Felic Demon Hunter"

      spell_dh?(card_info) ->
        :"Spell Demon Hunter"

      naga_dh?(card_info) ->
        :"Naga Demon Hunter"

      menagerie?(card_info) ->
        :"Menagerie DH"

      aggro_dh?(card_info) && outcast_dh?(card_info) ->
        :"Aggro Outcast DH"

      aggro_dh?(card_info) && relic_dh?(card_info) ->
        :"Aggro Relic DH"

      aggro_dh?(card_info) ->
        :"Aggro Demon Hunter"

      fel_dh?(card_info) ->
        :"Fel Demon Hunter"

      relic_dh?(card_info) ->
        :"Relic Demon Hunter"

      outcast_dh?(card_info) ->
        :"Outcast DH"

      true ->
        fallbacks(card_info, "Demon Hunter")
    end
  end

  def naga_dh?(ci) do
    "Blindeye Sharpshooter" in ci.card_names and type_count(ci, "Naga") >= 4
  end

  def spell_dh?(c),
    do:
      min_count?(c, 3, [
        "Souleater's Scythe",
        "Mark of Scorn",
        "Fel'dorei Warband",
        "Deal with a Devil"
      ])

  def outcast_dh?(c), do: min_keyword_count?(c, 4, "outcast")

  def archetype(%{format: 2, cards: c, class: "DRUID"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) -> :"Highlander Druid"
      quest?(card_info) || questline?(card_info) -> :"Quest Druid"
      boar?(card_info) -> :"Boar Druid"
      vanndar?(card_info) -> :"Vanndar Druid"
      fire_druid?(card_info) -> :"Fire Druid"
      chad_druid?(card_info) -> :"Chad Druid"
      big_druid?(card_info) -> :"Big Druid"
      celestial_druid?(card_info) -> :"Celestial Druid"
      menagerie?(card_info) -> :"Menagerie Druid"
      moonbeam_druid?(card_info) -> :"Moonbeam Druid"
      treant_druid?(card_info) -> :"Treant Druid"
      murloc?(card_info) -> :"Murloc Druid"
      "Lady Prestor" in card_info.card_names -> :"Prestor Druid"
      aggro_druid?(card_info) -> :"Aggro Druid"
      "Gadgetzan Auctioneer" in card_info.card_names -> :"Miracle Druid"
      ignis_druid?(card_info) -> :"Ignis Druid"
      "Tony, King of Piracy" in card_info.card_names -> :"Tony Druid"
      zok_druid?(card_info) -> :"Zok Druid"
      hero_power_druid?(card_info) -> :"Hero Power Druid"
      choose_one?(card_info) -> :"Choose Druid"
      afk_druid?(card_info) -> :"AFK Druid"
      "Drum Circle" in card_info.card_names -> :"Drum Druid"
      ramp_druid?(card_info) -> :"Ramp Druid"
      true -> fallbacks(card_info, "Druid")
    end
  end

  defp ignis_druid?(ci) do
    min_count?(ci, 2, ["Forbidden Fruit", "Ignis, the Eternal Flame"])
  end

  defp deathrattle_druid?(ci) do
    min_count?(ci, 2, ["Hedge Maze", "Death Blossom Whomper"])
  end

  defp moonbeam_druid?(ci) do
    "Moonbeam" in ci.card_names &&
      min_count?(ci, 2, ["Bloodmage Thalnos", "Kobold Geomancer", "Rainbow Glowscale"])
  end

  defp treant_druid?(ci),
    do: min_count?(ci, 2, ["Witchwood Apple", "Conservator Nymph", "Blood Treant", "Cultivation"])

  defp afk_druid?(ci),
    do: min_count?(ci, 2, ["Rhythm and Roots", "Timber Tambourine"])

  defp choose_one?(ci),
    do: min_count?(ci, 3, ["Embrace Nature", "Disciple of Eonar"])

  defp zok_druid?(ci),
    do: min_count?(ci, 2, ["Zok Fogsnout", "Anub'Rekhan"])

  def archetype(%{format: 2, cards: c, class: "HUNTER"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander Hunter"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Hunter"

      vanndar?(card_info) && big_beast_hunter?(card_info) ->
        :"Vanndar Beast Hunter"

      vanndar?(card_info) ->
        :"Vanndar Hunter"

      arcane_hunter?(card_info) && (big_beast_hunter?(card_info) or beast_hunter?(card_info)) ->
        :"Arcane Beast Hunter"

      arcane_hunter?(card_info) ->
        :"Arcane Hunter"

      secret_hunter?(card_info) ->
        :"Secret Hunter"

      rat_hunter?(card_info) ->
        :"Rattata Hunter"

      big_beast_hunter?(card_info) ->
        :"Big Beast Hunter"

      cleave_hunter?(card_info) ->
        :"Cleave Hunter"

      beast_hunter?(card_info) ->
        :"Beast Hunter"

      murloc?(card_info) ->
        :"Murloc Hunter"

      boar?(card_info) ->
        :"Boar Hunter"

      menagerie?(card_info) ->
        :"Menagerie Hunter"

      aggro_hunter?(card_info) ->
        :"Aggro Hunter"

      shockspitter?(card_info) ->
        :"Shockspitter Hunter"

      zoo_hunter?(card_info) ->
        :"Zoo Hunter"

      egg_hunter?(card_info) ->
        :"Egg Hunter"

      wildseed_hunter?(card_info) ->
        :"Wildseed Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  defp zoo_hunter?(ci) do
    min_count?(ci, 3, ["Observer of Myths", "Hawkstrider Rancher", "Saddle Up!", "Shadehound"])
  end

  defp egg_hunter?(ci),
    do: min_count?(ci, 3, ["Foul Egg", "Nerubian Egg", "Ravenous Kraken", "Yelling Yodeler"])

  defp secret_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "Costumed Singer",
        "Anonymous Informant",
        "Titanforged Traps",
        "Starstrung Bow"
      ])

  def shockspitter?(ci) do
    "Shockspitter" in ci.card_names
  end

  def archetype(%{format: 2, cards: c, class: "MAGE"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander Mage"

      arcane_mage?(card_info) && (quest?(card_info) || questline?(card_info)) ->
        :"Arcane Quest Mage"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Mage"

      vanndar?(card_info) ->
        :"Vanndar Mage"

      menagerie?(card_info) ->
        :"Menagerie Mage"

      "Grand Magister Rommath" in card_info.card_names ->
        :"Rommath Mage"

      naga_mage?(card_info) && rainbow_mage?(card_info) ->
        :"Rainbow Naga Mage"

      rainbow_mage?(card_info) ->
        :"Rainbow Mage"

      arcane_mage?(card_info) ->
        :"Arcane Mage"

      naga_mage?(card_info) && arcane_mage?(card_info) ->
        :"Arcane Naga Mage"

      secret_mage?(card_info) ->
        :"Secret Mage"

      naga_mage?(card_info) && secret_mage?(card_info) ->
        :"Secret Naga Mage"

      burn_mage?(card_info) && secret_mage?(card_info) ->
        :"Burn Secret Mage"

      naga_mage?(card_info) && burn_mage?(card_info) && secret_mage?(card_info) ->
        :"Secret Burn Naga Mage"

      naga_mage?(card_info) && casino_mage?(card_info) ->
        :"Casino Naga Mage"

      casino_mage?(card_info) ->
        :"Casino Mage"

      frost_mage?(card_info) ->
        :"Frost Mage"

      burn_mage?(card_info) && naga_mage?(card_info) ->
        :"Burn Naga Mage"

      naga_mage?(card_info) && skeleton_mage?(card_info) ->
        :"Spooky Naga Mage"

      naga_mage?(card_info) ->
        :"Naga Mage"

      mech_mage?(card_info) ->
        :"Mech Mage"

      excavate_mage?(card_info) ->
        :"Excavate Mage"

      burn_mage?(card_info) && skeleton_mage?(card_info) ->
        :"Burn Spooky Mage"

      burn_mage?(card_info) ->
        :"Burn Mage"

      skeleton_mage?(card_info) ->
        :"Spooky Mage"

      ping_mage?(card_info) ->
        :"Ping Mage"

      big_spell_mage?(card_info) ->
        :"Big Spell Mage"

      murloc?(card_info) ->
        :"Murloc Mage"

      boar?(card_info) ->
        :"Boar Mage"

      true ->
        fallbacks(card_info, "Mage")
    end
  end

  defp excavate_mage?(ci) do
    min_count?(ci, 3, [
      "Cryopreservation",
      "Reliquary Researcher",
      "Blastmage Miner" | @neutral_excavate
    ])
  end

  def rainbow_mage?(ci),
    do:
      min_count?(ci, 3, [
        "Discovery of Magic",
        "Inquisitive Creation",
        "Sif",
        "Elemental Inspiration"
      ])

  def burn_mage?(ci), do: min_count?(ci, 2, ["Vexallus", "Aegwynn, the Guardian"])

  def arcane_mage?(card_info),
    do:
      min_count?(card_info, 3, [
        "Vexalllus",
        "Arcsplitter",
        "Arcane Wyrm",
        "Magister's Apprentice"
      ]) && min_spell_school_count?(card_info, 4, "arcane")

  def casino_mage?(card_info),
    do:
      min_count?(card_info, 3, [
        "Energy Shaper",
        "Grand Magister Rommath",
        "The Sunwell",
        "Vast Wisdowm",
        "Prismatic Elemental"
      ])

  def archetype(%{format: 2, cards: c, class: "PALADIN"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) && pure_paladin?(card_info) -> :"Highlander Pure Paladin"
      pure_paladin?(card_info) && dude_paladin?(card_info) -> :Chadadin
      earthen_paladin?(card_info) && pure_paladin?(card_info) -> :"Gaia Pure Paladin"
      pure_paladin?(card_info) -> :"Pure Paladin"
      highlander?(card_info, c) -> :"Highlander Paladin"
      aggro_paladin?(card_info) -> :"Aggro Paladin"
      menagerie?(card_info) -> :"Menagerie Paladin"
      quest?(card_info) || questline?(card_info) -> :"Quest Paladin"
      dude_paladin?(card_info) -> :"Dude Paladin"
      handbuff_paladin?(card_info) -> :"Handbuff Paladin"
      mech_paladin?(card_info) -> :"Mech Paladin"
      earthen_paladin?(card_info) -> :"Gaia Paladin"
      holy_paladin?(card_info) -> :"Holy Paladin"
      kazakusan?(card_info) -> :"Kazakusan Paladin"
      big_paladin?(card_info) -> :"Big Paladin"
      order_luladin?(card_info) -> :"Order LULadin"
      vanndar?(card_info) -> :"Vanndar Paladin"
      murloc?(card_info) -> :"Murloc Paladin"
      boar?(card_info) -> :"Boar Paladin"
      oathbreaker_paladin?(card_info) -> :"Oathbreaker Paladin"
      true -> fallbacks(card_info, "Paladin")
    end
  end

  defp oathbreaker_paladin?(card_info) do
    min_count?(card_info, 1, ["Tour Guide", "Hawkstrider Rancher", "Magatha, Bane of Music"])
  end

  defp aggro_paladin?(card_info) do
    min_count?(card_info, 5, [
      "For Quel'Thalas!",
      "Seal of Blood",
      "Blessing of Kings",
      "Sunwing Squawker",
      "Foul Egg",
      "Sanguine Soldier",
      "Blood Matriarch Liadrin",
      "Gold Panner",
      "Crusader Aura",
      "Sinstone Totem",
      "Crooked Cook",
      "Sea Giant",
      "Buffet Biggun",
      "Nerubian Egg",
      "Righteous Protector"
    ])
  end

  def archetype(%{format: 2, cards: c, class: "PRIEST"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander Priest"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Priest"

      boar?(card_info) ->
        :"Boar Priest"

      menagerie?(card_info) ->
        :"Menagerie Priest"

      naga_priest?(card_info) ->
        :"Naga Priest"

      boon_priest?(card_info) ->
        :"Boon Priest"

      shellfish_priest?(card_info) ->
        :"Shellfish Priest"

      vanndar?(card_info) && shadow_priest?(card_info) ->
        :"Vanndar Shadow Priest"

      vanndar?(card_info) ->
        :"Vanndar Priest"

      control_priest?(card_info) ->
        :"Control Priest"

      thief_priest?(card_info) ->
        :"Thief Priest"

      automaton_priest?(card_info) ->
        :"Automaton Priest"

      shadow_priest?(card_info) ->
        :"Shaggro Priest"

      rager_priest?(card_info) ->
        :"Rager Priest"

      overheal_priest?(card_info) ->
        :"Overheal Priest"

      svalna_priest?(card_info) ->
        :"Svalna Priest"

      shadow_priest?(card_info) ->
        :"Shadow Priest"

      "Photographer Fizzle" in card_info.card_names ->
        :"Fizzle Priest"

      "Pip the Potent" in card_info.card_names ->
        :"Pip Priest"

      murloc?(card_info) ->
        :"Murloc Priest"

      true ->
        fallbacks(card_info, "Priest")
    end
  end

  @type fallbacks_opt :: minion_type_fallback_opt()
  @spec fallbacks(card_info(), String.t(), fallbacks_opt()) :: String.t()
  defp fallbacks(ci, class_name, opts \\ []) do
    cond do
      miracle_chad?(ci) -> "Miracle Chad #{class_name}"
      "Rivendare, Warrider" in ci.card_names -> "Rivendare #{class_name}"
      tentacle(ci) -> "Tentacle #{class_name}"
      "Gadgetzan Auctioneer" in ci.card_names -> "Miracle #{class_name}"
      ogre?(ci) -> "Ogre #{class_name}"
      true -> minion_type_fallback(ci, class_name, opts)
    end
  end

  defp tentacle(ci), do: "Chaotic Tendril" in ci.card_names

  defp miracle_chad?(ci), do: min_count?(ci, 2, ["Thaddius, Monstrosity", "Cover Artist"])

  defp yogg_priest?(ci) do
    "Yogg Saron, Unleashed" in ci.card_names and min_count?(ci, 2, "Yogg Saron, Unleashed")
  end

  defp automaton_priest?(ci),
    do:
      "Astral Automaton" in ci.card_names and
        min_count?(ci, 3, [
          "Celestial Projectionist",
          "Creation Protocol",
          "Ra-den",
          "Power Chord: Synchronize",
          "Zola the Gordon",
          "Creepy Painting",
          "Ravenous Kraken",
          "Cover Artist"
        ])

  defp overheal_priest?(ci) do
    min_count?(ci, 3, [
      "Crimson Clergy",
      "Funnel Cake",
      "Dreamboat",
      "Holy Champion",
      "Mana Geode",
      "Heartthrob",
      "Ambient Lightspawn",
      "Heartbreaker Hedanis"
    ])
  end

  defp svalna_priest?(card_info),
    do: min_count?(card_info, 3, ["Radiant Elemental", "Animate Dead", "Sister Svalna"])

  defp rager_priest?(card_info),
    do:
      "Scourge Rager" in card_info.card_names and
        min_count?(card_info, 2, ["Animate Dead", "Grave Digging", "High Cultist Basaleph"])

  def archetype(%{format: 2, cards: c, class: "ROGUE"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander Rogue"

      coc_rogue?(card_info) && (quest?(card_info) || questline?(card_info)) ->
        :"Quest Coc Rogue"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Rogue"

      menagerie?(card_info) ->
        :"Menagerie Rogue"

      mech_rogue?(card_info) ->
        :"Mech Rogue"

      miracle_rogue?(card_info) ->
        :"Miracle Rogue"

      coin_rogue?(card_info) and secret_rogue?(card_info) ->
        :"Secret Coin Rogue"

      coin_rogue?(card_info) ->
        :"Coin Rogue"

      ogre?(card_info) ->
        :"Ogre Rogue"

      excavate_rogue?(card_info) ->
        :"Drilling Rogue"

      mine_rogue?(card_info) ->
        :"Mine Rogue"

      pirate_rogue?(card_info) && thief_rogue?(card_info) ->
        :"Pirate Thief Rogue:"

      jackpot_rogue?(card_info) ->
        :"Jackpot Rogue"

      edwin_rogue?(card_info) ->
        :"Edwin Rogue"

      thief_rogue?(card_info) ->
        :"Thief Rogue"

      boar?(card_info) ->
        :"Boar Rogue"

      pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      vanndar?(card_info) ->
        :"Vanndar Rogue"

      secret_rogue?(card_info) ->
        :"Secret Rogue"

      shark_rogue?(card_info) ->
        :"Shark Rogue"

      deathrattle_rogue?(card_info) ->
        :"Deathrattle Rogue"

      min_secret_count?(card_info, 3) ->
        :"Secret Rogue"

      miracle_rogue?(card_info) ->
        :"Miracle Rogue"

      coc_rogue?(card_info) ->
        :"Coc Rogue"

      true ->
        fallbacks(card_info, "Rogue")
    end
  end

  defp excavate_rogue?(ci) do
    min_count?(ci, 3, [
      "Antique Flinger",
      "Drilly the Kid",
      "Bloodrock Co Shovel",
      "Bloodrock Co. Shovel" | @neutral_excavate
    ])
  end

  defp coin_rogue?(ci) do
    "Wishing Well" in ci.card_names and
      min_count?(ci, 2, ["Dart Throw", "Greedy Partner", "Bounty Wrangler"])
  end

  defp miracle_rogue?(ci),
    do:
      miracle_wincon?(ci) &&
        min_count?(ci, 2, ["Queen Azshara", "Preparation", "Serrated Bone Spike"])

  defp mech_rogue?(ci), do: type_count(ci, "Mech") > 5

  def archetype(%{format: 2, cards: c, class: "SHAMAN"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) -> :"Highlander Shaman"
      quest?(card_info) || questline?(card_info) -> :"Quest Shaman"
      boar?(card_info) -> :"Boar Shaman"
      vanndar?(card_info) -> :"Vanndar Shaman"
      menagerie?(card_info) -> :"Menagerie Shaman"
      "Barbaric Sorceress" in card_info.card_names -> :"Big Spell Shaman"
      aggro_shaman?(card_info) -> :"Aggro Shaman"
      big_bone_shaman?(card_info) -> :"Big Bone Shaman"
      totem_shaman?(card_info) -> :"Totem Shaman"
      elemental_shaman?(card_info) -> :"Elemental Shaman"
      nature_shaman?(card_info) -> :"Nature Shaman"
      overload_shaman?(card_info) -> :"Overload Shaman"
      evolve_shaman?(card_info) -> :"Evolve Shaman"
      burn_shaman?(card_info) -> :"Burn Shaman"
      moist_shaman?(card_info) -> :"Moist Shaman"
      control_shaman?(card_info) -> :"Control Shaman"
      murloc?(card_info) -> :"Murloc Shaman"
      bloodlust_shaman?(card_info) -> :"Bloodlust Shaman"
      "From De Other Side" in card_info.card_names -> "FDOS Shaman"
      true -> fallbacks(card_info, "Shaman")
    end
  end

  defp totem_shaman?(ci) do
    min_count?(ci, 2, ["Gigantotem", "Grand Totem Eys'or", "The Stonewright"])
  end

  defp nature_shaman?(ci),
    do:
      min_count?(ci, 2, [
        "Flash of Lightning",
        "Crash of Thunder",
        "Champion of Storms"
      ])

  defp big_bone_shaman?(ci),
    do:
      "Bonelord Frostwhisper" in ci.card_names and
        min_count?(ci, 2, ["Al'Akir the Windlord", "Prescience", "Criminal Lineup"])

  defp aggro_shaman?(ci),
    do:
      min_count?(ci, 3, [
        "Hawkstrider Rancher",
        "Irondeep Trogg",
        "Rotgill",
        "Sourge Troll",
        "Incorporeal Corporal"
      ])

  def archetype(%{format: 2, cards: c, class: "WARLOCK"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        :"Highlander Warlock"

      implock?(card_info) && (quest?(card_info) || questline?(card_info)) ->
        :"Quest Implock"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Warlock"

      menagerie?(card_info) ->
        :"Menagerie Warlock"

      murloc?(card_info) ->
        :"Murloc Warlock"

      implock?(card_info) && boar?(card_info) ->
        :"Boar Implock"

      boar?(card_info) ->
        :"Boar Warlock"

      implock?(card_info) && phylactery_warlock?(card_info) ->
        :"Phylactery Implock"

      phylactery_warlock?(card_info) ->
        :"Phylactery Warlock"

      snek?(card_info) && neutral_bouncers?(card_info) ->
        :"Snek Warlock"

      implock?(card_info) && abyssal_warlock?(card_info) && chad?(card_info) ->
        :"Abyssal Chimplock"

      implock?(card_info) && chad?(card_info) ->
        :Chimplock

      implock?(card_info) && handlock?(card_info) ->
        :"Hand Implock"

      handlock?(card_info) ->
        :Handlock

      implock?(card_info) && agony_warlock?(card_info) ->
        :"Agony Implock"

      agony_warlock?(card_info) ->
        :"Agony Warlock"

      abyssal_warlock?(card_info) && chad?(card_info) ->
        :"Abyssal Chadlock"

      implock?(card_info) && abyssal_warlock?(card_info) ->
        :"Abyssal Implock"

      chad?(card_info) ->
        :Chadlock

      abyssal_warlock?(card_info) ->
        :"Abyssal Warlock"

      implock?(card_info) ->
        :Implock

      sludgelock?(card_info) ->
        :"Sludge Warlock"

      snek?(card_info) ->
        :"Snek Warlock"

      control_warlock?(card_info) ->
        :"Control Warlock"

      insanity_warlock?(card_info) ->
        :"Insanity Warlock"

      "Lord Jaraxxus" in card_info.card_names ->
        :"J-Lock"

      true ->
        fallbacks(card_info, "Warlock")
    end
  end

  defp neutral_bouncers?(ci, min_count \\ 2) do
    min_count?(ci, min_count, ["Youthful Brewmaster", "Saloon Brewmaster", "Zola the Gorgon"])
  end

  defp sludgelock?(ci) do
    min_count?(ci, 3, [
      "Tram Mechanic",
      "Disposal Assistant",
      "Sludge on Wheels",
      "Pop'gar the Putrid"
    ])
  end

  defp insanity_warlock?(ci) do
    min_count?(ci, 2, ["Lady Darkvein", "Encroaching Insanity"])
  end

  defp control_warlock?(ci) do
    min_count?(ci, 5, [
      "Sargeras, the Destroyer",
      "Symphony of Sins",
      "Defile",
      "Drain Soul",
      "Mortal Eradication",
      "Thornveil Tentacle",
      "Armor Vendor",
      "Prison of Yogg-Saron",
      "Gigafin"
    ])
  end

  defp chad?(ci) do
    min_count?(ci, 2, ["Amorphous Slime", "Thaddius, Monstrosity"])
  end

  def archetype(%{format: 2, cards: c, class: "WARRIOR"}) do
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) -> :"Highlander Warrior"
      questline?(card_info) && warrior_aoe?(card_info) -> :"Quest Control Warrior"
      quest?(card_info) || questline?(card_info) -> :"Quest Warrior"
      galvangar_combo?(card_info) -> :"Charge Warrior"
      n_roll?(card_info) && menagerie_warrior?(card_info) -> :"Menagerie 'n' Roll"
      n_roll?(card_info) && enrage?(card_info) -> :"Enrage 'n' Roll"
      menagerie_warrior?(card_info) -> :"Menagerie Warrior"
      enrage?(card_info) -> :"Enrage Warrior"
      n_roll?(card_info) -> :"Rock 'n' Roll Warrior"
      warrior_aoe?(card_info) -> :"Control Warrior"
      "Odyn, Prime Designate" in card_info.card_names -> :"Odyn Warrior"
      excavate_warrior?(card_info) -> :"Excavate Warrior"
      riff_warrior?(card_info) -> :"Riff Warrior"
      weapon_warrior?(card_info) -> :"Weapon Warrior"
      murloc?(card_info) -> :"Murloc Warrior"
      boar?(card_info) -> :"Boar Warrior"
      true -> fallbacks(card_info, "Warrior")
    end
  end

  defp excavate_warrior?(ci),
    do:
      min_count?(ci, 3, [
        "Blast Charge",
        "Reinforced Plating",
        "Slagmaw the Slumbering",
        "Badlands Brawler" | @neutral_excavate
      ])

  defp riff_warrior?(ci), do: min_count?(ci, 3, ["Verse Riff", "Chorus Riff", "Bridge Riff"])
  defp n_roll?(card_info), do: "Blackrock 'n' Roll" in card_info.card_names

  defp menagerie_warrior?(card_info) do
    min_count?(card_info, 3, [
      "Roaring Applause",
      "Party Animal",
      "The One-Amalgam Band",
      "Rock Master Voone",
      "Power Slider"
    ])
  end

  def archetype(%{class: class, cards: c, format: 4}) do
    class_name = Deck.class_name(class)
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        String.to_atom("Highlander #{class_name}")

      quest?(card_info) || questline?(card_info) ->
        String.to_atom("Quest #{class_name}")

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      # DEMON HUNTER
      outcast_dh?(card_info) ->
        :"Outcast DH"

      # DRUID
      "Linecracker" in card_info.card_names && class_name == "Druid" ->
        :"Linecracker Druid"

      # HUNTER
      big_beast_hunter?(card_info) ->
        :"Big Beast Hunter"

      # MAGE
      ping_mage?(card_info) ->
        :"Ping Mage"

      "Mozaki, Master Duelist" in card_info.card_names ->
        :"Mozaki Mage"

      haleh_mage?(card_info) ->
        :"Haleh Mage"

      spell_mage?(card_info) ->
        :"Spell Mage"

      # PALADIN
      libram_paladin?(card_info) ->
        :"Libram Paladin"

      # PRIEST
      miracle_priest?(card_info) ->
        :"Miracle Priest"

      # ROGUE
      "Kingsbane" in card_info.card_names ->
        :"Kingsbane Rogue"

      weapon_rogue?(card_info) ->
        :"Weapon Rogue"

      # SHAMAN
      "Shudderwock" in card_info.card_names ->
        :"Shudderwock Shaman"

      # WARLOCK
      phylactery_warlock?(card_info) ->
        :"Phylactery Warlock"

      fatigue_warlock?(card_info) ->
        :"Fatigue Warlock"

      # FALLBACK to standard
      vanndar?(card_info) ->
        String.to_atom("Vanndar #{class_name}")

      true ->
        archetype(%{class: class, cards: c, format: 2})
    end
  end

  defp snek?(ci) do
    min_count?(ci, 4, [
      "Smokestack",
      "Mo'arg Drillfist",
      "Tram Conductor Gerry" | @neutral_excavate
    ])
  end

  defp weapon_rogue?(card_info) do
    "Swinetusk Shank" in card_info.card_names &&
      min_count?(card_info, 3, [
        "Deadly Poison",
        "Paralytic Poison",
        "Silverleaf Poison",
        "Harmonic Hip Hop",
        "Mic Drop",
        "Cutting Class",
        "Nitroboost Poison"
      ])
  end

  defp haleh_mage?(card_info) do
    min_count?(card_info, 2, ["Hot Streak", "Haleh, Matron Protectorate", "Drakefire Amulet"])
  end

  defp spell_mage?(card_info) do
    min_count?(card_info, 3, [
      "Deck of Lunacy",
      "Incanter's Flow",
      "Refreshing Spring Water"
    ])
  end

  defp fatigue_warlock?(card_info) do
    min_count?(
      card_info,
      5,
      [
        "Altar of Fire",
        "Blood Shard Bristleback",
        "Soul Rend",
        "Neeru Fireblade",
        "Barrens Scavenger",
        "Tickatus",
        "Fanottem, Lord of the Opera"
      ]
    )
  end

  defp miracle_priest?(card_info) do
    min_count?(card_info, 5, [
      "Gift of Luminance",
      "Nazmani Bloodweaver",
      "Switcheroo",
      "Psyche Split",
      "Power Word: Fortitude"
    ])
  end

  defp ping_mage?(card_info) do
    min_count?(card_info, 4, [
      "Wildfire",
      "Reckless Apprentice",
      "Magister Dawngrasp",
      "Mordresh Fire Eye"
    ])
  end

  defp libram_paladin?(card_info) do
    min_count?(card_info, 5, [
      "Aldor Attendant",
      "Libram of Wisdom",
      "Libram of Justice",
      "Aldor Truthseeker",
      "Libram of Judgment",
      "Libram of Hope"
    ])
  end

  def archetype(%{class: class, cards: c, format: 1}) do
    class_name = Deck.class_name(class)
    card_info = full_cards(c)

    cond do
      highlander?(card_info, c) ->
        String.to_atom("Highlander #{class_name}")

      quest?(card_info) || questline?(card_info) ->
        String.to_atom("Quest #{class_name}")

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      odd?(card_info) ->
        String.to_atom("Odd #{class_name}")

      even?(card_info) ->
        String.to_atom("Even #{class_name}")

      pure_paladin?(card_info) ->
        :"Pure Paladin"

      "Kingsbane" in card_info.card_names ->
        :"Kingsbane Rogue"

      "Shudderwock" in card_info.card_names ->
        :"Shudderwock Shaman"

      "King Togwaggle" in card_info.card_names ->
        String.to_atom("Tog #{class_name}")

      "Linecracker" in card_info.card_names && class_name == "Druid" ->
        :"Linecracker Druid"

      min_secret_count?(card_info, 4) ->
        String.to_atom("Secret #{class_name}")

      outcast_dh?(card_info) ->
        :"Outcast DH"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  def archetype(_), do: nil

  defp deathrattle_dh?(%{card_names: card_names}),
    do:
      "Death Speaker Blackthorn" in card_names ||
        ("Tuskpiercier" in card_names && "Razorboar" in card_names)

  defp aggro_dh?(ci) do
    min_count?(ci, 4, [
      "Irondeep Trogg",
      "Bibliomite",
      "Mankrik",
      "Sightless Magistrate",
      "Battlefiend",
      "Metamorfin",
      "Magnifying Glaive"
    ])
  end

  defp relic_dh?(ci) do
    min_count?(ci, 4, [
      "Relic of Extinction",
      "Relic Vault",
      "Relic of Phantasms",
      "Relic of Dimensions",
      "Artificer Xy'mox"
    ])
  end

  defp fel_dh?(ci) do
    min_count?(ci, 4, [
      "Fury (Rank 1)",
      "Chaos Strike",
      "Fel Barrage",
      "Predation",
      "Multi Strike"
    ]) &&
      min_count?(ci, 1, [
        "Fossil Fanatic",
        "Jace Darkweaver",
        "Felgorger"
      ])
  end

  defp big_dh?(ci = %{card_names: card_names}),
    do:
      "Sigil of Reckoning" in card_names || vanndar?(ci) ||
        min_count?(ci, 2, ["Felscale Evoker", "Illidari Inquisitor", "Brutal Annihilan"])

  defp clean_slate_dh?(ci),
    do:
      min_count?(ci, 4, [
        "Dispose of Evidence",
        "Magnifying Glaive",
        "Kryxis the Voracious",
        "Bibliomite"
      ])

  defp relic?(ci),
    do:
      min_count?(ci, 4, [
        "Relic of Extinction",
        "Relic of Phantasms",
        "Relic Vault",
        "Relic Of Dimensions",
        "Artificer Xy'mox"
      ])

  def prepend_relic(name, ci) do
    if relic?(ci) do
      "Relic " <> to_string(name)
    else
      name
    end
  end

  defp celestial_druid?(%{card_names: card_names}), do: "Celestial Alignment" in card_names

  defp fire_druid?(ci) do
    min_count?(ci, 2, [
      "Pyrotechnician",
      "Thaddius, Monstrosity"
    ])
  end

  defp chad_druid?(ci) do
    min_count?(ci, 2, [
      "Flesh Behemoth",
      "Thaddius, Monstrosity"
    ])
  end

  defp big_druid?(ci),
    do:
      min_count?(ci, 3, [
        "Sessellie of the Fae Court",
        "Neptulon the Tidehunter",
        "Masked Reveler",
        "Stoneborn General"
      ])

  defp ramp_druid?(ci = %{card_names: card_names}),
    do: "Nourish" in card_names or min_count?(ci, 2, ["Wild Growth", "Widowbloom Seedsman"])

  defp hero_power_druid?(ci),
    do: min_count?(ci, 2, ["Free Spirit", "Groovy Cat"])

  defp aggro_druid?(ci),
    do:
      min_count?(ci, 3, [
        "Herald of Nature",
        "Lingering Zombie",
        "Vicious Slitherspear",
        "Mark of the Wild",
        "Soul of the Forest",
        "Blood Treant",
        "Elder Nadox"
      ])

  defp cleave_hunter?(card_info) do
    min_count?(card_info, 3, ["Hollow Hound", "Stonebound Gargon", "Always a Bigger Jormungar"]) &&
      min_count?(card_info, 2, [
        "Absorbent Parasite",
        "Beastial Madness",
        "Messenger Buzzard",
        "Hope of Quel'Thalas"
      ])
  end

  defp arcane_hunter?(card_info),
    do:
      min_count?(card_info, 2, ["Halduron Brightwing", "Silvermoon Farstrider", "Arcane Quiver"]) &&
        min_spell_school_count?(card_info, 4, "arcane")

  defp rat_hunter?(ci),
    do:
      min_count?(ci, 4, [
        "Leartherworking Kit",
        "Rodent Nest",
        "Sin'dorei Scentfinder",
        "Defias Blastfisher",
        "Shadehound",
        "Rats of Extraordinary Size"
      ])

  defp big_beast_hunter?(ci),
    do:
      min_count?(ci, 2, ["King Krush", "Stranglehorn Heart", "Faithful Companions", "Banjosaur"])

  defp beast_hunter?(ci),
    do:
      min_count?(ci, 2, [
        "Harpoon Gun",
        "Selective Breeder",
        "Stormpike Battle Ram",
        "Azsharan Saber",
        "Revive Pet",
        "Pet Collector"
      ])

  defp aggro_hunter?(ci),
    do:
      min_count?(ci, 2, [
        "Doggie Biscuit",
        "Bunch of Bananas",
        "Vicious Slitherspear",
        "Ancient Krakenbane",
        "Arrow Smith",
        "Raj Naz'jan"
      ])

  def wildseed_hunter?(ci),
    do: min_count?(ci, 3, ["Spirit Poacher", "Stag Charge", "Wild Spirits", "Ara'lon"])

  defp pirate_rogue?(ci),
    do: min_count?(ci, 1, ["Swordfish", "Pirate Admiral Hooktusk"])

  defp edwin_rogue?(ci),
    do:
      min_count?(ci, 7, [
        "Preparation",
        "Shadowstep",
        "Door of Shadows",
        "Maestra of the Masquerade",
        "Serrated Bone Spike",
        "Sinstone Graveyard",
        "Shroud of Concealment",
        "Necrolord Draka"
      ])

  defp jackpot_rogue?(ci),
    do:
      thief_rogue?(ci) &&
        min_count?(ci, 2, [
          "Jackpot!",
          "Swiftscale Trickster"
        ])

  defp thief_rogue?(ci = %{card_names: card_names}),
    do:
      "Maestra of the Masquerade" in card_names ||
        min_count?(ci, 3, [
          "Tess Greymane",
          "Mixtape",
          "Hipster",
          "Plagiarizarrr",
          "Jackpot!",
          "Kaja'mite Creation",
          "Hench-Clan Burglar",
          "Sketchy Stranger",
          "Invitation Courier",
          "Swashburglar",
          "Ransack",
          "Murloc Holmes",
          "Plagiarize"
        ])

  defp miracle_wincon?(ci), do: min_count?(ci, 1, ["Sinstone Graveyard", "Necrolord Draka"])

  defp coc_rogue?(ci),
    do:
      min_count?(ci, 3, [
        "Concoctor",
        "Ghoulish Alchemist",
        "Potion Belt",
        "Potionmaster Putricide",
        "Vile Apothecary"
      ])

  defp mine_rogue?(ci),
    do: min_count?(ci, 2, ["Naval Mine", "Snowfall Graveyard"])

  defp secret_rogue?(ci),
    do:
      min_secret_count?(ci, 3) &&
        min_count?(ci, 2, [
          "Ghastly Gravedigger",
          "Halkias",
          "Private Eye",
          "Anonymous Informant",
          "Sketchy Stranger",
          "Sunreaver Spy",
          "Crossroads Gossiper",
          "Scuttlebutt Ghoul"
        ])

  defp shark_rogue?(ci),
    do: "Loan Shark" in ci.card_names && miracle_wincon?(ci)

  defp deathrattle_rogue?(%{card_names: card_names}), do: "Snowfall Graveyard" in card_names

  defp frost_mage?(ci) do
    case spell_school_map(ci) |> Map.to_list() do
      # only frost
      [{"frost", _}] -> true
      _ -> false
    end
  end

  defp skeleton_mage?(ci),
    do:
      min_count?(ci, 4, [
        "Volatile Skeleton",
        "Nightcloak Sanctum",
        "Cold Case",
        "Deathborne",
        "Kel'Thuzad, the Inevitable"
      ])

  defp secret_mage?(ci),
    do:
      min_count?(ci, 2, [
        "Anonymous Informant",
        "Chatty Bartender",
        "Orion, Mansion Manager",
        "Sunreaver Spy",
        "Crossroads Gossiper",
        "Scuttlebutt Ghoul"
      ]) ||
        min_secret_count?(ci, 3)

  defp naga_mage?(%{card_names: card_names}), do: "Spitelash Siren" in card_names
  defp mech_mage?(%{card_names: card_names}), do: "Mecha-Shark" in card_names
  defp ping_mage?(%{card_names: card_names}), do: "Wildfire" in card_names

  defp big_spell_mage?(ci = %{card_names: card_names}),
    do:
      !mech_mage?(ci) && "Grey Sage Parrot" in card_names &&
        min_count?(ci, 1, ["Rune of the Archmage", "Drakefire Amulet"])

  defp pure_paladin?(%{full_cards: full_cards}), do: !Enum.any?(full_cards, &not_paladin?/1)

  defp not_paladin?(card) do
    case Card.class(card, "PALADIN") do
      {:ok, "PALADIN"} -> false
      _ -> true
    end
  end

  defp mech_paladin?(%{card_names: card_names}), do: "Radar Detector" in card_names

  defp order_luladin?(ci = %{card_names: card_names}),
    do:
      "Order in the Court" in card_names &&
        min_count?(ci, 2, ["The Jailer", "Reno Jackson", "The Countess"])

  defp big_paladin?(ci),
    do:
      min_count?(ci, 1, ["Front Lines", "Kangor, Dancing King", "Lead Dancer"]) &&
        min_count?(ci, 2, [
          "Ragnaros the Firelord",
          "Annoy-o-Troupe",
          "Tirion Fordring",
          "Stoneborn General",
          "Neptulon the Tidehunter",
          "Flesh Behemoth",
          "Thaddius, Monstrosity"
        ])

  defp holy_paladin?(ci = %{card_names: card_names}),
    do:
      "The Garden's Grace" in card_names &&
        min_count?(ci, 1, ["Righteous Defense", "Battle Vicar", "Knight of Anointment"])

  defp handbuff_paladin?(%{card_names: card_names}),
    do:
      "Prismatic Jewel Kit" in card_names &&
        ("First Blade of Wyrnn" in card_names || "Overlord Runthak" in card_names)

  defp earthen_paladin?(ci),
    do: min_count?(ci, 2, ["Stoneheart King", "Disciple of Amitus"])

  defp dude_paladin?(ci),
    do:
      min_count?(ci, 3, [
        "Jury Duty",
        "Promotion",
        "Soldier's Caravan",
        "Stewart the Steward",
        "Muster for Battle",
        "Lothraxion the Redeemed",
        "Jukebox Totem",
        "Warhorse Trainer",
        "Stand Against Darkness"
      ])

  defp shellfish_priest?(%{card_names: card_names}),
    do: "Selfish Shellfish" in card_names && "Xyrella, the Devout" in card_names

  defp boon_priest?(ci = %{card_names: card_names}) do
    min_count?(ci, 5, [
      "Radiant Elemental",
      "Switcheroo",
      "Boon of the Ascended",
      "Bless",
      "Power Word: Fortitude",
      "Focused Will",
      "Illuminate"
    ]) && type_count(ci, "Naga") < 5
  end

  defp naga_priest?(ci = %{card_names: card_names}) do
    "Serpent Wig" in card_names && type_count(ci, "Naga") >= 5
  end

  defp shadow_priest?(%{card_names: card_names}), do: "Darkbishop Benedictus" in card_names

  defp control_priest?(ci) do
    min_count?(ci, 2, ["Harmonic Pop", "Clean the Scene", "Whirlpool"])
  end

  defp thief_priest?(ci),
    do:
      min_count?(
        ci,
        5,
        [
          "Psychic Conjurer",
          "Mysterious Visitor",
          "Soothsayer's Caravan",
          "Copycat",
          "Identity Theft",
          "Murloc Holmes",
          "The Harvester of Envy"
        ]
      )

  defp burn_shaman?(ci),
    do:
      min_count?(ci, 3, [
        "Frostbite",
        "Lightning Bolt",
        "Scalding Geyser",
        "Bioluminescence"
      ])

  defp overload_shaman?(ci),
    do: min_count?(ci, 2, ["Flowrider", "Overdraft", "Inzah"])

  defp evolve_shaman?(ci),
    do:
      min_count?(ci, 3, [
        "Convincing Disguise",
        "Muck Pools",
        "Primordial Wave",
        "Baroness Vashj",
        "Tiny Toys"
      ])

  defp moist_shaman?(ci = %{card_names: card_names}),
    do:
      "Schooling" in card_names &&
        min_count?(ci, 4, [
          "Amalgam of the Deep",
          "Clownfish",
          "Cookie the Cook",
          "Gorloc Ravager",
          "Mutanus the Devourer"
        ])

  defp control_shaman?(ci),
    do:
      !burn_shaman?(ci) &&
        min_count?(ci, 4, [
          "Bolner Hammerbeak",
          "Brann Bronzebeard",
          "Bru'kan of the Elements",
          "Mutanus the Devourer",
          "Chain Lightning (Rank 1)",
          "Maelstrom Portal"
        ])

  defp elemental_shaman?(ci),
    do:
      min_count?(ci, 4, [
        "Kindling Elemental",
        "Wailing Vapor",
        "Menacing Nimbus",
        "Arid Stormer",
        "Canal Slogger",
        "Earth Revenant",
        "Granite Forgeborn",
        "Lilypad Lurker",
        "Fire Elemental",
        "Al'Akir the Windlord",
        "Tar Creeper"
      ])

  defp bloodlust_shaman?(%{card_names: card_names}), do: "Bloodlust" in card_names

  defp implock?(ci),
    do:
      min_count?(ci, 6, [
        "Flame Imp",
        "Flustered Librarian",
        "Bloodbound Imp",
        "Imp Swarm (Rank 1)",
        "Impending Catastrophe",
        "Fiendish Circle",
        "Imp Gang Boss",
        "Piggyback Imp",
        "Mischievous Imp",
        "Imp King Rafaam"
      ])

  defp phylactery_warlock?(%{card_names: card_names}),
    do: "Tamsin's Phylactery" in card_names && "Tamsin Roame" in card_names

  defp abyssal_warlock?(ci),
    do: min_count?(ci, 3, ["Dragged Below", "Sira'kess Cultist", "Za'qul", "Abyssal Wave"])

  defp agony_warlock?(%{card_names: card_names}), do: "Curse of Agony" in card_names

  defp handlock?(ci),
    do: min_count?(ci, 2, ["Anetheron", "Dark Alley Pact", "Entitled Customer", "Twilight Drake"])

  defp enrage?(ci) do
    min_count?(ci, 5, [
      "Sanguine Depths",
      "Warsong Envoy",
      "Whirlwind",
      "Anima Extractor",
      "Crazed Wretch",
      "Cruel Taskmaster",
      "Frothing Berserker",
      "Sunfury Champion",
      "Jam Session",
      "Imbued Axe",
      "Grommash Hellscream"
    ])
  end

  defp galvangar_combo?(ci, min_count \\ 4),
    do:
      min_count?(ci, min_count, [
        "Captain Galvangar",
        "Faceless Manipulator",
        "Battleground Battlemaster",
        "To the Front!"
      ])

  defp warrior_aoe?(ci, min_count \\ 2),
    do: min_count?(ci, min_count, ["Shield Shatter", "Brawl", "Rancor", "Man the Cannons"])

  defp weapon_warrior?(ci),
    do:
      min_count?(ci, 3, [
        "Azsharan Trident",
        "Outrider's Axe",
        "Blacksmithing Hammer",
        "Lady Ashvane"
      ])

  defp murloc?(ci),
    do:
      min_count?(ci, 4, [
        "Murloc Tinyfin",
        "Murloc Tidecaller",
        "Lushwater Scout",
        "Lushwater Mercenary",
        "Murloc Tidehunter",
        "Coldlight Seer",
        "Murloc Warleader",
        "Twin-fin Fin Twin",
        "Gorloc Ravager"
      ])

  defp min_count?(%{card_names: cn}, min, cards) do
    min <= cards |> Enum.filter(&(&1 in cn)) |> Enum.count()
  end

  defp min_keyword_count?(%{full_cards: full_cards}, min, keyword_slug) do
    num =
      full_cards
      |> Enum.filter(&Card.has_keyword?(&1, keyword_slug))
      |> Enum.count()

    num >= min
  end

  defp min_spell_school_count?(ci, min, spell_school) do
    num =
      ci
      |> spell_school_map()
      |> Map.get(spell_school, 0)

    num >= min
  end

  defp spell_school_map(%{full_cards: full_cards}) do
    full_cards
    |> Enum.flat_map(&Card.spell_schools/1)
    |> Enum.frequencies()
  end

  defp ogre?(ci) do
    # Stupid API has one in the picture and one in the api
    min_count?(ci, 2, [
      "Ogre Gang Outlaw",
      "Ogre-Gang Outlaw",
      "Ogre Gang Rider",
      "Ogre-Gang Rider",
      "Ogre-Gang Ace",
      "Ogre Gang Ace"
    ]) and "Kingpin Pud" in ci.card_names
  end

  defp menagerie?(%{card_names: card_names}), do: "The One-Amalgam Band" in card_names
  defp boar?(%{card_names: card_names}), do: "Elwynn Boar" in card_names
  defp kazakusan?(%{card_names: card_names}), do: "Kazakusan" in card_names

  defp highlander?(card_info, cards) do
    num_dupl = num_duplicates(cards)
    num_dupl == 0 or (num_dupl < 4 and highlander_payoff?(card_info))
  end

  defp num_duplicates(cards) do
    cards
    |> Enum.frequencies()
    |> Enum.filter(fn {_, count} -> count > 1 end)
    |> Enum.count()
  end

  defp vanndar?(%{card_names: card_names}), do: "Vanndar Stormpike" in card_names
  defp quest?(%{full_cards: full_cards}), do: Enum.any?(full_cards, &Card.quest?/1)
  defp questline?(%{full_cards: full_cards}), do: Enum.any?(full_cards, &Card.questline?/1)

  defp highlander_payoff?(%{full_cards: full_cards}),
    do: Enum.any?(full_cards, &Card.highlander?/1)

  defp odd?(%{card_names: card_names}), do: "Baku the Mooneater" in card_names
  defp even?(%{card_names: card_names}), do: "Genn Greymane" in card_names

  @type minion_type_fallback_opt ::
          {:fallback, String.t() | nil} | {:min_count, number()} | {:ignore_types, [String.t()]}
  @spec minion_type_fallback(card_info(), String.t(), [minion_type_fallback_opt()]) :: String.t()
  defp minion_type_fallback(
         ci,
         class_part,
         opts \\ [fallback: nil, min_count: 6, ignore_types: []]
       ) do
    fallback = Keyword.get(opts, :fallback, nil)
    min_count = Keyword.get(opts, :min_count, 6)
    ignore_types = Keyword.get(opts, :ignore_types, [])

    with counts = [_ | _] <- minion_type_counts(ci),
         filtered <- Enum.reject(counts, &(to_string(elem(&1, 0)) in ignore_types)),
         {type, count} when count >= min_count <- Enum.max_by(counts, &elem(&1, 1)) do
      "#{type} #{class_part}"
    else
      _ -> fallback
    end
  end

  defp min_secret_count?(%{full_cards: fc}, min) do
    secret_count =
      fc
      |> Enum.uniq_by(&Card.dbf_id/1)
      |> Enum.count(&Card.secret?/1)

    min <= secret_count
  end

  @spec full_cards([integer()]) :: card_info()
  defp full_cards(cards) do
    {full_cards, card_names} =
      Enum.map(cards, fn c ->
        with card = %{name: name} <- Backend.Hearthstone.get_card(c) do
          {card, name}
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.unzip()

    %{full_cards: full_cards, card_names: card_names}
  end

  @spec minion_type_counts(card_info()) :: [{String.t(), integer()}]
  defp minion_type_counts(%{full_cards: fc}) do
    base_counts =
      fc
      |> Enum.uniq_by(&Card.dbf_id/1)
      |> Enum.flat_map(fn
        %{minion_type: %{name: name}} -> [name]
        _ -> []
      end)
      |> Enum.frequencies()

    {all_count, without_all} = Map.pop(base_counts, "All", 0)

    without_all
    |> Enum.map(fn {key, val} -> {key, val + all_count} end)
  end

  @spec type_count(card_info(), String.t()) :: integer()
  defp type_count(card_info, type) do
    card_info
    |> minion_type_counts()
    |> List.keyfind(type, 0, {type, 0})
    |> elem(1)
  end
end
