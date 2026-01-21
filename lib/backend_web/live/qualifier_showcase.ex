defmodule BackendWeb.QualifierShowcaseLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias FunctionComponents.Battlefy

  data(tournaments, :list)
  data(multi_query, :map)

  def mount(_params, session, socket) do
    tournament_ids = session["tournament_ids"]
    title = session["title"] || "Qualifiers"

    tournaments = tournaments(tournament_ids)

    multi_query =
      %{
        "tournaments" => Enum.map(tournament_ids, &"battlefy|#{&1}")
      }

    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(:tournaments, tournaments)
     |> assign(:multi_query, multi_query)
     |> assign(:page_title, title)}
  end

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">{@page_title}</div>
      <div class="subtitle is-5">
        <a href={~p"/tournament-lineups/popularity?#{@multi_query}"}><span class="is-hidden-mobile">Archetype/Lineup </span>Popularity</a> |
        <a href={~p"/tournament-lineups/stats?#{@multi_query}"}><span class="is-hidden-mobile">Archetype</span> Winrates</a> |
        <a href={~p"/streaming-now?#{@multi_query}"}>Streams</a>
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
