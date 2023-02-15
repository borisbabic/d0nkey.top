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

  def archetype(%{format: 2, cards: c, class: "DEATHKNIGHT"}) do
    card_info = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander DK"
      burn_dk?(card_info) -> :"Burn DK"
      handbuff_dk?(card_info) -> :"Handbuff DK"
      aggro_dk?(card_info) -> :"Aggro DK"
      boar?(card_info) -> :"Boar DK"
      quest?(card_info) || questline?(card_info) -> :"Quest DK"
      murloc?(card_info) -> :"Murloc DK"
      true -> minion_type_fallback(card_info, "DK")
    end
  end

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
      highlander?(c) ->
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

      aggro_dh?(card_info) && outcast_dh?(card_info) ->
        :"Aggro Outcast DH"

      aggro_dh?(card_info) && relic_dh?(card_info) ->
        :"Aggro Relic DH"

      aggro_dh?(card_info) ->
        :"Aggro Demon Hunter"

      outcast_dh?(card_info) ->
        :"Outcast DH"

      fel_dh?(card_info) && spell_dh?(card_info) && relic_dh?(card_info) ->
        :"Spffellic Demon Hunter"

      spell_dh?(card_info) && fel_dh?(card_info) ->
        :"Spffell Demon Hunter"

      spell_dh?(card_info) && relic_dh?(card_info) ->
        :"Spellic Demon Hunter"

      fel_dh?(card_info) && relic_dh?(card_info) ->
        :"Felic Demon Hunter"

      spell_dh?(card_info) ->
        :"Spellic Demon Hunter"

      fel_dh?(card_info) ->
        :"Fel Demon Hunter"

      relic_dh?(card_info) ->
        :"Relic Demon Hunter"

      true ->
        minion_type_fallback(card_info, "Demon Hunter")
    end
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
      highlander?(c) -> :"Highlander Druid"
      quest?(card_info) || questline?(card_info) -> :"Quest Druid"
      boar?(card_info) -> :"Boar Druid"
      vanndar?(card_info) -> :"Vanndar Druid"
      big_druid?(card_info) -> :"Big Druid"
      celestial_druid?(card_info) -> :"Celestial Druid"
      ramp_druid?(card_info) -> :"Ramp Druid"
      murloc?(card_info) -> :"Murloc Druid"
      "Lady Prestor" in card_info.card_names -> :"Prestor Druid"
      aggro_druid?(card_info) -> :"Aggro Druid"
      true -> minion_type_fallback(card_info, "Druid")
    end
  end

  def archetype(%{format: 2, cards: c, class: "HUNTER"}) do
    card_info = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Hunter"
      quest?(card_info) || questline?(card_info) -> :"Quest Hunter"
      vanndar?(card_info) && big_beast_hunter?(card_info) -> :"Vanndar Beast Hunter"
      vanndar?(card_info) -> :"Vanndar Hunter"
      arcane_hunter?(card_info) -> :"Arcane Hunter"
      rat_hunter?(card_info) -> :"Rattata Hunter"
      big_beast_hunter?(card_info) -> :"Big Beast Hunter"
      beast_hunter?(card_info) -> :"Beast Hunter"
      murloc?(card_info) -> :"Murloc Hunter"
      boar?(card_info) -> :"Boar Hunter"
      aggro_hunter?(card_info) -> :"Aggro Hunter"
      wildseed_hunter?(card_info) -> :"Wildseed Hunter"
      true -> minion_type_fallback(card_info, "Hunter")
    end
  end

  def archetype(%{format: 2, cards: c, class: "MAGE"}) do
    card_info = full_cards(c)

    cond do
      highlander?(c) ->
        :"Highlander Mage"

      arcane_mage?(card_info) && (quest?(card_info) || questline?(card_info)) ->
        :"Arcane Quest Mage"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Mage"

      vanndar?(card_info) ->
        :"Vanndar Mage"

      arcane_mage?(card_info) ->
        :"Arcane Mage"

      secret_mage?(card_info) ->
        :"Secret Mage"

      naga_mage?(card_info) && casino_mage?(card_info) ->
        :"Naga Casino Mage"

      casino_mage?(card_info) ->
        :"Casino Mage"

      frost_mage?(card_info) ->
        :"Frost Mage"

      naga_mage?(card_info) ->
        :"Naga Mage"

      mech_mage?(card_info) ->
        :"Mech Mage"

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
        minion_type_fallback(card_info, "Mage")
    end
  end

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
      highlander?(c) && pure_paladin?(card_info) -> :"Highlander Pure Paladin"
      pure_paladin?(card_info) && dude_paladin?(card_info) -> :Chadadin
      pure_paladin?(card_info) -> :"Pure Paladin"
      highlander?(c) -> :"Highlander Paladin"
      aggro_paladin?(card_info) -> :"Aggro Paladin"
      quest?(card_info) || questline?(card_info) -> :"Quest Paladin"
      dude_paladin?(card_info) -> :"Dude Paladin"
      handbuff_paladin?(card_info) -> :"Handbuff Paladin"
      mech_paladin?(card_info) -> :"Mech Paladin"
      holy_paladin?(card_info) -> :"Holy Paladin"
      kazakusan?(card_info) -> :"Kazakusan Paladin"
      big_paladin?(card_info) -> :"Big Paladin"
      order_luladin?(card_info) -> :"Order LULadin"
      vanndar?(card_info) -> :"Vanndar Paladin"
      murloc?(card_info) -> :"Murloc Paladin"
      boar?(card_info) -> :"Boar Paladin"
      true -> minion_type_fallback(card_info, "Paladin")
    end
  end

  defp aggro_paladin?(card_info),
    do:
      min_count?(card_info, 5, [
        "For Quel'Thalas!",
        "Seal of Blood",
        "Blessing of Kings",
        "Sunwing Squawker",
        "Foul Egg",
        "Sanguine Soldier",
        "Blood Matriarch Liadrin",
        "Nerubian Egg",
        "Righteous Protector"
      ])

  def archetype(%{format: 2, cards: c, class: "PRIEST"}) do
    card_info = full_cards(c)

    cond do
      highlander?(c) ->
        :"Highlander Priest"

      quest?(card_info) || questline?(card_info) ->
        :"Quest Priest"

      boar?(card_info) ->
        :"Boar Priest"

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

      thief_priest?(card_info) ->
        :"Thief Priest"

      shadow_priest?(card_info) && "Voidtouched Attendant" in card_info.card_names ->
        :"Shaggro Priest"

      rager_priest?(card_info) ->
        :"Rager Priest"

      svalna_priest?(card_info) ->
        :"Svalna Priest"

      shadow_priest?(card_info) ->
        :"Shadow Priest"

      murloc?(card_info) ->
        :"Murloc Priest"

      true ->
        minion_type_fallback(card_info, "Priest")
    end
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
      highlander?(c) -> :"Highlander Rogue"
      coc_rogue?(card_info) && (quest?(card_info) || questline?(card_info)) -> :"Quest Coc Rogue"
      quest?(card_info) || questline?(card_info) -> :"Quest Rogue"
      coc_rogue?(card_info) && miracle_rogue?(card_info) -> :"Cocacle Rogue"
      coc_rogue?(card_info) && thief_rogue?(card_info) -> :"Coc Thief Rogue"
      coc_rogue?(card_info) -> :"Coc Rogue"
      mine_rogue?(card_info) -> :"Mine Rogue"
      pirate_rogue?(card_info) && thief_rogue?(card_info) -> :"Pirate Thief Rogue"
      jackpot_rogue?(card_info) -> :"Jackpot Rogue"
      edwin_rogue?(card_info) -> :"Edwin Rogue"
      thief_rogue?(card_info) -> :"Thief Rogue"
      boar?(card_info) -> :"Boar Rogue"
      pirate_rogue?(card_info) -> :"Pirate Rogue"
      vanndar?(card_info) -> :"Vanndar Rogue"
      secret_rogue?(card_info) -> :"Secret Rogue"
      shark_rogue?(card_info) -> :"Shark Rogue"
      deathrattle_rogue?(card_info) -> :"Deathrattle Rogue"
      min_secret_count?(card_info, 3) -> :"Secret Rogue"
      true -> minion_type_fallback(card_info, "Rogue")
    end
  end

  def archetype(%{format: 2, cards: c, class: "SHAMAN"}) do
    card_info = full_cards(c)

    Backend.Hearthstone.CardBag.all()
    |> Enum.map(&elem(&1, 1))
    |> Enum.find(&(&1.name =~ "Find the Imposter"))
    |> Backend.Hearthstone.Card.questline?()

    cond do
      highlander?(c) -> :"Highlander Shaman"
      quest?(card_info) || questline?(card_info) -> :"Quest Shaman"
      boar?(card_info) -> :"Boar Shaman"
      vanndar?(card_info) -> :"Vanndar Shaman"
      "Barbaric Sorceress" in card_info.card_names -> :"Big Spell Shaman"
      aggro_shaman?(card_info) -> :"Aggro Shaman"
      big_bone_shaman?(card_info) -> :"Big Bone Shaman"
      "Gigantotem" in card_info.card_names -> :"Totem Shaman"
      elemental_shaman?(card_info) -> :"Elemental Shaman"
      evolve_shaman?(card_info) -> :"Evolve Shaman"
      burn_shaman?(card_info) -> :"Burn Shaman"
      moist_shaman?(card_info) -> :"Moist Shaman"
      control_shaman?(card_info) -> :"Control Shaman"
      murloc?(card_info) -> :"Murloc Shaman"
      minion_type_fallback(card_info, "Shaman") -> minion_type_fallback(card_info, "Shaman")
      bloodlust_shaman?(card_info) -> :"Bloodlust Shaman"
      true -> nil
    end
  end

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
      highlander?(c) -> :"Highlander Warlock"
      implock?(card_info) && (quest?(card_info) || questline?(card_info)) -> :"Quest Implock"
      quest?(card_info) || questline?(card_info) -> :"Quest Warlock"
      murloc?(card_info) -> :"Murloc Warlock"
      implock?(card_info) && boar?(card_info) -> :"Boar Implock"
      boar?(card_info) -> :"Boar Warlock"
      implock?(card_info) && phylactery_warlock?(card_info) -> :"Phylactery Implock"
      phylactery_warlock?(card_info) -> :"Phylactery Warlock"
      implock?(card_info) && handlock?(card_info) -> :"Hand Implock"
      handlock?(card_info) -> :Handlock
      implock?(card_info) && agony_warlock?(card_info) -> :"Agony Implock"
      agony_warlock?(card_info) -> :"Agony Warlock"
      implock?(card_info) && abyssal_warlock?(card_info) -> :"Abyssal Implock"
      abyssal_warlock?(card_info) -> :"Abyssal Warlock"
      implock?(card_info) -> :Implock
      "Lord Jaraxxus" in card_info.card_names -> :"J-Lock"
      true -> minion_type_fallback(card_info, "Warlock")
    end
  end

  def archetype(%{format: 2, cards: c, class: "WARRIOR"}) do
    card_info = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Warrior"
      questline?(card_info) && warrior_aoe?(card_info) -> :"Quest Control Warrior"
      quest?(card_info) || questline?(card_info) -> :"Quest Warrior"
      galvangar_combo?(card_info) -> :"Charge Warrior"
      enrage?(card_info) -> :"Enrage Warrior"
      warrior_aoe?(card_info) -> :"Control Warrior"
      weapon_warrior?(card_info) -> :"Weapon Warrior"
      murloc?(card_info) -> :"Murloc Warrior"
      boar?(card_info) -> :"Boar Warrior"
      true -> minion_type_fallback(card_info, "Warrior")
    end
  end

  def archetype(%{class: class, cards: c, format: 1}) do
    class_name = Deck.class_name(class)
    card_info = full_cards(c)

    cond do
      highlander?(c) ->
        String.to_atom("Highlander #{class_name}")

      quest?(card_info) || questline?(card_info) ->
        String.to_atom("Quest #{class_name}")

      boar?(card_info) ->
        String.to_atom("Boar #{class_name}")

      odd?(card_info) ->
        String.to_atom("Odd #{class_name}")

      even?(card_info) ->
        String.to_atom("Even #{class_name}")

      true ->
        minion_type_fallback(card_info, class_name)
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
    do: "Sigil of Reckoning" in card_names || vanndar?(ci)

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

  defp big_druid?(ci),
    do:
      min_count?(ci, 3, [
        "Abominable Lieutenant",
        "Sesselle of the Fae Court",
        "Neptulon the Tidehunter",
        "Stoneborn General"
      ])

  defp ramp_druid?(ci = %{card_names: card_names}),
    do:
      "Wildheart Guff" in card_names &&
        min_count?(ci, 2, ["Wild Growth", "Nourish", "Widowbloom Seedsman"])

  defp aggro_druid?(ci),
    do:
      min_count?(ci, 1, [
        "Oracle of Elune",
        "Clawflury Adept",
        "Peasant",
        "Encumbered Pack Mule",
        "Pride's Fury"
      ])

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
    do: beast_hunter?(ci) && min_count?(ci, 1, ["King Krush", "Wing Commander Ichman"])

  defp beast_hunter?(ci),
    do:
      min_count?(ci, 2, [
        "Selective Breeder",
        "Stormpike Battle Ram",
        "Azsharan Saber",
        "Revive Pet",
        "Pet Collector"
      ])

  defp aggro_hunter?(ci),
    do:
      (min_count?(ci, 1, ["Bloodseeker", "Quick Shot", "Piercing Shot"]) &&
         min_count?(ci, 1, ["Peasant", "Irondeep Trogg", "Gnome Private"])) ||
        "Beaststalker Tavish" not in ci.card_names

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
        min_count?(ci, 2, ["Tess Greymane", "Contraband Stash"])

  defp miracle_rogue?(ci), do: min_count?(ci, 1, ["Mailbox Dancer"]) && miracle_wincon?(ci)
  defp miracle_wincon?(ci), do: min_count?(ci, 2, ["Sinstone Graveyard", "Necrolord Draka"])

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
    do: min_count?(ci, 2, ["Front Lines", "Cavalry Horn"])

  defp holy_paladin?(ci = %{card_names: card_names}),
    do:
      "The Garden's Grace" in card_names &&
        min_count?(ci, 1, ["Righteous Defense", "Battle Vicar", "Knight of Anointment"])

  defp handbuff_paladin?(%{card_names: card_names}),
    do:
      "Prismatic Jewel Kit" in card_names &&
        ("First Blade of Wyrnn" in card_names || "Overlord Runthak" in card_names)

  defp dude_paladin?(ci),
    do:
      min_count?(ci, 3, [
        "Jury Duty",
        "Promotion",
        "Soldier's Caravan",
        "Stewart the Steward",
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
      "Imbued Axe",
      "Barrens Blacksmith",
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

  defp boar?(%{card_names: card_names}), do: "Elwynn Boar" in card_names
  defp kazakusan?(%{card_names: card_names}), do: "Kazakusan" in card_names
  defp highlander?(cards), do: Enum.count(cards) == Enum.count(Enum.uniq(cards))
  defp vanndar?(%{card_names: card_names}), do: "Vanndar Stormpike" in card_names
  defp quest?(%{full_cards: full_cards}), do: Enum.any?(full_cards, &Card.quest?/1)
  defp questline?(%{full_cards: full_cards}), do: Enum.any?(full_cards, &Card.questline?/1)

  defp odd?(%{card_names: card_names}), do: "Baku the Mooneater" in card_names
  defp even?(%{card_names: card_names}), do: "Grenn Greymane" in card_names

  defp minion_type_fallback(ci, class_part, fallback \\ nil, min_count \\ 6) do
    with counts = [_ | _] <- minion_type_counts(ci),
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

    {all_count, without_all} = Map.pop(base_counts, "all", 0)

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
