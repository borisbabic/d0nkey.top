defmodule Components.FantasyLeague do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.FantasyModal
  alias Components.RosterModal
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  alias Backend.Fantasy
  use BackendWeb.ViewHelpers
  prop(league, :any)

  def render(assigns = %{league: league = %{id: _}}) do
    ~H"""
      <div>
        <Context get={{ user: user }} >
          <div class="title is-2">{{ @league.name }} </div>
        
          <div class="level"> 
            <div class="level-left">

              <div class="level-item" :if={{ League.can_manage?(@league, user) }} >
                <div class="level-item">
                  <FantasyModal id={{ "edit_modal_#{@league.id}" }} league={{ @league }} title="Edit League"/>
                </div>
                <div class="level-item">
                  <a class="is-link button"  href="/fantasy/leagues/join/{{ @league.join_code }}">Join Link</a>
                </div>
              </div>

              <div class="level-item">
                <a class="is-link button"  href="/fantasy/leagues/{{ @league.id }}/draft">View Draft</a>
              </div>
              <div class="level-item is-5 tag is-info">
                Point System: {{ @league |> League.scoring_display() }}
              </div>
              <div class="level-item is-5 tag is-info" :if={{ @league.draft_deadline }}>
                Draft Deadline: {{ render_datetime(@league.draft_deadline) }}
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
             <tr :for={{ {lt, points} <- teams_with_points(@league) }}>
              <td>{{ lt |> LeagueTeam.display_name() }}</td>
              <td>{{ lt.owner |> User.display_name() }}</td>
              <td>{{ points }}</td>
              <td>
                <button  :if={{ false && League.can_manage?(@league, user) }} class="button" type="button" :on-click="remove_league_team" phx-value-id="{{ lt.id }}">Remove</button>
                <RosterModal id="roster_modal_{{lt.id}}" league_team={{ lt }} />
              </td>
            </tr>
              
            </tbody>
          </table>

        </Context>
      </div>
    """
  end

  defp teams_with_points(league) do
    results = Backend.FantasyCompetitionFetcher.fetch_results(league)

    league.teams
    |> Enum.map(fn t ->
      points =
        t.picks
        |> Enum.map(&(results |> Map.get(&1.pick) || 0))
        |> Enum.sum()

      {t, points}
    end)
    |> Enum.sort_by(&(&1 |> elem(1)), :desc)
  end

  def render(assigns) do
    ~H"""
    <div class="title is-2">League not found</div>
    """
  end

  def handle_event("remove_league_team", %{"id" => id}, socket) do
    Fantasy.delete_league_team(id)
  end
end
