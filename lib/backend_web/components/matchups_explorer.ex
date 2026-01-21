defmodule Components.MatchupsExplorer do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Backend.Hearthstone.Deck
  alias Components.MatchupsTable
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ForceFreshDropdown
  alias Components.Filter.RegionDropdown
  alias Components.LivePatchDropdown
  alias Components.TierList

  @default_default_min_matchup_sample 100
  @default_default_min_archetype_sample 1000
  prop(default_min_matchup_sample, :integer, default: @default_default_min_matchup_sample)
  prop(default_min_archetype_sample, :integer, default: @default_default_min_archetype_sample)
  prop(default_params, :map, default: %{})
  prop(filter_context, :atom, default: :public)
  prop(additional_params, :map, default: %{})
  prop(params, :map, required: true)
  prop(path_params, :any, default: nil)
  prop(weight_merging_map, :map, default: %{})
  prop(live_view, :module, required: true)
  data(player_perspective, :string, default: "archetype")
  data(opponent_perspective, :string, default: "archetype")
  data(win_loss_percentage, :string, default: "percentage")
  data(user, :map, from_context: :user)
  data(missing_premium, :boolean, default: false)
  data(criteria, :map)
  data(archetype_stats, :map)
  data(updated_at, :any, default: nil)
  data(premium_filters, :boolean, default: nil)
  data(min_matchup_sample, :integer)
  data(min_archetype_sample, :integer)

  def render(assigns) do
    ~F"""
    <div>
      <.warning />
      <PeriodDropdown id="matchups_period_dropdown" filter_context={@filter_context} aggregated_only={!@premium_filters} />
      <FormatDropdown :if={user_has_premium?(@user)} id="matchups_format_dropdown" filter_context={@filter_context} aggregated_only={!@premium_filters}/>
      <RankDropdown id="matchups_rank_dropdown" filter_context={@filter_context} aggregated_only={!@premium_filters}/>
      <RegionDropdown :if={@premium_filters} id="matchups_region_dropdown" filter_context={@filter_context} warning={@filter_context != :personal}/>
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
        <LivePatchDropdown
          id="player_perspective"
          :if={@filter_context == :personal}
          options={[{"class", "Class"}, {"archetype", "Archetype"}]}
          title={"Player Perspective"}
          param={"player_perspective"}
          current_val={@player_perspective}
          selected_as_title={true}
          selected_as_title_prefix={"Player: "}
          />
        <LivePatchDropdown
          :if={@filter_context == :personal}
          id="opponent_perspective"
          options={[{"class", "Class"}, {"archetype", "Archetype"}]}
          title={"Opponent Perspective"}
          param={"opponent_perspective"}
          current_val={@opponent_perspective}
          selected_as_title={true}
          selected_as_title_prefix={"Opponent: "}
          />
        <LivePatchDropdown
          :if={@filter_context == :personal}
          id="win_loss_percentage"
          options={[{"win_loss", "Win-Loss"}, {"percentage", "Percentage %"}]}
          title={"Win-Loss/Percentage"}
          param={"win_loss_percentage"}
          current_val={@win_loss_percentage}
          selected_as_title={true}
          />
      <ForceFreshDropdown :if={@premium_filters && @filter_context != :personal} id="force_fresh_dropdown" />
      <div :if={@missing_premium} class="title is-3">You do not have access to these filters. Join the appropriate tier to access <Components.Socials.patreon link="/patreon" /></div>
      <div :if={!@missing_premium && @archetype_stats.loading}>
        Preparing stats...
      </div>
      <MatchupsTable win_loss={@win_loss_percentage == "win_loss"} :if={!@missing_premium and !@archetype_stats.loading and @archetype_stats.ok?}  id={"matchups_table"} matchups={@archetype_stats.result} weight_merging_map={@weight_merging_map} min_matchup_sample={@min_matchup_sample} min_archetype_sample={@min_archetype_sample} headers_by_opponent={@filter_context == :personal} show_popularity={@filter_context != :personal}/>
    </div>
    """
  end

  def update(assigns_raw, socket_raw) do
    socket =
      socket_raw
      |> assign(assigns_raw)
      |> assign_optional(assigns_raw.params, :player_perspective)
      |> assign_optional(assigns_raw.params, :opponent_perspective)
      |> assign_optional(assigns_raw.params, :win_loss_percentage)

    filtered_params =
      Map.drop(assigns_raw.params, [
        "player_perspective",
        "opponent_perspective",
        "win_loss_percentage"
      ])

    params = Map.merge(socket.assigns.default_params, filtered_params)

    default = default_criteria(params)

    criteria =
      Map.merge(default, socket.assigns.additional_params)
      |> Map.merge(params)
      |> TierList.filter_parse_params()
      |> Map.drop(["min_games", "min_matchup_sample", "min_archetype_sample"])
      |> set_matchups_reducer_opts(socket.assigns)

    min_matchup_sample =
      Map.get(params, "min_matchup_sample", socket.assigns.default_min_matchup_sample)
      |> Util.to_int_or_orig()

    min_archetype_sample =
      Map.get(params, "min_archetype_sample", socket.assigns.default_min_archetype_sample)
      |> Util.to_int_or_orig()

    {needs_premium?, updated_at, matchups} =
      case Hearthstone.DeckTracker.aggregated_matchups(criteria) do
        {:ok, %{matchups: matchups, updated_at: updated_at}} -> {false, updated_at, matchups}
        _ -> {socket.assigns.filter_context == :public and true, nil, nil}
      end

    premium_filters =
      if socket.assigns.filter_context == :personal do
        true
      else
        user_has_premium?(socket.assigns)
      end

    assigns_raw.params

    if needs_premium? and !user_has_premium?(socket.assigns) do
      {:ok, assign(socket, missing_premium: true, updated_at: updated_at)}
    else
      {:ok,
       socket
       |> assign(
         criteria: criteria,
         updated_at: updated_at,
         premium_filters: premium_filters,
         missing_premium: false,
         min_matchup_sample: min_matchup_sample,
         min_archetype_sample: min_archetype_sample
       )
       |> update_context()
       |> fetch_matchups(socket, matchups)
       |> assign_meta()}
    end
  end

  def assign_meta(socket) do
    socket
    |> assign_meta_tags(%{
      description: "Hearthstone Archetype Matchups",
      title: "HS Matchups"
    })
  end

  def warning(assigns) do
    ~H"""
    <div class="notification is-warning" :if={show_warning?()} >
      Blobxigar and Broxigar separation is subpar. The Cliff Dive versions are only split for miniset games
    </div>
    """
  end

  def fetch_matchups(
        %{assigns: %{criteria: new_criteria}} = new_socket,
        %{
          assigns: %{criteria: old_criteria}
        },
        _matchups
      )
      when new_criteria == old_criteria do
    new_socket
  end

  def fetch_matchups(socket, _old_socket, nil) do
    criteria = socket.assigns.criteria

    socket
    |> assign_async([:archetype_stats], fn ->
      {:ok, matchups} = Hearthstone.DeckTracker.matchups(criteria)
      {:ok, %{archetype_stats: matchups}}
    end)
  end

  def fetch_matchups(socket, _old_socket, matchups) do
    socket
    |> assign(archetype_stats: Phoenix.LiveView.AsyncResult.ok(matchups))
  end

  defp show_warning?() do
    start = ~N[2025-11-13 17:00:00]
    end_time = ~N[2026-02-13 19:00:00]
    now = NaiveDateTime.utc_now()

    NaiveDateTime.compare(start, now) == :lt and
      NaiveDateTime.compare(end_time, now) == :gt
  end

  defp set_matchups_reducer_opts(criteria, %{
         filter_context: :personal,
         player_perspective: player_perspective,
         opponent_perspective: opponent_perspective
       }) do
    opts =
      [{:include_opponent_perspective, false}]
      |> add_transformer(:player_transformer, player_perspective)
      |> add_transformer(:opponent_transformer, opponent_perspective)

    Map.put(criteria, :matchups_reducer_opts, opts)
  end

  defp set_matchups_reducer_opts(criteria, _), do: Map.put(criteria, :matchups_reducer_opts, [])

  defp add_transformer(opts, key, "class") do
    [{key, &Deck.extract_class_name/1} | opts]
  end

  defp add_transformer(opts, _, _), do: opts

  def update_context(%{assigns: assigns} = socket) do
    socket
    |> Components.LivePatchDropdown.update_context(
      assigns.live_view,
      assigns.params,
      assigns.path_params,
      Map.merge(default_criteria(assigns.criteria), assigns.criteria)
    )
  end

  defp default_criteria(params), do: TierList.default_criteria(params)
end
