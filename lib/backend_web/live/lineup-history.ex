defmodule BackendWeb.LineupHistoryLive do
  use BackendWeb, :surface_live_view
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.ExpandableLineup

  data(name, :string)
  data(source, :string)
  data(user, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2"><a href={Routes.player_path(BackendWeb.Endpoint, :player_profile, @name)}>{@name}</a></div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
        <table class="table" :if={lineups = Backend.Hearthstone.lineup_history(@source, @name)}>
          <thead>
            <tr>
              <th>Submitted</th>
              <th>Decks</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={l <- lineups}>
              <td>{l.tournament_id}</td>
              <td><ExpandableLineup id={"#{l.tournament_id}#{l.name}"} lineup={l}/></td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    name = params["name"]
    source = params["source"]
    {:noreply, socket |> assign(name: name, source: source)}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
