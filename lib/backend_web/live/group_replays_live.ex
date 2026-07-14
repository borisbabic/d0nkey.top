defmodule BackendWeb.GroupReplaysLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.ReplayExplorer

  data(user, :any)
  data(group_id, :any)
  data(group, :any, default: nil)
  data(membership, :any, default: nil)
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
      <div :if={@group && @membership}>
        <.page_header title={"#{@group.name} Replays"}>
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <ReplayExplorer
          show_player_btag={true}
          path_params={@group_id}
          id="my-replays"
          additional_params={additional_params(@membership)}
          default_period={"all"}
          params={@filters}
          live_view={__MODULE__}
          filter_context={:personal}
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

  def handle_info({:update_params, params}, %{assigns: %{group_id: group_id}} = socket) do
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
      |> BackendWeb.GroupLive.assign_group_and_membership()
    }
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}
end
