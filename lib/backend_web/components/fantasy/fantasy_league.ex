defmodule Components.FantasyLeague do
  @moduledoc false
  use Surface.Component
  alias Components.FantasyModal
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  prop(league, :map)

  def render(assigns = %{league: %{id: _}}) do
    ~H"""
      <div>
        <Context get={{ user: user }} >
          <div class="title is-2">{{ @league.name }} </div>
        
          <div :if={{ League.can_manage?(@league, user) }} >

            <div class="level">
              <div class="level-left">
                <div class="level-item">
                  <FantasyModal id={{ "edit_modal_#{@league.id}" }} league={{ @league }} title="Edit League"/>
                </div>
                <div class="level-item">
                  <a class="link"  href="/fantasy/leagues/join/{{ @league.join_code }}">Join Link</a>
                </div>
              </div>
            </div>
          </div>

          <table class="table is-fullwidth is-striped">
            <thead>
              <th>Team</th>
              <th>Owner</th>
            </thead>
            <tbody>
             <tr :for={{ lt <- @league.teams }}>
              <td>{{ lt |> LeagueTeam.display_name() }}</td>
              <td>{{ lt.owner |> User.display_name() }}</td>
            </tr>
              
            </tbody>
          </table>

        </Context>
      </div>
    """
  end
end
