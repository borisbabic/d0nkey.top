defmodule BackendWeb.GroupReplaysLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Backend.UserManager.User
  alias Backend.UserManager
  alias Components.ReplayExplorer
  use Components.ExpandableDecklist

  data(user, :any)
  data(group_id, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    # filters
    # player class
    # opponent class
    # player rank
    # region
    ~F"""
      <div :if={({group, membership} = BackendWeb.GroupLive.group_membership(@group_id, @user)) && group && membership}>
        <div class="title is-2">{group.name} Replays</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
        <ReplayExplorer
          show_player_btag={true}
          path_params={@group_id}}
          id="my-replays"
          additional_params={additional_params(membership)}
          params={@filters}
          live_view={__MODULE__}
          period_context={:personal}
          />
      </div>
    """
  end

  def additional_params(group_membership) do
    %{
      "in_group" => group_membership,
      "game_type" => Hearthstone.Enums.GameType.constructed_types()
    }
  end

  def handle_info({:update_params, params}, socket = %{assigns: %{group_id: group_id}}) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, group_id, params))}
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
      |> assign(:group_id, params["group_id"])
    }
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
