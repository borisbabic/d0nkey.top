defmodule Components.DraftPicksTable do
  @moduledoc false
  use Surface.LiveComponent
  use BackendWeb.ViewHelpers
  alias Backend.Fantasy.LeagueTeam
  prop(league, :map)

  def render(assigns) do
    ~F"""
      <table class="table is-fullwidth is-striped"> 
        <thead>
          <th>
            Competitor
          </th>
          <th>
            Picked By
          </th>
          <th>
            Picked at
          </th>
        </thead>
        <tbody>
          <tr :for={pick <- @league |> picks()} >
            <td>{pick.name}</td>
            <td>{pick.team_name}</td>
            <td>{pick.picked_at |> render_datetime()}</td>
          </tr>
        </tbody>
      </table>

    """
  end

  def picks(league) do
    league.teams
    |> Enum.flat_map(fn lt ->
      lt.picks
      |> Enum.map(
        &%{name: &1.pick, team_name: lt |> LeagueTeam.display_name(), picked_at: &1.inserted_at}
      )
    end)
    |> Enum.sort_by(&(&1.picked_at |> NaiveDateTime.to_iso8601()), :desc)
  end
end
