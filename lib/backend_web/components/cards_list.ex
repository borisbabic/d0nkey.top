defmodule Components.CardsList do
  @moduledoc false
  use Surface.Component
  alias Components.DecklistCard
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck.Sideboard
  alias Backend.UserManager.User
  alias Backend.Hearthstone.Card
  prop(cards, :list, required: true)
  prop(comparison, :any, required: false, default: nil)
  prop(highlight_rotation, :boolean, required: false)
  prop(deck_class, :string, required: false, default: "NEUTRAL")
  prop(sideboard, :list, default: [])

  @type display_info :: %{
          card: Card.t(),
          count: integer | nil,
          class: String.t(),
          sideboarded_in: boolean
        }

  def render(assigns) do
    ~F"""
      <Context get={user: user}>
        <div class="decklist_card_container" :for={%{card: card, count: count, class: class, sideboarded_in: s_in} <- cards_to_display(@cards, @comparison, @sideboard, @highlight_rotation)} style="margin: 0; padding: 0;">
            <div class={class}>
              <DecklistCard
                show_mana_cost={true}
                deck_class={@deck_class}
                card={card}
                count={count}
                decklist_options={User.decklist_options(user)}
                sideboarded_in={s_in}
              />
            </div>
        </div>
      </Context>
    """
  end

  @spec cards_to_display([integer], [integer] | nil, [Sideboard.t()], boolean) :: [display_info]
  defp cards_to_display(cards, comparison, sideboard, highlight_rotation) do
    cards_map = card_map(cards)
    comparison_map = (comparison || []) |> Enum.map(&{&1.id, &1}) |> Map.new()

    to_check =
      comparison || Enum.map(cards_map, fn {_, {c, _}} -> c end) |> Hearthstone.sort_cards()

    to_check
    |> Enum.flat_map(fn c ->
      {class, count} =
        case {Map.get(comparison_map, c.id), Map.get(cards_map, c.id)} do
          {cc, {_, count}} when not is_nil(cc) -> {comparison_class(cc, count), count}
          {nil, {card, count}} -> {rotation_class(highlight_rotation, card), count}
          {_, nil} -> {"not-in-list", nil}
        end

      actual = %{card: c, count: count, class: class, sideboarded_in: false}

      sideboards_after =
        sideboard
        |> Enum.filter(&(&1.sideboard == c.id))
        |> Enum.flat_map(&sideboard_display(&1, highlight_rotation))
        |> Hearthstone.sort_cards(& &1.card)

      [actual | sideboards_after]
    end)
  end

  @spec sideboard_display(Sideboard.t(), boolean) :: [display_info]
  defp sideboard_display(%{card: c, count: count}, highlight_rotation) do
    case Hearthstone.get_card(c) do
      nil ->
        []

      card ->
        [
          %{
            card: card,
            count: count,
            class: rotation_class(highlight_rotation, card),
            sideboarded_in: true
          }
        ]
    end
  end

  defp add_sideboards(_), do: []

  defp card_map(cards) do
    cards
    |> Hearthstone.ordered_frequencies()
    |> Enum.map(fn {card, count} ->
      {card.id, {card, count}}
    end)
    |> Map.new()
  end

  def rotation_class(_highlight, _card), do: ""

  defp comparison_class(%{rarity_id: 5}, _), do: "card-comparison-legendary"
  defp comparison_class(%{rarity: "LEGENDARY"}, _), do: "card-comparison-legendary"
  defp comparison_class(_, count), do: "card-comparison-count-#{count}"
end
