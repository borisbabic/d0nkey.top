defmodule BackendWeb.MetaLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.TierList
  alias Components.AggLogSubtitle

  data(user, :any)
  data(criteria, :map)
  data(params, :map)
  data(missing_premium, :boolean, default: false)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(%{missing_premium: true} = assigns) do
    ~F"""
        <.page_header title="Meta" />
        <.alert>
          You do not have access to these filters. <a href="/auth/bnet">Login</a> to access this page
        </.alert>
    """
  end

  def render(assigns) do
    ~F"""
      <div>

        <.page_header title="Meta">
          <:nav_links>
            <a href={~p"/matchups"}>Matchups</a>
          </:nav_links>
          <:meta_info>
            <.contribution />
            <div class="tw-hidden md:tw-block tw-h-3 tw-w-px tw-bg-slate-800"></div>
            <AggLogSubtitle criteria={@criteria} />
          </:meta_info>
        </.page_header>
        <FunctionComponents.Ads.below_title/>
        <TierList id="tier_list" criteria={@criteria} params={@params} live_view={__MODULE__}/>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = TierList.default_criteria(params)
    criteria = Map.merge(default, params) |> TierList.filter_parse_params()

    if needs_premium?(criteria) and !has_premium?(socket.assigns) do
      {:noreply, assign(socket, missing_premium: true)}
    else
      {:noreply,
       assign(socket, criteria: criteria, params: params)
       |> assign_meta()}
    end
  end

  def needs_premium?(criteria) do
    :fresh == Hearthstone.DeckTracker.fresh_or_agg_archetype_stats(criteria)
  end

  def has_premium?(assigns) do
    !!user_from_context(assigns)
  end

  def assign_meta(socket) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Meta Info Tier List",
      title: "HS Meta"
    })
  end
end
