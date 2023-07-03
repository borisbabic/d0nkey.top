defmodule Components.FantasyLeaguesTable do
  use Surface.Component
  alias Backend.Fantasy.League
  alias Backend.UserManager.User
  import BackendWeb.FantasyHelper

  prop(leagues, :list, required: true)

  def render(assigns) do
    ~F"""
      <table class="table is-striped is-fullwidth">
        <thead>
          <th>
            Name
          </th>
          <th>
            Competition
          </th>
          <th>
            Owner
          </th>
          <th>
            Members
          </th>
        </thead>
        <tbody>
          <tr :for={league <- @leagues |> Enum.uniq_by(& &1.id)}>
            <td>
              <a href={"/fantasy/leagues/#{league.id}"}>{league.name}</a>
            </td>
            <td>
              {league |> competition_name()}
            </td>
            <td>
              {league.owner |> User.display_name()}
            </td>
            <td>
              {league |> League.teams() |> Enum.count()}
            </td>
          </tr>
        </tbody>
      </table>
    """
  end

  def update_leagues(id, leagues) do
    Phoenix.Component.send_update(__MODULE__, id: id, leagues: leagues)
  end
end
