defmodule BackendWeb.GroupMatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsExplorer
  alias Backend.UserManager.User

  data(user, :any)
  data(group_id, :any)
  data(params, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div :if={({group, membership} = BackendWeb.GroupLive.group_membership(@group_id, @user)) && group && membership}>
        <div class="title is-2">{group.name} Matchups</div>
        <div class="subtitle is-5">
          Powered by <a href="https://www.firestoneapp.com/" target="_blank">Firestone<HeroIcons.external_link /></a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <FunctionComponents.Ads.below_title/>
        <MatchupsExplorer id="matchups_explorer" additional_params={%{"in_group" => membership}} filter_context={:personal} params={@params} live_view={__MODULE__} default_min_archetype_sample={1} default_min_matchup_sample={1} weight_merging_map={BackendWeb.PlayedCardsArchetypePopularity.deck_archetype_mapping()} path_params={@group_id}/>
      </div>
    """
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, @group_id, params))}
  end

  def handle_params(raw_params, _uri, socket) do
    {group_id, params} = Map.pop(raw_params, "group_id")
    {:noreply, assign(socket, group_id: group_id, params: params)}
  end
end
