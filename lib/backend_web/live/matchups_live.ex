defmodule BackendWeb.MatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsTable
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.LivePatchDropdown
  alias Components.TierList

  import Components.TierList, only: [premium_filters?: 2]

  @default_min_matchup_sample 50
  data(missing_premium, :boolean, default: false)
  data(criteria, :map)
  data(params, :map)
  data(archetype_stats, :map)
  data(premium_filters, :boolean, default: true)
  data(min_matchup_sample, :integer, default: @default_min_matchup_sample)

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
        <div class="notification is-warning">Archetyping is WIP</div>
        <PeriodDropdown id="tier_list_period_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)} />
        <FormatDropdown id="tier_list_format_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <RankDropdown id="tier_list_rank_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <LivePatchDropdown
          id="min_played_count"
          options={[1, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]}
          title={"Min Matchup Sample"}
          param={"min_matchup_sample"}
          current_val={@min_matchup_sample}
          selected_as_title={false}
          normalized={&Util.to_int_or_orig/1}
          />
        <FunctionComponents.Ads.below_title/>
        <div :if={@archetype_stats.loading}>
          Preparing stats...
        </div>
        <MatchupsTable :if={!@archetype_stats.loading and @archetype_stats.ok?}  id={"matchups_table"} matchups={@archetype_stats.result} min_sample={@min_matchup_sample}/>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = default_criteria(params)

    criteria =
      Map.merge(default, params)
      |> TierList.filter_parse_params()
      |> Map.drop(["min_games", "min_matchup_sample"])

    min_matchup_sample =
      Map.get(params, "min_matchup_sample", @default_min_matchup_sample) |> Util.to_int_or_orig()

    if needs_premium?(criteria) and !user_has_premium?(socket.assigns) do
      {:noreply, assign(socket, missing_premium: true)}
    else
      {:noreply,
       assign(socket, criteria: criteria, params: params, min_matchup_sample: min_matchup_sample)
       |> update_context()
       |> fetch_matchups(socket)
       |> assign_meta()}
    end
  end

  defp fetch_matchups(%{assigns: %{criteria: new_criteria}} = new_socket, %{
         assigns: %{criteria: old_criteria}
       })
       when new_criteria == old_criteria do
    new_socket
  end

  defp fetch_matchups(socket, _old_socket) do
    criteria = socket.assigns.criteria

    socket
    |> assign_async([:archetype_stats], fn ->
      {:ok, matchups} = Hearthstone.DeckTracker.matchups(criteria)
      {:ok, %{archetype_stats: matchups}}
    end)
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
