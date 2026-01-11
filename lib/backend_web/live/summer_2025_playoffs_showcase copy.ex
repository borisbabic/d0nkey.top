defmodule BackendWeb.Summer2025PlayoffsShowcaseLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias FunctionComponents.Battlefy

  @tournament_ids [
    "6894fe4027e0c8001817fb64",
    "68952016453af600175f8c7c",
    "68951f3027e0c8001817fcd6"
  ]
  data(tournaments, :list)
  data(multi_query, :map)

  def mount(_params, session, socket) do
    tournaments = tournaments(@tournament_ids)

    multi_query =
      %{
        "tournaments" => Enum.map(@tournament_ids, &"battlefy|#{&1}")
      }

    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(:tournaments, tournaments)
     |> assign(:multi_query, multi_query)
     |> assign(:page_title, "Summer 2025 Playoffs")}
  end

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">Summer 2025 Playoffs</div>
      <div class="subtitle is-5">
        <a href={~p"/tournament-lineups/popularity?#{@multi_query}"}><span class="is-hidden-mobile">Archetype/Lineup </span>Popularity</a> |
        <a href={~p"/tournament-lineups/stats?#{@multi_query}"}><span class="is-hidden-mobile">Archetype</span> Winrates</a> |
        <a href={~p"/streaming-now?#{@multi_query}"}>Other Streams</a>
      </div>
      <div class="notification is-primary">
        Day 1 (Saturday): Swiss - no official stream<span class="is-hidden-mobile">, players may stream their POV</span>
      </div>
      <div class="notification is-primary">
        Day 2 (Sunday): Top 8 - <a href="https://www.twitch.tv/playhearthstone">Official Stream<HeroIcons.external_link /></a><span class="is-hidden-mobile"> and costreams</span>
      </div>
      <div :for={tournament <- @tournaments}>
        <Battlefy.tournament_card tournament={tournament} />
        <br>
      </div>
    </div>
    """
  end

  def tournaments(tournament_ids) do
    Enum.map(tournament_ids, &Backend.Battlefy.get_tournament/1)
    |> Enum.filter(& &1)
  end
end
