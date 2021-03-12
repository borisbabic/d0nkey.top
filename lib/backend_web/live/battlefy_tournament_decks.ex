defmodule BackendWeb.BattlefyTournamentDecksLive do
  @moduledoc false

  import BackendWeb.LiveHelpers
  use Surface.LiveView
  alias Components.ExpandableLineup
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker

  data(tournament_id, :list)
  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    # ~H"""
    # <Context put={{ user: @user }}>
    # <div class="level">
    # <div :for={{ {class, index} <- @classes |> Enum.sort() |> Enum.with_index() }} class=" level-item deck-class-tab {{ class |> String.downcase()}} ">
    # A
    # </div>
    # </div>
    # <a class="button link" href="/deckviewer/@lineup_id">Deckviewer</a>
    # <button type="button" class="button"> Show </button>
    # </Context>
    # """

    ~H"""
    <Context  put={{ user: @user }}>
      <table> 
        <thead>
          <tr>
            <th>Name</th>
            <th>Decks</th>
          </tr>ExpandableDecklist
        </thead>
        <tbody>
          <tr :for={{ lineup <- Backend.Battlefy.lineups(@tournament_id) }}>
            <td> {{ lineup.name }} </td>
            <td> 
              <ExpandableLineup lineup={{ lineup }} id={{"modal_lineup_#{lineup.id}"}}/>
            </td>
          </tr>
        </tbody>
      </table>
    </Context>
    """
  end

  def handle_params(params, _uri, socket) do
    tournament_id = params["tournament_id"]

    {
      :noreply,
      socket |> assign(tournament_id: tournament_id, show_cards: false)
    }
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
