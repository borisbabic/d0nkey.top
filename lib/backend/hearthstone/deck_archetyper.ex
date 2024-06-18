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

  def archetype(%{cards: _cards} = deck) do
    card_info = full_cards(deck)

    if splendiferous_whizbang?(card_info) do
      :"Splendiferous Whizbang"
    else
      do_archetype(deck, card_info)
    end
  end

  def archetype(_), do: nil

  @neutral_excavate ["Kobold Miner", "Burrow Buster"]
  @neutral_spell_damage [
    "Bloodmage Thalnos",
    "Kobold Geomancer",
    "Rainbow Glowscale",
    "Silvermoon Arcanist",
    "Azure Drake"
  ]
  defp do_archetype(%{format: 2, cards: c, class: "DEATHKNIGHT"}, card_info) do
    cond do
      highlander?(card_info, c) ->
        :"Highlander DK"

      burn_dk?(card_info) ->
        :"Burn DK"

      handbuff_dk?(card_info) ->
        :"Handbuff DK"

      rainbow_dk?(card_info) && plague_dk?(card_info) ->
        :"Rainbow Plague DK"

      rainbow_dk?(card_info) && excavate_dk?(card_info) ->
        :"Rainbow Excavate DK"

      rainbow_dk?(card_info) ->
        :"Rainbow DK"

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

      control_dk?(card_info) ->
        :"Control DK"

      true ->
        fallbacks(card_info, "DK", ignore_types: ["Undead", "undead", "UNDEAD"])
    end
  end

  def rainbow_dk?(ci) do
    case Deck.rune_cost(ci.cards) do
      %{blood: b, frost: f, unholy: u} when b > 0 and f > 0 and u > 0 -> true
      _ -> false
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

  def control_dk?(c) do
    min_count?(c, 2, ["Corpse Explosion", "Soulstealer"])
  end

  def handbuff_dk?(c),
    do:
      min_count?(c, 3, [
        "Lesser Spinel Spellstone",
        "Amateur Puppeteer",
        "Blood Tap",
        "Toysnatching Geist",
        "Darkfallen Neophyte",
        "Vicious Bloodworm",
        "Overlord Runthak",
        "Ram Commander",
        "Encumbered Pack Mule"
      ])

  defp do_archetype(%{format: 2, cards: c, class: "DEMONHUNTER"}, card_info) do
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

      naga_dh?(card_info) and shopper_dh?(card_info) ->
        :"Naga Shopper DH"

      naga_dh?(card_info) ->
        :"Naga Demon Hunter"

      menagerie?(card_info) ->
        :"Menagerie DH"

      cycle_dh?(card_info) ->
        :"Cycle DH"

      weapon_dh?(card_info) ->
        :"Weapon DH"

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

      shopper_dh?(card_info) ->
        :"Shopper DH"

      attack_dh?(card_info) ->
        :"Attack DH"

      outcast_dh?(card_info) ->
        :"Outcast DH"

      true ->
        fallbacks(card_info, "Demon Hunter")
    end
  end

  defp attack_dh?(ci) do
    min_count?(ci, 5, [
      "Illidari Inquisitor",
      "Sock Puppet Slitherspear",
      "Burning Heart",
      "Battlefiend",
      "Parched Desperado",
      "Spirit of the Team",
      "Going Down Swinging",
      "Chaos Strike",
      "Lesser Opal Spellstone",
      "Saronite Shambler",
      "Gan'arg Glaivesmith",
      "Gibbering Reject",
      "Rhythmdancer Risa"
    ])
  end

  def shopper_dh?(ci) do
    min_count?(ci, 2, ["Window Shopper", "Umpire's Grasp"])
  end

  def cycle_dh?(ci) do
    "Playhouse Giant" in ci.card_names or
      min_count?(ci, 2, ["Momentum", "Mindbender", "Eredar Deceptor", "Argunite Golem"])
  end

  def weapon_dh?(ci) do
    min_count?(ci, 2, ["Quick Pick", "Umberwing", "Umpire's Grasp"]) and
      min_count?(ci, 1, [
        "Abyssal Bassist",
        "Shadestone Skulker",
        "Instrument Tech",
        "Air Guitarist"
      ])
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

  defp do_archetype(%{format: 2, cards: c, class: "DRUID"}, card_info) do
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
      murloc?(card_info) -> :"Murloc Druid"
      "Lady Prestor" in card_info.card_names -> :"Prestor Druid"
      "Gadgetzan Auctioneer" in card_info.card_names -> :"Miracle Druid"
      ignis_druid?(card_info) -> :"Ignis Druid"
      "Tony, King of Piracy" in card_info.card_names -> :"Tony Druid"
      zok_druid?(card_info) -> :"Zok Druid"
      hero_power_druid?(card_info) -> :"Hero Power Druid"
      choose_one?(card_info) -> :"Choose Druid"
      afk_druid?(card_info) -> :"AFK Druid"
      mill_druid?(card_info) -> :"Mill Druid"
      owlonius_druid?(card_info) -> :"Owlonius Druid"
      spell_damage_druid?(card_info) -> :"Spell Damage Druid"
      ramp_druid?(card_info) && "Death Beetle" in card_info.card_names -> :"Beetle Druid"
      "Topior the Shrubbagazzor" in card_info.card_names -> :"Topior Druid"
      treant_druid?(card_info) -> :"Treant Druid"
      aggro_druid?(card_info) -> :"Aggro Druid"
      "Therazane" in card_info.card_names and deathrattle_druid?(card_info) -> :"Therazane Druid"
      deathrattle_druid?(card_info) -> :"Deathrattle Druid"
      "Drum Circle" in card_info.card_names -> :"Drum Druid"
      ramp_druid?(card_info) -> :"Ramp Druid"
      true -> fallbacks(card_info, "Druid")
    end
  end

  @non_owlonius_druid_sd_cards [
    "Magical Dollhouse",
    "Bottomless Toy Chest",
    "Woodland Wonders",
    "Chia Drake",
    "Sparkling Phial" | @neutral_spell_damage
  ]
  defp owlonius_druid?(ci) do
    "Owlonius" in ci.card_names and min_count?(ci, 2, @non_owlonius_druid_sd_cards)
  end

  defp spell_damage_druid?(ci) do
    min_count?(ci, 4, @non_owlonius_druid_sd_cards)
  end

  defp mill_druid?(ci) do
    min_count?(ci, 2, ["Dew Process", "Prince Renathal", "Selfish Shellfish"])
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
    do:
      min_count?(ci, 2, [
        "Witchwood Apple",
        "Conservator Nymph",
        "Blood Treant",
        "Cultivation",
        "Overgrown Beanstalk"
      ])

  defp afk_druid?(ci),
    do: min_count?(ci, 2, ["Rhythm and Roots", "Timber Tambourine"])

  defp choose_one?(ci),
    do: min_count?(ci, 3, ["Embrace Nature", "Disciple of Eonar"])

  defp zok_druid?(ci),
    do: min_count?(ci, 2, ["Zok Fogsnout", "Anub'Rekhan"])

  defp do_archetype(%{format: 2, cards: c, class: "HUNTER"}, card_info) do
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

      zoo_hunter?(card_info) ->
        :"Zoo Hunter"

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

      egg_hunter?(card_info) ->
        :"Egg Hunter"

      mystery_egg_hunter?(card_info) ->
        :"Mystery Egg Hunter"

      wildseed_hunter?(card_info) ->
        :"Wildseed Hunter"

      true ->
        fallbacks(card_info, "Hunter")
    end
  end

  defp beast_hunter?(ci) do
    min_count?(ci, 4, [
      "Fetch!",
      "Bunny Stomper",
      "Jungle Gym",
      "Painted Canvasaur",
      "Master's Call",
      "Ball of Spiders",
      "Kill Command"
    ])
  end

  defp zoo_hunter?(ci) do
    min_count?(ci, 4, [
      "Observer of Myths",
      "Hawkstrider Rancher",
      "Saddle Up!",
      "Shadehound",
      "R.C. Rampage",
      "Remote Control",
      "Jungle Gym"
    ])
  end

  defp egg_hunter?(ci),
    do: min_count?(ci, 3, ["Foul Egg", "Nerubian Egg", "Ravenous Kraken", "Yelling Yodeler"])

  defp secret_hunter?(ci),
    do:
      min_count?(ci, 3, [
        "Lesser Emerald Spellstone",
        "Costumed Singer",
        "Anonymous Informant",
        "Titanforged Traps",
        "Product 9",
        "Starstrung Bow"
      ])

  def shockspitter?(ci) do
    "Shockspitter" in ci.card_names
  end

  defp do_archetype(%{format: 2, cards: c, class: "MAGE"}, card_info) do
    rommath? = "Grand Magister Rommath" in card_info.card_names
    lightshow? = "Lightshow" in card_info.card_names

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

      rommath? ->
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

      burn_spell_mage?(card_info) ->
        :"Burn Spell Mage"

      spell_mage?(card_info) ->
        :"Spell Mage"

      murloc?(card_info) ->
        :"Murloc Mage"

      boar?(card_info) ->
        :"Boar Mage"

      lightshow? ->
        :"Lightshow Mage"

      "The Galactic Projection Orb" in card_info.card_names ->
        :"Orb Mage"

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

  defp do_archetype(%{format: 2, cards: c, class: "PALADIN"}, card_info) do
    cond do
      highlander?(card_info, c) && pure_paladin?(card_info) -> :"Highlander Pure Paladin"
      pure_paladin?(card_info) && dude_paladin?(card_info) -> :Chadadin
      earthen_paladin?(card_info) && pure_paladin?(card_info) -> :"Gaia Pure Paladin"
      pure_paladin?(card_info) -> :"Pure Paladin"
      highlander?(card_info, c) -> :"Highlander Paladin"
      excavate_paladin?(card_info) -> :"Excavate Paladin"
      handbuff_paladin?(card_info) -> :"Handbuff Paladin"
      aggro_paladin?(card_info) -> :"Aggro Paladin"
      menagerie?(card_info) -> :"Menagerie Paladin"
      quest?(card_info) || questline?(card_info) -> :"Quest Paladin"
      dude_paladin?(card_info) -> :"Dude Paladin"
      mech_paladin?(card_info) -> :"Mech Paladin"
      earthen_paladin?(card_info) -> :"Gaia Paladin"
      holy_paladin?(card_info) -> :"Holy Paladin"
      kazakusan?(card_info) -> :"Kazakusan Paladin"
      big_paladin?(card_info) -> :"Big Paladin"
      order_luladin?(card_info) -> :"Order LULadin"
      vanndar?(card_info) -> :"Vanndar Paladin"
      murloc?(card_info) -> :"Murloc Paladin"
      boar?(card_info) -> :"Boar Paladin"
      true -> fallbacks(card_info, "Paladin")
    end
  end

  defp excavate_paladin?(card_info) do
    min_count?(
      card_info,
      3,
      ["Shroomscavate", "Sir Finley, the Intrepid", "Fossilized Kaleidosaur" | @neutral_excavate]
    )
  end

  defp aggro_paladin?(card_info) do
    min_count?(card_info, 6, [
      "Vicous Slitherspear",
      "Worgen Inflitrator",
      "Flash Sale",
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
      "Leeroy Jenkins",
      "Boogie Down",
      "Mining Casualties",
      "Buffet Biggun",
      "Muster for Battle",
      "Miracle Salesman",
      "Flash Sale",
      "Disco Maul",
      "Nerubian Egg",
      "Sea Giant",
      "Righteous Protector"
    ])
  end

  defp do_archetype(%{format: 2, cards: c, class: "PRIEST"}, card_info) do
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

      "Timewinder Zarimi" in card_info.card_names ->
        :"Zarimi Priest"

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
      "Mecha'thun" in ci.card_names -> "Mecha'thun #{class_name}"
      miracle_chad?(ci) -> "Miracle Chad #{class_name}"
      "Rivendare, Warrider" in ci.card_names -> "Rivendare #{class_name}"
      tentacle?(ci) -> "Tentacle #{class_name}"
      ogre?(ci) -> "Ogre #{class_name}"
      "Colifero the Artist" in ci.card_names -> "Colifero #{class_name}"
      quest?(ci) or questline?(ci) -> "Quest #{class_name}"
      "Gadgetzan Auctioneer" in ci.card_names -> "Miracle #{class_name}"
      even?(ci) -> "Even #{class_name}"
      odd?(ci) -> "Odd #{class_name}"
      giants?(ci) -> "Giants #{class_name}"
      true -> minion_type_fallback(ci, class_name, opts)
    end
  end

  defp giants?(ci, min_count \\ 3) do
    count =
      ci.card_names
      |> Enum.filter(&(String.reverse(&1) |> String.starts_with?("tnaiG")))
      |> Enum.count()

    count >= min_count
  end

  defp tentacle?(ci), do: "Chaotic Tendril" in ci.card_names

  defp miracle_chad?(ci), do: min_count?(ci, 2, ["Thaddius, Monstrosity", "Cover Artist"])

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
    min_count?(ci, 5, [
      "Crimson Clergy",
      "Funnel Cake",
      "Dreamboat",
      "Holy Champion",
      "Flash Heal",
      "Idol's Adoration",
      "Grace of the Highfather",
      "Hidden Gem",
      "Mana Geode",
      "Injured Hauler",
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

  defp do_archetype(%{format: 2, cards: c, class: "ROGUE"}, card_info) do
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

      pirate_rogue?(card_info) and cycle_rogue?(card_info) ->
        :"Pirate Cycle Rogue"

      pirate_rogue?(card_info) ->
        :"Pirate Rogue"

      cycle_rogue?(card_info) ->
        :"Cycle Rogue"

      cutlass_rogue?(card_info) ->
        :"Cutlass Rogue"

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

      virus_rogue?(card_info) ->
        :"Virus Rogue"

      goldbeard?(card_info) ->
        :"Goldbeard Rogue"

      sonya?(card_info) ->
        :"Sonya Rogue"

      dorian_rogue?(card_info) ->
        :"Dorian Rogue"

      true ->
        fallbacks(card_info, "Rogue")
    end
  end

  defp dorian_rogue?(card_info) do
    "Puppetmaster Dorian" in card_info.card_names
  end

  defp goldbeard?(ci) do
    min_count?(ci, 2, ["Shoplifter Goldbeard", "The Replicator-inator"])
  end

  defp sonya?(ci) do
    min_count?(ci, 3, ["Cover Artist", "Sonya Waterdancer", "Sandbox Scoundrel"])
  end

  defp virus_rogue?(ci) do
    min_count?(ci.zilliax_modules_names, 2, ["Power Module", "Virus Module"]) and
      min_count?(ci, 3, ["Pit Stop", "Frequency Oscillator", "SP-3Y3-D3R", "From the Scrapheap"])
  end

  defp excavate_rogue?(ci) do
    min_count?(ci, 3, [
      "Antique Flinger",
      "Drilly the Kid",
      "Bloodrock Co Shovel",
      "Scourge Illusionist",
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

  defp do_archetype(%{format: 2, cards: c, class: "SHAMAN"}, card_info) do
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
      spell_damage_shaman?(card_info) -> :"Spell Damage Shaman"
      nature_shaman?(card_info) -> :"Nature Shaman"
      overload_shaman?(card_info) -> :"Overload Shaman"
      excavate_shaman?(card_info) -> :"Excavate Shaman"
      evolve_shaman?(card_info) -> :"Evolve Shaman"
      burn_shaman?(card_info) -> :"Burn Shaman"
      moist_shaman?(card_info) -> :"Moist Shaman"
      control_shaman?(card_info) -> :"Control Shaman"
      murloc?(card_info) -> :"Murloc Shaman"
      wish_shaman?(card_info) -> :"Wish Shaman"
      bloodlust_shaman?(card_info) -> :"Bloodlust Shaman"
      "Wave of Nostalgia" in card_info.card_names -> :"Nostalgia Shaman"
      "From De Other Side" in card_info.card_names -> :"FDOS Shaman"
      true -> fallbacks(card_info, "Shaman")
    end
  end

  defp wish_shaman?(card_info) do
    "Wish Upon a Star" in card_info.card_names and
      min_count?(card_info, 3, [
        "Leeroy Jenkins",
        "Outfit Tailor",
        "Al'Akir the Windlord",
        "Backstage Bouncer",
        "Southsea Deckhand",
        "Murloc Growfin"
      ])
  end

  defp excavate_shaman?(card_info) do
    min_count?(
      card_info,
      3,
      ["Shroomscavate", "Sir Finley, the Intrepid", "Digging Straight Down" | @neutral_excavate]
    )
  end

  defp totem_shaman?(ci) do
    min_count?(ci, 2, ["Gigantotem", "Grand Totem Eys'or", "The Stonewright"])
  end

  defp spell_damage_shaman?(ci) do
    min_count?(ci, 3, ["Novice Zapper", "Spirit Claws" | @neutral_spell_damage])
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

  defp do_archetype(%{format: 2, cards: c, class: "WARLOCK"}, card_info) do
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

      snek?(card_info) ->
        :"Snek Warlock"

      implock?(card_info) && abyssal_warlock?(card_info) && chad?(card_info) ->
        :"Abyssal Chimplock"

      implock?(card_info) && chad?(card_info) ->
        :Chimplock

      implock?(card_info) && handlock?(card_info) ->
        :"Hand Implock"

      big_demon_warlock?(card_info) ->
        :"Big Demon Warlock"

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

      handlock?(card_info) ->
        :Handlock

      painlock?(card_info) ->
        :Painlock

      fatigue_warlock?(card_info) ->
        :"Insanity Warlock"

      "Wheel of DEATH!!!" in card_info.card_names ->
        :"Wheel Warlock"

      leeroy_warlock?(card_info) ->
        :"Leeroooooy Warlock"

      control_warlock?(card_info) ->
        :"Control Warlock"

      "Lord Jaraxxus" in card_info.card_names ->
        :"J-Lock"

      true ->
        fallbacks(card_info, "Warlock")
    end
  end

  defp leeroy_warlock?(card_info) do
    min_count?(card_info, 3, ["Leeroy Jenkins", "Monstrous Form", "Reverberations"])
  end

  defp painlock?(ci) do
    min_count?(ci, 4, [
      "Flame Imp",
      "Spirit Bomb",
      "Malefic Rook",
      "Lesser Amethyst Spellstone",
      "Molten Giant",
      "Imprisoned Horror",
      "Trogg Exile",
      "INFERNAL!",
      "Mass Production",
      "Elementium Geode"
    ])
  end

  defp neutral_bouncers?(ci, min_count \\ 2) do
    min_count?(ci, min_count, ["Youthful Brewmaster", "Saloon Brewmaster", "Zola the Gorgon"])
  end

  defp big_demon_warlock?(ci) do
    min_count?(ci, 4, [
      "Endgame",
      "Cursed Champion",
      "Doomguard",
      "Dirge of Despair",
      "Game Master Nemsy",
      "Enhanced Dreadloard",
      "Wretched Queeen"
    ])
  end

  defp sludgelock?(ci) do
    min_count?(ci, 3, [
      "Tram Mechanic",
      "Disposal Assistant",
      "Sludge on Wheels",
      "Pop'gar the Putrid"
    ])
  end

  @self_fatigue_package ["Crescendo", "Baritone Imp", "Crazed Conductor"]
  defp fatigue_warlock?(ci) do
    min_count?(ci, 2, ["Pop'gar the Putrid", "Encroaching Insanity"]) and
      min_count?(ci, 3, @self_fatigue_package)
  end

  defp control_warlock?(ci) do
    min_count?(ci, 5, [
      "Sargeras, the Destroyer",
      "Symphony of Sins",
      "Domino Effect",
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

  defp do_archetype(%{format: 2, cards: c, class: "WARRIOR"}, card_info) do
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
      excavate_warrior?(card_info) && odyn?(card_info) -> :"Excavate Odyn Warrior"
      # cycle_odyn?(card_info) -> :"Cycle Odyn Warrior"
      odyn?(card_info) -> :"Odyn Warrior"
      excavate_warrior?(card_info) -> :"Excavate Warrior"
      riff_warrior?(card_info) -> :"Riff Warrior"
      taunt_warrior?(card_info) -> :"Taunt Warrior"
      weapon_warrior?(card_info) -> :"Weapon Warrior"
      "Deepminer Brann" in card_info.card_names -> :"Brann Warrior"
      murloc?(card_info) -> :"Murloc Warrior"
      boar?(card_info) -> :"Boar Warrior"
      mech_warrior?(card_info) -> :"Mech Warrior"
      bomb_warrior?(card_info) -> :"Bomb Warrior"
      "Justicar Trueheart" in card_info.card_names -> :"Justicar Warrior"
      "Safery Expert" in card_info.card_names -> :"Safety Warrior"
      true -> fallbacks(card_info, "Warrior")
    end
  end

  def taunt_warrior?(ci) do
    min_count?(ci, 4, [
      "Quality Assurance",
      "Unlucky Powderman",
      "Battlepickaxe",
      "Stonehill Defender",
      "Detonation Juggernaut"
    ])
  end

  def bomb_warrior?(card_info) do
    min_count?(card_info, 2, ["Explodineer", "Safety Expert"])
  end

  def mech_warrior?(card_info) do
    min_count?(card_info, 2, ["Boom Wrench", "Testing Dummy"])
  end

  defp odyn?(card_info) do
    "Odyn, Prime Designate" in card_info.card_names
  end

  defp cycle_odyn?(ci) do
    odyn?(ci) and
      min_count?(ci, 3, [
        "Acolyte of Pain",
        "Needlerock Totem",
        "Stoneskin Armorer",
        "Gold Panner"
      ])
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

  defp twist_whizbangs_heros(card_info) do
    # generated in Scratchpad
    cond do
      min_count?(card_info, 19, [
        "Grave Defiler",
        "Taste of Chaos",
        "Chaos Strike",
        "Dryscale Deputy",
        "Fel Barrage",
        "Fossil Fanatic",
        "Multi-Strike",
        "Quick Pick",
        "Coordinated Strike",
        "Disciple of Argus",
        "Herald of Chaos",
        "Sigil of Time",
        "Stargazer Luna",
        "Archmage Vargoth",
        "Demonic Assault",
        "Fan the Hammer",
        "Metamorphosis",
        "Jotun, the Eternal",
        "Queen Azshara",
        "Chaos Creation",
        "Impfestation",
        "Expendable Performers",
        "Jace Darkweaver"
      ]) ->
        :"Illidan Stormrage"

      min_count?(card_info, 31, [
        "Elemental Evocation",
        "Devolving Missiles",
        "Elemental Allies",
        "Fire Fly",
        "Flame Geyser",
        "Kindling Elemental",
        "Synthesize",
        "Wailing Vapor",
        "Aqua Archivist",
        "Elementary Reaction",
        "Menacing Nimbus",
        "Sandstorm Elemental",
        "Sleetbreaker",
        "Spotlight",
        "Trusty Companion",
        "Arid Stormer",
        "Frostfin Chomper",
        "Gyreworm",
        "Lightning Storm",
        "Minecart Cruiser",
        "Baking Soda Volcano",
        "Dang-Blasted Elemental",
        "Al'ar",
        "Lilypad Lurker",
        "Mes'Adune the Fractured",
        "Tainted Remnant",
        "Waxadred",
        "Horn of the Windlord",
        "Baron Geddon",
        "Kalimos, Primal Lord",
        "Siamat",
        "Skarr, the Catastrophe",
        "Therazane",
        "Al'Akir the Windlord",
        "Ragnaros the Firelord"
      ]) ->
        :"Al'Akir the Windlord"

      min_count?(card_info, 31, [
        "Ivus, the Forest Lord",
        "Sir Finley, Sea Guide",
        "Sphere of Sapience",
        "Astalor Bloodsworn",
        "Bloodmage Thalnos",
        "Flint Firearm",
        "Archdruid Naralex",
        "Brann Bronzebeard",
        "Brightwing",
        "Flightmaster Dungar",
        "Mankrik",
        "SN1P-SN4P",
        "Blademaster Okani",
        "Korrak the Bloodrager",
        "Maiev Shadowsong",
        "Pozzik, Audio Engineer",
        "Emperor Thaurissan",
        "Loatheb",
        "Moonfang",
        "Overlord Runthak",
        "Zilliax",
        "Cairne Bloodhoof",
        "Gnomelia, S.A.F.E. Pilot",
        "Sylvanas Windrunner",
        "Dr. Boom",
        "Lor'themar Theron",
        "Mutanus the Devourer",
        "Siamat",
        "Goliath, Sneed's Masterpiece",
        "Jepetto Joybuzz",
        "Ozumat",
        "Alexstrasza the Life-Binder",
        "Yogg-Saron, Unleashed",
        "Neptulon the Tidehunter",
        "Raid Boss Onyxia"
      ]) ->
        :"Arch-Villain Rafaam"

      min_count?(card_info, 31, [
        "Blessing of Wisdom",
        "First Day of School",
        "Knight of Anointment",
        "Sanguine Soldier",
        "Argent Protector",
        "Blood Matriarch Liadrin",
        "Crooked Cook",
        "For Quel'Thalas!",
        "Hand of A'dal",
        "Hi Ho Silverwing",
        "Hydrologist",
        "Knife Juggler",
        "Manafeeder Panthara",
        "Sound the Bells!",
        "Squashling",
        "Acolyte of Pain",
        "Aldor Peacekeeper",
        "Alliance Bannerman",
        "Cathedral of Atonement",
        "Consecration",
        "Disco Maul",
        "Divine Favor",
        "Funkfin",
        "Goody Two-Shields",
        "Hammer of Wrath",
        "Keeper of Uldaman",
        "Magnifying Glaive",
        "Salhet's Pride",
        "Stargazer Luna",
        "Voracious Reader",
        "Warsong Commander",
        "Wickerflame Burnbristle",
        "Ancestral Guardian",
        "Crusader Aura",
        "Keeper's Strength"
      ]) ->
        :"Leeroy Jenkins"

      min_count?(card_info, 41, [
        "Arcane Wyrm",
        "Babbling Book",
        "Evocation",
        "Fire Fly",
        "First Day of School",
        "First Flame",
        "Jar Dealer",
        "Learn Draconic",
        "Magic Trick",
        "Synthesize",
        "Training Session",
        "Unstable Felbolt",
        "Violet Spellwing",
        "Wand Thief",
        "Astral Rift",
        "Dark Peddler",
        "Dryscale Deputy",
        "Expired Merchant",
        "Flint Firearm",
        "Mana Cyclone",
        "Primordial Glyph",
        "Prismatic Elemental",
        "Ram Commander",
        "Runed Orb",
        "Tiny Knight of Evil",
        "Unstable Portal",
        "Wandmaker",
        "Whelp Wrangler",
        "Arcsplitter",
        "Dark Skies",
        "Instructor Fireheart",
        "Messenger Raven",
        "Ravencaller",
        "Reckless Diretroll",
        "Trolley Problem",
        "Gloomstone Guardian",
        "Leyline Manipulator",
        "School Teacher",
        "Blast Wave",
        "Cobalt Spellkin",
        "Spawn of Deathwing",
        "Maruut Stonebinder",
        "Cho'gall",
        "Mana Giant",
        "Grand Magister Rommath"
      ]) ->
        :"Kael'Thas Sunstrider"

      min_count?(card_info, 26, [
        "Cactus Construct",
        "Living Roots",
        "Chaotic Consumption",
        "Forest Seedlings",
        "Grimoire of Sacrifice",
        "Lingering Zombie",
        "Plague of Flames",
        "Pop-Up Book",
        "Wicked Shipment",
        "Dreamway Guardians",
        "Haunted Creeper",
        "Mining Casualties",
        "Shrubadier",
        "Thorngrowth Sentries",
        "BEEEES!!!",
        "Darkshire Councilman",
        "Frostwolf Kennels",
        "Imp Gang Boss",
        "Plot of Sin",
        "Swipe",
        "Branching Paths",
        "Klaxxi Amber-Weaver",
        "Murlocula",
        "Flipper Friends",
        "Glowfly Swarm",
        "Swarm of Lightbugs",
        "Twilight Darkmender",
        "Ancient Shieldbearer",
        "Trial by Fire",
        "Twin Emperor Vek'lor"
      ]) ->
        :"C'Thun"

      min_count?(card_info, 41, [
        "Arcane Breath",
        "Cleric of Scales",
        "Flight of the Bronze",
        "Giftwrapped Whelp",
        "Sand Breath",
        "Twilight Whelp",
        "Alexstrasza's Champion",
        "Breath of Dreams",
        "Corrosive Breath",
        "Dragonmaw Sentinel",
        "Firetree Witchdoctor",
        "Lay Down the Law",
        "Nether Breath",
        "Netherspite Historian",
        "Redscale Dragontamer",
        "Splish-Splash Whelp",
        "Wyrmrest Agent",
        "Amber Whelp",
        "Breath of the Infinite",
        "Consecration",
        "Dragonrider Talritha",
        "Lightbringer's Hammer",
        "Lightning Breath",
        "Timewarden",
        "Desert Nestmatron",
        "Duskbreaker",
        "Future Emissary",
        "Molten Breath",
        "Blackwing Corruptor",
        "Chronobreaker",
        "Crazed Netherwing",
        "Dragonfire Potion",
        "Malygos, Aspect of Magic",
        "Onyxian Warder",
        "Aeon Reaver",
        "Candle Breath",
        "Nithogg",
        "Anachronos",
        "Murozond, Thief of Time",
        "Deathwing, Mad Aspect",
        "Murozond the Infinite",
        "Alexstrasza the Life-Binder",
        "Fye, the Setting Sun",
        "Ysera the Dreamer",
        "Raid Boss Onyxia"
      ]) ->
        :Nozdormu

      min_count?(card_info, 17, [
        "Arms Dealer",
        "Body Bagger",
        "Fistful of Corpses",
        "Heart Strike",
        "Lingering Zombie",
        "Plagued Grain",
        "Runes of Darkness",
        "Haunted Creeper",
        "Mining Casualties",
        "Acolyte of Death",
        "Corpse Farm",
        "Crop Rotation",
        "Eulogizer",
        "Unliving Champion",
        "Ymirjar Deathbringer",
        "Malignant Horror",
        "Sickly Grimewalker",
        "Tomb Guardians",
        "Corpse Bride",
        "Stitched Giant",
        "The Scourge"
      ]) ->
        :"The Lich King"

      min_count?(card_info, 31, [
        "Cleric of An'she",
        "Deafen",
        "Mistress of Mixtures",
        "Shadowtouched Kvaldir",
        "Shard of the Naaru",
        "The Light! It Burns!",
        "Astalor Bloodsworn",
        "Auchenai Phantasm",
        "City Tax",
        "Hi Ho Silverwing",
        "Hidden Gem",
        "Serena Bloodfeather",
        "Benevolent Banker",
        "Dehydrate",
        "Devouring Plague",
        "Haunting Nightmare",
        "Holy Nova",
        "Wickerflame Burnbristle",
        "Brittlebone Destroyer",
        "Fight Over Me",
        "Hysteria",
        "Ivory Knight",
        "School Teacher",
        "Xyrella",
        "Crystal Stag",
        "Mass Hysteria",
        "Raza the Chained",
        "Sandhoof Waterbearer",
        "Harmonic Pop",
        "Khartut Defender",
        "Lightshower Elemental",
        "Aman'Thul",
        "Blackwater Behemoth",
        "Blightblood Berserker",
        "Soul Mirror"
      ]) ->
        :Xyrella

      min_count?(card_info, 31, [
        "Backstab",
        "Blackwater Cutlass",
        "Bloodsail Flybooter",
        "Dig For Treasure",
        "Execute",
        "Gone Fishin'",
        "Jolly Roger",
        "Patches the Pirate",
        "Shiver Their Timbers!",
        "Sky Raider",
        "Swashburglar",
        "Amalgam of the Deep",
        "Bloodsail Raider",
        "Eviscerate",
        "Fan of Knives",
        "Fogsail Freebooter",
        "Harbor Scamp",
        "Obsidiansmith",
        "Parachute Brigand",
        "Serrated Bone Spike",
        "Toy Boat",
        "Ancharrr",
        "Bargain Bin Buccaneer",
        "Crow's Nest Lookout",
        "Defias Cannoneer",
        "Pufferfist",
        "Skybarge",
        "Swordfish",
        "Edwin, Defias Kingpin",
        "Hoard Pillager",
        "Sword Eater",
        "Bootstrap Sunkeneer",
        "Cannon Barrage",
        "Mr. Smite",
        "Pirate Admiral Hooktusk"
      ]) ->
        :"Patches the Pirate"

      min_count?(card_info, 31, [
        "Adaptation",
        "Embalming Ritual",
        "Grimscale Chum",
        "Grimscale Oracle",
        "Imprisoned Sungill",
        "Murloc Growfin",
        "Murloc Tidecaller",
        "Murmy",
        "Sir Finley, Sea Guide",
        "Spawnpool Forager",
        "Toxfin",
        "Unite the Murlocs",
        "Amalgam of the Deep",
        "Auctionhouse Gavel",
        "Hand of A'dal",
        "Hydrologist",
        "Lushwater Murcenary",
        "Murgur Murgurgle",
        "Primalfin Lookout",
        "Rockpool Hunter",
        "South Coast Chieftain",
        "Underbelly Angler",
        "Voidgill",
        "Bloodscent Vilefin",
        "Clownfish",
        "Coldlight Seer",
        "Consecration",
        "Cookie the Cook",
        "Murloc Warleader",
        "Nofin Can Stop Us",
        "Underlight Angling Rod",
        "Gentle Megasaur",
        "Murloc Knight",
        "Rotgill",
        "Everyfin is Awesome"
      ]) ->
        :"Sir Finley Mrrgglton"

      min_count?(card_info, 31, [
        "Ricochet Shot",
        "Tracking",
        "Urchin Spines",
        "Wound Prey",
        "Barrel of Monkeys",
        "Bola Shot",
        "Call Pet",
        "Fetch!",
        "Grievous Bite",
        "Rapid Fire",
        "Tame Beast (Rank 1)",
        "Animal Companion",
        "Master's Call",
        "Powershot",
        "Revive Pet",
        "Shellshot",
        "Swipe",
        "Unleash the Hounds",
        "Flanking Strike",
        "Marked Shot",
        "Swamp King Dred",
        "Amani War Bear",
        "Blackwater Behemoth",
        "Colaque",
        "Druid of the Plains",
        "Hydralodon",
        "King Mosh",
        "Toyrannosaurus",
        "Winged Guardian",
        "King Krush",
        "Oondasta",
        "Trenchstalker",
        "Banjosaur",
        "Tyrantus",
        "Shirvallah, the Tiger"
      ]) ->
        :"King Krush"

      min_count?(card_info, 26, [
        "Aquatic Form",
        "Innervate",
        "Preparation",
        "Forest Seedlings",
        "Mark of the Lotus",
        "Nature Studies",
        "Sow the Soil",
        "Witchwood Apple",
        "Lunar Eclipse",
        "Malfunction",
        "Mark of Scorn",
        "Natural Causes",
        "Fungal Fortunes",
        "Landscaping",
        "Overgrown Beanstalk",
        "Plot of Sin",
        "Soul of the Forest",
        "Fel'dorei Warband",
        "Aeroponics",
        "Arbor Up",
        "Deal with a Devil",
        "Living Mana",
        "Manufacturing Error",
        "Refreshing Spring Water",
        "Runic Carvings",
        "To My Side!",
        "Unending Swarm",
        "Drum Circle",
        "Rhok'delar",
        "Cultivation"
      ]) ->
        :"Forest Warden Omu"

      min_count?(card_info, 36, [
        "Drone Deconstructor",
        "Execute",
        "Glow-Tron",
        "Omega Assembly",
        "Trench Surveyor",
        "Amalgam of the Deep",
        "Bomb Toss",
        "From the Scrapheap",
        "Micro Mummy",
        "Noble Minibot",
        "Security Automaton",
        "Venomizer",
        "Bellowing Flames",
        "Coldlight Oracle",
        "Gorillabot A-3",
        "Mecha-Shark",
        "Mimiron, the Mastermind",
        "Powermace",
        "Seascout Operator",
        "Sky Claw",
        "SN1P-SN4P",
        "SP-3Y3-D3R",
        "Spider Bomb",
        "Ursatron",
        "Giggling Toymaker",
        "Outrider's Axe",
        "Pozzik, Audio Engineer",
        "Tiny Worldbreaker",
        "Brawl",
        "Dyn-o-matic",
        "Fireworker",
        "Zilliax",
        "Flame Behemoth",
        "Mothership",
        "V-07-TR-0N Prime",
        "Blastmaster Boom",
        "Boommaster Flark",
        "The Leviathan",
        "Gaia, the Techtonic",
        "Inventor Boom"
      ]) ->
        :"Dr. Boom"

      min_count?(card_info, 36, [
        "Blackjack Stunner",
        "Costumed Singer",
        "Secretkeeper",
        "Arcane Flakmage",
        "Bait and Switch",
        "Bargain Bin",
        "Cat Trick",
        "Explosive Trap",
        "Freezing Trap",
        "Hidden Meaning",
        "Hydrologist",
        "Ice Trap",
        "Mad Scientist",
        "Medivh's Valet",
        "Phase Stalker",
        "Quick Shot",
        "Snipe",
        "Sword of the Fallen",
        "Wandering Monster",
        "ZOMBEEEES!!!",
        "Cloaked Huntress",
        "Commander Rhyssa",
        "Inconspicuous Rider",
        "Petting Zoo",
        "Sparkjoy Cheat",
        "Chatty Bartender",
        "Throw Glaive",
        "Apexis Smuggler",
        "Halkias",
        "Orion, Mansion Manager",
        "Professor Putricide",
        "Spring the Trap",
        "Cannonmaster Smythe",
        "Lesser Emerald Spellstone",
        "Product 9",
        "Aggramar, the Avenger",
        "Contract Conjurer",
        "Sayge, Seer of Darkmoon",
        "Starstrung Bow",
        "King Plush"
      ]) ->
        :"Zul'jin"

      min_count?(card_info, 31, [
        "Batty Guest",
        "Call of the Grave",
        "Lingering Zombie",
        "Play Dead",
        "Unstable Felbolt",
        "Dead Ringer",
        "Defile",
        "Kindly Grandmother",
        "Loot Hoarder",
        "Museum Curator",
        "Roll the Bones",
        "Shallow Grave",
        "Starscryer",
        "Terrorscale Stalker",
        "Unstable Shadow Blast",
        "Devouring Ectoplasm",
        "Domino Effect",
        "Necrium Blade",
        "Piggyback Imp",
        "Reefwalker",
        "Voodoo Doll",
        "Ball Hog",
        "Baron Rivendare",
        "Infested Tauren",
        "Piloted Shredder",
        "Stubborn Suspect",
        "Teacher's Pet",
        "Vectus",
        "Claw Machine",
        "Ring Matron",
        "Darkmoon Tonk",
        "Enhanced Dreadlord",
        "Wretched Queen",
        "Obsidian Statue",
        "Stoneborn General"
      ]) ->
        :"N'Zoth, the Corruptor"

      min_count?(card_info, 41, [
        "Alleycat",
        "Blazing Invocation",
        "Mystery Winner",
        "Overwhelm",
        "Shock Hopper",
        "Slam",
        "Tracking",
        "Trinket Tracker",
        "Auctionhouse Gavel",
        "Crackling Razormaw",
        "Deeprun Engineer",
        "EVIL Cable Rat",
        "Grimestreet Informant",
        "Maze Guide",
        "Novice Engineer",
        "Painted Canvasaur",
        "Shrubadier",
        "Waxmancy",
        "Brilliant Macaw",
        "Crow's Nest Lookout",
        "Fairy Tale Forest",
        "Harmonica Soloist",
        "Kobold Apprentice",
        "Sewer Crawler",
        "Stitched Tracker",
        "Crud Caretaker",
        "Fire Plume Phoenix",
        "Rattling Rascal",
        "Triplewick Trickster",
        "Bomb Squad",
        "Cattle Rustler",
        "Dyn-o-matic",
        "Former Champ",
        "Loatheb",
        "Night Elf Huntress",
        "Abyssal Summoner",
        "Entitled Customer",
        "Lord Godfrey",
        "Swampqueen Hagatha",
        "Deathwing, Mad Aspect",
        "Gigafin",
        "Jepetto Joybuzz",
        "Murozond the Infinite",
        "Tidal Revenant",
        "Alexstrasza the Life-Binder"
      ]) ->
        :"Brann Bronzebeard"

      min_count?(card_info, 36, [
        "Aquatic Form",
        "Pounce",
        "Battlefiend",
        "Burning Heart",
        "Feast and Famine",
        "Jolly Roger",
        "Lesser Jasper Spellstone",
        "Secure the Deck",
        "Sock Puppet Slitherspear",
        "Toxic Reinforcements",
        "Battleworn Vanguard",
        "Crooked Cook",
        "Deathmatch Pavilion",
        "Felfire Deadeye",
        "Lesser Opal Spellstone",
        "Manafeeder Panthara",
        "Multi-Strike",
        "Papercraft Angel",
        "Rake",
        "Savage Striker",
        "Stoneskin Armorer",
        "Wickerclaw",
        "Defias Cannoneer",
        "Hookfist-3000",
        "Ironclad",
        "Keeneye Spotter",
        "Pufferfist",
        "Silithid Swarmer",
        "Dragonbane",
        "Glaiveshark",
        "Going Down Swinging",
        "Park Panther",
        "Sand Art Elemental",
        "Savage Combatant",
        "Shockspitter",
        "Spread the Word",
        "Captain Galvangar",
        "Khaz'goroth",
        "Confessor Paletress",
        "Frost Giant"
      ]) ->
        :"Guff Runetotem"

      min_count?(card_info, 31, [
        "Howling Blast",
        "Plague Strike",
        "Death Strike",
        "Frost Strike",
        "Heart Strike",
        "Patchwerk",
        "Defrost",
        "Meat Grinder",
        "Graveyard Shift",
        "Vicious Bloodworm",
        "Body Bagger",
        "Harbinger of Winter",
        "Bone Breaker",
        "Stitched Giant",
        "Obliterate",
        "Bonedigger Geist",
        "Thassarian",
        "Blightfang",
        "Hardcore Cultist",
        "Climactic Necrotic Explosion",
        "The Primus",
        "Pile of Bones",
        "Fistful of Corpses",
        "Harrowing Ox",
        "Maw and Paw",
        "Crop Rotation",
        "Reska, the Pit Boss",
        "Mining Casualties",
        "Arthas's Gift",
        "Quartzite Crusher",
        "Rainbow Seamstress",
        "Threads of Despair",
        "Hematurge",
        "Necrotic Mortician",
        "Soulbreaker"
      ]) ->
        :Arfus

      true ->
        nil
    end
  end

  defp do_archetype(%{class: class, cards: c, format: 4}, card_info) do
    class_name = Deck.class_name(class)

    cond do
      result = twist_whizbangs_heros(card_info) ->
        result

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
    excavates = [
      "Smokestack",
      "Mo'arg Drillfist",
      "Tram Conductor Gerry" | @neutral_excavate
    ]

    min_count?(ci, 4, excavates) or
      (min_count?(ci, 2, excavates) and neutral_bouncers?(ci))
  end

  defp weapon_rogue?(card_info) do
    min_count?(card_info, 4, [
      "Air Guitarist",
      "Shadestone Skulker",
      "Valeera's Gift",
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
    min_count?(card_info, 2, [
      "Malfunction",
      "Spot the Difference",
      # what hdt uses for unknown cards
      "NOOOOOOOOOOOO",
      "Yogg in the Box",
      "Manufacturing Error"
    ])
  end

  defp burn_spell_mage?(card_info) do
    spell_mage?(card_info) and
      min_count?(card_info, 4, [
        "Flame Geyser",
        "Frostbolt",
        "Lightshow",
        "Molten Rune",
        "Fireball"
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
      "Sing-Along Buddy",
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

  defp do_archetype(%{class: class, cards: c, format: 1}, card_info) do
    class_name = Deck.class_name(class)

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

      "Darkbishop Benedictus" in card_info.card_names && class_name == "Priest" ->
        :"Shadow Priest"

      class_name == "Rogue" && wild_gnoll_miracle_rogue?(card_info) ->
        :"Gnoll Miracle Rogue"

      class_name == "Rogue" && wild_miracle_rogue?(card_info) ->
        :"Miracle Rogue"

      "Garrote" in card_info.card_names && class_name == "Rogue" ->
        :"Garrote Rogue"

      "Pirate Admiral Hooktusk" in card_info.card_names && class_name == "Rogue" ->
        :"Hooktusk Rogue"

      wild_alex_rogue?(card_info) ->
        :"Alex Rogue"

      class_name == "Rogue" && wild_thief_rogue?(card_info) ->
        :"Thief Rogue"

      lion_hunter?(card_info) ->
        :"Lion Hunter"

      wild_big_shaman?(card_info) ->
        :"Big Shaman"

      wild_combo_priest?(card_info) ->
        :"Combo Priest"

      ping_mage?(card_info) ->
        :"Ping Mage"

      class_name == "Demon Hunter" && "Jace Darkweaver" in card_info.card_names &&
          min_spell_school_count?(card_info, 5, "Fel") ->
        :"Jace Demon Hunter"

      min_secret_count?(card_info, 4) ->
        String.to_atom("Secret #{class_name}")

      outcast_dh?(card_info) ->
        :"Outcast DH"

      "Spirit of the Shark" in card_info.card_names && class_name == "Rogue" ->
        :"Shark Rogue"

      "Odyn, Prime Designate" in card_info.card_names && class_name == "Warrior" ->
        :"Odyn Warrior"

      wild_treant_druid?(card_info) ->
        :"Treant Druid"

      wild_exodia_paladin?(card_info) ->
        :"Exodia Paladin"

      "Warsong Commander" in card_info.card_names ->
        :"Warsong Warrior"

      aviana_druid?(card_info) ->
        :"Aviana Druid"

      wild_mill_druid?(card_info) ->
        :"Mill Druid"

      earthen_paladin?(card_info) ->
        :"Gaia Paladin"

      fel_dh?(card_info) ->
        :"Fel DH"

      "Sif" in card_info.card_names && class_name == "Mage" ->
        :"Sif Mage"

      excavate_rogue?(card_info) ->
        :"Drilling Rogue"

      overheal_priest?(card_info) ->
        :"Overheal Priest"

      sludgelock?(card_info) ->
        :"Sludge Warlock"

      fatigue_warlock?(card_info) ->
        :"Insanity Warlock"

      wild_rez_priest?(card_info) ->
        :"Rez Priest"

      true ->
        fallbacks(card_info, class_name)
    end
  end

  defp do_archetype(_, _), do: nil

  defp wild_rez_priest?(card_info) do
    min_count?(card_info, 3, [
      "Eternal Servitude",
      "Lesser Diamond Spellstone",
      "Mass Resurrection"
    ])
  end

  defp lion_hunter?(card_info) do
    min_count?(card_info, 2, ["Mok'Nathal Lion", "Mystery Egg"])
  end

  defp aviana_druid?(card_info) do
    "Aviana" in card_info.card_names
  end

  defp wild_thief_rogue?(card_info) do
    min_count?(card_info, 3, [
      "Wildpaw Gnoll",
      "Obsidian Shard",
      "Twisted Pack",
      "Tess Greymane",
      "Maestra of the Masquerade",
      "Velarok"
    ])
  end

  defp wild_mill_druid?(card_info) do
    min_count?(card_info, 3, ["Dew Process", "Coldlight Oracle", "Naturalize"])
  end

  defp wild_treant_druid?(card_info) do
    min_count?(card_info, 5, [
      "Cultivation",
      "Blood Treant",
      "Aeuroponics",
      "Overgrown Beanstalk",
      "Aerosoilizer",
      "Witchwood Apple",
      "Forest Seedlings",
      "Treenforcements",
      "Sow the Soil",
      "Soul of the Forest",
      "Plot of Sin"
    ])
  end

  defp wild_exodia_paladin?(card_info) do
    "Uther of the Ebon Blade" in card_info.card_names and
      min_count?(card_info, 2, [
        "Nozdormu the Timeless",
        "Sing-Along Buddy",
        "Garrison Commander"
      ])
  end

  defp wild_combo_priest?(card_info) do
    min_count?(card_info, 3, [
      "Inner Fire",
      "Divine Spirit",
      "Bless",
      "Radiant Elemental",
      "Power Word: Fortitude",
      "Grave Horror"
    ])
  end

  defp wild_big_shaman?(card_info) do
    min_count?(card_info, 2, ["Muckmorpher", "Eureka!", "Ancestor's Call"])
  end

  defp wild_gnoll_miracle_rogue?(card_info) do
    min_count?(card_info, 2, ["Wildpaw Gnoll", "Arcane Giant"])
  end

  defp wild_alex_rogue?(card_info) do
    "Spirit of the Shark" in card_info.card_names and
      "Alexstrasza the Life-Binder" in card_info.etc_sideboard_names
  end

  defp wild_miracle_rogue?(card_info) do
    min_count?(card_info, 3, [
      "Prize Plunderer",
      "Mailbox Dancer",
      "Arcane Giant",
      "Edwin VanCleef",
      "Scribbling Stenographer",
      "Zephrys the Great"
    ])
  end

  defp wild_thief_rogue?(card_info) do
    min_count?(
      card_info,
      4,
      [
        "Kaj'mite Creation",
        "Shell Game",
        "Obsidian Shard",
        "Velarok Windblade",
        "Vendetta",
        "Wildpaw Gnoll",
        "Stick Up",
        "Flint Firearm"
      ]
    )
  end

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
    min_spell_school_count?(ci, 5, "fel") and
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

  defp ramp_druid?(ci),
    do:
      min_count?(ci, 1, ["Nourish", "Crystal Cluster"]) or
        min_count?(ci, 2, ["Wild Growth", "Widowbloom Seedsman"])

  defp hero_power_druid?(ci),
    do: min_count?(ci, 2, ["Free Spirit", "Groovy Cat", "Sing-Along Buddy"])

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

  defp mystery_egg_hunter?(card_info) do
    min_count?(card_info, 1, ["Mystery Egg"])
  end

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

  defp cutlass_rogue?(ci),
    do:
      "Spectral Cutlass" in ci.card_names and
        min_count?(ci, 3, [
          "Deadly Poison",
          "Valeera's Gift",
          "Harmonic Hip Hop",
          "Mic Drop",
          "Shadestone Skulker",
          "Instrument Tech"
        ])

  defp cycle_rogue?(ci),
    do:
      min_count?(ci, 3, [
        "Fal'dorei Strider",
        "Triple Sevens",
        "Everything Must Go!",
        "Playhouse Giant",
        "Gear Shift",
        "Celestial Projectionist"
      ])

  defp pirate_rogue?(ci),
    do:
      min_count?(ci, 2, ["Toy Boat", "Raiding Party", "Treasure Distributor", "Dig for Treasure"])

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
        min_count?(ci, 4, [
          "Tess Greymane",
          "Twisted Pack",
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
          "Pipsi Painthoof",
          "Ragnaros the Firelord",
          "Annoy-o-Troupe",
          "Tirion Fordring",
          "Stoneborn General",
          "Neptulon the Tidehunter",
          "Flesh Behemoth",
          "Thaddius, Monstrosity"
        ])

  defp holy_paladin?(ci = %{card_names: card_names}) do
    min_count?(ci, 3, [
      "Hi Ho Silverwing",
      "Flickering Lightbot",
      "Holy Cowboy",
      "Starlight Groove",
      "Holy Glowsticks"
    ])
  end

  defp handbuff_paladin?(ci) do
    min_count?(ci, 2, ["Painter's Virtue", "Instrument Tech"]) or
      min_count?(ci, 3, [
        "Grimestreet Outfitter",
        "Muscle-o Tron",
        "Outfit Tailor",
        "Painter's Virtue",
        "Overlord Runthak"
      ])
  end

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

  defp boon_priest?(ci) do
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
          "Incriminating Psychic",
          "Plagiarizarrr",
          "Mind Eater",
          "Theft Accusation",
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
    do: min_count?(ci, 2, ["Flowrider", "Overdraft", "Inzah", "Thorim, Stormlord"])

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
    do: min_count?(ci, 2, ["Mountain Giant", "Table Flip"])

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

  defp min_count?(%{card_names: card_names}, min, cards) do
    min_count?(card_names, min, cards)
  end

  defp min_count?(card_names, min, cards) do
    min <= cards |> Enum.filter(&(&1 in card_names)) |> Enum.count()
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
         opts
       ) do
    fallback = Keyword.get(opts, :fallback, nil)
    min_count = Keyword.get(opts, :min_count, 6)
    ignore_types = Keyword.get(opts, :ignore_types, [])

    with counts = [_ | _] <- minion_type_counts(ci),
         filtered = [_ | _] <- Enum.reject(counts, &(to_string(elem(&1, 0)) in ignore_types)),
         {type, count} when count >= min_count <- Enum.max_by(filtered, &elem(&1, 1)) do
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

  @spec full_cards(Deck.t()) :: card_info()
  defp full_cards(%{cards: cards} = deck) do
    {full_cards, card_names} =
      Enum.map(cards, fn c ->
        with card = %{name: name} <- Backend.Hearthstone.get_card(c) do
          {card, name}
        end
      end)
      |> Enum.filter(& &1)
      |> Enum.unzip()

    zilliax_modules_names =
      Map.get(deck, :sideboards, []) |> Deck.zilliax_modules_cards() |> Enum.map(& &1.name)

    etc_sideboard_names =
      Map.get(deck, :sideboards, []) |> Deck.etc_sideboard_cards() |> Enum.map(& &1.name)

    %{
      full_cards: full_cards,
      card_names: card_names,
      cards: cards,
      zilliax_modules_names: zilliax_modules_names,
      etc_sideboard_names: etc_sideboard_names
    }
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

  defp splendiferous_whizbang?(ci) do
    # second part generated by Scratchpad.whizbang_codes_code
    "Splendiferous Whizbang" in ci.card_names or
      min_count?(ci, 16, [
        "Bloodmage Thalnos",
        "Dryscale Deputy",
        "Multicaster",
        "Thrive in the Shadows",
        "Wild Growth",
        "Hellfire",
        "Consecration",
        "Chaos Strike",
        "Coral Keeper",
        "Bash",
        "Remorseless Winter",
        "Hipster",
        "Celestial Shot",
        "Elemental Inspiration",
        "Fan of Knives",
        "Clearance Promoter"
      ]) or
      min_count?(ci, 16, [
        "Ci'Cigi",
        "Ball Hog",
        "Magtheridon, Unreleased",
        "Illidari Inquisitor",
        "Chaos Nova",
        "Aldrachi Warblades",
        "Chaos Strike",
        "Raging Felscreamer",
        "Eye Beam",
        "Illidari Studies",
        "Spirit of the Team",
        "Workshop Mishap",
        "Umpire's Grasp",
        "Red Card",
        "Window Shopper",
        "Wish"
      ]) or
      min_count?(ci, 6, [
        "Nourish",
        "Wild Growth",
        "Overgrowth",
        "Crystal Cluster",
        "Invigorate",
        "Moment of Discovery"
      ]) or
      min_count?(ci, 15, [
        "Emperor Thaurissan",
        "Acidmaw",
        "Dreadscale",
        "Zixor, Apex Predator",
        "Beastmaster Leoroxx",
        "King Krush",
        "Blademaster Okani",
        "The Sunwell",
        "Lor'themar Theron",
        "Astalor Bloodsworn",
        "Mister Mukla",
        "Zilliax",
        "Stranglethorn Heart",
        "Flint Firearm",
        "King Plush"
      ]) or
      min_count?(ci, 1, ["Morphing Card"]) or
      min_count?(ci, 10, [
        "Reno Jackson",
        "Brann Bronzebeard",
        "Elise Starseeker",
        "Sir Finley of the Sands",
        "Elise the Enlightened",
        "Reno the Relicologist",
        "Dinotamer Brann",
        "Dragonqueen Alexstrasza",
        "The Amazing Reno",
        "Sir Finley, Sea Guide"
      ]) or
      min_count?(ci, 15, [
        "Psychic Conjurer",
        "Shadow Word: Death",
        "Zola the Gorgon",
        "Love Everlasting",
        "Pip the Potent",
        "Shadow Word: Pain",
        "Thrive in the Shadows",
        "Holy Nova",
        "Holy Smite",
        "Lightbomb",
        "Crimson Clergy",
        "Fan Club",
        "Celestial Projectionist",
        "Shattered Reflections",
        "Astral Automaton"
      ]) or
      min_count?(ci, 14, [
        "Fogsail Freebooter",
        "Shoplifter Goldbeard",
        "Sonya Waterdancer",
        "Deadly Poison",
        "Shadowstep",
        "Swashburglar",
        "Hench-Clan Burglar",
        "Mixtape",
        "Breakdance",
        "Kaja'mite Creation",
        "Quick Pick",
        "Dig for Treasure",
        "Sandbox Scoundrel",
        "Watercannon"
      ]) or
      min_count?(ci, 17, [
        "Neptulon",
        "Sir Finley Mrrgglton",
        "Scargil",
        "Quest Accepted!",
        "Siltfin Spiritwalker",
        "Ancestral Knowledge",
        "Finders Keepers",
        "Brrrloc",
        "Underbelly Angler",
        "Sludge Slurper",
        "Fishflinger",
        "South Coast Chieftain",
        "Spawnpool Forager",
        "Gorloc Ravager",
        "Clownfish",
        "Command of Neptulon",
        "Turn the Tides"
      ]) or
      min_count?(ci, 13, [
        "Chef Nomi",
        "Archivist Elysiana",
        "Blood Shard Bristleback",
        "Neeru Fireblade",
        "Rin, Orchestrator of Doom",
        "Fanottem, Lord of the Opera",
        "Barrens Scavenger",
        "Waste Remover",
        "Fracking",
        "Tar Slime",
        "Scarab Keychain",
        "Chaos Creation",
        "Furnace Fuel"
      ]) or
      min_count?(ci, 21, [
        "Arch-Thief Rafaam",
        "Dr. Boom, Mad Genius",
        "Rafaam's Scheme",
        "Dr. Boom's Scheme",
        "Hagatha's Scheme",
        "Togwaggle's Scheme",
        "Lazul's Scheme",
        "Heistbaron Togwaggle",
        "Arch-Villain Rafaam",
        "Swampqueen Hagatha",
        "Madame Lazul",
        "Dr. Boom",
        "EVIL Cable Rat",
        "EVIL Conscripter",
        "EVIL Miscreant",
        "Plot Twist",
        "Sinister Deal",
        "EVIL Totem",
        "Livewire Lance",
        "EVIL Quartermaster",
        "Shiv"
      ]) or
      min_count?(ci, 18, [
        "Body Bagger",
        "Rolling Stone",
        "Mosh Pit",
        "Halveria Darkraven",
        "Rush the Stage",
        "Climactic Necrotic Explosion",
        "Coordinated Strike",
        "Feast of Souls",
        "Crimson Sigil Runner",
        "Possessifier",
        "Defrost",
        "Chillfallen Baron",
        "Corpse Bride",
        "Bonedigger Geist",
        "Wrathscale Naga",
        "Snakebite",
        "SECURITY!!",
        "Tour Guide"
      ]) or
      min_count?(ci, 17, [
        "Wrath",
        "Kodohide Drumkit",
        "Zok Fogsnout",
        "Kiri, Chosen of Elune",
        "Shield Slam",
        "Shield Block",
        "Razorfen Rockstar",
        "Verse Riff",
        "Chorus Riff",
        "Bridge Riff",
        "Peaceful Piper",
        "Harmonic Mood",
        "Free Spirit",
        "Spread the Word",
        "Groovy Cat",
        "Woodcutter's Axe",
        "Tour Guide"
      ]) or
      min_count?(ci, 16, [
        "Overlord Runthak",
        "Deathbringer Saurfang",
        "Righteous Protector",
        "Annoy-o-Tron",
        "Nerubian Swarmguard",
        "Chillfallen Baron",
        "Vicious Bloodworm",
        "Blood Tap",
        "Darkfallen Neophyte",
        "Malignant Horror",
        "Disco Maul",
        "Jitterbug",
        "Funkfin",
        "Harmonic Metal",
        "Party Animal",
        "Grimestreet Outfitter"
      ]) or
      min_count?(ci, 16, [
        "Quick Shot",
        "Bounce Around (ft. Garona)",
        "Backstab",
        "Deadly Poison",
        "Tracking",
        "Shadowstep",
        "Preparation",
        "Gadgetzan Auctioneer",
        "Harmonica Soloist",
        "Beatboxer",
        "Breakdance",
        "Jungle Jammer",
        "Arrow Smith",
        "Bunch of Bananas",
        "Barrel of Monkeys",
        "Eviscerate"
      ]) or
      min_count?(ci, 17, [
        "Aegwynn, the Guardian",
        "Bloodmage Thalnos",
        "Saxophone Soloist",
        "Fire Sale",
        "Novice Zapper",
        "Lightning Bolt",
        "Lightning Storm",
        "Shooting Star",
        "Keyboard Soloist",
        "Lightshow",
        "Rewind",
        "Audio Splitter",
        "Flowrider",
        "Volume Up",
        "Overdraft",
        "Zap!",
        "Ancestral Knowledge"
      ]) or
      min_count?(ci, 20, [
        "Shadow Word: Death",
        "Siphon Soul",
        "Twisting Nether",
        "Lord Jaraxxus",
        "Drain Soul",
        "Rin, Orchestrator of Doom",
        "Love Everlasting",
        "Symphony of Sins",
        "Photographer Fizzle",
        "Shard of the Naaru",
        "Lightbomb",
        "Thrive in the Shadows",
        "Holy Nova",
        "Holy Smite",
        "Mortal Coil",
        "Doomsayer",
        "Opera Soloist",
        "Idol's Adoration",
        "Fight Over Me",
        "Defile"
      ]) or
      min_count?(ci, 16, [
        "Altruis the Outcast",
        "Metamorphosis",
        "Umberwing",
        "Imprisoned Antaen",
        "Raging Felscreamer",
        "Shadowhoof Slayer",
        "Crimson Sigil Runner",
        "Spectral Sight",
        "Priestess of Fury",
        "Satyr Overseer",
        "Furious Felfin",
        "Skull of Gul'dan",
        "Twin Slice",
        "Eye Beam",
        "Aldrachi Warblades",
        "Battlefiend"
      ]) or
      min_count?(ci, 17, [
        "Shudderwock",
        "Barista Lynchen",
        "Kronx Dragonhoof",
        "Galakrond, the Tempest",
        "Mana Tide Totem",
        "Far Sight",
        "Lifedrinker",
        "Mutate",
        "Sludge Slurper",
        "EVIL Totem",
        "Dragon's Pack",
        "Corrupt Elementalist",
        "Shield of Galakrond",
        "Devoted Maniac",
        "Invocation of Frost",
        "Faceless Corruptor",
        "Mogu Fleshshaper"
      ]) or
      min_count?(ci, 17, [
        "Dr. Boom, Mad Genius",
        "Zilliax",
        "Augmented Elekk",
        "Blastmaster Boom",
        "Brawl",
        "Shield Slam",
        "Town Crier",
        "Warpath",
        "Militia Commander",
        "Weapons Project",
        "Omega Assembly",
        "Dyn-o-matic",
        "Eternium Rover",
        "Clockwork Goblin",
        "Wrenchcalibur",
        "Omega Devastator",
        "Shield Block"
      ]) or
      min_count?(ci, 17, [
        "Spiritsinger Umbra",
        "Bloodreaver Gul'dan",
        "Skull of the Man'ari",
        "Lord Godfrey",
        "Doomsayer",
        "Doomguard",
        "Hellfire",
        "Mortal Coil",
        "Stonehill Defender",
        "Defile",
        "Kobold Librarian",
        "Dark Pact",
        "Lesser Amethyst Spellstone",
        "Carnivorous Cube",
        "Voidlord",
        "Voodoo Doll",
        "Possessed Lackey"
      ]) or
      min_count?(ci, 17, [
        "Edwin VanCleef",
        "Moroes",
        "Patches the Pirate",
        "The Caverns Below",
        "Backstab",
        "Novice Engineer",
        "Shadowstep",
        "Youthful Brewmaster",
        "Stonetusk Boar",
        "Southsea Deckhand",
        "Eviscerate",
        "Violet Teacher",
        "Preparation",
        "Swashburglar",
        "Gadgetzan Ferryman",
        "Mimic Pod",
        "Fan of Knives"
      ]) or
      min_count?(ci, 15, [
        "Ci'Cigi",
        "Ball Hog",
        "Magtheridon, Unreleased",
        "Illidari Inquisitor",
        "Chaos Nova",
        "Aldrachi Warblades",
        "Chaos Strike",
        "Raging Felscreamer",
        "Eye Beam",
        "Illidari Studies",
        "Spirit of the Team",
        "Workshop Mishap",
        "Umpire's Grasp",
        "Red Card",
        "Window Shopper"
      ]) or
      min_count?(ci, 10, [
        "Kun the Forgotten King",
        "Yogg-Saron, Master of Fate",
        "Convoke the Spirits",
        "Ultimate Infestation",
        "Eonar, the Life-Binder",
        "Overgrowth",
        "Wild Growth",
        "Nourish",
        "Crystal Cluster",
        "Invigorate"
      ]) or
      min_count?(ci, 14, [
        "Psychic Conjurer",
        "Shadow Word: Death",
        "Zola the Gorgon",
        "Love Everlasting",
        "Pip the Potent",
        "Crimson Clergy",
        "Thrive in the Shadows",
        "Holy Nova",
        "Holy Smite",
        "Lightbomb",
        "Astral Automaton",
        "Fan Club",
        "Celestial Projectionist",
        "Shadow Word: Pain"
      ]) or
      min_count?(ci, 14, [
        "Patches the Pirate",
        "Pirate Admiral Hooktusk",
        "Sonya Waterdancer",
        "Deadly Poison",
        "Shadowstep",
        "Swashburglar",
        "Filletfighter",
        "Hench-Clan Burglar",
        "Breakdance",
        "Kaja'mite Creation",
        "Quick Pick",
        "Dig for Treasure",
        "Sandbox Scoundrel",
        "Watercannon"
      ]) or
      min_count?(ci, 15, [
        "Scargil",
        "Finders Keepers",
        "Primalfin Lookout",
        "Underbelly Angler",
        "Sludge Slurper",
        "Fishflinger",
        "Serpentshrine Portal",
        "South Coast Chieftain",
        "Spawnpool Forager",
        "Gorloc Ravager",
        "Clownfish",
        "Command of Neptulon",
        "Brrrloc",
        "Turn the Tides",
        "Ancestral Knowledge"
      ]) or
      min_count?(ci, 13, [
        "Chef Nomi",
        "Archivist Elysiana",
        "Blood Shard Bristleback",
        "Neeru Fireblade",
        "Rin, Orchestrator of Doom",
        "Fanottem, Lord of the Opera",
        "Barrens Scavenger",
        "Waste Remover",
        "Fracking",
        "Tar Slime",
        "Scarab Keychain",
        "Chaos Creation",
        "Furnace Fuel"
      ]) or
      min_count?(ci, 15, [
        "Emperor Thaurissan",
        "Zixor, Apex Predator",
        "Astromancer Solarian",
        "Beastmaster Leoroxx",
        "Reliquary of Souls",
        "Serena Bloodfeather",
        "King Krush",
        "Blademaster Okani",
        "Lor'themar Theron",
        "Mister Mukla",
        "Zilliax",
        "Infinitize the Maxitude",
        "Velarok Windblade",
        "Flint Firearm",
        "King Plush"
      ]) or
      min_count?(ci, 19, [
        "Dr. Boom, Mad Genius",
        "Togwaggle's Scheme",
        "Heistbaron Togwaggle",
        "Swampqueen Hagatha",
        "Dark Pharaoh Tekahn",
        "Grand Lackey Erkh",
        "Madame Lazul",
        "Arch-Villain Rafaam",
        "Hagatha's Scheme",
        "EVIL Cable Rat",
        "EVIL Conscripter",
        "EVIL Miscreant",
        "Sinister Deal",
        "EVIL Recruiter",
        "Weaponized Wasp",
        "EVIL Totem",
        "Livewire Lance",
        "Whispers of EVIL",
        "EVIL Quartermaster"
      ]) or
      min_count?(ci, 15, [
        "Hallucination",
        "Multicaster",
        "Thrive in the Shadows",
        "Wild Growth",
        "Consecration",
        "Chaos Strike",
        "Coral Keeper",
        "Hellfire",
        "Bash",
        "Remorseless Winter",
        "Hipster",
        "Elemental Inspiration",
        "Patchwork Pals",
        "Clearance Promoter",
        "Primordial Glyph"
      ])
  end
end
