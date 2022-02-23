defmodule Components.CompetitorsTable do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Backend.Fantasy
  alias Backend.MastersTour
  alias Backend.Fantasy.League
  alias Backend.Fantasy.Competition.Participant
  alias Backend.Fantasy.LeagueTeam
  alias Surface.Components.Form
  alias Components.PlayerName
  alias Surface.Components.Form.TextInput
  alias SurfaceBulma.Table
  alias SurfaceBulma.Table.Column

  alias Backend.TournamentStats.TournamentTeamStats
  alias Backend.TournamentStats.TeamStats

  prop(league, :map)
  prop(participants, :list, default: [])
  prop(search, :any, default: nil)
  prop(user, :any)
  prop(mt_stats, :map, default: nil)

  def update(assigns, socket) do
    {:ok, socket |> assign(assigns) |> add_participants() |> add_mt_stats()}
  end

  def render(assigns) do
    ~F"""
    <div>

      <Form for={:search} change="search" submit="search" opts={autocomplete: "off"}>
        <div class="columns is-mobile is-multiline">
          <div class="column is-narrow">
            <TextInput class="input" opts={placeholder: "Search"}/>
          </div>
        </div>
      </Form>
      <div :if={prepared = prepare_data(@participants, @league, @search)}>
        <Table id="competitiors_table" data={participant <- prepared} striped>
          <Column label="Competitor">
            {#if player_profile?(@league)}
              <PlayerName player={participant.name}/>
            {#else}
              <span>{participant.name}</span>
            {/if}
          </Column>
          <Column label="Status">
            <div :if={picked_by = picked_by(@league, participant, @user)}>
              <div :if={!League.unpickable?(@league, picked_by, @user, participant.name)}class="tag is-info"> {picked_by |> LeagueTeam.display_name()}</div>
              <button :if={League.unpickable?(@league, picked_by, @user, participant.name)} class="button" type="button" :on-click="unpick" phx-value-league_team={"#{picked_by.id}"} phx-value-pick={"#{participant.name}"}>
                Unpick
              </button>
            </div>
            <div :if={has_current_pick?(@league, @user) && League.pickable?(@league, @user, participant.name)}>
              <button class="button" type="button" :on-click="pick" phx-value-name={"#{participant.name}"}>Pick</button>
            </div>
            <div :if={!has_current_pick?(@league, @user) && League.pickable?(@league, @user, participant.name)}>
              <div class="tag">Available</div>
            </div>
          </Column>
        </Table>
      </div>
    </div>
    """
  end
  def prepare_data(participants, league, search), do: participants |> filter(search) |> Enum.uniq_by(& &1.name) |> cut(league)

  def player_profile?(league), do: gm?(league) || mt?(league)
  def gm?(%{competition_type: "grandmasters"}), do: true
  def gm?(_), do: false
  def mt?(%{competition_type: "masters_tour"}), do: true
  def mt?(_), do: false

  defp cut(participants, %{competition_type: "card_changes"}), do: participants |> Enum.take(20)
  defp cut(participants, _), do: participants |> Enum.take(500)

  defp picked_by(league = %{real_time_draft: true}, %{name: name}, _),
    do: league |> League.picked_by(name)

  defp picked_by(league = %{real_time_draft: false}, %{name: name}, user),
    do: !League.pickable?(league, user, name) && League.team_for_user(league, user)

  defp has_current_pick?(league = %{real_time_draft: false, roster_size: roster_size}, user) do
    lt = league |> League.team_for_user(user)
    lt && roster_size > LeagueTeam.current_roster_size(lt)
  end

  defp has_current_pick?(league = %{real_time_draft: true}, user),
    do: league |> League.drafting_now() |> LeagueTeam.can_manage?(user)

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

  defp add_mt_stats(socket = %{assigns: %{league: %{competition_type: "masters_tour"}}}) do
    map =
      Backend.MastersTour.masters_tours_stats()
      |> Backend.MastersTour.create_mt_stats_collection()
      |> Enum.map(fn {name, tts} ->
        stats =
          tts
          |> Enum.map(&TournamentTeamStats.total_stats/1)
          |> TeamStats.calculate_team_stats()
        {
          name,
          %{
            total: tts |> Enum.count(),
            wins: stats.wins,
            winrate: stats |> TeamStats.matches_won_percent() |> Float.round(2),
          }
        }
      end)
      |> Map.new()
    socket |> assign(:mt_stats, map)
  end
  defp add_mt_stats(socket), do: socket
end
