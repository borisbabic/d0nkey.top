defmodule BackendWeb.WC2021Live do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.LiveHelpers

  alias Components.TournamentLineupExplorer
  alias Backend.Hearthstone.Lineup
  alias Backend.Blizzard
  alias Components.Dropdown
  alias Backend.DeckInteractionTracker, as: Tracker
  alias BackendWeb.Router.Helpers, as: Routes

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~F"""
    <Context  put={user: @user}>
      <div class="container">
        <div>
          <div>
            <div class="title is-2">WC 2021 decks</div>
            <div class="subtitle is-5">
              <a class="link" href="https://playhearthstone.com/en-gb/esports/tournament/world-championship-2021" target="_blank">
                Standings
              </a>

              <a class="link" href="https://www.youtube.com/hearthstoneesports/live" target="_blank">
                Stream
              </a>
            </div>

            <TournamentLineupExplorer id={"wc_2021"} tournament_id={"wc_2021"} tournament_source="import_command" show_page_dropdown={false} filters={%{"order_by" => {:asc, :name}}} page_size={100}>
            </TournamentLineupExplorer>
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end