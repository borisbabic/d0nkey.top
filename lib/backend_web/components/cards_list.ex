defmodule Components.CardsList do
  @moduledoc false
  use Surface.Component
  alias Components.DecklistCard
  alias Backend.Hearthstone
  alias Backend.UserManager.User
  prop(cards, :list, required: true)
  prop(comparison, :any, required: false, default: nil)
  prop(highlight_rotation, :boolean, required: false)
  prop(deck_class, :string, required: false, default: "NEUTRAL")

  def render(assigns = %{cards: cards, comparison: comparison}) when is_list(comparison) do
    cards_map =
      cards
      |> Hearthstone.ordered_frequencies()
      |> Enum.map(fn {card, count} ->
        {card.id, {card, count}}
      end)
      |> Map.new()

    card = fn %{id: id} ->
      cards_map[id] |> elem(0)
    end

    count = fn %{id: id} ->
      cards_map[id] |> elem(1)
    end

    ~H"""
      <Context get={{ user: user }}>
        <div class="decklist_card_container" :for={{ cc <- comparison }}>
          <div :if={{ cards_map[cc.id]}} class="{{ comparison_class(cc, count.(cc)) }}">
            <DecklistCard  show_mana_cost={{ true }} deck_class={{ @deck_class }} card={{ card.(cc) }} count={{ count.(cc) }} decklist_options={{ User.decklist_options(user) }}/>
          </div>
          <div :if={{ !cards_map[cc.id] }} class="not-in-list">
            <DecklistCard show_mana_cost={{ true }} deck_class={{ @deck_class }} card={{ cc }} count={{ nil }} decklist_options={{ User.decklist_options(user) }}/>
          </div>
        </div>
      </Context>
    """
  end

  def render(assigns = %{cards: c}) do
    cards = c |> Hearthstone.ordered_frequencies()

    ~H"""
      <Context get={{ user: user }}>
        <div class="decklist_card_container" :for ={{ {card, count} <- cards }} style="margin: 0; padding: 0;">
            <div class="{{ rotation_class(@highlight_rotation, card) }}">
              <DecklistCard show_mana_cost={{ true }} deck_class={{ @deck_class }} card={{ card }} count={{ count }} decklist_options={{ User.decklist_options(user) }}/>
            </div>
        </div>
      </Context>
    """
  end

  def rotation_class(highlight, card), do: ""

  defp comparison_class(%{rarity: "LEGENDARY"}, _), do: "card-comparison-legendary"
  defp comparison_class(_, count), do: "card-comparison-count-#{count}"
end
