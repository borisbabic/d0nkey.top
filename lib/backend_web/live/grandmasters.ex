defmodule BackendWeb.GrandmastersLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Components.GMResultsTable
  alias Components.GMStandingsTable
  alias Components.GMStandingsModal
  alias Components.Dropdown

  alias Backend.Blizzard

  data(user, :map)
  data(week, :string)
  data(region, :atom)

  def mount(_params, session, socket) do
    {:ok, assign_defaults(socket, session) |> assign_default_week()}
  end

  defp assign_default_week(socket) do
    week = Blizzard.current_or_default_week_title()
    socket |> assign(week: week)
  end

  def render(assigns) do
    ~F"""
     <Context put={user: @user}>
      <div>
        <div class="title is-2">
          Grandmasters
        </div>
        <div class="subtitle is-6">
          <a target"_blank" href="https://hearthstone.blizzard.com/en-us/esports/standings/">Official Site</a>
          | <a href={lineup_url(@week)}>Lineups</a>
        </div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div>

        <div class="level is-mobile">
          <div class="level-left">
            <div class="level-item">
              <Dropdown title={@week} >
                <a class={"dropdown-item #{@week == week && 'is-active' || ''}"} :for={week <- weeks()} :on-click="change-week" phx-value-week={week}>
                  {week}
                </a>
              </Dropdown>
            </div>
            <div class="level-item">
              <GMStandingsModal id="gm_standings_modal_week" button_title="Week Standings" week={@week} region={@region} title={"#{gm_region_display(@region)} Standings"} />
            </div>
          </div>
        </div>
        <GMStandingsTable region={@region} />
        <GMResultsTable week={@week} region={@region} />
      </div>
    </Context>
    """
  end

  def lineup_url(week),
    do: Routes.live_path(BackendWeb.Endpoint, BackendWeb.GrandmastersLineup, %{"week" => week})

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
    week = params["week"] || Blizzard.current_or_default_week_title()
    region = params["region"] |> Backend.Grandmasters.parse_region(:XX)
    {:noreply, socket |> assign(week: week, region: region)}
  end

  def gm_region_display(:APAC), do: "Asia-Pacific"
  def gm_region_display(:EU), do: "Europe"
  def gm_region_display(:NA), do: "Americas"
  def gm_region_display(:XX), do: "Last Call"
end
