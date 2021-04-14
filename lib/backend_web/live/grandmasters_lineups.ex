defmodule BackendWeb.GrandmastersLineup do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.LiveHelpers

  alias Components.ExpandableLineup
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~H"""
    <Context  put={{ user: @user }}>
      <div class="container">
        <div class="title is-2">Grandmasters Decks</div>
        <table class="table is-striped is-narrow is-fullwidth"> 
          <thead>
            <tr>
              <th>Name</th>
              <th>Decks</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={{ lineup <- Backend.Blizzard.get_grandmasters_lineups() |> Enum.sort_by(& String.upcase(&1.name)) }}>
              <td> {{ lineup.name }} </td>
              <td> 
                <ExpandableLineup lineup={{ lineup }} id={{"modal_lineup_#{lineup.id}"}}/>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </Context>
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
