defmodule Components.ExpandableLineup do
  @moduledoc false
  use Surface.LiveComponent
  alias Backend.Hearthstone.Deck
  alias Components.Decklist
  alias Backend.DeckInteractionTracker, as: Tracker

  prop(lineup, :map)
  prop(show_cards, :boolean, default: false)
  prop(track_copied, :boolean, default: true)
  prop(stats, :map, default: nil)

  def render(assigns) do
    ~H"""
    <div>
        <span :on-click="show_cards" class="is-clickable is-pulled-left" style="margin-top: 0.75em;">
          <span class="icon">
            <i :if={{ !@show_cards }} class="fas fa-eye"></i>
            <i :if={{ @show_cards }} class="fas fa-eye-slash"></i>
          </span>
        </span>
      <div class="columns">
        <div class=" column " :for={{ deck <- @lineup.decks |> sort(@stats) }} >
          <Decklist deck={{ deck }} show_cards={{ @show_cards }}/>
        </div>
      </div>
    </div>
    """
  end

  def sort(decks, stats) when is_map(stats) do
    decks |> Deck.sort() |> Enum.sort_by(&(stats |> Map.get(&1 |> Deck.class(), 1)), :desc)
  end

  def sort(decks, _), do: decks |> Deck.sort()

  def handle_event("show_cards", _, socket = %{assigns: %{show_cards: old, lineup: l}}) do
    {
      :noreply,
      socket
      |> assign(show_cards: !old)
    }
  end

  def handle_event(
        "deck_copied",
        %{"deckcode" => code},
        socket = %{assigns: %{track_copied: track_copied}}
      ) do
    if track_copied do
      Tracker.inc_copied(code)
    end

    {:noreply, socket}
  end
end
