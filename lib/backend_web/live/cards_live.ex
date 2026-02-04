defmodule BackendWeb.CardsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.CardsExplorer

  data(user, :any)
  data(params, :map)

  @conditional_formats [
    %{format: "timeways_prerelease_brawl", until: ~N[2025-11-05 17:00:00]},
    # %{format: "standard_2025", until: ~N[2026-03-31 18:00:00]},
    %{format: "standard_2026", until: ~N[2026-03-31 18:00:00]}
  ]

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

  def active_conditional_formats(cutoff \\ nil) do
    cutoff = cutoff || NaiveDateTime.utc_now()

    for %{until: until} = cf <- @conditional_formats,
        :lt == NaiveDateTime.compare(cutoff, until),
        do: cf
  end

  defp format_options() do
    default_options = [{"the_past", "The Past"} | CardsExplorer.default_format_options()]
    conditional = for %{format: f} <- active_conditional_formats(), do: {f, format_name(f)}
    default_options ++ conditional
  end

  def format_name(<<"standard_"::binary, year::binary-size(4)>>) do
    "#{year} Standard"
  end

  def format_name(format) when is_binary(format) do
    if format =~ "prerelease_brawl" do
      "Prerelease Brawl"
    else
      format
      |> Util.to_int_or_orig()
      |> Backend.Hearthstone.Deck.format_name()
    end
  end

  def format_name(format), do: Backend.Hearthstone.Deck.format_name(format)

  def handle_info({:update_filters, params}, socket) do
    {:noreply, push_patch(socket, to: Routes.live_path(socket, __MODULE__, params))}
  end

  def handle_params(params, _uri, socket) do
    params = CardsExplorer.filter_relevant(params)
    {:noreply, assign(socket, :params, params)}
  end
end
