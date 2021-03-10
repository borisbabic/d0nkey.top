defmodule BackendWeb.FantasyDraftLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.Fantasy
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeam
  alias Backend.UserManager.User
  alias BackendWeb.Presence
  alias Components.CompetitorsTable
  import BackendWeb.LiveHelpers

  data(league, :map)
  data(user, :map)
  data(present, :list)

  def mount(params, session, s) do
    socket = s |> assign_defaults(session) |> assign_league(params)

    user = socket.assigns.user

    topic = socket |> presence_topic()
    Presence.track(self(), topic, socket.id, %{name: user |> User.display_name()})
    BackendWeb.Endpoint.subscribe(topic)
    BackendWeb.Endpoint.subscribe("entity_leagues_#{socket.assigns.league_id}")
    {:ok, socket |> assign_present()}
  end

  def render(assigns = %{user: %{id: _}}) do
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
        <div :if={{ League.draft_started?(@league) }}>
          <div :if={{ now = League.drafting_now(@league) }} class="tag is-success" >Drafting Now: {{ now |> LeagueTeam.display_name() }}  </div>
          <div :if={{ next = League.drafting_next(@league) }} class="tag is-info" >Drafting Next: {{ next |> LeagueTeam.display_name() }}  </div>
        </div>
        <a class="link" href="/fantasy/leagues/{{ @league.id }}">View League</a>

        <div :if={{ League.can_manage?(@league, @user) && !League.draft_started?(@league) }} >
            <button class="button" type="button" :on-click="start_draft">Start Draft</button>
        </div>
        <CompetitorsTable id="competitors_{{ @league.id }}" league={{ @league }} user={{ @user }}/>
      </div>
    </Context>
    """
  end

  def render(assigns) do
    ~H"""
    <Context put={{ user: @user }} >
      <div class="container">
        <div class="title is-3">Please login to draft Fantasy Leagues!</div>
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
      |> Enum.flat_map(fn m ->
        case m do
          %{name: n} -> [n]
          _ -> []
        end
      end)
    end)
  end

  def handle_info(%{event: "presence_diff"}, socket) do
    {:noreply, socket |> assign_present()}
  end

  def handle_info(
        %{payload: %{id: payload_id, table: "leagues"}},
        socket = %{assigns: %{league: %{id: league_id}}}
      )
      when league_id == payload_id do
    {:noreply, socket |> assign_league(payload_id)}
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
