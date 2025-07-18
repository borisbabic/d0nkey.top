defmodule Components.ImportCountriesFromBattlenetButton do
  use BackendWeb, :surface_live_component

  prop(user, :any, required: true)
  prop(tournament_id, :string, required: true)

  def render(assigns) do
    ~F"""
      <div>
        <button class="button" type="button" :on-click="import_countries">Import Countries</button>
      </div>
    """
  end

  def handle_event(
        "import_countries",
        _,
        %{assigns: %{tournament_id: tournament_id, user: user}} = socket
      ) do
    Backend.Battlenet.import_from_battlefy(tournament_id, user)
    {:noreply, socket}
  end
end
