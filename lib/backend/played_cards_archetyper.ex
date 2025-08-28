defmodule Backend.PlayedCardsArchetyper do
  @moduledoc false

  alias Backend.PlayedCardsArchetyper.DeathKnightArchetyper

  @type card_info :: %{
          card_names: [String.t()],
          full_cards: [Card.t()],
          cards: [integer()]
        }
  def archetype(cards, class, format \\ 2) when is_binary(class) and is_list(cards) do
    card_info = card_info(cards)

    case {Util.to_int_or_orig(format), class} do
      {2, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard(card_info)
      {1, "DEATHKNIGHT"} -> DeathKnightArchetyper.standard(card_info)
      _ -> nil
    end
  end

  def archetype(_cards, _, _), do: nil

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
