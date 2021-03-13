defmodule Components.CompetitorsTable do
  @moduledoc false
  use Surface.LiveComponent

  alias Backend.Fantasy
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Surface.Components.Form
  alias Surface.Components.Form.TextInput

  prop(league, :map)
  prop(participants, :list, default: [])
  prop(search, :any, default: nil)
  prop(user, :any)

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> add_participants()}
  end

  def render(assigns) do
    ~H"""

     <div>
        <Form for={{ :search }} change="search" opts={{ autocomplete: "off" }}>
          <div class="columns is-mobile is-multiline">
            <div class="column is-narrow">
              <TextInput class="input" opts={{ placeholder: "Search" }}/>
            </div>
          </div>
        </Form>
        <table class="table is-fullwidth is-striped"> 
          <thead>
            <th>
              Competitor
            </th>
            <th>
              Status
            </th>
          </thead>
          <tbody>
            <tr :for={{ participant <- @participants |> filter(@search)}} >
              <td>{{ participant.name }}</td>
              <td>
                <div :if={{ picked_by = picked_by(@league, participant, @user) }}>
                  <div class="tag is-info"> {{ picked_by |> LeagueTeam.display_name() }}</div>
                </div>
                <div :if={{ has_current_pick?(@league, @user) && League.pickable?(@league, @user, participant.name) }}>
                  <button class="button" type="button" :on-click="pick" phx-value-name="{{ participant.name }}">Pick</button>
                </div>
                <div :if={{ !has_current_pick?(@league, @user) && League.pickable?(@league, @user, participant.name)}}>
                  <div class="tag">Available</div>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    """
  end

  defp picked_by(league = %{real_time_draft: true}, %{name: name}, _),
    do: league |> League.picked_by(name)

  defp picked_by(league = %{real_time_draft: false}, %{name: name}, user),
    do: !League.pickable?(league, user, name) && League.team_for_user(league, user)

  # defp current_team(league, user), do: league |> League.team_for_user(user)
  defp has_current_pick?(league = %{real_time_draft: false, roster_size: roster_size}, user) do
    lt = league |> League.team_for_user(user)
    lt && roster_size > Enum.count(lt.picks)
  end

  defp has_current_pick?(league = %{real_time_draft: true}, user),
    do: league |> League.drafting_now() |> LeagueTeam.can_manage?(user)

  def handle_event("search", %{"search" => [search]}, socket),
    do: {:noreply, assign(socket, :search, search)}

  def handle_event("pick", %{"name" => name}, socket = %{assigns: %{league: league, user: user}}) do
    Fantasy.make_pick(league, user, name)
    {:noreply, socket}
  end

  defp filter(participants, search) when is_binary(search) do
    down_search = search |> String.downcase()
    participants |> Enum.filter(&(String.downcase(&1.name) =~ down_search))
  end

  defp filter(participants, _), do: participants

  defp add_participants(socket = %{assigns: %{league: league}}) do
    p = league |> Backend.FantasyCompetitionFetcher.get_participants()
    socket |> assign(:participants, p)
  end

  defp add_participants(socket), do: socket
end