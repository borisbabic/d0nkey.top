defmodule BackendWeb.MatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsExplorer

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> MatchupsExplorer.assign_meta()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Matchups</div>
        <div class="subtitle is-5">
          To contribute use <a href="https://www.firestoneapp.com/" target="_blank">Firestone<HeroIcons.external_link /></a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        </div>
        <FunctionComponents.Ads.below_title/>
        <MatchupsExplorer id="matchups_explorer" filter_context={:public} params={@params} live_view={__MODULE__} weight_merging_map={BackendWeb.PlayedCardsArchetypePopularity.deck_archetype_mapping()} />
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
