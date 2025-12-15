defmodule Components.CardsList do
  @moduledoc false
  use Surface.Component
  alias Components.DecklistCard
  alias Backend.Hearthstone
  alias Backend.Hearthstone.Deck.Sideboard
  alias Backend.UserManager.User
  alias Backend.UserManager.User.DecklistOptions
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
      <div class="decklist_card_container" :for={%{card: card, count: count, class: class, sideboard: sideboard} <- cards_to_display(@deck, @comparison, highlight_rotation(@highlight_rotation, @user), @user)} style="margin: 0; padding: 0;">
          <div class={"is-clickable": !!@on_card_click} phx-value-sideboard={sideboard} phx-value-card_id={card.id} :on-click={@on_card_click} >
            <DecklistCard
              show_mana_cost={true}
              deck_class={@deck_class}
              non_hover_class={class}
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

  @spec cards_to_display(Deck.t(), [integer] | nil, boolean, map() | nil) :: [display_info]
  defp cards_to_display(
         %{cards: cards, sideboards: sideboard} = deck,
         comparison,
         highlight_rotation,
         user
       ) do
    cards_map = card_map(cards, deck)

    {fade_unowned, owned_card_map} = owned_card_map(user)

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
        case {Map.get(comparison_map, CardBag.deckcode_copy_id(c.id)), Map.get(cards_map, c.id),
              highlight_rotation, fade_unowned} do
          {cc, {_, count}, _, _} when not is_nil(cc) -> {comparison_class(cc, count), count}
          {nil, {card, count}, true, _} -> {rotation_class(highlight_rotation, card), count}
          {nil, {card, count}, _, true} -> {unowned_class(card, count, owned_card_map), count}
          {_, {_card, count}, _, _} -> {nil, count}
          {_, nil, _, _} -> {"not-in-list", nil}
        end

      actual = %{card: c, count: count, class: class, sideboard: false}

      sideboards_after =
        sideboard
        |> Enum.filter(&(&1.sideboard == c.id))
        |> Enum.flat_map(&sideboard_display(&1, highlight_rotation, fade_unowned, owned_card_map))
        |> Hearthstone.sort_cards(cost: &Deck.card_mana_cost(deck, &1))

      [actual | sideboards_after]
    end)
  end

  defp unowned_class(card_raw, count, owned_card_map) do
    card = Card.dbf_id_for_collection_checks(card_raw)
    owned_count = Backend.CollectionManager.card_count(owned_card_map, card)

    cond do
      owned_count >= count -> nil
      owned_count > 0 -> "card-comparison-count-1"
      owned_count <= 0 -> "not-in-list"
    end
  end

  defp owned_card_map(%{current_collection: %{card_map: card_map}} = user)
       when is_map(card_map) do
    if user
       |> User.decklist_options()
       |> DecklistOptions.fade_missing_cards() do
      {true, card_map}
    else
      {false, card_map}
    end
  end

  defp owned_card_map(_), do: {false, nil}

  @spec sideboard_display(Sideboard.t(), boolean, boolean, map()) :: [display_info]
  defp sideboard_display(
         %{card: c, count: count, sideboard: sideboard},
         highlight_rotation,
         fade_unowned,
         owned_card_map
       ) do
    case Hearthstone.get_card(c) do
      nil ->
        []

      card ->
        class =
          case {highlight_rotation, fade_unowned} do
            {true, _} -> rotation_class(card)
            {_, true} -> unowned_class(card, count, owned_card_map)
            _ -> nil
          end

        [
          %{
            card: card,
            count: count,
            class: class,
            sideboard: sideboard
          }
        ]
    end
  end

  defp highlight_rotation(true, _), do: true

  defp highlight_rotation(_, %User{} = user) do
    user
    |> User.decklist_options()
    |> DecklistOptions.fade_rotating_cards()
  end

  defp highlight_rotation(hr, _), do: hr

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
    # ED
    1946,
    # unguro
    1952,
    # timeways
    1957
  ]
  @rotating_sets [
    # dgb
    1935,
    # perils
    1905,
    # whizbang,
    1897
  ]
  def rotation_class(true, card), do: rotation_class(card)
  def rotation_class(_highlight, _card), do: ""

  def rotation_class(%{card_set_id: id}) when id in @staying_sets, do: ""
  def rotation_class(%{card_set_id: id}) when id in @rotating_sets, do: "not-in-list"
  # core cards are left, and unknown
  def rotation_class(_), do: "card-comparison-count-1"

  defp comparison_class(%{rarity_id: 5}, _), do: "card-comparison-legendary"
  defp comparison_class(%{rarity: "LEGENDARY"}, _), do: "card-comparison-legendary"
  defp comparison_class(_, count), do: "card-comparison-count-#{count}"
end
