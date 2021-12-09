defmodule BackendWeb.DecksLive do
  @moduledoc false
  use Surface.LiveView
  alias BackendWeb.Router.Helpers, as: Routes
  alias Components.DecksExplorer
  import BackendWeb.LiveHelpers

  data(user, :any)
  data(filters, :map)
  def mount(_params, session, socket), do: {:ok, socket |> assign_defaults(session)}

  def render(assigns) do
    ~F"""
    <Context put={user: @user} >
      <div class="container">
        <div class="title is-2">Decks</div>
        <div class="subtitle is-6">
        To contribute use <a href="https://www.firestoneapp.com/">Firestone</a>
        </div>
        <DecksExplorer live_view={__MODULE__} id="decks_explorer" params={@filters}/>
      </div>
    </Context>
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
    {:noreply, assign(socket, :filters, filters)}
  end
end
