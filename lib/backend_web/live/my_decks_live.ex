defmodule BackendWeb.MyDecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.DecksExplorer
  alias Backend.UserManager.User

  data(user, :any)
  data(filters, :map)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do

    ~F"""
    <Context put={user: @user} >
      <div :if={btag = User.battletag(@user)}>
        <div class="title is-2">My Decks</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Pludin</a>
        </div>
        <DecksExplorer
          id="decks_explorer"
          default_order_by="latest"
          default_rank="all"
          period_options={[{"all", "All time"}, {"past_60_days", "Past 60 Days"}, {"past_30_days", "Past 30 Days"}, {"past_2_weeks", "Past 2 Weeks"}, {"past_week", "Past Week"}, {"past_day", "Past Day"}, {"past_3_days", "Past 3 Days"}, {"alterac_valley", "Alterac Valley"}]}
          default_min_games={1}
          min_games_floor={1}
          additional_params={%{"player_btag" => btag}}
          live_view={__MODULE__}
          params={@filters}/>
      </div>
    </Context>
    """
  end

  @spec handle_info({:update_params, any}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_params(params, _uri, socket) do
    filters = DecksExplorer.filter_relevant(params)
    {:noreply, assign(socket, :filters, filters)}
  end
end
