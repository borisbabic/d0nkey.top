defmodule BackendWeb.BattlefyTournamentDecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.TournamentLineupExplorer

  data(tournament_id, :list)
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
        <div class="title is-2">Explore Decks</div>
        <div id="nitropay-below-title-leaderboard"></div>
        <TournamentLineupExplorer id={"lineup_explorer#{@tournament_id}"}tournament_id={@tournament_id} tournament_source={"battlefy"}/>
      </div>
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
end
