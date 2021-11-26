defmodule BackendWeb.TournamentLineups do
  use Surface.LiveView
  import BackendWeb.LiveHelpers
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
      <div class="container">
        <div :if={lineups = Backend.Hearthstone.get_lineups(@tournament_id, @tournament_source)} >
          <div :if={Lineup.stats(lineups)} >
            <div class="title is-2">Lineups</div>
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
