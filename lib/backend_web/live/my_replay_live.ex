defmodule BackendWeb.MyReplaysLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Components.ReplayExplorer

  data(user, :any)
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
        <div class="title is-2">My Replays</div>
        <div class="subtitle is-6">

          <abbr title="Share your public replays"><a href={Routes.live_path(BackendWeb.Endpoint, BackendWeb.PlayerReplaysLive, @user.battletag)} target="_blank">Share</a></abbr>
          | Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <div id="nitropay-below-title-leaderboard"></div><br>
        <ReplayExplorer
          id="my-replays"
          additional_params={additional_params(@user)}
          params={@filters}
          live_view={__MODULE__}
          extra_period_options={[{"all", "All time"}, {"past_60_days", "Past 60 Days"}]}
        />
      </div>
    </Context>
    """
  end

  @spec additional_params(any) :: %{optional(<<_::72, _::_*16>>) => any}
  def additional_params(user) do
    %{
      "player_btag" => User.battletag(user),
      "game_type" => Hearthstone.Enums.GameType.constructed_types()
    }
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
