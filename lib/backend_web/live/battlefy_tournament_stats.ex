defmodule BackendWeb.BattlefyTournamentStatsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  data(tournaments_raw, :string, default: nil)
  data(tournament_ids, :list, default: nil)

  def mount(_params, session, socket) do
    {
      :ok,
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      |> assign(:page_title, "Battlefy MultiTournamentStats")
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <div>
          <div class="title is-2">Tournaments Stats</div>
          <FunctionComponents.Ads.below_title/>
          <.form for={%{}} as={:tournaments} phx-change="change">
            <label>One battlefy link per line:</label>
            <textarea name="tournaments" class="textarea has-text-black" placeholder="Enter tournament stats" value={@tournaments_raw} />
          </.form>
        </div>
        <div :if={{with_source_query, ids_query} = battlefy_tournaments_query(@tournament_ids)}>
          <a :if={with_source_query} target="_blank" href={~p"/tournament-lineups/stats?#{with_source_query}"}>Archetype Stats</a>
          <br>
          <a :if={with_source_query} target="_blank" href={~p"/tournament-lineups/popularity?#{with_source_query}"}>Popularity</a>
          <br>
          <a :if={with_source_query} target="_blank" href={~p"/tournament-lineups/matchups?#{with_source_query}"}>Matchups</a>
          <br>
          <a :if={ids_query} target="_blank" href={~p"/battlefy/tournaments-stats?#{ids_query}"}>Player Stats</a>
        </div>
      </div>
    """
  end

  defp battlefy_tournaments_query([_ | _] = ids) do
    source_ids = Enum.map(ids, &"battlefy|#{&1}")
    {%{"tournaments" => source_ids}, %{"tournaments" => ids}}
  end

  defp battlefy_tournaments_query(_), do: {nil, nil}

  def handle_event("change", %{"tournaments" => tournaments_raw}, socket) do
    tournament_ids =
      tournaments_raw
      |> String.split("\n")
      |> Enum.map(&Backend.Battlefy.tournament_link_to_id/1)
      |> Enum.filter(& &1)

    {:noreply, socket |> assign(tournaments_raw: tournaments_raw, tournament_ids: tournament_ids)}
  end
end
