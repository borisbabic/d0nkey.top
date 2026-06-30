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
        <.page_header title="Matchups">
          <:meta_info>
            <.contribution hdt={false} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <MatchupsExplorer id="matchups_explorer" format_filter?={true} filter_context={:public} params={@params} live_view={__MODULE__} weight_merging_map={BackendWeb.PlayedCardsArchetypePopularity.deck_archetype_mapping()} />
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
