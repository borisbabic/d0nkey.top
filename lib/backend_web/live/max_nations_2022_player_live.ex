defmodule BackendWeb.MaxNations2022PlayerLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Backend.MaxNations2022
  alias Components.ExpandableLineup

  data(player, :string)
  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-2"><a href={Routes.player_path(BackendWeb.Endpoint, :player_profile, @player)}>{@player}</a></div>
        <div class="subtitle is-5" :if={nation = MaxNations2022.get_nation(@player)}><a href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.MaxNations2022NationLive, nation)}>{nation}</a></div>
        <table class="table" :if={lineups = MaxNations2022.get_player_lineups(@player)}>
          <thead>
            <tr>
              <th>Week</th>
              <th>Lineup</th>
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
    </Context>
    """
  end

  def handle_params(params, _uri, socket) do
    player = params["player"]
    {:noreply, socket |> assign(player: player)}
  end
  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

end
