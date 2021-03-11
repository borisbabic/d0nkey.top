defmodule BackendWeb.FantasyDraftLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Fantasy
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  alias BackendWeb.Presence
  alias Components.CompetitorsTable
  alias Components.RosterModal
  alias Components.DraftOrderModal
  import BackendWeb.LiveHelpers

  data(league, :map)
  data(user, :any)
  data(present, :list)

  def mount(params, session, s) do
    socket = s |> assign_defaults(session) |> assign_league(params)

    user = socket.assigns.user

    topic = socket |> presence_topic()

    if user do
      Presence.track(self(), topic, socket.id, %{name: user |> User.display_name()})
    end

    BackendWeb.Endpoint.subscribe(topic)
    BackendWeb.Endpoint.subscribe("entity_leagues_#{socket.assigns.league_id}")
    {:ok, socket |> assign_present()}
  end

  def render(assigns) do
    ~H"""
    <Context put={{ user: @user }} >
      <div class="container">
        <div class="title is-2">{{ @league.name }} Draft</div>
        <div class="subtitle is-4">
          Online now: {{ @present |> Enum.uniq() |> Enum.join(" | ") }}
        </div>
        <div :if={{ !League.draft_started?(@league) }} >
          Draft Not Started 
        </div>
        <div :if={{ League.draft_started?(@league) &&  @league.real_time_draft}} class="level">
          <div class="level-left">
            <DraftOrderModal id="draft_order_modal_{{@league.id}}" league={{ @league }} button_title="Draft Order" />
            <div :if={{ now = League.drafting_now(@league) }} class="level-item" ><RosterModal include_points={{ false }} id="drafting_now_{{now.id}}" league_team={{ now }} button_title="Drafting Now: {{ now |> LeagueTeam.display_name() }}" /></div>
            <div :if={{ next = League.drafting_next(@league) }} class="level-item" ><RosterModal include_points={{ false }} id="drafting_next_{{next.id}}" league_team={{ next }} button_title="Drafting next: {{ next |> LeagueTeam.display_name() }}" /></div>
            <div :if={{ next = League.drafting_pos(@league, 2) }} class="level-item" ><RosterModal include_points={{ false }} id="drafting_2_{{next.id}}" league_team={{ next }} button_title="{{ next |> LeagueTeam.display_name() }}" /></div>
            <div :if={{ next = League.drafting_pos(@league, 3) }} class="level-item" ><RosterModal include_points={{ false }} id="drafting_3_{{next.id}}" league_team={{ next }} button_title="{{ next |> LeagueTeam.display_name() }}" /></div>
          </div>
        </div>
        <div class="notification is-warning" :if={{ League.draft_deadline_passed?(@league) }}>
          Draft Deadline Passed!
        </div>
        <a class="link" href="/fantasy/leagues/{{ @league.id }}">View League</a>
        <div :if={{ lt = League.team_for_user(@league, @user)}}>
          Your roster: {{ lt.picks |> Enum.count() }} / {{ @league.roster_size }}
        </div>

        <div :if={{ @user && League.can_manage?(@league, @user) && !League.draft_started?(@league) }} >
            <button class="button" type="button" :on-click="start_draft">Start Draft</button>
        </div>
        <CompetitorsTable id="competitors_{{ @league.id }}" league={{ @league }} user={{ @user }}/>
      </div>
    </Context>
    """
  end

  def handle_event("start_draft", _, socket = %{assigns: %{league: league}}) do
    Backend.Fantasy.start_draft(league)
    {:noreply, socket}
  end

  defp present_names(present) do
    present
    |> Enum.flat_map(fn {_k, v} ->
      v.metas
      |> Enum.flat_map(&extract_names/1)
    end)
  end

  defp extract_names(meta) do
    case meta do
      %{name: n} -> [n]
      _ -> []
    end
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, socket |> assign_present()}
  end

  def handle_info(
        %{payload: %{id: payload_id, table: "leagues"}},
        s = %{assigns: %{league_id: league_id}}
      ) do
    socket =
      if to_string(payload_id) == to_string(league_id) do
        s |> assign_league(league_id)
      else
        s
      end

    {:noreply, socket}
  end

  defp assign_present(socket) do
    present =
      socket
      |> presence_topic()
      |> Presence.list()
      |> present_names()

    socket |> assign(present: present)
  end

  defp assign_league(socket, %{"league_id" => league_id}), do: socket |> assign_league(league_id)

  defp assign_league(socket, league_id) when is_binary(league_id) or is_integer(league_id) do
    socket
    |> assign(league_id: league_id, league: get_league(league_id) || %{})
  end

  defp get_league(league_id), do: Fantasy.get_league(league_id)

  defp presence_topic(%{assigns: %{league: league = %League{}}}), do: presence_topic(league)
  defp presence_topic(%League{id: id}), do: "fantasy_draft_#{id}"
end
