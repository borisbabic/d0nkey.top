defmodule BackendWeb.MyMatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsExplorer
  alias Backend.UserManager.User

  data(user, :any)
  data(params, :map)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> MatchupsExplorer.assign_meta("My Matchups")}

  def render(assigns) do
    ~F"""
      <div :if={btag = User.battletag(@user)}>
        <.page_header title="My Matchups">
          <:meta_info>
            <.contribution powered={true} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <MatchupsExplorer
          id="matchups_explorer"
          additional_params={%{"player_btag" => btag}}
          filter_context={:personal} params={@params}
          live_view={__MODULE__}
          default_min_archetype_sample={1}
          default_min_matchup_sample={1}
          weight_merging_map={BackendWeb.PlayedCardsArchetypePopularity.deck_archetype_mapping()} default_params={%{"rank" => "all"}}
          default_player_perspective={"deck_archetype"}
          default_opponent_perspective={"class"}
        />
      </div>
    """
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    {:noreply, assign(socket, :params, params)}
  end
end
