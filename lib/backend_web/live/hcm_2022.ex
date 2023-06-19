defmodule BackendWeb.HCM2022Live do
  use BackendWeb, :surface_live_view

  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.Dropdown
  alias Components.TournamentLineupExplorer

  data(match, :string)
  data(user, :any)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div>
        <div class="title is-2">Hearthstone Collegiate Masters</div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div>
        <TournamentLineupExplorer id={"hcm_2022"} tournament_id={@week} tournament_source={"hcm_2022"} show_page_dropdown={false} filters={%{"order_by" => {:asc, :name}}} page_size={150}>
            <Dropdown title={@week} >
              <a class={"dropdown-item #{@week == week && 'is-active' || ''}"} :for={week <- weeks()} :on-click="change-week" phx-value-week={week}>
                {week}
              </a>
            </Dropdown>
            <:lineup_name :let={lineup_name: lineup_name}>
              <a href={"/lineup-history/hcm_2022/#{lineup_name}"}>{lineup_name}</a>
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

  def weeks(), do: Backend.Hearthstone.get_tournament_ids_for_source("hcm_2022")

  def handle_params(params, _uri, socket) do
    week = params["week"] || Backend.Hearthstone.get_latest_tournament_id_for_source("hcm_2022")
    {:noreply, socket |> assign(week: week)}
  end
end
