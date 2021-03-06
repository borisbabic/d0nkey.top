defmodule Components.FantasyLeaguesTable do
  use Surface.Component

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
        </thead>
        <tbody>
          <tr :for={{ league <- @leagues }}>
            <td>
              {{ league.name }}
            </td>
            <td>
              <a href="/fantasy/leagues/{{ league.id }}">View</a>
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
