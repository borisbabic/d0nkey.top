defmodule BackendWeb.MaxNations2022Live do
  @moduledoc false
  use BackendWeb, :surface_live_view
  import BackendWeb.LiveHelpers
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.Dropdown
  alias Backend.MaxNations2022
  alias Components.TournamentLineupExplorer
  alias Components.MaxNations2022LineupName, as: LineupName

  data(week, :string)
  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-2">Max League of Nations 2022</div>
        <div class="subtitle is-2">
          <a href="https://www.twitch.tv/MAXTeamTV">
            <img style="height: 30px;" class="image" alt="Twitch" src="/images/brands/twitch_extruded_wordmark_purple.svg"/>
          </a>
        </div>
        <div id="nitropay-below-title-leaderboard"></div>
          <TournamentLineupExplorer id={"max_lineups_explorer"} tournament_id={@week} tournament_source={MaxNations2022.lineup_tournament_source()} show_page_dropdown={false} filters={%{"order_by" => {:asc, :name}}} page_size={150}>
              <Dropdown title={@week} >
                <a class={"dropdown-item #{@week == week && 'is-active' || ''}"} :for={week <- weeks()} :on-click="change-week" phx-value-week={week}>
                  {week}
                </a>
              </Dropdown>
              <:lineup_name :let={lineup_name: lineup_name}>
                <LineupName lineup_name={lineup_name} />
              </:lineup_name>
          </TournamentLineupExplorer>
      </div>
    </Context>
    """
  end
  def handle_event("change-week", %{"week" => week}, socket) do
    {:noreply, socket |> push_patch(to: Routes.live_path(socket, __MODULE__, %{week: week}))}
  end
  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
  def weeks(), do: MaxNations2022.get_possible_lineups_tournament_id()

  def handle_params(params, _uri, socket) do
    week = params["week"] || MaxNations2022.get_latest_lineups_tournament_id()
    {:noreply, socket |> assign(week: week)}
  end

end
