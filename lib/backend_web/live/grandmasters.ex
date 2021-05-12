defmodule BackendWeb.GrandmastersLive do
  @moduledoc false
  use Surface.LiveView

  alias Components.GMResultsTable
  alias Components.GMStandingsModal
  alias Components.Dropdown
  alias BackendWeb.Router.Helpers, as: Routes
  import BackendWeb.LiveHelpers

  alias Backend.Blizzard
  alias Backend.Grandmasters.Response.Match

  data(user, :map)
  data(week, :string)
  data(region, :atom)

  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session) |> assign_default_week()}
  end

  defp assign_default_week(socket) do
    week = Blizzard.current_gm_week_title!()
    socket |> assign(week: week)
  end

  def render(assigns) do
    ~H"""
     <Context put={{ user: @user }}>
      <div class="container">
        <div class="title is-2">
          Grandmasters
        </div>
        <div class="level is-mobile">
          <div class="level-left">
            <div class="level-item">
              <Dropdown title={{ @week }} >
                <a class="dropdown-item {{ @week == week && 'is-active' || '' }}" :for={{ week <- weeks() }} :on-click="change-week" phx-value-week={{ week }}>
                  {{ week }}
                </a>
              </Dropdown>
            </div>
            <div class="level-item">
              <Dropdown title={{ @region |> gm_region_display() }} >
                <a class="dropdown-item {{ @region == region && 'is-active' || '' }}" :for={{ region <- [:NA, :APAC, :EU]}} :on-click="change-region" phx-value-region={{ region }}>
                  {{ gm_region_display(region) }}
                </a>
              </Dropdown>
            </div>
            <div class="level-item">
              <GMStandingsModal id="gm_standings_modal_total" button_title="Total Standings" region={{ @region }} title="{{gm_region_display(@region)}} Standings" />
            </div>
            <div class="level-item">
              <GMStandingsModal id="gm_standings_modal_week" button_title="Week Standings" week={{ @week }} region={{ @region }} title="{{gm_region_display(@region)}} Standings" />
            </div>
          </div>
        </div>
        <GMResultsTable week={{ @week }} region={{ @region }} />
      </div>
    </Context>
    """
  end

  def weeks() do
    season = Blizzard.current_gm_season()

    season
    |> Blizzard.weeks_so_far()
    |> Enum.map(fn {_, week} ->
      season
      |> Blizzard.gm_week_title(week)
      |> Util.bangify()
    end)
  end

  def handle_event("change-week", %{"week" => week}, socket) do
    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.live_path(socket, __MODULE__, socket |> current_params() |> Map.put(:week, week))
     )}
  end

  def handle_event("change-region", %{"region" => region}, socket) do
    {:noreply,
     socket
     |> push_patch(
       to:
         Routes.live_path(
           socket,
           __MODULE__,
           socket |> current_params() |> Map.put(:region, region)
         )
     )}
  end

  defp current_params(%{assigns: %{week: week, region: region}}),
    do: %{region: region, week: week}

  def handle_params(params, _uri, socket) do
    week = params["week"] || Blizzard.current_gm_week_title!()
    region = params["region"] |> Backend.Grandmasters.parse_region()
    {:noreply, socket |> assign(week: week, region: region)}
  end

  def gm_region_display(:APAC), do: "Asia-Pacific"
  def gm_region_display(:EU), do: "Europe"
  def gm_region_display(:NA), do: "Americas"
end
