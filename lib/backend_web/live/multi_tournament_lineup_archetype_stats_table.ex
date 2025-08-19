defmodule BackendWeb.MultiTournamentLineupArchetypeStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_view
  import BackendWeb.MultiTournamentLineupPopularityTableLive, only: [links: 1]
  alias Components.Lineups.ArchetypeStatsTable

  data(user, :any)
  data(tournament_tuples, :list)
  data(raw_tournaments, :list)
  data(archetype_stats, :any)
  data(adjusted_winrate_type, :atom)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(:page_title, "Tournament Archetype Stats")}
  end

  def render(assigns) do
    ~F"""
      <div class="title is-2">{@page_title}</div>
      <div class="subtitle is-6">
        <a href={~p"/tournament-lineups/popularity?#{%{"tournaments" => @raw_tournaments}}"}>Archetype Popularity</a>
        <span :for={{link, display} <- links(@tournament_tuples)}>
          | <a href={link}>{display}</a>
        </span>
      </div>
      <FunctionComponents.Ads.below_title/>
      <div :if={@archetype_stats.loading}>
        Preparing stats...
      </div>
      <ArchetypeStatsTable adjusted_winrate_type={@adjusted_winrate_type.result || nil} :if={@archetype_stats.ok?}  id={"lineup_archetype_stats_table_#{Enum.count(@tournament_tuples)}"} stats={@archetype_stats.result}/>
    """
  end

  def handle_params(params, _uri, socket) do
    raw_tournaments = params["tournaments"]
    tournament_tuples = Backend.Hearthstone.parse_tournaments(raw_tournaments)

    assigns = [
      tournament_tuples: tournament_tuples,
      raw_tournaments: raw_tournaments
    ]

    {:noreply,
     socket
     |> assign(assigns)
     |> assign_async([:archetype_stats, :adjusted_winrate_type], fn ->
       Backend.Tournaments.multi_tournament_archetype_stats(tournament_tuples)
     end)}
  end
end
