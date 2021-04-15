defmodule Components.FantasyLeague do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.FantasyModal
  alias Components.LeagueInfoModal
  alias Components.RosterModal
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  alias Backend.Fantasy
  alias Backend.FantasyCompetitionFetcher, as: ResultsFetcher
  use BackendWeb.ViewHelpers
  prop(league, :any)
  prop(round, :any, default: nil)

  def render(assigns = %{league: league = %{id: _}}) do
    ~H"""
      <div>
        <Context get={{ user: user }} >
          <div class="title is-2">{{ @league.name }} </div>
        
          <div class="level is-mobile "> 
            <div class="level-left">

              <div class="level-item" :if={{ League.can_manage?(@league, user) }} >
                  <FantasyModal id={{ "edit_modal_#{@league.id}" }} league={{ @league }} title="Edit League"/>
              </div>
              <div class="level-item" :if={{ !League.can_manage?(@league, user) }} >
                  <LeagueInfoModal id={{ "league_info_modal_#{@league.id}" }} league={{ @league }}/>
              </div>

              <div class="level-item dropdown is-hoverable">
                <div class="dropdown-trigger"><button aria-haspopup="true" aria-controls="dropdown-menu" class="button" type="button">{{ round_title(@league, @round) }}</button></div>
                <div class="dropdown-menu" role="menu">
                    <div class="dropdown-content">
                        <a  :for={{ r <- round_options(@league) }} :on-click="set_round" phx-value-round={{ r }} class="dropdown-item is-link {{ current_round_option(@league, @round) == r && 'is-active' || '' }}">{{ round_title(r) }}</a>
                    </div>
                </div>
              </div>

              <div class="level-item">
                <a class="is-link button"  href="/fantasy/leagues/{{ @league.id }}/draft">{{ draft_title(@league) }}</a>
              </div>

              <div class="level-item" :if={{ League.can_manage?(@league, user) }} >
                <a class="is-link button"  href="/fantasy/leagues/join/{{ @league.join_code }}">Join Link</a>
              </div>


            </div>
          </div>

          <table class="table is-fullwidth is-striped">
            <thead>
              <th>Team</th>
              <th>Owner</th>
              <th>Points</th>
              <th>Actions</th>
            </thead>
            <tbody>
             <tr :for={{ {lt, points} <- teams_with_points(@league, @round) }}>
              <td>{{ lt |> LeagueTeam.display_name() }}</td>
              <td>{{ lt.owner |> User.display_name() }}</td>
              <td>{{ points }}</td>
              <td>
                <button  :if={{ can_remove?(@league, user, lt) }} class="button" type="button" :on-click="remove_league_team" phx-value-id="{{ lt.id }}">Remove</button>
                <RosterModal id="roster_modal_{{lt.id}}" league_team={{ lt }} />
              </td>
            </tr>
              
            </tbody>
          </table>

        </Context>
      </div>
    """
  end

  def draft_title(%{real_time_draft: true}), do: "View Draft"
  def draft_title(%{real_time_draft: false}), do: "Manage Roster"

  def handle_event("set_round", %{"round" => round}, socket) do
    round_val =
      round
      |> Integer.parse()
      |> case do
        {r, _} -> r
        _ -> :all
      end

    {:noreply, socket |> assign(round: round_val)}
  end

  def round_title(league, round), do: current_round_option(league, round) |> round_title()
  def round_title("All"), do: "All Rounds"
  def round_title(round), do: "Round #{round}"

  def current_round_option(_, :all), do: "All"
  def current_round_option(league, round), do: League.round(league, round)

  def round_options(%{current_round: cr}) do
    ["All" | 1..cr |> Enum.into([])]
  end

  def can_remove?(league, user, league_team) do
    cond do
      !League.can_manage?(league, user) -> false
      !League.draft_started?(league) -> true
      league.real_time_draft -> false
      league_team.picks |> Enum.any?() -> false
      true -> true
    end
  end

  defp teams_with_points(league, round) do
    results =
      results_rounds(league, round)
      |> Enum.map(&{&1, ResultsFetcher.fetch_results(league, &1)})
      |> Map.new()

    league.teams
    |> Enum.map(fn t ->
      points =
        t.picks
        |> Enum.map(&(get_in(results, [&1.round, &1.pick]) || 0))
        |> Enum.sum()

      {t, points}
    end)
    |> Enum.sort_by(&(&1 |> elem(1)), :desc)
  end

  defp results_rounds(league, :all), do: 1..league.current_round |> Enum.into([])
  defp results_rounds(_, round) when is_integer(round), do: [round]
  defp results_rounds(league, _), do: [league.current_round]

  def render(assigns) do
    ~H"""
    <div class="title is-2">League not found</div>
    """
  end

  def handle_event("remove_league_team", %{"id" => id}, socket) do
    Fantasy.delete_league_team(id)
    {:noreply, socket}
  end
end
