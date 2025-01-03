defmodule Components.CardsList do
  @moduledoc false
  use Surface.Component
  alias Components.DecklistCard
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck.Sideboard
  alias Backend.UserManager.User
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.CardBag
  prop(deck, :map, required: true)
  prop(comparison, :any, required: false, default: nil)
  prop(highlight_rotation, :boolean, required: false)
  prop(deck_class, :string, required: false, default: "NEUTRAL")
  prop(sideboard, :list, default: [])
  prop(on_card_click, :event, default: nil)
  prop(user, :map, from_context: :user)

  @type display_info :: %{
          card: Card.t(),
          count: integer | nil,
          class: String.t(),
          sideboarded_in: boolean
        }

  def render(assigns) do
    ~F"""
      <div class="decklist_card_container" :for={%{card: card, count: count, class: class, sideboard: sideboard} <- cards_to_display(@deck, @comparison, @highlight_rotation)} style="margin: 0; padding: 0;">
          <div class={class, "is-clickable": !!@on_card_click} phx-value-sideboard={sideboard} phx-value-card_id={card.id} :on-click={@on_card_click} >
            <DecklistCard
              show_mana_cost={true}
              deck_class={@deck_class}
              card={card}
              count={count}
              deck={@deck}
              decklist_options={User.decklist_options(@user)}
              disable_link={!!@on_card_click}
              sideboarded_in={!!sideboard}
            />
          </div>
      </div>
    """
  end

  @spec cards_to_display(Deck.t(), [integer] | nil, boolean) :: [display_info]
  defp cards_to_display(
         %{cards: cards, sideboards: sideboard} = deck,
         comparison,
         highlight_rotation
       ) do
    cards_map = card_map(cards, deck)

    comparison_map =
      (comparison || [])
      |> Enum.filter(& &1)
      |> Enum.map(&{Hearthstone.CardBag.deckcode_copy_id(&1.id), &1})
      |> Map.new()

    to_check =
      comparison ||
        Enum.map(cards_map, fn {_, {c, _}} -> c end)
        |> Hearthstone.sort_cards(cost: &Deck.card_mana_cost(deck, &1))

    to_check
    |> Enum.flat_map(fn c ->
      {class, count} =
        case {Map.get(comparison_map, CardBag.deckcode_copy_id(c.id)), Map.get(cards_map, c.id)} do
          {cc, {_, count}} when not is_nil(cc) -> {comparison_class(cc, count), count}
          {nil, {card, count}} -> {rotation_class(highlight_rotation, card), count}
          {_, nil} -> {"not-in-list", nil}
        end

      actual = %{card: c, count: count, class: class, sideboard: false}

      sideboards_after =
        sideboard
        |> Enum.filter(&(&1.sideboard == c.id))
        |> Enum.flat_map(&sideboard_display(&1, highlight_rotation))
        |> Hearthstone.sort_cards(cost: &Deck.card_mana_cost(deck, &1))

      [actual | sideboards_after]
    end)
  end

  @spec sideboard_display(Sideboard.t(), boolean) :: [display_info]
  defp sideboard_display(%{card: c, count: count, sideboard: sideboard}, highlight_rotation) do
    case Hearthstone.get_card(c) do
      nil ->
        []

      card ->
        [
          %{
            card: card,
            count: count,
            class: rotation_class(highlight_rotation, card),
            sideboard: sideboard
          }
        ]
    end
  end

  defp card_map(cards, deck) do
    cards
    # using the canoncial id fixes an issues with some cards not being shown
    # might be hacky might be useful overall
    |> Enum.map(&CardBag.deckcode_copy_id/1)
    |> Hearthstone.ordered_frequencies(cost: &Deck.card_mana_cost(deck, &1))
    |> Enum.map(fn {card, count} ->
      {card.id, {card, count}}
    end)
    |> Map.new()
  end

  @staying_sets [
    # dgb
    1935,
    # perils
    1905,
    # whizbang,
    1897
  ]
  @rotating_sets [
    # festival,
    1809,
    # titans
    1858,
    # badlands
    1892
  ]
  def rotation_class(true, %{card_set_id: id}) when id in @staying_sets, do: ""

  def rotation_class(true, %{card_set_id: id}) when id in @rotating_sets,
    do: "not-in-list"

  # core cards are left, and unknown
  def rotation_class(true, _),
    do: "card-comparison-count-1"

  def rotation_class(_highlight, _card), do: ""

  defp comparison_class(%{rarity_id: 5}, _), do: "card-comparison-legendary"
  defp comparison_class(%{rarity: "LEGENDARY"}, _), do: "card-comparison-legendary"
  defp comparison_class(_, count), do: "card-comparison-count-#{count}"
end
