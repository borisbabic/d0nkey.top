defmodule BackendWeb.BattlefyTournamentDecksLive do
  @moduledoc false

  import BackendWeb.LiveHelpers
  use Surface.LiveView
  alias Components.ExpandableLineup
  alias Components.TournamentLineupExplorer
  alias Backend.Hearthstone.Deck
  alias Backend.DeckInteractionTracker, as: Tracker

  data(tournament_id, :list)
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
        <div class="title is-1">Explore Decks</div>
        <TournamentLineupExplorer id={{ "lineup_explorer#{@tournament_id}" }}tournament_id={{ @tournament_id }} tournament_source={{ "battlefy" }}/>
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
