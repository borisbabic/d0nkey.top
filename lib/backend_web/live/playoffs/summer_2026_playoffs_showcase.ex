defmodule BackendWeb.Summer2026PlayoffsShowcaseLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias FunctionComponents.Battlefy

  @tournament_ids [
    "6a4289c78a9628001313d372",
    "6a428cea3232ef0012e5f4bf",
    "6a428ed88a9628001313d3b0"
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
     |> assign(:page_title, "Summer 2026 Playoffs")}
  end

  def render(assigns) do
    ~F"""
    <div>
      <.page_header title={@page_title}>
        <:nav_links>
          <a href={~p"/tournament-lineups/popularity?#{@multi_query}"}><span class="is-hidden-mobile">Archetype/Lineup </span>Popularity</a>
          <a href={~p"/tournament-lineups/stats?#{@multi_query}"}><span class="is-hidden-mobile">Archetype</span> Winrates</a>
          <a href={~p"/streaming-now?#{@multi_query}"}>Other Streams</a>
          <a href="https://hearthstone.blizzard.com/news/24286286">Viewer Guide <HeroIcons.external_link /></a>
        </:nav_links>
      </.page_header>
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
