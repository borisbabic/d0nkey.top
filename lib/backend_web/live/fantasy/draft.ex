defmodule BackendWeb.FantasyDraftLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.Fantasy
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  alias BackendWeb.Presence
  alias Components.CompetitorsTable
  alias Components.DraftPicksTable
  alias Components.RosterModal
  alias Components.DraftOrderModal
  alias Components.LeagueInfoModal

  data(league, :map)
  data(user, :any)
  data(present, :list)
  data(show_draft_picks_table, :boolean)

  def mount(params, session, s) do
    socket = s |> assign_defaults(session) |> assign_league(params)

    user = socket.assigns.user

    topic = socket |> presence_topic()

    if user do
      Presence.track(self(), topic, socket.id, %{name: user |> User.display_name()})
    end

    BackendWeb.Endpoint.subscribe(topic)
    BackendWeb.Endpoint.subscribe("entity_leagues_#{socket.assigns.league_id}")
    {:ok, socket |> assign_present() |> assign(show_draft_picks_table: false)}
  end

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-2">{@league.name} Draft</div>
        <div class="subtitle is-4">
          Online now: {@present |> Enum.uniq() |> Enum.join(" | ")}
        </div>
        <div :if={!League.draft_started?(@league)} >
          Draft Not Started
        </div>
        <div :if={League.draft_started?(@league) &&  @league.real_time_draft} class="level">
          <div class="level-left">
            <DraftOrderModal id={"draft_order_modal_#{@league.id}"} league={@league} button_title="Draft Order" />
            <div :if={now = League.drafting_now(@league)} class="level-item" ><RosterModal include_points={false} id={"drafting_now_#{now.id}"} league_team={now} button_title={"Drafting Now: #{now |> LeagueTeam.display_name()}"} /></div>
            <div :if={next = League.drafting_next(@league)} class="level-item" ><RosterModal include_points={false} id={"drafting_next_#{next.id}"} league_team={next} button_title={"Drafting next: #{next |> LeagueTeam.display_name()}"} /></div>
            <div :if={next = League.drafting_pos(@league, 2)} class="level-item" ><RosterModal include_points={false} id={"drafting_2_#{next.id}"} league_team={next} button_title={"#{next |> LeagueTeam.display_name()}"} /></div>
            <div :if={next = League.drafting_pos(@league, 3)} class="level-item" ><RosterModal include_points={false} id={"drafting_3_#{next.id}"} league_team={next} button_title={"#{next |> LeagueTeam.display_name()}"} /></div>
          </div>
        </div>
        <div class="level is-mobile">
          <div class="level-left">
            <div class="level-item notification is-warning" :if={League.draft_deadline_passed?(@league)}>
              Draft Deadline Passed!
            </div>
            <a class="is-link level-item button" href={"/fantasy/leagues/#{@league.id}"}>View League</a>
            <div :if={lt = League.team_for_user(@league, @user)} style="position: sticky; top: 0; z-index: 10;">
              <RosterModal :if={@league} id={"self_roster_modal_{{lt.id}}"} league_team={lt} button_title={"Your roster: #{LeagueTeam.current_roster_size(lt)} / #{@league.roster_size}"} />
            </div>
            <div class="level-item">
              <LeagueInfoModal id={"league_info_modal_#{@league.id}"} league={@league}/>
            </div>

            <button class="button level-item" type="button" :on-click="start_draft" :if={@user && League.can_manage?(@league, @user) && !League.draft_started?(@league)} >
              Start Draft
            </button>
            <button :if={show_draft_picks_table_button(@league)} class="button level-item" type="button" :on-click="toggle_draft_picks_table">{toggle_draft_picks_table_button_name(@show_draft_picks_table)}</button>
          </div>
        </div>
        <DraftPicksTable :if={show_draft_picks_table(@league, @show_draft_picks_table)} id={"draft_picks_table_#{@league.id}"} league={@league} />
        <CompetitorsTable id={"competitors_#{@league.id}"} league={@league} user={@user}/>
      </div>
    </Context>
    """
  end

  def show_draft_picks_table(league = %{real_time_draft: true}, true),
    do: League.any_picks?(league)

  def show_draft_picks_table(_, _), do: false

  def show_draft_picks_table_button(league = %{real_time_draft: true}),
    do: League.any_picks?(league)

  def show_draft_picks_table_button(_), do: false
  def toggle_draft_picks_table_button_name(true), do: "Hide picked order"
  def toggle_draft_picks_table_button_name(false), do: "Show picked order"

  def handle_event(
        "toggle_draft_picks_table",
        _,
        socket = %{assigns: %{show_draft_picks_table: sdpt}}
      ) do
    {:noreply, socket |> assign(show_draft_picks_table: !sdpt)}
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
