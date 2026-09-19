defmodule Components.DeckCardsHorizontal do
  @moduledoc """
  Displays the cards in a deck left-to-right in the same sorted order as Hearthstone decklists
  (mana cost ascending, then alphabetical, with any sideboard cards placed sequentially after their parent).
  Uses `Components.CompactCard` for each card.
  """

  use BackendWeb, :surface_component
  alias Components.CompactCard
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Card
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Deck.Sideboard

  prop(deck, :map, required: true)
  prop(shape, :string, default: "squarish")
  prop(size, :string, default: "md")
  prop(mode, :string, default: "card_top")
  prop(use_deck_card_cost, :boolean, default: true)
  prop(disable_links, :boolean, default: false)
  prop(show_tooltips, :boolean, default: true)
  prop(gap, :string, default: "0")
  prop(wrap, :boolean, default: true)
  prop(class, :string, default: "")
  data(cards_list, :list)

  def render(assigns) do
    deck = assigns[:deck]
    cards_list = cards_to_display(deck)

    assigns = assign(assigns, cards_list: cards_list)

    ~F"""
    <div class={["tw-flex tw-items-center", if(@wrap, do: "tw-flex-wrap", else: "tw-flex-nowrap"), gap_class(@gap), @class]}>
      {#for item <- @cards_list}
        <CompactCard
          card={item.card}
          count={item.count}
          deck={@deck}
          use_deck_card_cost={@use_deck_card_cost}
          sideboarded_in={item.sideboard?}
          disable_link={@disable_links}
          shape={@shape}
          size={@size}
          mode={@mode}
          show_tooltip={@show_tooltips}
        />
      {/for}
    </div>
    """
  end

  defp gap_class("0"), do: "tw-gap-0"
  defp gap_class("px"), do: "tw-gap-px"
  defp gap_class("0.5"), do: "tw-gap-0.5"
  defp gap_class("1"), do: "tw-gap-1"
  defp gap_class("1.5"), do: "tw-gap-1.5"
  defp gap_class("2"), do: "tw-gap-2"
  defp gap_class(_), do: "tw-gap-0"

  @doc """
  Extracts and sorts all cards to display for a deck in the exact same order as CardsList.
  """
  def cards_to_display(nil), do: []

  def cards_to_display(%{cards: cards} = deck) when is_list(cards) do
    {ordered_cards, sideboards_by_parent} = Deck.ordered_cards_with_sideboards(deck)

    Enum.flat_map(ordered_cards, fn {c, count} ->
      actual = %{card: c, count: count, sideboard?: false}

      sideboards_after =
        sideboards_by_parent
        |> Map.get(c.id, [])
        |> Enum.flat_map(&sideboard_items/1)
        |> Hearthstone.sort_cards(cost: &Deck.card_mana_cost(deck, &1))

      [actual | sideboards_after]
    end)
  end

  def cards_to_display(_), do: []

  defp sideboard_items(%Sideboard{card: card_id, count: count, sideboard: parent_id}) do
    sideboard_entry(card_id, count, parent_id)
  end

  defp sideboard_items(%{card: card_id, count: count, sideboard: parent_id}) do
    sideboard_entry(card_id, count, parent_id)
  end

  defp sideboard_items(_), do: []

  defp sideboard_entry(card_id, count, parent_id) do
    case Hearthstone.get_card(card_id) do
      nil ->
        []

      card ->
        actual_count = Card.multiply_count_for_sideboard(parent_id, count)
        [%{card: card, count: actual_count, sideboard?: true}]
    end
  end
end
