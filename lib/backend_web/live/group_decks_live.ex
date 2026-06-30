defmodule BackendWeb.GroupDecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.DecksExplorer

  data(user, :any)
  data(group_id, :any)
  data(filters, :map)
  data(group, :any, default: nil)
  data(membership, :any, default: nil)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div :if={@group && @membership}>
        <.page_header title={"#{@group.name} Decks"}>
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <DecksExplorer
          id="decks_explorer"
          default_order_by="latest"
          default_rank="all"
          extra_period_options={[{"all", "All time"}, {"past_60_days", "Past 60 Days"}]}
          default_min_games={1}
          min_games_floor={1}
          additional_params={%{"in_group" => @membership}}
          live_view={__MODULE__}
          path_params={@group_id}
          params={@filters}/>
      </div>
    """
  end

  @spec handle_info({:update_params, any}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({:update_params, params}, %{assigns: %{group_id: group_id}} = socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, group_id, params))}
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_params(params, _uri, socket) do
    filters = DecksExplorer.filter_relevant(params)

    {:noreply,
     assign(socket, :filters, filters)
     |> assign(:group_id, params["group_id"])
     |> BackendWeb.GroupLive.assign_group_and_membership()}
  end
end
