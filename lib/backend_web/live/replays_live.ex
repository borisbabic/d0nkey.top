defmodule BackendWeb.ReplaysLive do
  @moduledoc false

  use BackendWeb, :surface_live_view
  alias Backend.DeckInteractionTracker, as: Tracker
  alias Components.ReplayExplorer

  data(user, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">Replays</div>
      <div class="subtitle is-6">
      To contribute <span class="is-hidden-mobile"> use <a href="https://www.firestoneapp.com/" target="_blank">Firestone</a>  or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a> and </span>make <a href={~p"/profile/settings"}>your replays public</a>
      </div>
      <FunctionComponents.Ads.below_title />
      <ReplayExplorer
      live_view={__MODULE__}
      id="replays_explorer"
      params={@filters}
      filter_context={:public}
      class_stats_modal={false}
      show_opponent_name={false}
      additional_params={%{"public" => true}}
      />
    </div>
    """
  end

  defp assign_meta(socket),
    do:
      assign_meta_tags(socket, %{
        description: "Hearthstone public replays",
        title: "Hearthstone Replays"
      })

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_params(params, _uri, socket) do
    filters = ReplayExplorer.filter_relevant(params)
    {:noreply, assign(socket, :filters, filters) |> assign_meta()}
  end
end
