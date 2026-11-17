defmodule BackendWeb.PlayedCardsArchetypePopularity do
  @moduledoc "Internal helper for archetyping based on played cards"
  use BackendWeb, :surface_live_view
  import Components.CardStatsTable, only: [add_arrow: 3, add_arrow: 4]
  alias Backend.UserManager.User
  alias Components.Filter.PeriodDropdown
  alias Components.Filter.FormatDropdown
  alias Components.Filter.RankDropdown
  alias Components.Filter.ClassDropdown
  alias Components.Filter.PlayableCardSelect
  alias Components.MultiSelectDropdown
  alias Components.LivePatchDropdown
  alias Components.DecklistCard
  alias Components.WinrateTag
  alias Backend.PlayedCardsArchetyper
  alias Backend.PlayedCardsArchetyper.ArchetyperHelper
  alias Backend.Hearthstone.Card
  alias Backend.PlayedCardsArchetyper.NextLevelGenerator

  @default_min_played_count 1000
  @default_min_min_played_count 100
  @default_max_min_played_count 2000
  @default_total_games_percent 1.0
  @default_max_percent_dropoff 10.0
  @default_sort_by "any_popularity"
  @default_card_grouping "single"
  @in_memory_excluded_levels "in_memory_excluded_levels"
  @in_memory_archetype_excludes "in_memory_archetype_excludes"
  data(user, :any)
  data(needs_auto_archetyping_vars?, :boolean, default: false)
  data(needs_class?, :boolean, default: false)
  data(can_access?, :boolean, default: false)
  data(card_popularity, :any)
  data(card_report, :any)
  data(auto_archetyping, :any)
  data(params, :map, default: %{})
  data(criteria, :map, default: %{})
  data(sort_by, :string, default: @default_sort_by)
  data(min_played_count, :integer, default: @default_min_played_count)
  data(min_min_played_count, :integer, default: @default_min_min_played_count)
  data(max_min_played_count, :integer, default: @default_max_min_played_count)
  data(total_games_percent, :number, default: @default_total_games_percent)
  data(max_percent_dropoff, :number, default: @default_max_percent_dropoff)
  data(exclude_config_levels, :integer, default: 0)
  data(filter_config_level, :integer, default: nil)
  data(filter_out_whizbang, :string, default: "yes")
  data(config_map, :map, default: %{})
  data(intermediate_report, :list, default: [])
  data(mode, :string, default: "popularity")
  data(card_grouping, :string, default: @default_card_grouping)
  # %{cards: [card_name], archetype: String.t()} in click order
  data(selected_rows, :list, default: [])
  data(next_level_archetype, :string, default: nil)

  @deck_archetype_mapping %{
    # "Ravenous Cliff Dive DH" => "Cliff Dive DH",
    # Maybe not the best
    # "Azshara Druid" => "Ramp Druid",
    # "Merithra Druid" => "Ramp Druid",
    # "Hostage Druid" => "Ramp Druid",
    "Unholy DK" => "Aggro DK",
    "Harold Blood DK" => "Blood DK",
    "N'Zoth Handbuff DK" => "Handbuff DK",
    "Harold Void Soul DH" => "Void Soul DH",
    "Broxigar DH" => "Spell DH",
    "No Minion DH" => "Spell DH",
    "Treant Druid" => "Token Druid",
    "Beast Attack Druid" => "Beast Druid",
    "Merithra Druid" => "Ramp Druid",
    "Krona Druid" => "Ramp Druid",
    "Azshara Druid" => "Ramp Druid",
    # "N'Zoth Hunter" => "N'Zoth Mech Hunter",
    # "Mech Hunter" => "N'Zoth Mech Hunter",
    "Contraband Face Hunter" => "Face Hunter",
    "Quest Spell Mage" => "Spell Mage",
    "Manastorm Mage" => "Summoner Mage",
    "Holy Paladin" => "Ursol Paladin",
    "Pure Paladin" => "Ursol Paladin",
    "Infinity Paladin" => "Combo Paladin",
    "Mill Paladin" => "Combo Paladin",
    "Archmage Paladin" => "Combo Paladin",
    "Sneaky AYAYA Rogue" => "AYAYA Rogue",
    "Sneaky Harold Rogue" => "Harold Rogue",
    "Sneaky Burn Rogue" => "Burn Rogue",
    "Zee C'Thun Shaman" => "Zee Shaman",
    "Wallow Shredslock" => "Wallow Warlock",
    "Harold Demon Warlock" => "Harold Warlock",
    "Zuramat Warlock" => "Divergence Warlock",
    "Piglock" => "Divergence Warlock",
    "Harold Piglock" => "Divergence Warlock",
    "Harold Egglock" => "Egglock",
    "Dino Egglock" => "Egglock",
    "Harold Warlock" => "C'Thun Warlock",
    "Harold C'Thun Warlock" => "C'Thun Warlock",
    "Dragon Pirate Warrior" => "Dragon Warrior",
    # "Mech Warrior" => "Boom Wrench Warrior",
    # "Safety Warrior" => "Boom Wrench Warrior",
    # "Ysondre Warrior" => "Dragon Warrior",
    #### WILD
    "XL HL Rainbow DK" => "Highlander DK",
    "XL HL Blood DK" => "Highlander DK",
    "XL HL LC Quest Death Knight" => "Highlander DK",
    "XL Highlander Death Knight" => "Highlander DK",
    "HL Rainbow DK" => "Highlander DK",
    "HL Blood DK" => "Highlander DK",
    "HL LC Quest Death Knight" => "Highlander DK",
    "Highlander Death Knight" => "Highlander DK",
    "Fatigue Demon Hunter" => "Questline DH",
    "XL Astral Communion Druid" => "Astral Communion Druid",
    "XL Mill Druid" => "Mill Druid",
    "XL Malygos Druid" => "OTK Druid",
    "XL Dungar Druid" => "OTK Druid",
    "XL Champions Druid" => "OTK Druid",
    "XL HL Dragon Druid" => "Highlander Druid",
    "XL Highlander Druid" => "Highlander Druid",
    "XL HL JtU Quest Druid" => "Highlander Druid",
    "XL Linecracker Druid" => "Linecracker Druid"
  }
  # hacky, ensuring they exist
  :"Spell DH"

  for {k, v} <- @deck_archetype_mapping do
    {String.to_atom(k), String.to_atom(v)}
  end

  def mount(_params, session, socket) do
    {:ok, socket |> assign_defaults(session) |> put_user_in_context() |> assign_can_access()}
  end

  def render(%{can_access?: false} = assigns) do
    ~H"""
      <div class="title is-2">UNAUTHORIZED</div>
      <div class="title is-3">Internal page. If you're really curious you can become a rare supporter since to access<Components.Socials.patreon link="/patreon" /></div>
      <br>
      <div>
        This page is intended for internal use for helping with archetyping based on played cards. It's unoptimized and taxing the servers. I allow premium supporters to access if they're curious because they have access to other taxing stuff on the site.
      </div>
    """
  end

  def render(assigns) do
    ~F"""
      <.page_header title="Played Cards Archetype Popularity" />
      <.filter_container>
        <PeriodDropdown id="period_dropdown" filter_context={:personal} aggregated_only={false} />
        <FormatDropdown id="format_dropdown" filter_context={:personal} aggregated_only={false} />
        <RankDropdown id="rank_dropdown" filter_context={:personal} aggregated_only={false} />
        <ClassDropdown id="class_dropdown" param="player_class"/>
        <LivePatchDropdown
          id="min_played_count"
          options={[1, 23, 69, 100, 420, 666, 1000, 2000, 3500, 5000, 7000, 9001, 15000, 20000]}
          title={"Min Played Count"}
          param={"min_played_count"}
          selected_as_title={false}
          normalizer={&to_string/1} />
        <LivePatchDropdown
          id="exclude_config_levels"
          options={0..50}
          title={"Exclude Config Levels"}
          param={"exclude_config_levels"}
          current_val={@exclude_config_levels}
          selected_as_title={false}
          normalizer={&Util.to_int_or_orig/1} />
        <LivePatchDropdown
          id="sort_by"
          options={[{"any_popularity", "Any Popularity"}, {"total", "Times Played"}]}
          icon={:sort}
          title={"Sort By"}
          param={"sort_by"}
          selected_as_title={false}
          />
        <LivePatchDropdown
          id="mode_dropdown"
          options={[{"popularity", "Popularity"}, {"report", "Report"}, {"auto_archetyping", "Auto Archetype"}]}
          title={"Mode"}
          param={"mode"}
          current_val={@mode}
          selected_as_title={true}
          />
        <LivePatchDropdown
          id="filter_config_level"
          options={[{nil, "Any"}, {"next", "Next"} | Enum.to_list(1..30)]}
          title={"Filter Config Level"}
          param={"filter_config_level"}
          current_val={@filter_config_level}
          selected_as_title={false}
          normalizer={&Util.to_int_or_orig/1} />
        <LivePatchDropdown
          :if={@mode == "popularity"}
          id="filter_out_whizbang"
          options={[{"yes", "Exclude Whizbang"}, {"no", "Include Whizbang"}]}
          title={"Filter out whizbang"}
          param={"filter_out_whizbang"}
          current_val={@filter_out_whizbang}
          selected_as_title={true}
          />
        <LivePatchDropdown
          :if={@mode in ["popularity", "auto_archetyping"]}
          id="card_grouping"
          options={[{"single", "Single Cards"}, {"pairs", "Card Pairs"}]}
          title={"Card Grouping"}
          param={"card_grouping"}
          current_val={@card_grouping}
          selected_as_title={true}
          />
        <MultiSelectDropdown
          :if={excludes_options = excludes_options(@params["format"], @params["player_class"])}
          id="excludes_to_user"
          options={excludes_options}
          title={"Excludes to use"}
          param={"archetype_excludes"}
          current_val={@params["archetype_excludes"] || []}
          selected_as_title={false}
          />

        <LivePatchDropdown
          :if={"auto_archetyping" == @mode}
          id="min_min_played_count"
          options={[1, 23, 69, 100, 420, 666, 1000, 2000, 3500, 5000, 7000, 9001, 15000, 20000]}
          title={"Min Min Played Count (for auto archetyping)"}
          param={"min_min_played_count"}
          selected_as_title={true}
          normalizer={&to_string/1} />
        <LivePatchDropdown
          :if={"auto_archetyping" == @mode}
          id="max_min_played_count"
          options={[1, 23, 69, 100, 420, 666, 1000, 2000, 3500, 5000, 7000, 9001, 15000, 20000]}
          title={"Max Min Played Count (for auto archetyping)"}
          param={"max_min_played_count"}
          selected_as_title={true}
          normalizer={&to_string/1} />
        <LivePatchDropdown
          :if={"auto_archetyping" == @mode}
          id="total_games_percent"
          options={[0.1, 0.25, 0.5, 0.75, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5]}
          title={"Total Games Percent For Min Account(for auto archetyping)"}
          param={"total_games_percent"}
          selected_as_title={true}
          normalizer={&to_string/1} />
        <LivePatchDropdown
          :if={"auto_archetyping" == @mode}
          id="max_percent_dropoff"
          options={[1,3,5,8,10,13,15,18]}
          title={"Max percent dropoff within a single level"}
          param={"max_percent_dropoff"}
          selected_as_title={true}
          normalizer={&to_string/1} />
        <PlayableCardSelect id={"player_deck_includes"} format={@params["format"]} param={"player_deck_includes"} selected={@params["player_deck_includes"] || []} title="Include cards"/>
        <PlayableCardSelect id={"player_deck_excludes"} format={@params["format"]} param={"player_deck_excludes"} selected={@params["player_deck_excludes"] || []} title="Exclude cards"/>
        <PlayableCardSelect id={"player_played_cards_includes"} format={@params["format"]} param={"player_played_cards_includes"} selected={@params["player_played_cards_includes"] || []} title="Played cards"/>
        <PlayableCardSelect id={"player_played_cards_excludes"} format={@params["format"]} param={"player_played_cards_excludes"} selected={@params["player_played_cards_excludes"] || []} title="Not Played cards"/>
      </.filter_container>

      <div :if={@needs_class?}>
        Select a class before proceeding. I'd suggest selecting your other filters first.
      </div>
      <div :if={@needs_auto_archetyping_vars?}>
        Select auto archetyping vers before proceeding.
      </div>
      <div :if={!@needs_class? and !@needs_auto_archetyping_vars?}>
        <div :if={@mode == "auto_archetyping"}>
          <div :if={@auto_archetyping.loading}>
            Loading Auto auto_archetyping
          </div>
          <div :if={@auto_archetyping.ok? && !@auto_archetyping.loading} id="auto-archetyping-result">
            <button
              id="copy-auto-archetyping"
              type="button"
              class="clip-btn-value button is-small tw-my-2 tw-transition-transform hover:tw-scale-105"
              data-balloon-pos="up"
              data-aria-on-copy="Copied!"
              aria-label="Copy generated config"
              data-clipboard-text={auto_archetyping_display(@auto_archetyping.result)}
            >
              <HeroIcons.copy size="small" /> Copy
            </button>
            <code>
              <pre>
                  {auto_archetyping_display(@auto_archetyping.result)}
              </pre>
            </code>
          </div>
        </div>
        <div :if={@mode == "report"}>
          <div :if={@card_report.loading}>
            Loading Card Popularity Report
          </div>
          <div :if={!Enum.empty?(@intermediate_report) || (@card_report.ok? && !@card_report.loading)} class="table-scrolling-sticky-wrapper">
            <.table id="card_report_table">
              <.thead>
                <.trh>
                  <.th class="tw-bg-gray-700">Card</.th>
                  <.th class="tw-bg-gray-700" >Archetype</.th>
                  <.th class="tw-bg-gray-700" >Config Level</.th>
                  <.th class="tw-bg-gray-700" >Popularity in Archetype</.th>
                </.trh>
              </.thead>
              <.tbody>
                <.trb :for={{_card_name, card_report} <- (if @card_report.ok?, do: @card_report.result, else: @intermediate_report)}>
                  <.td>{Card.name(card_report.card)}</.td>
                  <.td>{card_report.archetype}</.td>
                  <.td>{card_report.config_level}</.td>
                  <.td>
                    <WinrateTag tag_name="div" class="tw-h-full" winrate={card_report.popularity} offset={-0.25}/>
                  </.td>
                </.trb>
              </.tbody>
            </.table>
          </div>
        </div>
        <div :if={@mode == "popularity"}>
          <div :if={@card_popularity.loading}>
            Loading Card Popularity
          </div>
          <.next_level_panel
            selected_rows={@selected_rows}
            archetype={next_level_archetype(@next_level_archetype, @selected_rows)}
          />
         <div :if={@card_popularity.ok? && @archetypes.ok? && !@card_popularity.loading} class="table-scrolling-sticky-wrapper">
          <.table id="card_popularity_table" class="table is-fullwidth is-striped tw-table">
            <.thead>
              <.trh>
                <.th class="tw-bg-gray-700">{if @card_grouping == "pairs", do: "Cards", else: "Card"}</.th>
                <.th class="tw-bg-gray-700" :if={User.can_access?(@user, :archetyping)}>Archetype</.th>
                <.th class="tw-bg-gray-700" :if={User.can_access?(@user, :archetyping)}>Config Level</.th>
                <th class={header_class("tw-bg-gray-700")} :on-click="change_sort" phx-value-sort_by={"total"}>
                  {add_arrow("Times Played", "total", @params, true)}
                </th>
                <th class={[header_class("tw-bg-gray-700")]} :on-click="change_sort" phx-value-sort_by={archetype} :for={archetype <- @archetypes.result}>
                  {add_arrow(archetype, to_string(archetype), @params)}
                </th>
              </.trh>
            </.thead>
            <.tbody>
              <.trb
                :for={{{card, level, card_archetype}, %{"total" => total} = popularity_map} <- sort_and_filter(@card_popularity.result, @min_played_count, @sort_by, handle_next(@filter_config_level, @exclude_config_levels), @config_map, @filter_out_whizbang)}
                id={"popularity-row-#{:erlang.phash2(row_card_names(card))}"}
                class="tw-cursor-pointer tw-transition-colors hover:tw-bg-gray-600"
                selected={selected_row?(@selected_rows, card)}
                phx-click="toggle_row"
                phx-value-cards={Jason.encode!(row_card_names(card))}
                phx-value-archetype={most_popular_arch(popularity_map)}>
                <.td class="sticky-column">
                  <div :for={c <- List.wrap(card)} class="decklist_card_container">
                    <DecklistCard deck_class="NEUTRAL" card={c} decklist_options={Backend.UserManager.User.decklist_options(@user)}/>
                  </div>
                </.td>
                <.td :if={User.can_access?(@user, :archetyping)}>{display_info(card_archetype)}</.td>
                <.td :if={User.can_access?(@user, :archetyping)}>{display_info(level)}</.td>
                <.td>{total}</.td>
                <.td :for={archetype <- @archetypes.result} class={class(archetype, card_archetype)}>{popularity_percent(popularity_map, archetype)}</.td>
              </.trb>
            </.tbody>
          </.table>
          </div>
        </div>
      </div>
    """
  end

  attr :selected_rows, :list, required: true
  attr :archetype, :string, required: true

  defp next_level_panel(%{selected_rows: []} = assigns) do
    ~H"""
    <div id="next-level-hint" class="tw-my-2 tw-text-sm tw-text-gray-400">
      Click rows to generate the next archetyper config level
    </div>
    """
  end

  defp next_level_panel(assigns) do
    assigns =
      assign(assigns,
        code: NextLevelGenerator.generate(assigns.archetype, Enum.map(assigns.selected_rows, & &1.cards)),
        form: to_form(%{"archetype" => assigns.archetype}, as: :next_level)
      )

    ~H"""
    <div id="next-level-panel" class="tw-my-4 tw-rounded-lg tw-border tw-border-gray-600 tw-bg-gray-800 tw-p-4">
      <div class="tw-flex tw-flex-wrap tw-items-end tw-gap-3">
        <.form for={@form} id="next-level-form" phx-change="update_next_level_archetype" phx-submit="update_next_level_archetype">
          <.input field={@form[:archetype]} label="Archetype" phx-debounce="300" />
        </.form>
        <button
          id="copy-next-level"
          type="button"
          class="clip-btn-value button is-small tw-transition-transform hover:tw-scale-105"
          data-balloon-pos="up"
          data-aria-on-copy="Copied!"
          aria-label="Copy next level"
          data-clipboard-text={@code}
        >
          <HeroIcons.copy size="small" /> Copy
        </button>
        <button id="clear-next-level" type="button" class="button is-small" phx-click="clear_selected_rows">
          Clear ({Enum.count(@selected_rows)})
        </button>
      </div>
      <pre id="next-level-code" class="tw-mt-3 tw-overflow-x-auto tw-rounded tw-bg-gray-900 tw-p-3 tw-text-sm">{@code}</pre>
    </div>
    """
  end

  # an explicitly typed archetype wins, otherwise use the most popular archetype of the first selected row
  defp next_level_archetype(archetype, _selected) when is_binary(archetype) and archetype != "", do: archetype
  defp next_level_archetype(_, [%{archetype: archetype} | _]), do: archetype
  defp next_level_archetype(_, _), do: ""

  defp row_card_names(card), do: card |> List.wrap() |> Enum.map(&Card.name/1)

  defp selected_row?(selected_rows, card) do
    names = row_card_names(card)
    Enum.any?(selected_rows, &(&1.cards == names))
  end

  defp toggle_selected_row(selected_rows, cards, archetype) do
    if Enum.any?(selected_rows, &(&1.cards == cards)) do
      Enum.reject(selected_rows, &(&1.cards == cards))
    else
      selected_rows ++ [%{cards: cards, archetype: archetype}]
    end
  end

  defp popularity_percent(%{"total" => total} = popularity_map, archetype) when is_integer(total) and total > 0 do
    popularity_map
    |> Map.get(archetype, 0)
    |> Util.percent(total)
    |> Float.round(1)
  end

  defp popularity_percent(_, _), do: 0

  defp auto_archetyping_display(archetyping_config) do
    inspect(archetyping_config, pretty: true)
  end

  @spec excludes_options(integer() | String.t(), String.t()) :: [{String.t(), String.t()}] | false
  defp excludes_options(_format, nil), do: false

  defp excludes_options(format, class) do
    case PlayedCardsArchetyper.excludes(format, class) do
      excludes when is_map(excludes) and map_size(excludes) > 0 ->
        for {archetype, _cards} <- excludes do
          arch = to_string(archetype)
          {arch, arch}
        end
        |> Enum.sort_by(&elem(&1, 0), :asc)

      _ ->
        false
    end
  end

  def card_info({card_id_a, card_id_b}, config_map) do
    infos = [card_info(card_id_a, config_map), card_info(card_id_b, config_map)]

    if Enum.all?(infos, fn {card, _, _} -> card end) do
      {
        Enum.map(infos, &elem(&1, 0)),
        Enum.map(infos, &elem(&1, 1)),
        Enum.map(infos, &elem(&1, 2))
      }
    else
      {nil, nil, nil}
    end
  end

  def card_info(card_id, config_map) do
    case Backend.Hearthstone.get_card(card_id) do
      %{} = card ->
        {level, archetype} = Map.get(config_map, Card.name(card), {nil, nil})
        {card, level, archetype}

      _ ->
        {nil, nil, nil}
    end
  end

  def archetyping_config_cards_excludes(config, levels) do
    config
    |> Enum.take(levels)
    |> Enum.map(fn
      {_archetype, {cards, exclude}} ->
        {PlayedCardsArchetyper.extract_card_names(cards), PlayedCardsArchetyper.extract_card_names(exclude)}

      {_archetype, cards} ->
        {PlayedCardsArchetyper.extract_card_names(cards), []}
    end)
  end

  # pairs have a list of values (one per card), single cards have the value directly
  defp display_info(values) when is_list(values) do
    Enum.map_join(values, " + ", &(&1 |> to_string() |> Util.empty_to("-")))
  end

  defp display_info(value), do: value

  defp class(archetype, card_archetype) do
    if Enum.any?(List.wrap(card_archetype), &(to_string(&1) == to_string(archetype))) do
      "tw-font-bold tw-text-gray-500"
    end
  end

  def handle_params(params, _uri, socket) do
    default = %{
      "period" => "all",
      "format" => 2,
      "min_played_count" => @default_min_played_count,
      "rank" => "diamond_to_legend"
    }

    exclude_config_levels = Map.get(params, "exclude_config_levels", 0) |> Util.to_int_or_orig()
    filter_config_level = Map.get(params, "filter_config_level") |> Util.to_int_or_orig()

    criteria =
      Map.merge(default, params)
      |> Map.take([
        "period",
        "format",
        "rank",
        "player_class",
        "player_deck_includes",
        "player_deck_excludes",
        "player_played_cards_includes",
        "player_played_cards_excludes"
      ])
      |> add_excludes(params["archetype_excludes"])
      |> add_excluded_config(exclude_config_levels)

    min_played_count =
      Map.get(params, "min_played_count", @default_min_played_count) |> Util.to_int_or_orig()

    min_min_played_count =
      Map.get(params, "min_min_played_count", @default_min_min_played_count) |> Util.to_int_or_orig()

    max_min_played_count =
      Map.get(params, "max_min_played_count", @default_max_min_played_count) |> Util.to_int_or_orig()

    total_games_percent =
      Map.get(params, "total_games_percent", @default_total_games_percent) |> Util.to_float_or_orig()

    max_percent_dropoff =
      Map.get(params, "max_percent_dropoff", @default_max_percent_dropoff) |> Util.to_float_or_orig()

    sort_by = Map.get(params, "sort_by", @default_sort_by)
    mode = Map.get(params, "mode", "popularity")
    card_grouping = Map.get(params, "card_grouping", @default_card_grouping)

    selected_params =
      default |> Map.merge(params) |> Map.put("min_played_count", min_played_count)

    same_assigns = [
      criteria: criteria,
      params: params,
      sort_by: sort_by,
      exclude_config_levels: exclude_config_levels,
      filter_config_level: filter_config_level,
      filter_out_whizbang: params["filter_out_whizbang"] || socket.assigns[:filter_out_whizbang],
      intermediate_report: [],
      mode: mode,
      card_grouping: card_grouping,
      min_played_count: min_played_count,
      min_min_played_count: min_min_played_count,
      max_min_played_count: max_min_played_count,
      max_percent_dropoff: max_percent_dropoff,
      total_games_percent: total_games_percent
    ]

    needed_vars_flags = needed_vars_flags(criteria, params, mode)
    socket = maybe_reset_selected_rows(socket, criteria, card_grouping)

    if Enum.any?(needed_vars_flags, fn {_flag, needed?} -> needed? end) do
      {:noreply,
       socket
       |> assign(needed_vars_flags)
       |> assign(same_assigns)
       |> update_context(selected_params)}
    else
      title = "#{criteria["player_class"]} #{mode}"

      {
        :noreply,
        socket
        |> assign(needed_vars_flags)
        |> assign(same_assigns)
        |> assign_config_map(criteria)
        |> update_context(selected_params)
        |> fetch_async(socket, mode)
        |> assign_meta_tags(%{
          title: title
        })
      }
    end
  end

  # selected cards only make sense for the same class, format and grouping
  defp maybe_reset_selected_rows(%{assigns: assigns} = socket, criteria, card_grouping) do
    same_selection_context? =
      Map.get(assigns, :card_grouping) == card_grouping and
        Map.get(assigns, :criteria, %{})["player_class"] == criteria["player_class"] and
        Map.get(assigns, :criteria, %{})["format"] == criteria["format"]

    if same_selection_context? do
      socket
    else
      assign(socket, selected_rows: [], next_level_archetype: nil)
    end
  end

  defp handle_next("next", excluded) when is_number(excluded), do: excluded + 1
  defp handle_next(level, _), do: level

  defp needed_vars_flags(criteria, params, mode) do
    needs_auto_archetyping_vars? =
      "auto_archetyping" == mode and
        !Util.has_keys?(params, [
          "min_min_played_count",
          "max_min_played_count",
          "total_games_percent",
          "max_percent_dropoff"
        ])

    needs_class? = !Map.has_key?(criteria, "player_class")

    [
      needs_class?: needs_class?,
      needs_auto_archetyping_vars?: needs_auto_archetyping_vars?
    ]
  end

  # plain card names are excluded from the deck in the db query
  # other matchers (ie {:start_of_game, cards}, functions) are filtered out after fetching
  defp add_excludes(criteria, [_ | _] = excludes) do
    format = criteria["format"]

    {card_names, matchers} =
      format
      |> PlayedCardsArchetyper.excludes(criteria["player_class"])
      |> Enum.filter(fn {archetype, _} -> to_string(archetype) in excludes end)
      |> Enum.flat_map(fn {_archetype, archetype_excludes} -> List.wrap(archetype_excludes) end)
      |> Enum.split_with(&is_binary/1)

    criteria
    |> add_deck_excludes(card_names, format)
    |> add_in_memory_archetype_excludes(matchers)
  end

  defp add_excludes(criteria, _), do: criteria

  defp add_deck_excludes(criteria, [_ | _] = card_names, format) do
    new_excludes = names_to_ids(card_names, format) ++ Map.get(criteria, "player_deck_excludes", [])
    Map.put(criteria, "player_deck_excludes", new_excludes)
  end

  defp add_deck_excludes(criteria, _, _), do: criteria

  defp add_in_memory_archetype_excludes(criteria, [_ | _] = matchers) do
    Map.put(criteria, @in_memory_archetype_excludes, matchers)
  end

  defp add_in_memory_archetype_excludes(criteria, _), do: criteria

  # no need to fetch because the criteria hasn't changed
  defp fetch_async(
         %{assigns: %{criteria: new_criteria, card_grouping: new_grouping}} = new_socket,
         %{
           assigns: %{criteria: old_criteria, card_grouping: old_grouping}
         },
         _
       )
       when new_criteria == old_criteria and new_grouping == old_grouping do
    new_socket
  end

  defp fetch_async(new_socket, _old_socket, "popularity"), do: fetch_popularity(new_socket)
  defp fetch_async(new_socket, _old_socket, "report"), do: fetch_report(new_socket)
  defp fetch_async(new_socket, _old_socket, "auto_archetyping"), do: fetch_auto_archetyping(new_socket)

  defp fetch_auto_archetyping(socket) do
    criteria = socket.assigns.criteria

    auto_archetyping_vars =
      Map.take(socket.assigns, [
        :min_min_played_count,
        :max_min_played_count,
        :total_games_percent,
        :max_percent_dropoff
      ])
      |> Map.put(:card_grouping, socket.assigns.card_grouping)

    exclude_config_levels = Map.get(socket.assigns, :exclude_config_levels) || 0

    socket
    |> assign_async([:auto_archetyping], fn ->
      IO.puts("assigning async from level #{exclude_config_levels}")
      fetch_auto_archetyping(criteria, auto_archetyping_vars, exclude_config_levels)
    end)
  end

  def fetch_auto_archetyping(base_criteria, vars, level, prev_config \\ nil) do
    format = Map.fetch!(base_criteria, "format") |> Util.to_int_or_orig()
    class = Map.fetch!(base_criteria, "player_class")

    new_level = level + 1

    puts_append =
      "auto archetyping level #{new_level}. class: #{class} format: #{format}|||#{NaiveDateTime.utc_now()}"

    IO.puts("Starting #{puts_append}")

    previous_archetyper_config =
      with nil <- prev_config do
        PlayedCardsArchetyper.config(format, class) |> Enum.take(level)
      end

    criteria = base_criteria |> add_excluded_config(level, previous_archetyper_config)
    games = games_with_played_cards(criteria, timeout: 120_000)
    game_count = Enum.count(games)
    IO.puts("Got #{game_count} games while #{puts_append}")
    min_played_count = min_played_count(vars, game_count)
    IO.puts("Min Played count #{min_played_count} games while #{puts_append}")
    card_grouping = Map.get(vars, :card_grouping, @default_card_grouping)
    {card_popularity, _archetypes} = process_games(games, card_grouping)
    config_map = config_map(previous_archetyper_config)

    case sort_and_filter(card_popularity, min_played_count, "any_popularity", nil, config_map, "yes")
         |> skip_zilly(config_map) do
      [{_card_info, popularity_map} = first | rest] ->
        arch = most_popular_arch(popularity_map)
        start_percent = popularity_percent(popularity_map, arch)
        percent_cutoff = start_percent - Map.get(vars, :max_percent_dropoff, @default_max_percent_dropoff)

        same =
          Enum.take_while(rest, fn {_, pop_map} ->
            most_popular_arch(pop_map) == arch and
              popularity_percent(pop_map, arch) >= percent_cutoff
          end)

        # single cards become plain names, pairs become {:all, [[card], partners]} groups
        cards =
          [first | same]
          |> Enum.map(fn {{card, _, _}, _} -> row_card_names(card) end)
          |> Enum.sort()
          |> NextLevelGenerator.matchers()

        string_arch =
          arch
          |> Util.empty_to("Other #{Backend.Hearthstone.Deck.short_name_if_multi_word(class)}")
          |> String.to_existing_atom()

        new_config = previous_archetyper_config ++ [{string_arch, cards}]

        IO.puts("Adding #{Enum.count(cards)} for #{arch}: #{inspect(cards)} while #{puts_append}")
        fetch_auto_archetyping(base_criteria, vars, new_level, new_config)

      _result ->
        IO.puts("Done auto archetyping, got up to #{level}")
        {:ok, %{auto_archetyping: previous_archetyper_config}}
    end
  end

  # hack because it gets stuck on always zilly
  # not 100% why this happens
  # hack seemed easiest
  defp skip_zilly([{{card, _, _}, _pop_map} | rest] = result, %{"Zilliax Deluxe 3000" => _}) do
    if "Zilliax Deluxe 3000" in row_card_names(card), do: rest, else: result
  end

  defp skip_zilly(result, _), do: result

  defp min_played_count(
         %{min_min_played_count: min, max_min_played_count: max, total_games_percent: total_games_percent},
         total_games
       ) do
    # min = Keyword.fetch!(vars, :min_min_played_count) |> Util.to_int_or_orig()
    # max = Keyword.fetch!(vars, :max_min_played_count) |> Util.to_int_or_orig()
    # total_games_percent = Keyword.fetch!(vars, :total_games_percent) |> Util.to_float_or_orig()
    games = total_games * total_games_percent * 0.01
    Util.median([min, games, max])
  end

  defp fetch_popularity(socket) do
    criteria = socket.assigns.criteria
    card_grouping = socket.assigns.card_grouping

    socket
    |> assign_async([:card_popularity, :archetypes], fn ->
      fetch_card_popularity(criteria, card_grouping)
    end)

    # |> assign(:card_report, Phoenix.LiveView.AsyncResult.loading())
  end

  defp fetch_report(socket) do
    criteria = socket.assigns.criteria
    pid = socket.root_pid

    socket
    |> assign_async([:card_report], fn ->
      fetch_card_report(criteria, pid)
    end)
  end

  defp assign_config_map(socket, %{"format" => format, "player_class" => player_class}) do
    config_map = config_map(format, player_class)

    socket |> assign(config_map: config_map)
  end

  defp assign_config_map(socket, _), do: socket

  defp config_map(format, player_class) do
    format
    |> Util.to_int_or_orig()
    |> PlayedCardsArchetyper.config(player_class)
    |> config_map()
  end

  defp config_map(archetyper_config) do
    archetyper_config
    |> Enum.with_index(1)
    |> Enum.flat_map(fn
      {{archetype, {cards, _exclude}}, level} ->
        cards
        |> PlayedCardsArchetyper.extract_card_names()
        |> Enum.map(fn card_name ->
          {card_name, {level, archetype}}
        end)

      {{archetype, cards}, level} ->
        cards
        |> PlayedCardsArchetyper.extract_card_names()
        |> Enum.map(fn card_name ->
          {card_name, {level, archetype}}
        end)
    end)
    |> Map.new()
  end

  defp add_excluded_config(criteria, levels, config \\ nil)

  defp add_excluded_config(
         %{"format" => format} = criteria,
         levels,
         config
       )
       when levels > 0 do
    case config(config, criteria) do
      nil ->
        criteria

      config ->
        {db_levels, in_memory_levels} =
          config
          |> Enum.take(levels)
          |> Enum.split_with(&db_expressible_level?/1)

        criteria
        |> add_db_excluded_levels(db_levels, format)
        |> add_in_memory_excluded_levels(in_memory_levels)
    end
  end

  defp add_excluded_config(criteria, _, _), do: criteria

  defp add_db_excluded_levels(criteria, [_ | _] = db_levels, format) do
    excludes_includes_levels =
      db_levels
      |> archetyping_config_cards_excludes(Enum.count(db_levels))
      |> Enum.map(fn {cards, excludes_in_level} ->
        cards_ids = names_to_ids(cards, format)
        excludes_in_level_ids = names_to_ids(excludes_in_level, format)

        # we want to skip the ones that match, so in the db we want to exclude the cards_ids but include those that have excluded ids
        %{"exclude" => cards_ids, "include_any" => excludes_in_level_ids}
      end)

    Map.put(criteria, "player_played_cards_excludes_includes_levels", excludes_includes_levels)
  end

  defp add_db_excluded_levels(criteria, _, _), do: criteria

  # levels with :all, :start_of_game, functions etc. can't be expressed in the db query
  # so the games matching them are filtered out after fetching
  defp add_in_memory_excluded_levels(criteria, [_ | _] = in_memory_levels) do
    Map.put(criteria, @in_memory_excluded_levels, in_memory_levels)
  end

  defp add_in_memory_excluded_levels(criteria, _), do: criteria

  defp db_expressible_level?({_archetype, {cards, exclude}}),
    do: card_names?(cards) and card_names?(exclude)

  defp db_expressible_level?({_archetype, cards}), do: card_names?(cards)

  defp card_names?(cards), do: is_list(cards) and Enum.all?(cards, &is_binary/1)

  defp games_with_played_cards(criteria, repo_opts) do
    {in_memory_levels, criteria} = Map.pop(criteria, @in_memory_excluded_levels, [])
    {archetype_excludes, db_criteria} = Map.pop(criteria, @in_memory_archetype_excludes, [])

    db_criteria
    |> Hearthstone.DeckTracker.games_with_played_cards(repo_opts)
    |> reject_matching_levels(in_memory_levels)
    |> reject_matching_excludes(archetype_excludes)
  end

  defp reject_matching_levels(games, [_ | _] = levels) do
    Enum.reject(games, &(ArchetyperHelper.process_config(levels, player_card_info(&1)) != nil))
  end

  defp reject_matching_levels(games, _), do: games

  defp reject_matching_excludes(games, [_ | _] = matchers) do
    Enum.reject(games, &ArchetyperHelper.matches?(player_card_info(&1), matchers))
  end

  defp reject_matching_excludes(games, _), do: games

  defp player_card_info(%{played_cards: played_cards}) do
    PlayedCardsArchetyper.card_info(
      played_cards.player_cards,
      played_cards.player_start_of_game || [],
      false
    )
  end

  defp config(config, _criteria) when is_list(config), do: config

  defp config(_, %{"format" => format, "player_class" => class}) do
    format
    |> Util.to_int_or_orig()
    |> PlayedCardsArchetyper.config(class)
  end

  defp config(_, _), do: nil

  defp names_to_ids(card_names, format) do
    Backend.Hearthstone.cards([
      {"format", format},
      {"names", card_names}
    ])
    |> Enum.map(fn %{id: id} -> Hearthstone.DeckTracker.tally_card_id(id) end)
    |> Enum.uniq()
  end

  defp assign_can_access(%{assigns: %{user: user}} = socket) do
    can_access? = User.can_access?(user, :archetyping) or User.premium?(user)
    assign(socket, can_access?: can_access?)
  end

  defp update_context(socket, selected_params) do
    LivePatchDropdown.update_context(
      socket,
      __MODULE__,
      selected_params
    )
  end

  def fetch_card_popularity(criteria, card_grouping \\ @default_card_grouping) do
    games = games_with_played_cards(criteria, timeout: 120_000)
    {popularity, archetypes_popularity} = process_games(games, card_grouping)

    {:ok, %{card_popularity: popularity, archetypes: sorted_archetypes(archetypes_popularity)}}
  end

  def fetch_card_report(base_criteria, pid) do
    format = Map.fetch!(base_criteria, "format") |> Util.to_int_or_orig()
    class = Map.fetch!(base_criteria, "player_class")
    archetyper_config = PlayedCardsArchetyper.config(format, class)
    config_map = config_map(archetyper_config)

    card_report =
      archetyper_config
      |> Enum.with_index(1)
      |> Enum.reject(fn {{archetype, _cards}, _} ->
        archetype
        |> to_string()
        |> String.starts_with?("Whizbang")
      end)
      |> Enum.reduce([], fn {{_archetype, cards_maybe_excludes}, level}, carry ->
        cards = cards_maybe_excludes |> cards() |> PlayedCardsArchetyper.extract_card_names()
        IO.puts("Processing level #{level}. class: #{class} format: #{format}")

        games =
          base_criteria
          |> add_excluded_config(level - 1)
          |> games_with_played_cards(timeout: :infinity)

        {popularity, _} = process_games(games)

        pop_map =
          popularity
          |> merge()
          |> Map.new(fn {card_id, pop} ->
            {card, level, archetype} = card_info(card_id, config_map)
            {Card.name(card), %{level: level, archetype: archetype, pop: pop, card: card}}
          end)

        new_level =
          Enum.flat_map(cards, fn card_name ->
            case Map.get(pop_map, card_name) do
              %{level: level, archetype: archetype, pop: pop, card: card} ->
                card_arch_popularity =
                  with total when is_integer(total) and total > 0 <- Map.get(pop, "total"),
                       card_arch_pop when is_integer(card_arch_pop) <-
                         Map.get(pop, to_string(archetype)) do
                    card_arch_pop / total
                  else
                    _ -> 0
                  end

                [
                  {card_name,
                   %{
                     card: card,
                     archetype: archetype,
                     config_level: level,
                     popularity: card_arch_popularity
                   }}
                ]

              _ ->
                []
            end
          end)

        new_carry = carry ++ new_level
        send(pid, {:update_intermediate_report, new_carry})
        new_carry
      end)

    {:ok, %{card_report: card_report}}
  end

  defp cards({cards, _excludes}), do: cards
  defp cards(cards), do: cards

  def handle_info({:update_intermediate_report, intermediate_report}, socket) do
    {:noreply, socket |> assign(intermediate_report: intermediate_report)}
  end

  @doc """
  Counts how often cards were played per archetype.

  With "pairs" grouping the keys are sorted `{card_id, card_id}` tuples
  and a pair is only counted when both cards were played in the game
  """
  def process_games(games, card_grouping \\ @default_card_grouping) do
    Enum.reduce(games, {%{}, %{}}, fn
      %{player_deck: %{archetype: archetype}, played_cards: played_cards}, {popularity, archetype_popularity} ->
        archetype = archetype |> to_string()

        pop =
          played_cards.player_cards
          |> Enum.map(&Hearthstone.DeckTracker.tally_card_id/1)
          |> popularity_keys(card_grouping)
          |> Enum.reduce(popularity, &increment_popularity(&2, &1, archetype))

        arch_pop = update_in(archetype_popularity, [Access.key(archetype, 0)], &(&1 + 1))
        {pop, arch_pop}

      _, carry ->
        carry
    end)
  end

  defp popularity_keys(card_ids, "pairs") do
    card_ids
    |> Enum.uniq()
    |> Enum.sort()
    |> card_pairs()
  end

  defp popularity_keys(card_ids, _single), do: card_ids

  # expects sorted ids so each pair is always keyed the same way
  defp card_pairs([first | rest]), do: Enum.map(rest, &{first, &1}) ++ card_pairs(rest)
  defp card_pairs([]), do: []

  defp increment_popularity(popularity, key, archetype) do
    Map.update(popularity, key, %{archetype => 1, "total" => 1}, fn card_pop ->
      card_pop
      |> Map.update(archetype, 1, &(&1 + 1))
      |> Map.update("total", 1, &(&1 + 1))
    end)
  end

  def sort_and_filter(
        card_played_popularity,
        min_played_count,
        sort_by,
        filter_config_level,
        config_map,
        filter_out_whizbang
      ) do
    sorter = sorter(sort_by)

    card_played_popularity
    |> Enum.filter(fn
      {_, %{"total" => total}} -> total >= min_played_count
      _ -> false
    end)
    |> merge()
    |> Enum.map(fn {card_id, popularity} ->
      {card_info(card_id, config_map), popularity}
    end)
    |> Enum.filter(fn {{card, _, _}, _} ->
      card |> List.wrap() |> Enum.all?(&(Card.name(&1) != "The Coin"))
    end)
    |> filter_config_level(filter_config_level)
    |> filter_out_whizbang(filter_out_whizbang)
    |> Enum.sort_by(sorter, :desc)
  end

  defp filter_out_whizbang(card_popularity, "no"), do: card_popularity

  defp filter_out_whizbang(card_popularity, "yes") do
    Enum.reject(card_popularity, fn {{_card, _level, archetype}, _} ->
      archetype |> List.wrap() |> Enum.any?(&(to_string(&1) =~ "Whizbang"))
    end)
  end

  defp filter_out_whizbang(card_popularity, _), do: card_popularity

  defp filter_config_level(card_popularity, filter_level) when is_integer(filter_level) do
    Enum.filter(card_popularity, fn {{_card, level, _popularity}, _} -> filter_level in List.wrap(level) end)
  end

  defp filter_config_level(card_popularity, _filter_level), do: card_popularity

  def merge(card_popularity) do
    card_popularity
    |> Enum.map(fn {id, popularity} ->
      {id, merge_archetypes_map(popularity)}
    end)
  end

  def get_merged_archetype(archetype, mapping \\ @deck_archetype_mapping) do
    case Map.get(mapping, archetype) do
      nil -> archetype
      a when a != archetype -> get_merged_archetype(a, mapping)
      _ -> archetype
    end
  end

  defp sorter("any_popularity") do
    fn
      {_card, popularity} ->
        {total, rest} = Map.pop(popularity, "total", 999_999_999)

        val = most_popular_count(rest)

        val / total
    end
  end

  defp sorter("total"), do: fn {_card, popularity} -> Map.get(popularity, "total", 0) end

  defp sorter(sort_by) do
    fn {_card, popularity} ->
      count = Map.get(popularity, sort_by, 0)
      total = Map.get(popularity, "total", 0)
      count / total
    end
  end

  defp most_popular(popularity_map) do
    popularity_map
    |> Map.delete("total")
    # ensure it's not empty
    |> Map.put_new("not_empty", 0)
    |> Enum.max_by(fn {_arch, val} -> val end)
  end

  defp most_popular_count(popularity_map) do
    most_popular(popularity_map)
    |> elem(1)
  end

  defp most_popular_arch(popularity_map) do
    most_popular(popularity_map)
    |> elem(0)
  end

  defp sorted_archetypes(archetypes_map) do
    archetypes_map
    |> merge_archetypes_map()
    |> Enum.sort_by(fn {_arch, count} -> count end, :desc)
    |> Enum.map(fn {archetype, _count} -> archetype end)
  end

  def merge_archetypes_map(map, mapping \\ @deck_archetype_mapping) do
    map
    |> Enum.group_by(fn {arch, _count} -> get_merged_archetype(arch, mapping) end, fn {_arch, count} ->
      count
    end)
    |> Map.new(fn {arch, counts} -> {arch, Enum.sum(counts)} end)
  end

  def deck_archetype_mapping, do: @deck_archetype_mapping

  def handle_event("toggle_row", %{"cards" => cards_json, "archetype" => archetype}, socket) do
    with {:ok, [_ | _] = cards} <- Jason.decode(cards_json) do
      selected_rows = toggle_selected_row(socket.assigns.selected_rows, cards, archetype)
      {:noreply, assign(socket, selected_rows: selected_rows)}
    else
      _ -> {:noreply, socket}
    end
  end

  def handle_event("update_next_level_archetype", %{"next_level" => %{"archetype" => archetype}}, socket) do
    {:noreply, assign(socket, next_level_archetype: archetype)}
  end

  def handle_event("clear_selected_rows", _, socket) do
    {:noreply, assign(socket, selected_rows: [], next_level_archetype: nil)}
  end

  def handle_event(
        "change_sort",
        sort,
        %{
          assigns: %{
            params: params
          }
        } = socket
      ) do
    new_params = Map.merge(params, sort)

    {:noreply,
     socket
     |> push_patch(
       to:
         LivePatchDropdown.link(
           BackendWeb.Endpoint,
           __MODULE__,
           nil,
           new_params
         )
     )}
  end
end
