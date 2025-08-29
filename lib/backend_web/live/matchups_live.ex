defmodule BackendWeb.MatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsTable
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.TierList

  import Components.TierList, only: [premium_filters?: 2]

  data(missing_premium, :boolean, default: false)
  data(criteria, :map)
  data(params, :map)
  data(archetype_stats, :map)
  data(premium_filters, :boolean, default: false)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(%{missing_premium: true} = assigns) do
    ~F"""
      <div>
        <div class="title is-2">Matchups</div>
        <div class="title is-3">You do not have access to this page. Join the appropriate tier to access <Components.Socials.patreon link="/patreon" />. It will be available freely after optimization.</div>
        <FunctionComponents.Ads.below_title/>
      </div>
    """
  end

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Matchups</div>
        <PeriodDropdown id="tier_list_period_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)} />
        <FormatDropdown id="tier_list_format_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <RankDropdown id="tier_list_rank_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <FunctionComponents.Ads.below_title/>
        <div class="notification is-warning">Archetyping is WIP</div>
        <div :if={@archetype_stats.loading}>
          Preparing stats...
        </div>
        <MatchupsTable :if={!@archetype_stats.loading and @archetype_stats.ok?}  id={"matchups_table"} matchups={@archetype_stats.result}/>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = default_criteria(params)

    criteria =
      Map.merge(default, params) |> TierList.filter_parse_params() |> Map.drop(["min_games"])

    if needs_premium?(criteria) and !user_has_premium?(socket.assigns) do
      {:noreply, assign(socket, missing_premium: true)}
    else
      {:noreply,
       assign(socket, criteria: criteria, params: params)
       |> update_context()
       |> assign_async([:archetype_stats], fn ->
         {:ok, matchups} = Hearthstone.DeckTracker.matchups(criteria)
         {:ok, %{archetype_stats: matchups}}
       end)
       |> assign_meta()}
    end
  end

  def update_context(%{assigns: assigns} = socket) do
    socket
    |> Components.LivePatchDropdown.update_context(
      __MODULE__,
      assigns.params,
      nil,
      Map.merge(default_criteria(assigns.criteria), assigns.criteria)
    )
  end

  def assign_meta(socket) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Archetype Matchups",
      title: "HS Matchups"
    })
  end

  def needs_premium?(_), do: true

  defp default_criteria(params), do: TierList.default_criteria(params)
end
