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
        <div class="title is-2">Meta</div>
        <div class="title is-3">You do not have access to these filters. Join the appropriate tier to access <Components.Socials.patreon link="/patreon" /></div>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Meta</div>
        <div class="subtitle is-6">
        To contribute use <a href="https://www.firestoneapp.com/" target="_blank">Firestone</a> or the <a target="_blank" href="/hdt-plugin">HDT Plugin</a>
        <AggLogSubtitle /></div>
        <FunctionComponents.Ads.below_title/>
        <TierList id="tier_list" criteria={@criteria} params={@params} live_view={__MODULE__}/>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = TierList.default_criteria(params)
    criteria = Map.merge(default, params) |> TierList.filter_parse_params()

    if needs_premium?(criteria) and !user_has_premium?(socket.assigns) do
      {:noreply, assign(socket, missing_premium: true)}
    else
      {:noreply,
       assign(socket, criteria: criteria, params: params)
       |> assign_meta()}
    end
  end

  def needs_premium?(criteria) do
    :fresh == Hearthstone.DeckTracker.fresh_or_agg(criteria)
  end

  def assign_meta(socket) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Meta Info Tier List",
      title: "HS Meta"
    })
  end
end
