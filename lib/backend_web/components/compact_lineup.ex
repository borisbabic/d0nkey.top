defmodule Components.CompactLineup do
  @moduledoc false
  use BackendWeb, :surface_live_component
  alias Backend.Hearthstone.Deck
  alias Backend.Hearthstone.Lineup
  alias Backend.Hearthstone
  alias Components.Decklist
  alias Backend.DeckInteractionTracker, as: Tracker

  # code or struct
  prop(extra_decks, :list, default: [])
  # id or struct
  prop(lineup, :any, default: nil)
  # structs
  data(decks, :list)
  data(selected_deck, :map, default: nil)

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> assign_decks() |> assign(selected_deck: nil)}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="decklist-info tabs is-fullwidth">
          <ul>
            <li :for={deck <- @decks} class={"is-active": selected_deck?(deck, @selected_deck)}>
              <a class={"player-name", Deck.class(deck) |> String.downcase()} :on-click={click_event(deck, @selected_deck)} phx-value-deckcode={Deck.deckcode(deck)}>
                <figure>
                    <img class="image is-16x16" src={"#{ BackendWeb.BattlefyView.class_url(Deck.class(deck)) }"} >
                </figure>
              </a>
            </li>
          </ul>
        </div>
        {#if @selected_deck}
          <Decklist deck={@selected_deck} />
        {/if}

      </div>
    """
  end

  defp selected_deck?(deck, selected_deck), do: Deck.equals?(deck, selected_deck)

  defp click_event(deck, selected_deck) do
    if selected_deck?(deck, selected_deck) do
      "unselect_deck"
    else
      "select_deck"
    end
  end

  defp assign_decks(%{assigns: %{extra_decks: extra_decks, lineup: lineup}} = socket) do
    from_extra = Enum.map(extra_decks, &parse_deck/1)
    from_lineup = parse_lineup(lineup)

    decks =
      (from_extra ++ from_lineup)
      |> Enum.filter(& &1)
      |> Enum.uniq_by(&Deck.deckcode/1)
      |> Deck.sort()

    assign(socket, decks: decks)
  end

  def parse_deck(%Deck{} = deck), do: deck

  def parse_deck(deckcode) do
    case Deck.decode(deckcode) do
      {:ok, deck} -> deck
      _ -> nil
    end
  end

  def parse_lineup(%Lineup{} = lineup), do: lineup.decks

  def parse_lineup(lineup_id) when is_integer(lineup_id) or is_binary(lineup_id),
    do: Hearthstone.lineup(lineup_id) |> parse_lineup()

  def parse_lineup(_), do: []

  def handle_event("select_deck", %{"deckcode" => deckcode}, %{assigns: %{decks: decks}} = socket) do
    selected = Enum.find(decks, &(Deck.deckcode(&1) == deckcode))

    {:noreply, assign(socket, selected_deck: selected)}
  end

  def handle_event("unselect_deck", _, socket) do
    {:noreply, assign(socket, selected_deck: nil)}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
