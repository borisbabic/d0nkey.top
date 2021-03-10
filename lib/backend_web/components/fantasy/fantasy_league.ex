defmodule Components.FantasyLeague do
  @moduledoc false
  use Surface.LiveComponent
  alias Components.FantasyModal
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  alias Backend.Fantasy
  prop(league, :any)

  def render(assigns = %{league: %{id: _}}) do
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
                  <a class="link"  href="/fantasy/leagues/join/{{ @league.join_code }}">Join Link</a>
                </div>
              </div>

              <div class="level-item">
                <a class="link"  href="/fantasy/leagues/{{ @league.id }}/draft">Draft Link</a>
              </div>

            </div>
          </div>

          <table class="table is-fullwidth is-striped">
            <thead>
              <th>Team</th>
              <th>Owner</th>
              <th :if={{ League.can_manage?(@league, user) }}>
                Actions
              </th>
            </thead>
            <tbody>
             <tr :for={{ lt <- @league.teams }}>
              <td>{{ lt |> LeagueTeam.display_name() }}</td>
              <td>{{ lt.owner |> User.display_name() }}</td>
              <th :if={{ League.can_manage?(@league, user) }}>
                <button class="button" type="button" :on-click="remove_league_team" phx-value-id="{{ lt.id }}">Remove</button>
              </th>
            </tr>
              
            </tbody>
          </table>

        </Context>
      </div>
    """
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
