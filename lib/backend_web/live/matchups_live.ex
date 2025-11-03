defmodule BackendWeb.MatchupsLive do
  @moduledoc false
  use BackendWeb, :surface_live_view
  alias Components.MatchupsTable
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ForceFreshDropdown
  alias Components.LivePatchDropdown
  alias Components.TierList

  import Components.TierList, only: [premium_filters?: 2]

  @default_min_matchup_sample 50
  @default_min_archetype_sample 250
  data(missing_premium, :boolean, default: false)
  data(criteria, :map)
  data(params, :map)
  data(archetype_stats, :map)
  data(updated_at, :any, default: nil)
  data(premium_filters, :boolean, default: false)
  data(min_matchup_sample, :integer, default: @default_min_matchup_sample)
  data(min_archetype_sample, :integer, default: @default_min_archetype_sample)

  def mount(_params, session, socket),
    do: {:ok, socket |> assign_defaults(session) |> put_user_in_context()}

  def render(assigns) do
    ~F"""
      <div>
        <div class="title is-2">Matchups</div>
        <div class="subtitle is-5">
          <span :if={@updated_at}>{Timex.from_now(@updated_at)}</span>
        </div>
        <div class="notification is-warning" :if={show_warning?()} >
          This data uses old archetyping. Archetyping will be updated after there is more data about the new meta
        </div>
        <div :if={@missing_premium} class="title is-3">You do not have access to these filters. Join the appropriate tier to access <Components.Socials.patreon link="/patreon" /></div>
        <PeriodDropdown id="tier_list_period_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)} />
        <FormatDropdown :if={user_has_premium?(@user)} id="tier_list_format_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <RankDropdown id="tier_list_rank_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <LivePatchDropdown
          id="min_played_count"
          options={[1, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000]}
          title={"Min Matchup Games"}
          param={"min_matchup_sample"}
          current_val={@min_matchup_sample}
          selected_as_title={false}
          normalized={&Util.to_int_or_orig/1}
          />
        <LivePatchDropdown
          id="min_played_count"
          options={[1, 10, 25, 50, 100, 250, 500, 1000, 2500, 5000, 10000, 25000, 50000]}
          title={"Min Archetype Games"}
          param={"min_archetype_sample"}
          current_val={@min_archetype_sample}
          selected_as_title={false}
          normalized={&Util.to_int_or_orig/1}
          />
        <ForceFreshDropdown :if={user_has_premium?(@user)} id="force_fresh_dropdown" />
        <FunctionComponents.Ads.below_title/>
        <div :if={!@missing_premium && @archetype_stats.loading}>
          Preparing stats...
        </div>
        <MatchupsTable :if={!@missing_premium and !@archetype_stats.loading and @archetype_stats.ok?}  id={"matchups_table"} matchups={@archetype_stats.result} min_matchup_sample={@min_matchup_sample} min_archetype_sample={@min_archetype_sample}/>
      </div>
    """
  end

  def handle_params(params, _uri, socket) do
    default = default_criteria(params)

    criteria =
      Map.merge(default, params)
      |> TierList.filter_parse_params()
      |> Map.drop(["min_games", "min_matchup_sample", "min_archetype_sample"])

    min_matchup_sample =
      Map.get(params, "min_matchup_sample", @default_min_matchup_sample) |> Util.to_int_or_orig()

    min_archetype_sample =
      Map.get(params, "min_archetype_sample", @default_min_archetype_sample)
      |> Util.to_int_or_orig()

    {needs_premium?, updated_at, matchups} =
      case Hearthstone.DeckTracker.aggregated_matchups(criteria) do
        {:ok, %{matchups: matchups, updated_at: updated_at}} -> {false, updated_at, matchups}
        _ -> {true, nil, nil}
      end

    if needs_premium? and !user_has_premium?(socket.assigns) do
      {:noreply, assign(socket, missing_premium: true, updated_at: updated_at)}
    else
      {:noreply,
       assign(socket,
         criteria: criteria,
         params: params,
         updated_at: updated_at,
         missing_premium: false,
         min_matchup_sample: min_matchup_sample,
         min_archetype_sample: min_archetype_sample
       )
       |> update_context()
       |> fetch_matchups(socket, matchups)
       |> assign_meta()}
    end
  end

  defp fetch_matchups(
         %{assigns: %{criteria: new_criteria}} = new_socket,
         %{
           assigns: %{criteria: old_criteria}
         },
         _matchups
       )
       when new_criteria == old_criteria do
    new_socket
  end

  defp fetch_matchups(socket, _old_socket, nil) do
    criteria = socket.assigns.criteria

    socket
    |> assign_async([:archetype_stats], fn ->
      {:ok, matchups} = Hearthstone.DeckTracker.matchups(criteria)
      {:ok, %{archetype_stats: matchups}}
    end)
  end

  defp fetch_matchups(socket, _old_socket, matchups) do
    socket
    |> assign(archetype_stats: Phoenix.LiveView.AsyncResult.ok(matchups))
  end

  defp show_warning?() do
    start = ~N[2025-11-04 17:00:00]
    now = NaiveDateTime.utc_now()
    NaiveDateTime.compare(start, now) == :lt
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

  defp default_criteria(params), do: TierList.default_criteria(params)
end
