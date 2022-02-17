defmodule BackendWeb.PlayerReplaysLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Backend.UserManager
  alias Components.ReplayExplorer

  data(user, :any)
  data(player_btag, :any)
  data(filters, :map)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    # filters
    # player class
    # opponent class
    # player rank
    # region
    ~F"""
    <Context put={user: @user}>
      <div>
        <div class="title is-2">{@player_btag}'s Replays</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <div id="nitropay-below-title-leaderboard"></div><br>
        <ReplayExplorer
          show_player_btag={true}
          path_params={@player_btag}}
          id="my-replays"
          additional_params={additional_params(@player_btag)}
          params={@filters}
          live_view={__MODULE__}/>
      </div>
    </Context>
    """
  end

  def additional_params(player_btag) do
    %{
      "player_btag" => player_btag,
      "public" => true,
      "game_type" => Hearthstone.Enums.GameType.constructed_types()
    }
  end


  def handle_info({:update_params, params}, socket = %{assigns: %{player_btag: player_btag}}) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, player_btag, params))}
  end
  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    filters = ReplayExplorer.filter_relevant(params)
    {
      :noreply,
      socket
      |> assign(:filters, filters)
      |> assign(:player_btag, params["player_btag"])
    }
  end

  def handle_event("toggle_cards", params, socket) do
    Components.ExpandableDecklist.toggle_cards(params)

    {
      :noreply,
      socket
    }
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
