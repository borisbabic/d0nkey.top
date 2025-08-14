defmodule BackendWeb.MultiTournamentLineupPopularityTableLive do
  use BackendWeb, :surface_live_view
  alias Components.Lineups.PopularityTable
  data(user, :any)
  data(tournament_tuples, :list)
  data(raw_tournaments, :list)
  data(lineups, :any)
  data(deck_group_size, :integer)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(:page_title, "Multi Tournament Archetype Popularity")}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div>
          <div>
            <div class="title is-2">{@page_title}</div>
            <div class="subtitle is-6">
              <a href={~p"/tournament-lineups/stats?#{%{"tournaments" => @raw_tournaments}}"}>Archetype Stats</a>
              <span :if={@lineups.ok?}> | Total Lineups: {Enum.count(@lineups.result)}</span>
              <span :for={{link, display} <- links(@tournament_tuples)}>
                | <a href={link}>{display}</a>
              </span>
            </div>
            <FunctionComponents.Ads.below_title/>
            <PopularityTable :if={@lineups.ok?} deck_group_size={@deck_group_size} id={"lineup_popularity_table_#{Enum.count(@tournament_tuples)}"} lineups={@lineups.result}/>
          </div>
        </div>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    raw_tournaments = params["tournaments"]
    tournament_tuples = Backend.Hearthstone.parse_tournaments(raw_tournaments)
    deck_group_size = params["deck_group_size"] |> Util.to_int_or_orig()

    assigns = [
      tournament_tuples: tournament_tuples,
      raw_tournaments: raw_tournaments,
      deck_group_size: deck_group_size
    ]

    {:noreply,
     socket
     |> assign(assigns)
     |> Components.LivePatchDropdown.update_context(
       __MODULE__,
       %{"deck_group_size" => deck_group_size, "tournaments" => raw_tournaments}
     )
     |> assign_async(:lineups, fn ->
       lineups = Backend.Hearthstone.lineups([{"tournaments", tournament_tuples}])

       {:ok, %{lineups: lineups}}
     end)}
  end

  def links(tournament_tuples) do
    for {source, id} <- tournament_tuples,
        link = Backend.Tournaments.get_any_link({source, id}) do
      {link, id}
    end
  end
end
