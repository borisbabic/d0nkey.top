defmodule BackendWeb.CardsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.CardsExplorer

  data(user, :any)
  data(params, :map)

  def mount(_params, session, socket),
    do:
      {:ok,
       socket
       |> assign_defaults(session)
       |> put_user_in_context()
       |> assign(:page_title, "Hearthstone Cards")}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Hearthstone Cards</div>
        <FunctionComponents.Ads.below_title/>
        <CardsExplorer live_view={__MODULE__} id="cards_explorer" params={@params} format_options={format_options()}/>
      </div>
    """
  end

  defp format_options() do
    now = NaiveDateTime.utc_now()
    cutoff = ~N[2025-11-05 17:00:00]
    default_options = [{"the_past", "The Past"} | CardsExplorer.default_format_options()]

    if :lt == NaiveDateTime.compare(now, cutoff) do
      [{"timeways_prerelease_brawl", "Brawl"} | default_options]
    else
      default_options
    end
  end

  def handle_info({:update_filters, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    params = CardsExplorer.filter_relevant(params)
    {:noreply, assign(socket, :params, params)}
  end
end
