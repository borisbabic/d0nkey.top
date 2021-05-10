defmodule Components.CompetitorsTable do
  @moduledoc false
  use Surface.LiveComponent

  alias Backend.Fantasy
  alias Backend.Fantasy.League
  alias Backend.Fantasy.Competition.Participant
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
        <Form for={{ :search }} change="search" submit="search" opts={{ autocomplete: "off" }}>
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
            <th :for={{ column <- competition_specific_columns(@league)}}>
              {{ column }}
            </th>
            <th>
              Status
            </th>
          </thead>
          <tbody>
            <tr :for={{ participant <- @participants |> filter(@search) |> cut(@league) }} >
              <td>{{ participant.name }}</td>
              <td :for={{ value <- competition_specific_columns(@league, participant)}}>
                {{ value }}
              </td>
              <td>
                <div :if={{ picked_by = picked_by(@league, participant, @user) }}>
                  <div :if={{ !League.unpickable?(@league, picked_by, @user, participant.name) }}class="tag is-info"> {{ picked_by |> LeagueTeam.display_name() }}</div>
                  <button :if={{ League.unpickable?(@league, picked_by, @user, participant.name) }} class="button" type="button" :on-click="unpick" phx-value-league_team="{{picked_by.id}}" phx-value-pick="{{ participant.name }}">
                    Unpick
                  </button>
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

  defp cut(participants, %{competition_type: "card_changes"}), do: participants |> Enum.take(20)
  defp cut(participants, _), do: participants |> Enum.take(500)
  defp competition_specific_columns(%{competition_type: "masters_tour"}), do: ["Signed Up"]
  defp competition_specific_columns(_), do: []

  defp competition_specific_columns(%{competition_type: "masters_tour"}, p) do
    if p |> Participant.in_battlefy?() do
      ["Yes"]
    else
      ["No"]
    end
  end

  defp competition_specific_columns(_, _), do: []

  def handle_event(
        "unpick",
        %{"pick" => pick, "league_team" => lt_string_id},
        socket = %{assigns: %{user: u}}
      ) do
    new_socket =
      with {lt_id, _} <- Integer.parse(lt_string_id),
           {:ok, league} <- Fantasy.unpick(lt_id, u, pick) do
        socket |> assign(league: league)
      else
        _ -> socket
      end

    {:noreply, new_socket}
  end

  defp picked_by(league = %{real_time_draft: true}, %{name: name}, _),
    do: league |> League.picked_by(name)

  defp picked_by(league = %{real_time_draft: false}, %{name: name}, user),
    do: !League.pickable?(league, user, name) && League.team_for_user(league, user)

  # defp current_team(league, user), do: league |> League.team_for_user(user)
  defp has_current_pick?(league = %{real_time_draft: false, roster_size: roster_size}, user) do
    lt = league |> League.team_for_user(user)
    lt && roster_size > LeagueTeam.current_roster_size(lt)
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
