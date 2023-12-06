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
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div :if={lineups = Backend.Hearthstone.get_lineups(@tournament_id, @tournament_source)} >
          <div>
            <div class="title is-2">Lineups</div>
            <FunctionComponents.Ads.below_title/>
            <TournamentLineupExplorer id={"tournament_lineup_explorer_#{@tournament_source}_#{@tournament_id}"} tournament_id={"#{@tournament_id}"} tournament_source={"#{@tournament_source}"} />
          </div>
        </div>
      </div>
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
