defmodule BackendWeb.TournamentLineupPopularityTableLive do
  use BackendWeb, :surface_live_view
  alias Components.Lineups.PopularityTable
  data(user, :any)
  data(tournament_id, :string)
  data(tournament_source, :string)
  data(lineups, :any)
  data(deck_group_size, :integer)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> put_user_in_context()
     |> assign(:page_title, "Tournament Archetype Popularity")}
  end

  def render(assigns) do
    ~F"""
      <div>
        <div>
          <div>
            <div class="title is-2">{@page_title}</div>
            <div class="subtitle is-6">
              <a href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}"}>Lineups</a>
              | <a href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}/stats"}>Archetype Stats</a>
              | <a href={~p"/tournament-lineups/#{@tournament_source}/#{@tournament_id}/matchups"}>Matchups</a>
              <span :if={link = Backend.Tournaments.get_any_link({@tournament_source, @tournament_id})}>
               | <a href={link}>Tournament</a>
              </span>
              <span :if={@lineups.ok?}>| Total Lineups: {Enum.count(@lineups.result)}</span>
            </div>
            <FunctionComponents.Ads.below_title/>
            <PopularityTable :if={@lineups.ok?} deck_group_size={@deck_group_size} id={"lineup_popularity_table_#{@tournament_source}_#{@tournament_id}"} lineups={@lineups.result}/>
          </div>
        </div>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    tournament_id = params["tournament_id"]
    tournament_source = params["tournament_source"]
    deck_group_size = params["deck_group_size"] |> Util.to_int_or_orig()

    assigns = [
      tournament_id: tournament_id,
      tournament_source: tournament_source,
      deck_group_size: deck_group_size
    ]

    {:noreply,
     socket
     |> assign(assigns)
     |> Components.LivePatchDropdown.update_context(
       __MODULE__,
       %{"deck_group_size" => deck_group_size},
       [tournament_source, tournament_id]
     )
     |> assign_async(:lineups, fn ->
       lineups =
         Backend.Hearthstone.lineups([
           {"tournament_id", tournament_id},
           {"tournament_source", tournament_source}
         ])

       {:ok, %{lineups: lineups}}
     end)}
  end
end
