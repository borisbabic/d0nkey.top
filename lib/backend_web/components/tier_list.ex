defmodule Components.TierList do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Hearthstone.DeckTracker
  alias Components.LivePatchDropdown
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.WinrateTag
  alias Backend.Hearthstone.Deck
  alias Surface.Components.LivePatch
  import Components.DecksExplorer, only: [parse_int: 2, class_options: 2]
  import Components.CardStatsTable, only: [add_arrow: 3, add_arrow: 4]

  prop(data, :list, default: [])
  prop(params, :map)
  prop(criteria, :map, default: %{})
  prop(live_view, :module, required: true)
  prop(min_games_options, :list, default: [100, 250, 500, 1000, 2500, 5000, 7500, 10_000])

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        nil,
        Map.merge(default_criteria(), assigns.criteria)
      )
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <PeriodDropdown id="tier_list_period_dropdown" filter_context={:public} aggregated_only={true} />
        <FormatDropdown id="tier_list_format_dropdown" filter_context={:public} aggregated_only={true}/>
        <RankDropdown id="tier_list_format_dropdown" filter_context={:public} aggregated_only={true}/>
        <LivePatchDropdown
          options={class_options("Any Class", "VS ")}
          title={"Opponent's Class"}
          param={"opponent_class"} />

        <LivePatchDropdown
          options={@min_games_options}
          title={"Min Games"}
          param={"min_games"}
          selected_as_title={false}
          normalizer={&to_string/1} />

        <table class="table is-fullwidth is-striped is-narrow">
          <thead>
            <th>Archetype</th>
            <th><LivePatch to={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "winrate"))}>
            {add_arrow("Winrate", "winrate", @params, true)}
            </LivePatch></th>
            <th><LivePatch to={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "total"))}>
            {add_arrow("Popularity", "total", @params)}
            </LivePatch></th>
          </thead>
          <tbody :if={{stats, total} = stats(@data, @criteria)}>
            <tr :for={as <- stats}>
              <td class={"decklist-info", Deck.extract_class(as.archetype) |> String.downcase()}>
                <a class="basic-black-text deck-title" href={~p"/archetype/#{as.archetype}"}>
                  {as.archetype}
                </a>
              </td>
              <td>
                <WinrateTag winrate={as.winrate}/>
              </td>
              <td>{percentage(as.total, total)}% ({as.total})</td>
            </tr>
          </tbody>
        </table>

      </div>
    """
  end

  @default_min_games 1000

  def percentage(num, total) do
    Util.percent(num, total)
    |> Float.round(1)
  end

  def stats([_ | _] = stats, _criteria), do: stats
  def stats(_, criteria), do: stats(criteria)

  def stats(criteria) do
    {min_games, crit} = criteria |> with_defaults() |> Map.pop("min_games")
    stats_all = crit |> DeckTracker.archetype_agg_stats()

    total =
      Enum.reduce(stats_all, 0, fn %{total: t}, sum ->
        sum + Util.to_int_or_orig(t)
      end)

    stats =
      Enum.filter(stats_all, fn %{total: t} ->
        Util.to_int_or_orig(t) >= min_games
      end)

    {stats, total}
  end

  def apply_min(stats, criteria) do
    min_games = Map.get(criteria, "min_games", @default_min_games)
    Enum.filter(stats, &(&1.total >= min_games))
  end

  def with_defaults(criteria), do: Map.put_new(criteria, "sort_by", "winrate")

  def filter_parse_params(filters) do
    filters
    |> parse_int(["min_games"])
  end

  def default_criteria() do
    %{
      "period" => PeriodDropdown.default(:public),
      "rank" => RankDropdown.default(:public),
      "opponent_class" => "any",
      "min_games" => @default_min_games,
      "format" => FormatDropdown.default(:public)
    }
  end

  def to_percent(int) when is_integer(int), do: int / 1
  def to_percent(num), do: "#{Float.round(num * 100, 2)}%"

  defp card_stats_params(params, archetype) do
    params
    |> Map.take(["format", "opponent_class", "period", "rank"])
    |> Map.put("archetype", archetype)
  end
end
