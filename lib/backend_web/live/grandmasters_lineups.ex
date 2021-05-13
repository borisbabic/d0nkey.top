defmodule BackendWeb.GrandmastersLineup do
  @moduledoc false
  use Surface.LiveView
  import BackendWeb.LiveHelpers

  alias Components.ExpandableLineup
  alias Components.TournamentLineupExplorer
  alias Backend.Hearthstone.Lineup
  alias Backend.Hearthstone.Deck
  alias Backend.Blizzard
  alias Components.Dropdown
  alias Backend.DeckInteractionTracker, as: Tracker
  alias BackendWeb.Router.Helpers, as: Routes

  data(user, :any)
  data(week, :string)

  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)}
  end

  def render(assigns) do
    ~H"""
    <Context  put={{ user: @user }}>
      <div class="container">
        <div :if={{ lineups = Backend.Blizzard.get_grandmasters_lineups(@week) }} >
          <div :if={{ stats = Lineup.stats(lineups) }} >
            <div class="title is-2">Grandmasters Decks</div>

            <TournamentLineupExplorer id="grandmasters_tournament_lineup_{{ @week }}" tournament_id="{{ tournament_id(@week) }}" tournament_source="grandmasters" show_page_dropdown={{ false }} gm_week={{ @week }}>
              <Dropdown title={{ @week }} >
                <a class="dropdown-item {{ @week == week && 'is-active' || '' }}" :for={{ week <- weeks() }} :on-click="change-week" phx-value-week={{ week }}>
                  {{ week }}
                </a>
              </Dropdown>
            </TournamentLineupExplorer>
          </div>
        </div>
      </div>
    </Context>
    """
  end

  def tournament_id(week),
    do: Blizzard.current_gm_season() |> Blizzard.gm_lineup_tournament_id(week)

  def handle_event("change-week", %{"week" => week}, socket) do
    {:noreply, socket |> push_patch(to: Routes.live_path(socket, __MODULE__, %{week: week}))}
  end

  def handle_params(params, _uri, socket) do
    week = params["week"] || Blizzard.current_gm_week_title!()
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

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end
end
