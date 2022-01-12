defmodule BackendWeb.MaxNations2022NationLive do
  @moduledoc false
  use Surface.LiveView
  use BackendWeb.ViewHelpers
  import BackendWeb.LiveHelpers
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Backend.MaxNations2022
  alias Components.MaxNations2022LineupName, as: LineupName
  alias Components.ExpandableLineup

  data(nation, :string)
  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div class="container">
        <div class="title is-2">{@nation}</div>
          <table class="table" :if={lineups = MaxNations2022.get_nation_lineups(@nation)}>
            <thead>
              <tr>
                <th>Player</th>
                <th>Week</th>
                <th>Lineup</th>
              </tr>
            </thead>
            <tbody>
              <tr :for={l <- lineups}>
                <td><LineupName lineup_name={l.name}/></td>
                <td>{l.tournament_id}</td>
                <td><ExpandableLineup id={"#{l.tournament_id}#{l.name}"} lineup={l}/></td>
              </tr>
            </tbody>
          </table>
      </div>
    </Context>
    """
  end

  def handle_params(params, _uri, socket) do
    nation = params["nation"]
    {:noreply, socket |> assign(nation: nation)}
  end
  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

end
