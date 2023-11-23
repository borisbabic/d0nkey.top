defmodule BackendWeb.MetaLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.TierList

  data(user, :any)
  data(criteria, :map)
  data(params, :map)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Meta</div>
        <div phx-update="ignore" id="nitropay-below-title-leaderboard"></div><br>
        <TierList id="tier_list" criteria={@criteria} params={@params} live_view={__MODULE__}/>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = TierList.default_criteria()
    criteria = Map.merge(default, params) |> TierList.filter_parse_params()

    {:noreply,
     assign(socket, criteria: criteria, params: params)
     |> assign_meta()}
  end

  def assign_meta(socket) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Meta Info Tier List",
      title: "HS Meta"
    })
  end
end
