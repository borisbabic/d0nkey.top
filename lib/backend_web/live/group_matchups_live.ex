defmodule BackendWeb.GroupMatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsExplorer

  data(user, :any)
  data(group_id, :any)
  data(params, :map)
  data(group, :any, default: nil)
  data(membership, :any, default: nil)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> MatchupsExplorer.assign_meta("Group Matchups")}

  def render(assigns) do
    ~F"""
      <div :if={@group && @membership}>
        <.page_header title={"#{@group.name} Matchups"}>
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <MatchupsExplorer
          id="matchups_explorer"
          additional_params={%{"in_group" => @membership}}
          filter_context={:personal}
          params={@params}
          live_view={__MODULE__}
          default_min_archetype_sample={1}
          default_min_matchup_sample={1}
          weight_merging_map={BackendWeb.PlayedCardsArchetypePopularity.deck_archetype_mapping()}
          path_params={@group_id}
          default_params={%{"rank" => "all"}}
          default_player_perspective={"deck_archetype"}
          default_opponent_perspective={"class"}
        />
      </div>
    """
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, socket.assigns.group_id, params))}
  end

  def handle_params(raw_params, _uri, socket) do
    {group_id, params} = Map.pop(raw_params, "group_id")
    {:noreply, assign(socket, group_id: group_id, params: params) |> BackendWeb.GroupLive.assign_group_and_membership()}
  end
end
