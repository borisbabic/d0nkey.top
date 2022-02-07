defmodule BackendWeb.MyReplaysLive do
  @moduledoc false
  use Surface.LiveView
  alias Backend.UserManager.User
  alias Components.ReplayExplorer
  alias BackendWeb.Router.Helpers, as: Routes
  import BackendWeb.LiveHelpers

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
      <div class="container">
        <div class="title is-2">My Replays</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a>
        </div>
        <ReplayExplorer id="my-replays" additional_params={%{"player_btag" => User.battletag(@user)}} params={@filters} live_view={__MODULE__}/>
      </div>
    </Context>
    """
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
