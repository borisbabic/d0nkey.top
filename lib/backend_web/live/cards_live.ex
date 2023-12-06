defmodule BackendWeb.CardsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.CardsExplorer

  data(user, :any)
  data(filters, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Hearthstone Cards</div>
        <FunctionComponents.Ads.below_title/>
        <CardsExplorer id="cards_explorer" filters={@filters} />
      </div>
    """
  end

  def handle_info({:update_filters, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    filters = CardsExplorer.filter_relevant(params)
    {:noreply, assign(socket, :filters, filters)}
  end
end
