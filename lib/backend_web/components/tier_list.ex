defmodule Components.TierList do
  @moduledoc false
  use BackendWeb, :surface_live_component

  alias Hearthstone.DeckTracker
  alias Components.LivePatchDropdown
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.ClassMultiDropdown
  alias Components.Filter.RegionDropdown
  alias Components.Filter.PlayerHasCoinDropdown
  alias Components.WinrateTag
  alias Backend.Hearthstone.Deck
  alias Components.Filter.ForceFreshDropdown
  alias FunctionComponents.ChartJs
  import Components.DecksExplorer, only: [parse_int: 2]
  import Components.CardStatsTable, only: [add_arrow: 3, add_arrow: 4]
  import FunctionComponents.Stats, only: [round: 2]

  prop(data, :list, default: [])
  prop(params, :map)
  prop(criteria, :map, default: %{})
  prop(live_view, :module, required: true)

  prop(min_games_options, :list,
    default: [100, 250, 500, 1000, 2500, 5000, 7500, 10_000, 25_000, 50_000, 100_000]
  )

  prop(premium_filters, :boolean, default: nil)
  prop(user, :map, from_context: :user)
  data(show_chart, :boolean, default: false)

  def update(assigns, socket) do
    {
      :ok,
      socket
      |> assign(assigns)
      |> LivePatchDropdown.update_context(
        assigns.live_view,
        assigns.params,
        nil,
        Map.merge(default_criteria(assigns.criteria), assigns.criteria)
      )
    }
  end

  def render(assigns) do
    ~F"""
      <div>
        <button class="button" id="toggle_chart" :on-click="toggle_chart">Chart {if @show_chart, do: "↑", else: "↓"}</button>
        <PeriodDropdown id="tier_list_period_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)} />
        <FormatDropdown id="tier_list_format_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <RankDropdown id="tier_list_rank_dropdown" filter_context={:public} aggregated_only={!premium_filters?(@premium_filters, @user)}/>
        <ClassMultiDropdown
          id="tier_list_opponents_class_dropdown"
          name_prefix={"VS "}
          title={"Opponent's Class"}
          param={"opponent_class"} />

        <LivePatchDropdown
          id="tier_list_min_games_dropdown"
          options={@min_games_options}
          title={"Min Games"}
          param={"min_games"}
          selected_as_title={false}
          normalizer={&to_string/1} />
        <PlayerHasCoinDropdown id="tier_list_player_has_coin_dropdown" />
        {#if premium_filters?(@premium_filters, @user)}
          <RegionDropdown title={Components.Helper.warning_triangle(%{before: "Region"})} id={"deck_region"} filter_context={:public} />
          <ForceFreshDropdown id={"force_fresh"} />
        {/if}

        <div :if={{stats, total} = stats(@data, @criteria)}>
        <div class="chart-container" :if={@show_chart}>
          <ChartJs.scatter
            canvas_class={"tw-max-h-[400px] tw-max-w-4xl tw-bg-gray-300"}
            id={"#{@id}_tier_list_scatter"}
            config={
              %{
                options: %{
                  plugins: %{
                    legend: %{display: false},
                    datalabels: %{
                      offset: 1,
                      anchor: "center",
                      align: "end",
                      display: "auto",
                    }
                  },
                  scales: %{
                    y: %{
                      min: 0,
                      title: %{display: true, text: "Popularity"}
                    },
                    x: %{
                      title: %{display: true, text: "Winrate"}
                    }
                  }
                }
              }
            }
            data={chart_data(stats, total)}
          />
        </div>
        <table class="table is-fullwidth is-striped is-narrow">
          <thead>
            <th>Archetype</th>
            <th><.link patch={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "winrate"))}>
            {add_arrow("Winrate", "winrate", @params, true)}
            </.link></th>
            <th><.link patch={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "total"))}>
            {add_arrow("Popularity", "total", @params)}
            </.link></th>
            <th class="is-hidden-mobile"><.link patch={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "turns"))}>
            {add_arrow("Turns", "turns", @params)}
            </.link></th>
            <th class="is-hidden-mobile"><.link patch={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "duration"))}>
            {add_arrow("Duration", "duration", @params)}
            </.link></th>
            <th class="is-hidden-mobile"><.link patch={Routes.live_path(BackendWeb.Endpoint, @live_view, Map.put(@params, "sort_by", "climbing_speed"))}>
            {add_arrow("Climbing Speed", "climbing_speed", @params)}
            </.link></th>
          </thead>
          <tbody>
            <tr :for={as <- stats}>
              <td class={"decklist-info", Deck.extract_class(as.archetype) |> String.downcase()}>
                <a class="basic-black-text deck-title" href={~p"/archetype/#{as.archetype}?#{add_games_filters(@params)}"}>
                  {as.archetype}
                </a>
              </td>
              <td>
                <WinrateTag winrate={as.winrate}/>
              </td>
              <td>{percentage(as.total, total)}% ({as.total})</td>
              <td class="is-hidden-mobile">{Float.round(as.turns, 1)}</td>
              <td class="is-hidden-mobile">{Float.round(as.duration/60, 1)}</td>
              <td class="is-hidden-mobile">{Float.round(as.climbing_speed, 2)}⭐/h</td>
            </tr>
          </tbody>
        </table>
        </div>

      </div>
    """
  end

  def chart_data(stats, total) do
    datasets =
      stats
      |> Enum.group_by(&Deck.extract_class(&1.archetype))
      |> Enum.map(fn {class, stats} ->
        class_name = Deck.class_name(class)

        data =
          Enum.map(stats, fn stats ->
            %{
              y: percentage(stats.total, total),
              x: round(stats.winrate, 1),
              label: stats.archetype || stats.class_name
            }
          end)

        %{
          label: class_name,
          data: data,
          backgroundColor: Deck.class_color(class)
        }
      end)

    %{
      datasets: datasets
    }

    # {data, labels, background_colors} = Enum.reduce(stats, {[], [], []}, fn stats, {d, l, bc} ->
    #   class = Deck.extract_class(stats.archetype)
    #   label = stats.archetype
    #   data =  %{y: percentage(stats.total, total), x: round(stats.winrate, 1)}
    #   background_color = Deck.class_color(class)
    #   {[data | d], [label | l], [background_color | bc]}
    # end)
    # %{
    #   labels: labels,
    #   datasets: [
    #     %{
    #       data: data,
    #       backgroundColor: background_colors
    #     }
    #   ]
    # }
  end

  def premium_filters?(show_premium?, _) when is_boolean(show_premium?), do: show_premium?

  def premium_filters?(_, %Backend.UserManager.User{battletag: battletag}) do
    !!battletag
  end

  def premium_filters?(_, _), do: false

  @default_min_games 1000

  def percentage(num, total) do
    Util.percent(num, total)
    |> Float.round(1)
  end

  def stats([_ | _] = stats, _criteria), do: stats
  def stats(_, criteria), do: stats(criteria)

  def stats(criteria) do
    {min_games, crit} = criteria |> with_defaults() |> Map.pop("min_games")
    stats_all = DeckTracker.archetype_stats(crit)

    total =
      Enum.reduce(stats_all, 0, fn %{total: t}, sum ->
        int_total = Util.to_int_or_orig(t)

        if is_integer(int_total) do
          sum + int_total
        else
          sum
        end
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
    |> parse_int(["min_games", "format"])
  end

  def default_criteria(criteria) do
    default_format = FormatDropdown.default(:public)

    %{
      "exclude_bugged_sources" => "true",
      "period" => PeriodDropdown.default(:public, criteria, default_format),
      "rank" => RankDropdown.default(:public),
      "opponent_class" => "any",
      "player_has_coin" => "any",
      "min_games" => @default_min_games,
      "format" => default_format
    }
  end

  def to_percent(int) when is_integer(int), do: int / 1
  def to_percent(num), do: "#{Float.round(num * 100, 2)}%"

  def handle_event(
        "toggle_chart",
        _,
        socket
      ) do
    {
      :noreply,
      socket
      |> update(:show_chart, &(!&1))
    }
  end

  # defp card_stats_params(params, archetype) do
  #   params
  #   |> Map.take(["format", "opponent_class", "period", "rank"])
  #   |> Map.put("archetype", archetype)
  # end
end
