defmodule BackendWeb.SummerChamps2022Live do
  @moduledoc false

  use BackendWeb, :surface_live_view

  alias Components.TournamentLineupExplorer
  alias Backend.DeckInteractionTracker, as: Tracker

  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~F"""
    <Context  put={user: @user}>
      <div>
        <div>
          <div>
            <div class="title is-2">Summer Champs Decks</div>
            <div class="subtitle is-5">
              <a class="link" href="https://playhearthstone.com/en-us/news/23788539" target="_blank">
                Info
              </a>

              <a class="link" href="https://www.youtube.com/Hearthstone/live" target="_blank">
                Stream
              </a>
            </div>
            <div id="nitropay-below-title-leaderboard"></div>

            <TournamentLineupExplorer id={"summer_champs_2022"} tournament_id={"62974ac9a643830800c8d125"} tournament_source="battlefy" show_page_dropdown={false} filters={%{"order_by" => {:asc, :name}}} page_size={100}>
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
