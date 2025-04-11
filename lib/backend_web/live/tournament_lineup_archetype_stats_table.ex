defmodule BackendWeb.TournamentLineupArchetypeStatsTable do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.Lineups.ArchetypeStatsTable
  alias Backend.Tournaments.Tournament
  alias Backend.Tournaments.ArchetypeStats
  data(user, :any)
  data(tournament_id, :string)
  data(tournament_source, :string)
  data(archetype_stats, :any)
  data(adjusted_winrate_type, :atom)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()}
  end

  def render(assigns) do
    ~F"""
      <div class="title is-2">Tournament Archetype Stats</div>
      <div class="subtitle is-6">
        <a href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}"}>Lineups</a>
        | <a href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}/popularity"}>Archetype Popularity</a>
        <span :if={link = Backend.Tournaments.get_any_link({@tournament_source, @tournament_id})}>
          | <a href={link}>Tournament</a>
        </span>
      </div>
      <FunctionComponents.Ads.below_title/>
      <div :if={@archetype_stats.loading}>
        Preparing stats...
      </div>
      <ArchetypeStatsTable adjusted_winrate_type={@adjusted_winrate_type.result || nil} :if={@archetype_stats.ok?}  id={"lineup_archetype_stats_table_#{@tournament_source}_#{@tournament_id}"} stats={@archetype_stats.result}/>
    """
  end

  def handle_params(params, _uri, socket) do
    tournament_id = params["tournament_id"]
    tournament_source = params["tournament_source"]

    assigns = [
      tournament_id: tournament_id,
      tournament_source: tournament_source
    ]

    {:noreply,
     socket
     |> assign(assigns)
     |> assign_async([:archetype_stats, :adjusted_winrate_type], fn ->
       archetype_stats(tournament_source, tournament_id)
     end)}
  end

  def archetype_stats("battlefy", tournament_id) do
    with {:ok, t} <- Backend.Battlefy.fetch_tournament(tournament_id),
         {:ok, as} <- Backend.Battlefy.archetype_stats(t) do
      awt = Tournament.tags(t) |> Enum.find(&ArchetypeStats.supports_adjusted_winrate?/1)
      {:ok, %{archetype_stats: as, adjusted_winrate_type: awt}}
    end
  end
end
