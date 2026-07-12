defmodule BackendWeb.TournamentLineups do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.TournamentLineupExplorer
  alias Backend.DeckInteractionTracker, as: Tracker
  data(user, :any)
  data(tournament_id, :string)
  data(tournament_source, :string)
  data(twitch, :string)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign(page_title: "Lineups")
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div :if={Backend.Hearthstone.get_lineups(@tournament_id, @tournament_source)} >
          <div>
            <.page_header title="Lineups">
              <:nav_links>
                <a href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}/popularity"}>Popularity</a>
                <a :if={link = Backend.Tournaments.get_any_link({@tournament_source, @tournament_id})} href={link}>Tournament</a>
                <a :if={@user} href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}/export.csv"}>Export Lineups</a>
                <a :if={@twitch} :for={stream <- String.split(@twitch || "", "|")}href={"https://www.twitch.tv/#{stream}"} class="dropdown">
                  <img style="height: 20px;" class="image" alt={stream} src="/images/brands/twitch_extruded_wordmark_purple.svg"/>
                </a>
              </:nav_links>
            </.page_header>
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
       twitch: params["twitch"],
       tournament_source: params["tournament_source"]
     )}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
