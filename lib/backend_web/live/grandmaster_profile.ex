defmodule BackendWeb.GrandmasterProfileLive do
  @moduledoc false
  use Surface.LiveView

  alias Components.GMResultsTable
  alias BackendWeb.Router.Helpers, as: Routes
  import BackendWeb.LiveHelpers

  alias Components.ExpandableLineup
  alias Components.GMProfileLink
  alias Components.Dropdown
  alias Components.GMStandingsModal
  alias BackendWeb.GrandmastersLive

  alias Backend.Blizzard
  alias Backend.Grandmasters
  alias Backend.Grandmasters.Response.Competitor
  alias Backend.DeckInteractionTracker, as: Tracker

  data(user, :map)
  data(gm, :string)
  data(week, :string)

  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session)}
  end

  def render(assigns) do
    ~H"""
     <Context put={{ user: @user }}>
      <div class="container">
        <div class="title is-2">
          {{ @gm }} {{ @week }}
        </div>
        <div class="subtitle is-5">
          Week Points: {{ points(@gm, @week) }} Total Points: {{ points(@gm) }}
        </div>

        <div class="level is-mobile">
          <div class="level-left">
            <a class="is-link button level-item" href="{{ grandmasters_link(@socket, @week, @gm) }}"> Grandmasters Overview</a>
            <div class="level-item">
              <Dropdown title={{ @week }} >
                <a class="dropdown-item {{ @week == week && 'is-active' || '' }}" :for={{ week <- GrandmastersLive.weeks() }} :on-click="change-week" phx-value-week={{ week }}>
                  {{ week }}
                </a>
              </Dropdown>
            </div>
            <div class="level-item" :if={{ region = region(@gm) }}>
              <GMStandingsModal region={{ region }} id="gm_standings_modal_total" button_title="Total Standings" title="{{GrandmastersLive.gm_region_display(region)}} Standings" />
            </div>
            <div class="level-item" :if={{ region = region(@gm) }}>
              <GMStandingsModal region={{ region }} id="gm_standings_modal_week" week={{ @week }} button_title="Week Standings" title="{{GrandmastersLive.gm_region_display(region)}} Standings" />
            </div>
          </div>
        </div>
        <ExpandableLineup :if={{ lineup = lineup(@gm, @week) }} id="{{ @gm }}_profile_lineup" lineup={{ lineup }}/>
        <br>
        <GMResultsTable :if={{ region = region(@gm) }}week={{ @week }} region={{ region }} match_filter={{ match_filter(@gm) }}/>
        <div class="title is-4">
          All weeks
        </div>
        <table class="table is-fullwidth is-striped"> 
          <thead>
            <tr>
              <th>Week</th>
              <th>Points</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={{ week <- BackendWeb.GrandmastersLive.weeks() }}>
              <td><GMProfileLink week="{{ week }}" gm={{@gm}} link_text={{ week }}/></td>
              <td>{{ points(@gm, week) }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </Context>
    """
  end

  def grandmasters_link(socket, week, gm) do
    Routes.live_path(socket, GrandmastersLive, %{week: week, region: region(gm)})
  end

  def match_filter(gm) do
    fn match ->
      match.competitors
      |> Enum.any?(&(gm == Competitor.name(&1)))
    end
  end

  def region(gm) do
    Backend.Grandmasters.regionified_competitors()
    |> Enum.find_value(fn {region, competitors} ->
      competitors |> Enum.any?(&(&1.name == gm)) && region
    end)
  end

  def handle_event("change-week", %{"week" => week}, socket) do
    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.live_path(
           socket,
           __MODULE__,
           gm(socket),
           socket |> current_params() |> Map.put(:week, week)
         )
     )}
  end

  def gm(%{assigns: %{gm: gm}}), do: gm

  def lineup(gm, week) do
    Blizzard.get_single_gm_lineup(week, gm)
  end

  def points(gm) do
    Grandmasters.total_results()
    |> Grandmasters.get_points(gm)
  end

  def points(gm, week) do
    Grandmasters.results(week)
    |> Grandmasters.get_points(gm)
  end

  def handle_params(params, _uri, socket) do
    week =
      case params["week"] do
        w = <<_::8, _::binary>> -> w
        _ -> Blizzard.current_gm_week_title!()
      end

    gm = params["gm"]
    {:noreply, socket |> assign(gm: gm, week: week)}
  end

  defp current_params(%{assigns: %{week: week}}), do: %{week: week}

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
