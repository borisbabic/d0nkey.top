defmodule BackendWeb.DecksLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.DecksExplorer
  alias Backend.DeckInteractionTracker, as: Tracker

  data(user, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
    <div>
      <div class="title is-2">Decks</div>
      <div class="subtitle is-6">
      <a href={~p"/stats/explanation"}>Stats Explanation</a>| To contribute use <a href="https://www.firestoneapp.com/" target="_blank">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
      </div>
      <FunctionComponents.Ads.below_title mobile_video={true} />
      <DecksExplorer live_view={__MODULE__} id="decks_explorer" params={@filters} filter_context={:public} />
    </div>
    """
  end

  def handle_info({:update_params, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_event("deck_copied", %{"deckcode" => code}, socket) do
    Tracker.inc_copied(code)
    {:noreply, socket}
  end

  def handle_event("deck_copied", _, socket), do: {:noreply, socket}

  def handle_params(params, _uri, socket) do
    filters = DecksExplorer.filter_relevant(params)
    {:noreply, assign(socket, :filters, filters) |> assign_meta()}
  end

  defp assign_meta(socket = %{assigns: %{filters: filters}}) do
    format_part =
      case Map.get(filters, "format") do
        nil -> ""
        f -> "#{Backend.Hearthstone.Deck.format_name(f)} "
      end

    socket
    |> assign_meta_tags(%{
      description: "Hearthstone #{format_part}Decks and Deck Stats",
      title: "#{format_part}Decks "
    })
  end

  defp assign_meta(socket), do: socket
end
