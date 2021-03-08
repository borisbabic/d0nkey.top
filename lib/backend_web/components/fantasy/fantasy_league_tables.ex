defmodule Components.FantasyLeaguesTable do
  use Surface.Component
  alias Backend.Fantasy.League
  alias Backend.UserManager.User

  prop(leagues, :list, required: true)

  def render(assigns) do
    ~H"""
      <table class="table is-striped is-fullwidth">
        <thead>
          <th>
            Name
          </th>
          <th>
            Link
          </th>
          <th>
            Owner
          </th>
          <th>
            Members
          </th>
        </thead>
        <tbody>
          <tr :for={{ league <- @leagues |> Enum.uniq_by(& &1.id)}}>
            <td>
              {{ league.name }}
            </td>
            <td>
              <a href="/fantasy/leagues/{{ league.id }}">View</a>
            </td>
            <td>
              {{ league.owner |> User.display_name() }}
            </td>
            <td>
              {{ league |> League.teams() |> Enum.count() }} / {{ league.max_teams }}
            </td>
          </tr>
        </tbody>
      </table>
    """
  end

  def update_leagues(id, leagues) do
    send_update(__MODULE__, id: id, leagues: leagues)
  end
end
