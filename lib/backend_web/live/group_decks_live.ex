defmodule BackendWeb.GroupDecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.DecksExplorer
  alias Backend.UserManager.User

  data(user, :any)
  data(group_id, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div :if={({group, membership} = BackendWeb.GroupLive.group_membership(@group_id, @user)) && group && membership}>
        <div class="title is-2">{group.name} Decks</div>
        <div class="subtitle is-6">
        Powered by <a href="https://www.firestoneapp.com/">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <FunctionComponents.Ads.below_title/>
        <DecksExplorer
          id="decks_explorer"
          default_order_by="latest"
          default_rank="all"
          extra_period_options={[{"all", "All time"}, {"past_60_days", "Past 60 Days"}]}
          default_min_games={1}
          min_games_floor={1}
          additional_params={%{"in_group" => membership}}
          live_view={__MODULE__}
          path_params={@group_id}
          params={@filters}/>
      </div>
    """
  end

  @spec handle_info({:update_params, any}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({:update_params, params}, socket = %{assigns: %{group_id: group_id}}) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, group_id, params))}
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_params(params, _uri, socket) do
    filters = DecksExplorer.filter_relevant(params)
    {:noreply, assign(socket, :filters, filters) |> assign(:group_id, params["group_id"])}
  end
end
