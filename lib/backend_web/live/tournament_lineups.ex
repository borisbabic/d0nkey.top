defmodule BackendWeb.TournamentLineups do
  use BackendWeb, :surface_live_view
  alias Components.TournamentLineupExplorer
  alias Backend.Hearthstone.Lineup
  alias Backend.DeckInteractionTracker, as: Tracker
  data(user, :any)
  data(tournament_id, :string)
  data(tournament_source, :string)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~F"""
    <Context  put={user: @user}>
      <div>
        <div :if={lineups = Backend.Hearthstone.get_lineups(@tournament_id, @tournament_source)} >
          <div>
            <div class="title is-2">Lineups</div>
            <div id="nitropay-below-title-leaderboard"></div>
            <TournamentLineupExplorer id={"tournament_lineup_explorer_#{@tournament_source}_#{@tournament_id}"} tournament_id={"#{@tournament_id}"} tournament_source={"#{@tournament_source}"} />
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def handle_params(params, _uri, socket) do
    {:noreply,
     socket
     |> assign(
       tournament_id: params["tournament_id"],
       tournament_source: params["tournament_source"]
     )}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
