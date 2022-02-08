defmodule BackendWeb.ExpandableLineupLive do
  @moduledoc false

  use BackendWeb, :surface_live_view_no_layout
  alias Components.ExpandableLineup
  alias Backend.DeckInteractionTracker, as: Tracker

  data(lineup_id, :list)
  data(current_index, :number, default: 0)
  data(user, :any)
  data(show_cards, :boolean)

  def mount(_params, p = %{"lineup_id" => lineup_id}, socket) do
    {:ok,
     socket
     |> assign(lineup_id: lineup_id, show_cards: !!p["show_cards"])
     |> assign_defaults(p)}
  end

  def render(assigns) do
    ~F"""
    <Context :if={lineup = Backend.Hearthstone.lineup(@lineup_id)} put={user: @user}>
      <ExpandableLineup id={@lineup_id} lineup={lineup} />
    </Context>
    """
  end

  def handle_event("show_cards", _, socket = %{assigns: %{show_cards: old}}) do
    {
      :noreply,
      socket
      |> assign(show_cards: !old)
    }
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
