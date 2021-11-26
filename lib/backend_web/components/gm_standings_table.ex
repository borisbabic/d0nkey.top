defmodule Components.GMStandingsTable do
  @moduledoc false
  use Surface.Component

  alias Backend.Grandmasters
  alias Components.GMProfileLink

  prop(region, :atom)

  def render(assigns) do
    ~F"""
      <table class="table is-fullwidth"> 
        <thead>
          <tr>
            <th>#</th>
            <th>Player</th>
            <th class="is-hidden-mobile" :for={week <- weeks()}>{week}</th>
            <th>Total Points</th>
          </tr>
        </thead>
        <tbody>
          <tr :for.with_index={{{player, total_results}, index} <- Grandmasters.region_results(@region)} class={"#{class(index)}"} >
            <td>{index + 1}.</td>
            <td><GMProfileLink link_class={class(index)} gm={player}/></td>
            <td class="is-hidden-mobile" :for={week <- weeks()}>{weekly_results(player, week)}</td>
            <td>{total_results}</td>
          </tr>
        </tbody>
      </table>
    """
  end

  def class(index) when index < 2, do: "gm-standings-playoff-top"
  def class(index) when index < 6, do: "gm-standings-playoff"
  def class(index) when index < 8, do: "gm-standings-playoff-bottom"
  def class(index) when index < 12, do: "gm-standings-boring"
  def class(_), do: "gm-standings-relegated"

  def weeks(), do: BackendWeb.GrandmastersLive.weeks()

  def weekly_results(player, week) do
    Grandmasters.results(week)
    |> Grandmasters.get_points(player)
  end
end
