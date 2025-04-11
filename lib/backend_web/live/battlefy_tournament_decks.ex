defmodule BackendWeb.BattlefyTournamentDecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.TournamentLineupExplorer
  alias Backend.DeckInteractionTracker, as: Tracker

  data(tournament_id, :list)
  data(user, :any)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Explore Decks</div>
        <div class="subtitle is-6">
          <a href={~p"/tournament-lineups/battlefy/#{@tournament_id}/popularity"}>Popularity</a>
          | <a href={~p"/tournament-lineups/battlefy/#{@tournament_id}/stats"}>Stats</a>
          <span :if={link = Backend.Tournaments.get_any_link({"battlefy", @tournament_id})}>
          | <a href={link}>Tournament</a>
          </span>
        </div>
        <FunctionComponents.Ads.below_title/>
        <TournamentLineupExplorer id={"lineup_explorer#{@tournament_id}"}tournament_id={@tournament_id} tournament_source={"battlefy"} />
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    tournament_id = params["tournament_id"]

    {
      :noreply,
      socket |> assign(tournament_id: tournament_id, show_cards: false)
    }
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
