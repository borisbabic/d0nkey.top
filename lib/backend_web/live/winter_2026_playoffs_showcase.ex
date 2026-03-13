defmodule BackendWeb.Winter2026PlayoffsShowcaseLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias FunctionComponents.Battlefy

  @tournament_ids [
    "69a9fb9cef8cb400130adee1",
    "69a9fb1fef8cb400130adec4",
    "69a9fab94fe28b0012b4bf8d"
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
     |> assign(:page_title, "Winter 2026 Playoffs")}
  end

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">{@page_title}</div>
      <div class="subtitle is-5">
        <a href={~p"/tournament-lineups/popularity?#{@multi_query}"}><span class="is-hidden-mobile">Archetype/Lineup </span>Popularity</a> |
        <a href={~p"/tournament-lineups/stats?#{@multi_query}"}><span class="is-hidden-mobile">Archetype</span> Winrates</a> |
        <a href={~p"/streaming-now?#{@multi_query}"}>Other Streams</a> |
        <a href="https://hearthstone.blizzard.com/en-us/news/24250390/hearthstone-esports-kicks-off-in-2026-with-the-winter-playoffs">Viewer Guide <HeroIcons.external_link /></a>
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
