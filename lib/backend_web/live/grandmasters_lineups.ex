defmodule BackendWeb.GrandmastersLineup do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Components.TournamentLineupExplorer
  alias Backend.Hearthstone.Lineup
  alias Backend.Blizzard
  alias Components.Dropdown
  alias Backend.DeckInteractionTracker, as: Tracker

  data(user, :any)
  data(week, :string)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~F"""
    <Context  put={user: @user}>
      <div>
        <div :if={lineups = Backend.Blizzard.get_grandmasters_lineups(@week)} >
          <div :if={Lineup.stats(lineups)} >
            <div class="title is-2">Grandmasters Decks</div>
            <div class="subtitle is-5">{subtitle(@week)}</div>
            <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div>

            <TournamentLineupExplorer id={"grandmasters_tournament_lineup_#{@week}"} tournament_id={"#{tournament_id(@week)}"} tournament_source="grandmasters" show_page_dropdown={false} gm_week={@week} filters={%{"order_by" => {:asc, :name}}} page_size={100}>
              <Dropdown title={@week} >
                <a class={"dropdown-item #{@week == week && 'is-active' || ''}"} :for={week <- weeks()} :on-click="change-week" phx-value-week={week}>
                  {week}
                </a>
              </Dropdown>
            </TournamentLineupExplorer>
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def subtitle(week) do
    case week do
      "Week 1" ->
        "Format: Conquest"

      "Week 2" ->
        assigns = %{}

        ~F"""
        Format: <a href="https://hearthstone.blizzard.com/en-us/news/23761137/hearthstone-grandmasters-2022-kicks-off-this-weekend" target="_blank">Trio</a>
        """

      "Week 3" ->
        "Format: LHS"

      "Playoffs" ->
        "Format: Bo7 Conquest"

      _ ->
        ""
    end

    # case week do
    #   "Week 1" -> "Format: Conquest"
    #   "Week 2" -> "Format: LHS"
    #   "Week 3" -> "Format: Conquest"
    #   "Week 4" -> "Format: LHS"
    #   "Week 5" -> "Format: Conquest"
    #   "Week 6" -> "Format: LHS"
    #   "Week 7" -> "Format: Conquest"
    #   "Playoffs" -> "Format: Conquest"
    #   _ -> ""
    # end
  end

  def tournament_id(week),
    do: Blizzard.current_gm_season() |> Blizzard.gm_lineup_tournament_id(week)

  def handle_event("change-week", %{"week" => week}, socket) do
    {:noreply, socket |> push_patch(to: Routes.live_path(socket, __MODULE__, %{week: week}))}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_params(params, _uri, socket) do
    week = params["week"] || Blizzard.current_or_default_week_title()
    {:noreply, socket |> assign(week: week)}
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
end
