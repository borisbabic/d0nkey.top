# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.Hearthstone.DeckArchetyper do
  @moduledoc "Determines the archetype of a deck"
  alias Backend.Hearthstone.Deck

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

  def archetype(%{format: 2, cards: c, class: "DEMONHUNTER"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander DH"
      boar?(card_names) -> :"Boar Demon Hunter"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Demon Hunter"
      deathrattle_dh?(card_names) -> :"Deathrattle DH"
      big_dh?(card_names) -> :"Big Demon Hunter"
      jace_dh?(card_names) -> :"Jace Demon Hunter"
      murloc?(card_names) -> :"Murloc Demon Hunter"
      aggro_dh?(card_names) -> :"Aggro Demon Hunter"
      true -> "Demon Hunter"
    end
  end

  def archetype(%{format: 2, cards: c, class: "DRUID"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Druid"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Druid"
      boar?(card_names) -> :"Boar Druid"
      vanndar?(card_names) -> :"Vanndar Druid"
      celestial_druid?(card_names) -> :"Celestial Druid"
      ramp_druid?(card_names) -> :"Ramp Druid"
      murloc?(card_names) -> :"Murloc Druid"
      aggro_druid?(card_names) -> :"Aggro Druid"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "HUNTER"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Hunter"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Hunter"
      big_beast_hunter?(card_names) -> :"Big Beast Hunter"
      murloc?(card_names) -> :"Murloc Hunter"
      boar?(card_names) -> :"Boar Hunter"
      aggro_hunter?(card_names) -> :"Aggro Hunter"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "MAGE"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Mage"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Mage"
      vanndar?(card_names) -> "Vanndar Mage"
      naga_mage?(card_names) -> :"Naga Mage"
      mech_mage?(card_names) -> :"Mech Mage"
      big_spell_mage?(card_names) -> :"Big Spell Mage"
      murloc?(card_names) -> :"Murloc Mage"
      boar?(card_names) -> :"Boar Mage"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "PALADIN"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Paladin"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Paladin"
      handbuff_paladin?(card_names) -> :"Handbuff Paladin"
      mech_paladin?(card_names) -> :"Mech Paladin"
      holy_paladin?(card_names) -> :"Holy Paladin"
      kazakusan?(card_names) -> :"Kazakusan Paladin"
      vanndar?(card_names) -> "Vanndar Paladin"
      murloc?(card_names) -> :"Murloc Paladin"
      boar?(card_names) -> :"Boar Paladin"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "PRIEST"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Priest"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Priest"
      boar?(card_names) -> :"Boar Priest"
      wig_priest?(card_names) -> :"Wig Priest"
      shellfish_priest?(card_names) -> :"Shellfish Priest"
      vanndar?(card_names) && shadow_priest?(card_names) -> :"Vanndar Shadow Priest"
      vanndar?(card_names) -> :"Vanndar Priest"
      shadow_priest?(card_names) -> :"Shadow Priest"
      murloc?(card_names) -> :"Murloc Priest"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "ROGUE"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Rogue"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Rogue"
      mine_rogue?(card_names) -> :"Mine Rogue"
      pirate_rogue?(card_names) && thief_rogue?(card_names) -> :"Pirate Thief Rogue"
      thief_rogue?(card_names) -> :"Thief Rogue"
      boar?(card_names) -> :"Boar Rogue"
      pirate_rogue?(card_names) -> :"Pirate Rogue"
      vanndar?(card_names) -> :"Vanndar Rogue"
      deathrattle_rogue?(card_names) -> :"Deathrattle Rogue"
      murloc?(card_names) -> :"Murloc Rogue"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "SHAMAN"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Shaman"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Shaman"
      boar?(card_names) -> :"Boar Shaman"
      vanndar?(card_names) -> :"Vanndar Shaman"
      elemental_shaman?(card_names) -> :"Elemental Shaman"
      burn_shaman?(card_names) -> :"Burn Shaman"
      control_shaman?(card_names) -> :"Control Shaman"
      murloc?(card_names) -> :"Murloc Shaman"
      bloodlust_shaman?(card_names) -> :"Bloodlust Shaman"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "WARLOCK"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Warlock"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Warlock"
      murloc?(card_names) -> :"Murloc Warlock"
      boar?(card_names) -> :"Boar Warlock"
      phylactery_warlock?(card_names) -> :"Phylactery Warlock"
      agony_warlock?(card_names) -> :"Agony Warlock"
      abyssal_warlock?(card_names) -> :"Abyssal Warlock"
      true -> nil
    end
  end

  def archetype(%{format: 2, cards: c, class: "WARRIOR"}) do
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) -> :"Highlander Warrior"
      questline?(full_cards) && warrior_aoe?(card_names) -> :"Quest Control Warrior"
      quest?(full_cards) || questline?(full_cards) -> :"Quest Warrior"
      galvangar_combo?(card_names) -> :"Charge Warrior"
      warrior_aoe?(card_names) -> :"Control Warrior"
      warrior_aoe?(card_names) -> :"Control Warrior"
      weapon_warrior?(card_names) -> :"Weapon Warrior"
      murloc?(card_names) -> :"Murloc Warrior"
      boar?(card_names) -> :"Boar Warrior"
      true -> nil
    end
  end

  def archetype(%{class: class, cards: c, format: 1}) do
    class_name = Deck.class_name(class)
    {full_cards, card_names} = full_cards(c)

    cond do
      highlander?(c) ->
        String.to_existing_atom("Highlander #{class_name}")

      quest?(full_cards) || questline?(full_cards) ->
        String.to_existing_atom("Quest #{class_name}")

      boar?(card_names) ->
        String.to_atom("Boar #{class_name}")

      true ->
        nil
    end
  end

  def archetype(_), do: nil

  defp jace_dh?(card_names), do: "Jace Darkweaver" in card_names

  defp deathrattle_dh?(card_names),
    do:
      "Death Speaker Blackthorn" in card_names ||
        ("Tuskpiercier" in card_names && "Razorboar" in card_names)

  defp aggro_dh?(card_names),
    do:
      "Drek'Thar" in card_names || "Battlefiend" in card_names || "Irondeep Trogg" in card_names ||
        "Peasant" in card_names || "Metamorfin" in card_names

  defp big_dh?(card_names), do: "Sigil of Reckoning" in card_names || vanndar?(card_names)

  defp celestial_druid?(card_names), do: "Celestial Alignment" in card_names

  defp ramp_druid?(card_names),
    do: "Wildheart Guff" in card_names && ("Wild Growth" in card_names || "Nourish" in card_names)

  defp aggro_druid?(card_names),
    do:
      "Oracle of Elune" in card_names || "Clawflury Adept" in card_names ||
        "Peasant" in card_names || "Encumbered Pack Mule" in card_names

  defp big_beast_hunter?(card_names),
    do: "Azsharan Saber" in card_names || "Wing Commander Ichman" in card_names

  defp aggro_hunter?(card_names),
    do:
      ("Quick Shot" in card_names || "Piercing Shot" in card_names) &&
        ("Peasant" in card_names || "Irondeep Trogg" in card_names ||
           "Gnome Private" in card_names)

  defp pirate_rogue?(card_names),
    do: "Swordfish" in card_names || "Pirate Admiral Hooktusk" in card_names

  defp thief_rogue?(card_names), do: "Maestra of the Masquerade" in card_names

  defp mine_rogue?(card_names),
    do: "Naval Mine" in card_names && "Desecrated Graveyard" in card_names

  defp deathrattle_rogue?(card_names), do: "Desecrated Graveyard" in card_names

  defp naga_mage?(card_names), do: "Spitelash Siren" in card_names
  defp mech_mage?(card_names), do: "Mecha-Shark" in card_names

  defp big_spell_mage?(card_names),
    do:
      !mech_mage?(card_names) && "Grey Sage Parrot" in card_names &&
        ("Rune of the Archmage" in card_names || "Drakefire Amulet" in card_names)

  defp mech_paladin?(card_names), do: "Radar Detector" in card_names

  defp holy_paladin?(card_names),
    do:
      "The Garden's Grace" in card_names &&
        ("Righteous Defense" in card_names || "Battle Vicar" in card_names ||
           "Knight of Anointment" in card_names)

  defp handbuff_paladin?(card_names),
    do:
      "Prismatic Jewel Kit" in card_names &&
        ("First Blade of Wyrnn" in card_names || "Overlord Runthak" in card_names)

  defp shellfish_priest?(card_names),
    do: "Selfish Shellfish" in card_names && "Xyrella, the Devout" in card_names

  defp wig_priest?(card_names), do: "Serpent Wig" in card_names
  defp shadow_priest?(card_names), do: "Darkbishop Benedictus" in card_names

  defp burn_shaman?(card_names),
    do:
      min_count?(card_names, 3, [
        "Frostbite",
        "Lightning Bolt",
        "Scalding Geyser",
        "Bioluminescence"
      ])

  defp control_shaman?(card_names),
    do:
      !burn_shaman?(card_names) && "Bolner Hammerbeak" in card_names &&
        "Brann Bronzebeard" in card_names && "Bru'kan of the Elements" in card_names

  defp elemental_shaman?(card_names),
    do:
      min_count?(card_names, 4, [
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

  defp bloodlust_shaman?(card_names), do: "Bloodlust" in card_names

  defp phylactery_warlock?(card_names),
    do: "Tamsin's Phlactery" in card_names && "Tamsin Roame" in card_names

  defp abyssal_warlock?(card_names),
    do:
      min_count?(card_names, 3, ["Dragged Below", "Sira'kess Cultist", "Za'qul", "Abyssal Wave"])

  defp agony_warlock?(card_names), do: "Curse of Agony" in card_names

  defp galvangar_combo?(card_names, min_count \\ 4),
    do:
      min_count?(card_names, min_count, [
        "Captain Galvangar",
        "Faceless Manipulator",
        "Battleground Battlemaster",
        "To the Front!"
      ])

  defp warrior_aoe?(card_names, min_count \\ 2),
    do:
      min_count?(card_names, min_count, ["Shield Shatter", "Brawl", "Rancor", "Man the Cannons"])

  defp weapon_warrior?(card_names),
    do:
      min_count?(card_names, 3, [
        "Azsharan Trident",
        "Outrider's Axe",
        "Blacksmithing Hammer",
        "Lady Ashvane"
      ])

  defp murloc?(card_names),
    do:
      min_count?(card_names, 4, [
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

  defp min_count?(card_names, min, cards) do
    min <= cards |> Enum.filter(&(&1 in card_names)) |> Enum.count()
  end

  defp boar?(card_names), do: "Elwynn Boar" in card_names
  defp kazakusan?(card_names), do: "Kazakusan" in card_names
  defp highlander?(cards), do: Enum.count(cards) == Enum.count(Enum.uniq(cards))
  defp vanndar?(card_names), do: "Vanndar Stormpike" in card_names
  defp quest?(full_cards), do: Enum.any?(full_cards, &(&1.text && &1.text =~ "Quest:"))
  defp questline?(full_cards), do: Enum.any?(full_cards, &(&1.text && &1.text =~ "Questline:"))

  defp full_cards(cards) do
    Enum.map(cards, fn c ->
      with card = %{name: name} <- Backend.HearthstoneJson.get_card(c) do
        {card, name}
      end
    end)
    |> Enum.filter(& &1)
    |> Enum.unzip()
  end
end
