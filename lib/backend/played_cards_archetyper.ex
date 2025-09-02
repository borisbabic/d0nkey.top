# credo:disable-for-this-file Credo.Check.Refactor.CyclomaticComplexity
defmodule Backend.PlayedCardsArchetyper do
  @moduledoc false

  alias Backend.PlayedCardsArchetyper.DeathKnightArchetyper
  alias Backend.PlayedCardsArchetyper.DemonHunterArchetyper
  alias Backend.PlayedCardsArchetyper.DruidArchetyper
  alias Backend.PlayedCardsArchetyper.HunterArchetyper
  alias Backend.PlayedCardsArchetyper.MageArchetyper
  alias Backend.PlayedCardsArchetyper.PaladinArchetyper
  alias Backend.PlayedCardsArchetyper.PriestArchetyper
  alias Backend.PlayedCardsArchetyper.RogueArchetyper
  alias Backend.PlayedCardsArchetyper.ShamanArchetyper
  alias Backend.PlayedCardsArchetyper.WarlockArchetyper
  alias Backend.PlayedCardsArchetyper.WarriorArchetyper

  @type card_info :: %{
          card_names: [String.t()],
          full_cards: [Card.t()],
          cards: [integer()]
        }
  def archetype(cards, class, format \\ 2)

  def archetype(cards, class, format) when is_binary(class) and is_list(cards) do
    card_info = card_info(cards)

    case {Util.to_int_or_orig(format), class} do
      {2, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard(card_info)
      {1, "DEATHKNIGHT"} -> DeathKnightArchetyper.wild(card_info)
      {2, "DEMONHUNTER"} -> DemonHunterArchetyper.standard(card_info)
      {1, "DEMONHUNTER"} -> DemonHunterArchetyper.wild(card_info)
      {2, "DRUID"} -> DruidArchetyper.standard(card_info)
      {1, "DRUID"} -> DruidArchetyper.wild(card_info)
      {2, "HUNTER"} -> HunterArchetyper.standard(card_info)
      {1, "HUNTER"} -> HunterArchetyper.wild(card_info)
      {2, "MAGE"} -> MageArchetyper.standard(card_info)
      {1, "MAGE"} -> MageArchetyper.wild(card_info)
      {2, "PALADIN"} -> PaladinArchetyper.standard(card_info)
      {1, "PALADIN"} -> PaladinArchetyper.wild(card_info)
      {2, "PRIEST"} -> PriestArchetyper.standard(card_info)
      {1, "PRIEST"} -> PriestArchetyper.wild(card_info)
      {2, "ROGUE"} -> RogueArchetyper.standard(card_info)
      {1, "ROGUE"} -> RogueArchetyper.wild(card_info)
      {2, "SHAMAN"} -> ShamanArchetyper.standard(card_info)
      {1, "SHAMAN"} -> ShamanArchetyper.wild(card_info)
      {2, "WARLOCK"} -> WarlockArchetyper.standard(card_info)
      {1, "WARLOCK"} -> WarlockArchetyper.wild(card_info)
      {2, "WARRIOR"} -> WarriorArchetyper.standard(card_info)
      {1, "WARRIOR"} -> WarriorArchetyper.wild(card_info)
      _ -> nil
    end
  end

  def archetype(_cards, _, _), do: nil

  def all_archetypes(format) do
    Backend.Hearthstone.Deck.classes()
    |> Enum.flat_map(fn class ->
      config(format, class)
      |> Enum.map(fn {archetype, _} ->
        archetype
      end)
    end)
    |> Enum.uniq()
  end

  def full_config(format) do
    Backend.Hearthstone.Deck.classes()
    |> Map.new(fn class ->
      {class, config(format, class)}
    end)
  end

  def config(format, class) do
    case {format, class} do
      {2, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard_config()
      {1, "DEATHKNIGHT"} -> DeathKnightArchetyper.wild_config()
      {2, "DEMONHUNTER"} -> DemonHunterArchetyper.standard_config()
      {1, "DEMONHUNTER"} -> DemonHunterArchetyper.wild_config()
      {2, "DRUID"} -> DruidArchetyper.standard_config()
      {1, "DRUID"} -> DruidArchetyper.wild_config()
      {2, "HUNTER"} -> HunterArchetyper.standard_config()
      {1, "HUNTER"} -> HunterArchetyper.wild_config()
      {2, "MAGE"} -> MageArchetyper.standard_config()
      {1, "MAGE"} -> MageArchetyper.wild_config()
      {2, "PALADIN"} -> PaladinArchetyper.standard_config()
      {1, "PALADIN"} -> PaladinArchetyper.wild_config()
      {2, "PRIEST"} -> PriestArchetyper.standard_config()
      {1, "PRIEST"} -> PriestArchetyper.wild_config()
      {2, "ROGUE"} -> RogueArchetyper.standard_config()
      {1, "ROGUE"} -> RogueArchetyper.wild_config()
      {2, "SHAMAN"} -> ShamanArchetyper.standard_config()
      {1, "SHAMAN"} -> ShamanArchetyper.wild_config()
      {2, "WARLOCK"} -> WarlockArchetyper.standard_config()
      {1, "WARLOCK"} -> WarlockArchetyper.wild_config()
      {2, "WARRIOR"} -> WarriorArchetyper.standard_config()
      {1, "WARRIOR"} -> WarriorArchetyper.wild_config()
      _ -> []
    end
  end

  def card_info(cards) when is_list(cards) do
    cards
    |> Enum.uniq()
    |> Enum.reduce(%{card_names: [], full_cards: [], cards: []}, fn id,
                                                                    %{
                                                                      card_names: names,
                                                                      full_cards: full_cards,
                                                                      cards: ids
                                                                    } = carry ->
      case Backend.Hearthstone.get_deckcode_card(id) do
        %{name: name} = full_card ->
          %{
            card_names: [name | names],
            full_cards: [full_card | full_cards],
            cards: [id | ids]
          }

        _ ->
          carry
      end
    end)
  end
end
