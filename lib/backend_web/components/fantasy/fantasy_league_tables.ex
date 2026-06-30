defmodule Components.FantasyLeaguesTable do
  use BackendWeb, :surface_component
  alias Backend.Fantasy.League
  alias Backend.UserManager.User
  import BackendWeb.FantasyHelper

  prop(leagues, :list, required: true)

  def render(assigns) do
    ~F"""
      <.table id="fantasy_leagues_table">
        <.thead>
          <.trh>
            <.th>
              Name
            </.th>
            <.th>
              Competition
            </.th>
            <.th>
              Owner
            </.th>
            <.th>
              Members
            </.th>
          </.trh>
        </.thead>
        <.tbody>
          <.trb :for={league <- @leagues |> Enum.uniq_by(& &1.id)}>
            <.td>
              <a href={"/fantasy/leagues/#{league.id}"}>{league.name}</a>
            </.td>
            <.td>
              {league |> competition_name()}
            </.td>
            <.td>
              {league.owner |> User.display_name()}
            </.td>
            <.td>
              {league |> League.teams() |> Enum.count()}
            </.td>
          </.trb>
        </.tbody>
      </.table>
    """
  end
end
