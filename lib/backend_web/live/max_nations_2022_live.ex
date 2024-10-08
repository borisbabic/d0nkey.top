defmodule BackendWeb.MaxNations2022Live do
  @moduledoc false
  use BackendWeb, :surface_live_view
  import BackendWeb.LiveHelpers
  alias Backend.DeckInteractionTracker, as: Tracker
  alias FunctionComponents.Dropdown
  alias Backend.MaxNations2022
  alias Components.TournamentLineupExplorer
  alias Components.MaxNations2022LineupName, as: LineupName

  data(week, :string)
  data(user, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Max League of Nations 2022</div>
        <div class="subtitle is-2">
          <a href="https://www.twitch.tv/MAXTeamTV">
            <img style="height: 30px;" class="image" alt="Twitch" src="/images/brands/twitch_extruded_wordmark_purple.svg"/>
          </a>
        </div>
        <FunctionComponents.Ads.below_title/>
          <TournamentLineupExplorer id={"max_lineups_explorer"} tournament_id={@week} tournament_source={MaxNations2022.lineup_tournament_source()} show_page_dropdown={false} filters={%{"order_by" => {:asc, :name}}} page_size={150}>
              <Dropdown.menu title={@week} >
                <Dropdown.item selected={@week == week} :for={week <- weeks()} phx-target={@myself} phx-click="change-week" phx-value-week={week}>
                  {week}
                </Dropdown.item>
              </Dropdown.menu>
              <:lineup_name :let={lineup_name: lineup_name}>
                <LineupName lineup_name={lineup_name} />
              </:lineup_name>
          </TournamentLineupExplorer>
      </div>
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
