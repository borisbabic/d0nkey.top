defmodule BackendWeb.PlayerDecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.DecksExplorer
  alias Backend.UserManager.User

  data(user, :any)
  data(player_btag, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">{@player_btag}'s Decks</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
        <DecksExplorer
          id="decks_explorer"
          default_order_by="latest"
          default_rank="all"
          filter_context={:personal}
          default_min_games={1}
          min_games_floor={1}
          additional_params={%{"player_btag" => @player_btag, "public" => true}}
          live_view={__MODULE__}
          path_params={@player_btag}
          params={@filters}/>
      </div>
    """
  end

  @spec handle_info({:update_params, any}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({:update_params, params}, socket = %{assigns: %{player_btag: player_btag}}) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, player_btag, params))}
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_params(params, _uri, socket) do
    filters = DecksExplorer.filter_relevant(params)
    {:noreply, assign(socket, :filters, filters) |> assign(:player_btag, params["player_btag"])}
  end
end
