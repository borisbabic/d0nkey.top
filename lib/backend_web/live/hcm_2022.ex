defmodule BackendWeb.HCM2022Live do
  use BackendWeb, :surface_live_view

  alias Backend.DeckInteractionTracker, as: Tracker
  alias FunctionComponents.Dropdown
  alias Components.TournamentLineupExplorer

  data(match, :string)
  data(user, :any)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Hearthstone Collegiate Masters</div>
        <FunctionComponents.Ads.below_title/>
        <TournamentLineupExplorer id={"hcm_2022"} tournament_id={@week} tournament_source={"hcm_2022"} show_page_dropdown={false} filters={%{"order_by" => {:asc, :name}}} page_size={150}>
            <Dropdown.menu title={@week} >
              <Dropdown.item selected={@week == week} :for={week <- weeks()} phx-target={@myself} phx-click="change-week" phx-value-week={week}>
                {week}
              </Dropdown.item>
            </Dropdown.menu>
            <:lineup_name :let={lineup_name: lineup_name}>
              <a href={"/lineup-history/hcm_2022/#{lineup_name}"}>{lineup_name}</a>
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

  def weeks(), do: Backend.Hearthstone.get_tournament_ids_for_source("hcm_2022")

  def handle_params(params, _uri, socket) do
    week = params["week"] || Backend.Hearthstone.get_latest_tournament_id_for_source("hcm_2022")
    {:noreply, socket |> assign(week: week)}
  end
end
