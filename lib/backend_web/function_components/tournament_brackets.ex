defmodule FunctionComponents.TournamentBrackets do
  @moduledoc """
  Reusable generic UI components for tournament bracket structures:
  - Match cards with scores, bans, and interactive pick support
  - GSL double-elimination groups with optional collapsibility
  - Single-elimination playoff trees with optional collapsibility
  - Double-elimination trees with optional collapsibility
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  # --- Match Card Component ---

  attr :match, :map, required: true
  attr :node, :map, default: nil
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :picked_winner, :string, default: nil
  attr :predicted_top, :string, default: nil
  attr :predicted_bottom, :string, default: nil
  attr :predicted_top_score, :integer, default: nil
  attr :predicted_bottom_score, :integer, default: nil
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false
  attr :score_label, :string, default: nil
  attr :show_pick_stats, :boolean, default: false
  attr :pick_stats, :map, default: nil
  attr :on_open_champion_picks, :string, default: nil

  def match_card(assigns) do
    match = assigns.match
    node = assigns.node

    top_name = (node && node.predicted_top) || assigns.predicted_top || Map.get(match, :top_name) || "TBD"
    bottom_name = (node && node.predicted_bottom) || assigns.predicted_bottom || Map.get(match, :bottom_name) || "TBD"

    picked_winner = (node && node.picked_winner) || assigns.picked_winner
    top_score = (node && node.predicted_top_score) || assigns.predicted_top_score
    bot_score = (node && node.predicted_bottom_score) || assigns.predicted_bottom_score

    {resolved_top_score, resolved_bottom_score} =
      cond do
        not is_nil(top_score) and not is_nil(bot_score) ->
          {top_score, bot_score}

        picked_winner == top_name and top_name != "TBD" ->
          {3, 2}

        picked_winner == bottom_name and bottom_name != "TBD" ->
          {2, 3}

        true ->
          {top_score, bot_score}
      end

    is_complete = Map.get(match, :is_complete, false)
    match_id = Map.get(match, :match_identifier, "")
    round_name = Map.get(match, :round_name, "")
    actual_winner = Map.get(match, :actual_winner_name)
    actual_top_score = Map.get(match, :top_score)
    actual_bottom_score = Map.get(match, :bottom_score)
    match_top_name = Map.get(match, :top_name)
    match_bottom_name = Map.get(match, :bottom_name)

    resolved_actual_top_score =
      cond do
        is_nil(actual_top_score) and is_nil(actual_bottom_score) ->
          nil

        is_nil(match_top_name) and is_nil(match_bottom_name) ->
          actual_top_score

        top_name == match_top_name ->
          actual_top_score

        top_name == match_bottom_name ->
          actual_bottom_score

        true ->
          nil
      end

    resolved_actual_bottom_score =
      cond do
        is_nil(actual_top_score) and is_nil(actual_bottom_score) ->
          nil

        is_nil(match_top_name) and is_nil(match_bottom_name) ->
          actual_bottom_score

        bottom_name == match_bottom_name ->
          actual_bottom_score

        bottom_name == match_top_name ->
          actual_top_score

        true ->
          nil
      end

    has_result = is_complete || not is_nil(actual_winner)

    top_is_picked = picked_winner == top_name and top_name != "TBD"
    top_is_actual_winner = has_result and actual_winner == top_name and top_name != "TBD"
    top_is_wrong_pick = top_is_picked and has_result and not top_is_actual_winner
    top_is_correct_pick = top_is_picked and top_is_actual_winner

    bottom_is_picked = picked_winner == bottom_name and bottom_name != "TBD"
    bottom_is_actual_winner = has_result and actual_winner == bottom_name and bottom_name != "TBD"
    bottom_is_wrong_pick = bottom_is_picked and has_result and not bottom_is_actual_winner
    bottom_is_correct_pick = bottom_is_picked and bottom_is_actual_winner

    # Bans: P2 banned P1's deck; P1 banned P2's deck
    top_ban = Map.get(match, :p2_banned_class)
    bottom_ban = Map.get(match, :p1_banned_class)

    # Won/Lost Decks and Games
    top_deck_statuses = Map.get(match, :top_deck_statuses, [])
    bottom_deck_statuses = Map.get(match, :bottom_deck_statuses, [])
    top_game_decks = Map.get(match, :top_game_decks, [])
    bottom_game_decks = Map.get(match, :bottom_game_decks, [])
    top_banned_deck = Map.get(match, :top_banned_deck)
    bottom_banned_deck = Map.get(match, :bottom_banned_deck)

    is_ongoing =
      Map.get(match, :is_ongoing, false) ||
        (not is_complete &&
           (Enum.any?(top_game_decks) || Enum.any?(bottom_game_decks) ||
              (not is_nil(actual_top_score) && actual_top_score > 0) ||
              (not is_nil(actual_bottom_score) && actual_bottom_score > 0) ||
              (not is_nil(top_ban) && top_ban != "") ||
              (not is_nil(bottom_ban) && bottom_ban != "")))

    show_score_selection =
      assigns.interactive &&
        (assigns.predict_scores || assigns.admin_mode) &&
        not is_nil(picked_winner) &&
        top_name != "TBD" &&
        bottom_name != "TBD" &&
        not is_complete

    show_pick_stats = assigns.show_pick_stats and not is_nil(assigns.pick_stats)
    total_picks = if show_pick_stats, do: Map.get(assigns.pick_stats, :total_picks, 0), else: 0

    top_stat = if show_pick_stats, do: get_in(assigns.pick_stats, [:by_player, top_name]), else: nil
    bot_stat = if show_pick_stats, do: get_in(assigns.pick_stats, [:by_player, bottom_name]), else: nil

    top_pick_pct =
      cond do
        not is_nil(top_stat) -> top_stat.percentage
        show_pick_stats and total_picks > 0 and top_name != "TBD" -> 0.0
        true -> nil
      end

    bot_pick_pct =
      cond do
        not is_nil(bot_stat) -> bot_stat.percentage
        show_pick_stats and total_picks > 0 and bottom_name != "TBD" -> 0.0
        true -> nil
      end

    top_pick_cnt = if top_stat, do: top_stat.count, else: 0
    bot_pick_cnt = if bot_stat, do: bot_stat.count, else: 0

    other_picks =
      if show_pick_stats and total_picks > 0 do
        assigns.pick_stats
        |> Map.get(:by_player, %{})
        |> Map.drop([top_name, bottom_name])
        |> Enum.map(fn {player, stat} ->
          %{player: player, count: stat.count, percentage: stat.percentage}
        end)
        |> Enum.sort_by(& &1.count, :desc)
      else
        []
      end

    is_finals_match =
      String.ends_with?(match_id, "_finals") or match_id == "playoffs_finals" or
        String.contains?(String.downcase(round_name), "grand final") or
        String.contains?(String.downcase(round_name), "championship")

    assigns =
      assigns
      |> assign(:display_top, top_name)
      |> assign(:display_bottom, bottom_name)
      |> assign(:active_winner, picked_winner)
      |> assign(:active_top_score, resolved_top_score)
      |> assign(:active_bottom_score, resolved_bottom_score)
      |> assign(:show_score_selection, show_score_selection)
      |> assign(:is_complete, is_complete)
      |> assign(:is_ongoing, is_ongoing)
      |> assign(:match_id, match_id)
      |> assign(:round_name, round_name)
      |> assign(:actual_winner, actual_winner)
      |> assign(:actual_top_score, resolved_actual_top_score)
      |> assign(:actual_bottom_score, resolved_actual_bottom_score)
      |> assign(:top_is_wrong_pick, top_is_wrong_pick)
      |> assign(:top_is_correct_pick, top_is_correct_pick)
      |> assign(:bottom_is_wrong_pick, bottom_is_wrong_pick)
      |> assign(:bottom_is_correct_pick, bottom_is_correct_pick)
      |> assign(:top_ban, top_ban)
      |> assign(:bottom_ban, bottom_ban)
      |> assign(:top_deck_statuses, top_deck_statuses)
      |> assign(:bottom_deck_statuses, bottom_deck_statuses)
      |> assign(:top_game_decks, top_game_decks)
      |> assign(:bottom_game_decks, bottom_game_decks)
      |> assign(:top_banned_deck, top_banned_deck)
      |> assign(:bottom_banned_deck, bottom_banned_deck)
      |> assign(:show_pick_stats, show_pick_stats)
      |> assign(:total_picks, total_picks)
      |> assign(:top_pick_pct, top_pick_pct)
      |> assign(:bot_pick_pct, bot_pick_pct)
      |> assign(:top_pick_cnt, top_pick_cnt)
      |> assign(:bot_pick_cnt, bot_pick_cnt)
      |> assign(:other_picks, other_picks)
      |> assign(:is_finals_match, is_finals_match)

    ~H"""
    <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-p-3.5 tw-shadow-lg tw-transition-all tw-duration-200 hover:tw-border-slate-600">
      <!-- Match Header -->
      <div class="tw-flex tw-justify-between tw-items-center tw-mb-2.5 tw-text-xs tw-font-semibold tw-text-slate-400">
        <span class="tw-tracking-wide tw-truncate">{@round_name}</span>
        <%= cond do %>
          <% @is_complete -> %>
            <span class="tw-bg-emerald-950/80 tw-text-emerald-400 tw-border tw-border-emerald-700/60 tw-px-2 tw-py-0.5 tw-rounded-full tw-font-mono tw-text-[11px]">
              Final
            </span>
          <% @is_ongoing -> %>
            <span class="tw-inline-flex tw-items-center tw-gap-1.5 tw-bg-amber-950/80 tw-text-amber-400 tw-border tw-border-amber-700/60 tw-px-2 tw-py-0.5 tw-rounded-full tw-font-mono tw-text-[11px]">
              <span class="tw-w-1.5 tw-h-1.5 tw-rounded-full tw-bg-amber-400 tw-animate-pulse"></span>
              Ongoing
            </span>
          <% true -> %>
            <span class="tw-text-slate-500 tw-font-mono tw-text-[11px]">Upcoming</span>
        <% end %>
      </div>

      <!-- Contestants -->
      <div class="tw-space-y-2">
        <!-- Top Contestant -->
        <.contestant_row
          name={@display_top}
          banned_class={@top_ban}
          game_decks={@top_game_decks}
          banned_deck={@top_banned_deck}
          deck_statuses={@top_deck_statuses}
          is_picked={@active_winner == @display_top and @display_top != "TBD"}
          is_actual_winner={@is_complete and @actual_winner == @display_top and @display_top != "TBD"}
          is_wrong_pick={@top_is_wrong_pick}
          is_correct_pick={@top_is_correct_pick}
          actual_score={@actual_top_score}
          predicted_score={@active_top_score}
          pick_percentage={@top_pick_pct}
          pick_count={@top_pick_cnt}
          total_picks={@total_picks}
          is_clickable={@interactive and @display_top != "TBD"}
          phx_click={if @interactive and @display_top != "TBD", do: JS.push(@on_pick, value: %{match_id: @match_id, winner: @display_top}), else: nil}
        >
          <:score_element :if={@show_score_selection}>
            <%= if @active_winner == @display_top do %>
              <span
                class="tw-w-10 tw-h-7 tw-flex tw-items-center tw-justify-center tw-rounded-md tw-bg-sky-500/20 tw-border tw-border-sky-400/50 tw-text-sky-300 tw-font-mono tw-font-bold tw-text-xs tw-shadow-sm"
                title="Winner score"
              >
                {@active_top_score || 3}
              </span>
            <% else %>
              <form
                id={"score_form_#{@match_id}"}
                phx-change={@on_score_change}
                onclick="event.stopPropagation()"
                onsubmit="return false;"
                class="tw-m-0 tw-p-0 tw-flex tw-items-center"
              >
                <select
                  id={"score_select_#{@match_id}"}
                  name={"score_select_#{@match_id}"}
                  phx-change={@on_score_change}
                  onclick="event.stopPropagation()"
                  aria-label={"Score prediction for #{@display_top}"}
                  class="tw-w-10 tw-h-7 tw-px-1 tw-text-center tw-rounded-md tw-bg-[#2a2a2a] tw-border tw-border-slate-600 hover:tw-border-sky-500/70 tw-text-slate-200 tw-font-mono tw-font-bold tw-text-xs focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/40 tw-cursor-pointer tw-transition-colors"
                >
                  <option value={"#{@match_id}:2:3"} selected={@active_top_score == 2}>2</option>
                  <option value={"#{@match_id}:1:3"} selected={@active_top_score == 1}>1</option>
                  <option value={"#{@match_id}:0:3"} selected={@active_top_score == 0}>0</option>
                </select>
              </form>
            <% end %>
          </:score_element>
        </.contestant_row>

        <div class="tw-h-px tw-bg-slate-700/70 tw-my-1"></div>

        <!-- Bottom Contestant -->
        <.contestant_row
          name={@display_bottom}
          banned_class={@bottom_ban}
          game_decks={@bottom_game_decks}
          banned_deck={@bottom_banned_deck}
          deck_statuses={@bottom_deck_statuses}
          is_picked={@active_winner == @display_bottom and @display_bottom != "TBD"}
          is_actual_winner={@is_complete and @actual_winner == @display_bottom and @display_bottom != "TBD"}
          is_wrong_pick={@bottom_is_wrong_pick}
          is_correct_pick={@bottom_is_correct_pick}
          actual_score={@actual_bottom_score}
          predicted_score={@active_bottom_score}
          pick_percentage={@bot_pick_pct}
          pick_count={@bot_pick_cnt}
          total_picks={@total_picks}
          is_clickable={@interactive and @display_bottom != "TBD"}
          phx_click={if @interactive and @display_bottom != "TBD", do: JS.push(@on_pick, value: %{match_id: @match_id, winner: @display_bottom}), else: nil}
        >
          <:score_element :if={@show_score_selection}>
            <%= if @active_winner == @display_bottom do %>
              <span
                class="tw-w-10 tw-h-7 tw-flex tw-items-center tw-justify-center tw-rounded-md tw-bg-sky-500/20 tw-border tw-border-sky-400/50 tw-text-sky-300 tw-font-mono tw-font-bold tw-text-xs tw-shadow-sm"
                title="Winner score"
              >
                {@active_bottom_score || 3}
              </span>
            <% else %>
              <form
                id={"score_form_#{@match_id}"}
                phx-change={@on_score_change}
                onclick="event.stopPropagation()"
                onsubmit="return false;"
                class="tw-m-0 tw-p-0 tw-flex tw-items-center"
              >
                <select
                  id={"score_select_#{@match_id}"}
                  name={"score_select_#{@match_id}"}
                  phx-change={@on_score_change}
                  onclick="event.stopPropagation()"
                  aria-label={"Score prediction for #{@display_bottom}"}
                  class="tw-w-10 tw-h-7 tw-px-1 tw-text-center tw-rounded-md tw-bg-[#2a2a2a] tw-border tw-border-slate-600 hover:tw-border-sky-500/70 tw-text-slate-200 tw-font-mono tw-font-bold tw-text-xs focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/40 tw-cursor-pointer tw-transition-colors"
                >
                  <option value={"#{@match_id}:3:2"} selected={@active_bottom_score == 2}>2</option>
                  <option value={"#{@match_id}:3:1"} selected={@active_bottom_score == 1}>1</option>
                  <option value={"#{@match_id}:3:0"} selected={@active_bottom_score == 0}>0</option>
                </select>
              </form>
            <% end %>
          </:score_element>
        </.contestant_row>
      </div>

      <!-- Collapsed by default: other players picked to win this match -->
      <%= if Enum.any?(@other_picks) do %>
        <details class="tw-group tw-mt-2.5 tw-pt-1.5 tw-border-t tw-border-slate-800 tw-text-[11px] tw-text-slate-400">
          <summary class="tw-cursor-pointer tw-select-none tw-text-slate-400 hover:tw-text-slate-300 tw-flex tw-items-center tw-justify-between">
            <span class="tw-flex tw-items-center tw-gap-1">
              <span>Other picks ({length(@other_picks)})</span>
            </span>
            <svg class="tw-w-3 tw-h-3 tw-text-slate-400 group-open:tw-rotate-180 tw-transition-transform" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
            </svg>
          </summary>
          <div class="tw-mt-1.5 tw-flex tw-flex-wrap tw-items-center tw-gap-1.5">
            <%= for other <- @other_picks do %>
              <span class="tw-bg-slate-800/80 tw-text-slate-300 tw-px-1.5 tw-py-0.5 tw-rounded tw-font-mono tw-text-[10px]" title={"#{other.count} of #{@total_picks} participants"}>
                {other.player} ({other.percentage}%)
              </span>
            <% end %>
          </div>
        </details>
      <% end %>

      <!-- Champion Pick % Button on Finals Match Card -->
      <%= if @is_finals_match and @show_pick_stats and @on_open_champion_picks do %>
        <div class="tw-mt-2.5 tw-pt-2 tw-border-t tw-border-slate-700/60 tw-flex tw-justify-center">
          <button
            type="button"
            phx-click={@on_open_champion_picks}
            class="tw-text-[11px] tw-font-bold tw-text-amber-300 tw-bg-amber-950/60 hover:tw-bg-amber-900/60 tw-border tw-border-amber-700/60 tw-px-2.5 tw-py-1 tw-rounded-lg tw-transition-all tw-flex tw-items-center tw-gap-1.5 active:tw-scale-95"
          >
            <span>🏆 View Champion Pick %</span>
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  # --- Contestant Row Component ---

  attr :name, :string, required: true
  attr :banned_class, :string, default: nil
  attr :game_decks, :list, default: []
  attr :banned_deck, :map, default: nil
  attr :deck_statuses, :list, default: []
  attr :won_decks, :list, default: []
  attr :lost_decks, :list, default: []
  attr :is_picked, :boolean, default: false
  attr :is_actual_winner, :boolean, default: false
  attr :is_wrong_pick, :boolean, default: false
  attr :is_correct_pick, :boolean, default: false
  attr :actual_score, :integer, default: nil
  attr :predicted_score, :integer, default: nil
  attr :pick_percentage, :float, default: nil
  attr :pick_count, :integer, default: nil
  attr :total_picks, :integer, default: nil
  attr :is_clickable, :boolean, default: false
  attr :phx_click, :any, default: nil
  slot :score_element

  def contestant_row(assigns) do
    ~H"""
    <div
      class={[
        "tw-flex tw-items-center tw-justify-between tw-px-3 tw-py-2 tw-rounded-lg tw-transition-all tw-duration-150 tw-select-none",
        @is_clickable && "tw-cursor-pointer hover:tw-bg-slate-700/60 active:tw-scale-[0.99]",
        @is_wrong_pick && "tw-bg-rose-500/15 tw-border tw-border-rose-500/40 tw-shadow-[0_0_12px_rgba(244,63,94,0.15)]",
        @is_correct_pick && "tw-bg-emerald-500/15 tw-border tw-border-emerald-500/40 tw-shadow-[0_0_12px_rgba(16,185,129,0.15)]",
        @is_picked && !@is_wrong_pick && !@is_correct_pick && "tw-bg-sky-500/15 tw-border tw-border-sky-500/40 tw-shadow-[0_0_12px_rgba(14,165,233,0.15)]",
        @is_actual_winner && !@is_picked && "tw-bg-emerald-500/10 tw-border tw-border-emerald-500/30",
        !@is_picked && !@is_actual_winner && "tw-bg-[#1c2222]/80 tw-border tw-border-transparent"
      ]}
      phx-click={@phx_click}
    >
      <div class="tw-flex tw-items-center tw-gap-2 tw-min-w-0 tw-flex-1">
        <!-- Pick check / cross / trophy icon -->
        <%= cond do %>
          <% @is_wrong_pick -> %>
            <div class="tw-w-4 tw-h-4 tw-rounded-full tw-bg-rose-600 tw-flex tw-items-center tw-justify-center tw-flex-shrink-0 tw-shadow-sm" title="Predicted winner">
              <svg class="tw-w-2.5 tw-h-2.5 tw-text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </div>
          <% @is_correct_pick -> %>
            <div class="tw-w-4 tw-h-4 tw-rounded-full tw-bg-emerald-500 tw-flex tw-items-center tw-justify-center tw-flex-shrink-0 tw-shadow-sm" title="Correct pick">
              <svg class="tw-w-2.5 tw-h-2.5 tw-text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
              </svg>
            </div>
          <% @is_picked -> %>
            <div class="tw-w-4 tw-h-4 tw-rounded-full tw-bg-sky-500 tw-flex tw-items-center tw-justify-center tw-flex-shrink-0 tw-shadow-sm" title="Your pick">
              <svg class="tw-w-2.5 tw-h-2.5 tw-text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="3" d="M5 13l4 4L19 7" />
              </svg>
            </div>
          <% @is_actual_winner -> %>
            <div class="tw-w-4 tw-h-4 tw-rounded-full tw-bg-emerald-500/20 tw-border tw-border-emerald-500/40 tw-flex tw-items-center tw-justify-center tw-flex-shrink-0" title="Actual winner">
              <span class="tw-text-emerald-400 tw-text-[10px]">★</span>
            </div>
          <% true -> %>
            <div class="tw-w-4 tw-h-4 tw-rounded-full tw-border tw-border-slate-600/60 tw-flex-shrink-0"></div>
        <% end %>

        <span class={[
          "tw-text-sm tw-font-semibold tw-truncate",
          @name == "TBD" && "tw-text-slate-500 tw-font-normal tw-italic",
          @is_wrong_pick && "tw-text-rose-300",
          @is_correct_pick && "tw-text-emerald-300",
          @is_picked && !@is_wrong_pick && !@is_correct_pick && "tw-text-sky-300",
          @is_actual_winner && !@is_picked && "tw-text-emerald-300",
          !@is_picked && !@is_actual_winner && @name != "TBD" && "tw-text-slate-200"
        ]}>
          {@name}
        </span>

        <%= if not is_nil(@pick_percentage) do %>
          <span
            class="tw-text-xs tw-font-mono tw-font-bold tw-text-sky-400 tw-bg-sky-950/70 tw-border tw-border-sky-800/60 tw-px-1.5 tw-py-0.5 tw-rounded tw-flex-shrink-0"
            title={"#{@pick_count || 0} of #{@total_picks || 0} participants picked #{@name} (#{@pick_percentage}%)"}
          >
            {@pick_percentage}%
          </span>
        <% end %>

        <%= if @is_wrong_pick do %>
          <span
            class="tw-text-[10px] tw-font-bold tw-text-rose-400 tw-bg-rose-950/80 tw-border tw-border-rose-800/60 tw-px-1.5 tw-py-0.5 tw-rounded tw-flex-shrink-0"
            title="Predicted winner"
          >
            Predicted
          </span>
        <% end %>
        <%= if @is_correct_pick do %>
          <span
            class="tw-text-[10px] tw-font-bold tw-text-emerald-400 tw-bg-emerald-950/80 tw-border tw-border-emerald-800/60 tw-px-1.5 tw-py-0.5 tw-rounded tw-flex-shrink-0"
            title="Picked correct winner"
          >
            Correct
          </span>
        <% end %>
        <%= if @is_actual_winner && !@is_picked do %>
          <span
            class="tw-text-[10px] tw-font-bold tw-text-emerald-400 tw-bg-emerald-950/60 tw-border tw-border-emerald-800/50 tw-px-1.5 tw-py-0.5 tw-rounded tw-flex-shrink-0"
            title="Actual winner"
          >
            Winner
          </span>
        <% end %>

        <%= if Enum.empty?(@game_decks) and is_nil(@banned_deck) and Enum.empty?(@deck_statuses) and @banned_class do %>
          <span
            class="tw-text-[10px] tw-font-medium tw-text-rose-400 tw-bg-rose-950/70 tw-border tw-border-rose-800/50 tw-px-1.5 tw-py-0.5 tw-rounded tw-flex-shrink-0"
            title={"Banned class: #{@banned_class}"}
          >
            Ban: {@banned_class}
          </span>
        <% end %>
      </div>

      <div class="tw-flex tw-items-center tw-gap-2.5 tw-flex-shrink-0 tw-ml-2">
        <!-- Deck / Class Icons with win/loss/ban indicator -->
        <%= if Enum.any?(@game_decks) or not is_nil(@banned_deck) or Enum.any?(@deck_statuses) do %>
          <div class="tw-flex tw-items-center tw-gap-1">
            <% display_games = if Enum.any?(@game_decks), do: @game_decks, else: Enum.reject(@deck_statuses, &(&1.status == :banned)) %>
            <% display_ban = if not is_nil(@banned_deck), do: @banned_deck, else: Enum.find(@deck_statuses, &(&1.status == :banned)) %>

            <%= for game <- display_games do %>
              <div class="tw-relative tw-inline-flex" title={game.tooltip}>
                <img
                  src={"/images/icons/#{game.class_slug}.png"}
                  alt={game.deck_name}
                  class={[
                    "tw-w-5 tw-h-5 tw-rounded-full tw-object-cover tw-bg-slate-800",
                    game.status == :won && "tw-ring-1.5 tw-ring-emerald-500 tw-shadow-[0_0_6px_rgba(16,185,129,0.3)]",
                    game.status == :lost && "tw-ring-1 tw-ring-rose-500/70 tw-opacity-70",
                    game.status == :unplayed && "tw-opacity-50"
                  ]}
                />
                <%= if game.status == :won do %>
                  <span class="tw-absolute -tw-top-1 -tw-right-1 tw-w-3 tw-h-3 tw-rounded-full tw-bg-emerald-500 tw-text-white tw-flex tw-items-center tw-justify-center tw-text-[8px] tw-font-bold tw-leading-none tw-shadow-sm">
                    ✓
                  </span>
                <% end %>
                <%= if game.status == :lost do %>
                  <span class="tw-absolute -tw-top-1 -tw-right-1 tw-w-3 tw-h-3 tw-rounded-full tw-bg-rose-500 tw-text-white tw-flex tw-items-center tw-justify-center tw-text-[8px] tw-font-bold tw-leading-none tw-shadow-sm">
                    ✗
                  </span>
                <% end %>
              </div>
            <% end %>

            <%= if display_ban do %>
              <%= if Enum.any?(display_games) do %>
                <div class="tw-h-4 tw-w-px tw-bg-slate-700/80 tw-mx-0.5"></div>
              <% end %>
              <div class="tw-relative tw-inline-flex" title={display_ban.tooltip}>
                <img
                  src={"/images/icons/#{display_ban.class_slug}.png"}
                  alt={display_ban.deck_name}
                  class="tw-w-5 tw-h-5 tw-rounded-full tw-object-cover tw-bg-slate-800 tw-ring-1 tw-ring-rose-800/80 tw-opacity-40 tw-grayscale"
                />
                <span class="tw-absolute -tw-top-1 -tw-right-1 tw-w-3 tw-h-3 tw-rounded-full tw-bg-rose-950 tw-border tw-border-rose-600 tw-text-rose-400 tw-flex tw-items-center tw-justify-center tw-text-[7px] tw-font-bold tw-leading-none tw-shadow-sm">
                  ✕
                </span>
              </div>
            <% end %>
          </div>
        <% end %>

        <%= if render_slot(@score_element) do %>
          {render_slot(@score_element)}
        <% else %>
          <%= if not is_nil(@actual_score) do %>
            <div class="tw-flex tw-items-center tw-gap-1.5 tw-font-mono">
              <%= if not is_nil(@predicted_score) and @actual_score != @predicted_score do %>
                <span
                  class="tw-text-[11px] tw-font-semibold tw-text-amber-300 tw-bg-amber-950/60 tw-border tw-border-amber-700/50 tw-px-1.5 tw-py-0.5 tw-rounded"
                  title={"Predicted: #{@predicted_score} (Actual: #{@actual_score})"}
                >
                  pred: {@predicted_score}
                </span>
              <% end %>
              <span class={[
                "tw-font-bold tw-text-sm tw-px-2 tw-py-0.5 tw-rounded",
                @is_actual_winner && "tw-text-emerald-400 tw-bg-emerald-950/60",
                !@is_actual_winner && "tw-text-slate-400 tw-bg-slate-800/60"
              ]} title={"Actual score: #{@actual_score}"}>
                {@actual_score}
              </span>
            </div>
          <% else %>
            <%= if not is_nil(@predicted_score) do %>
              <span
                class="tw-font-mono tw-font-semibold tw-text-sm tw-px-2 tw-py-0.5 tw-rounded tw-text-slate-400 tw-bg-slate-800/60"
                title={"Predicted score: #{@predicted_score}"}
              >
                {@predicted_score}
              </span>
            <% end %>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  # --- GSL Double-Elimination Group Bracket ---

  attr :group_name, :string, required: true
  attr :matches, :list, required: true
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false
  attr :collapsible, :boolean, default: false
  attr :default_open, :boolean, default: true
  attr :winners_day, :string, default: nil
  attr :elim_day, :string, default: nil
  attr :days_label, :string, default: nil
  attr :show_pick_stats, :boolean, default: false
  attr :match_pick_stats, :map, default: %{}
  attr :on_open_champion_picks, :string, default: nil

  def gsl_group_bracket(assigns) do
    matches = assigns.matches || []

    opening_1 = Enum.find(matches, &String.ends_with?(&1.match_identifier, "opening_1"))
    opening_2 = Enum.find(matches, &String.ends_with?(&1.match_identifier, "opening_2"))
    winners = Enum.find(matches, &String.ends_with?(&1.match_identifier, "winners"))
    elim = Enum.find(matches, &String.ends_with?(&1.match_identifier, "elim"))
    decider = Enum.find(matches, &String.ends_with?(&1.match_identifier, "decider"))

    assigns =
      assigns
      |> assign(:m_op1, opening_1)
      |> assign(:m_op2, opening_2)
      |> assign(:m_win, winners)
      |> assign(:m_elim, elim)
      |> assign(:m_dec, decider)

    if assigns.collapsible do
      ~H"""
      <details class="tw-group tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-4 sm:tw-p-6 tw-shadow-xl tw-transition-all tw-duration-200" open={@default_open}>
        <summary class="tw-flex tw-items-center tw-justify-between tw-cursor-pointer tw-select-none hover:tw-opacity-95 tw-border-b tw-border-slate-700/70 tw-pb-3">
          <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2.5">
            <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">{@group_name}</h3>
            <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/80 tw-px-2.5 tw-py-0.5 tw-rounded-full tw-border tw-border-slate-700/50">
              Double Elimination
            </span>
            <span class="tw-text-xs tw-text-emerald-400 tw-bg-emerald-950/60 tw-border tw-border-emerald-800/40 tw-px-2.5 tw-py-0.5 tw-rounded-md tw-font-medium">
              Top 2 Advance to Playoffs
            </span>
            <%= if @days_label do %>
              <span class="tw-text-xs tw-text-sky-300 tw-bg-sky-950/60 tw-border tw-border-sky-800/40 tw-px-2.5 tw-py-0.5 tw-rounded-md tw-font-medium">
                {@days_label}
              </span>
            <% end %>
          </div>
          <svg class="tw-w-5 tw-h-5 tw-text-slate-400 group-open:tw-rotate-180 tw-transition-transform tw-duration-200 tw-flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </summary>

        <div class="tw-pt-6 tw-space-y-6">
          <.gsl_group_body
            m_op1={@m_op1}
            m_op2={@m_op2}
            m_win={@m_win}
            m_elim={@m_elim}
            m_dec={@m_dec}
            nodes_map={@nodes_map}
            interactive={@interactive}
            predict_scores={@predict_scores}
            admin_mode={@admin_mode}
            on_pick={@on_pick}
            on_score_change={@on_score_change}
            winners_day={@winners_day}
            elim_day={@elim_day}
            show_pick_stats={@show_pick_stats}
            match_pick_stats={@match_pick_stats}
            on_open_champion_picks={@on_open_champion_picks}
          />
        </div>
      </details>
      """
    else
      ~H"""
      <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-6 tw-shadow-xl tw-space-y-6">
        <!-- Group Header -->
        <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3">
          <div class="tw-flex tw-items-center tw-gap-2.5">
            <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">{@group_name}</h3>
            <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/80 tw-px-2.5 tw-py-0.5 tw-rounded-full tw-border tw-border-slate-700/50">
              Double Elimination
            </span>
          </div>
          <span class="tw-text-xs tw-text-emerald-400 tw-bg-emerald-950/60 tw-border tw-border-emerald-800/40 tw-px-3 tw-py-1 tw-rounded-md tw-font-medium">
            Top 2 Advance to Playoffs
          </span>
        </div>

        <.gsl_group_body
          m_op1={@m_op1}
          m_op2={@m_op2}
          m_win={@m_win}
          m_elim={@m_elim}
          m_dec={@m_dec}
          nodes_map={@nodes_map}
          interactive={@interactive}
          predict_scores={@predict_scores}
          admin_mode={@admin_mode}
          on_pick={@on_pick}
          on_score_change={@on_score_change}
          winners_day={@winners_day}
          elim_day={@elim_day}
          show_pick_stats={@show_pick_stats}
          match_pick_stats={@match_pick_stats}
          on_open_champion_picks={@on_open_champion_picks}
        />
      </div>
      """
    end
  end

  attr :m_op1, :map, default: nil
  attr :m_op2, :map, default: nil
  attr :m_win, :map, default: nil
  attr :m_elim, :map, default: nil
  attr :m_dec, :map, default: nil
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :admin_mode, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :winners_day, :string, default: nil
  attr :elim_day, :string, default: nil
  attr :show_pick_stats, :boolean, default: false
  attr :match_pick_stats, :map, default: %{}
  attr :on_open_champion_picks, :string, default: nil

  defp gsl_group_body(assigns) do
    ~H"""
    <!-- 1. Winners Bracket (Upper Bracket) -->
    <div class="tw-space-y-3">
      <div class="tw-flex tw-items-center tw-justify-between">
        <div class="tw-text-xs tw-font-bold tw-text-sky-400 tw-uppercase tw-tracking-wider tw-flex tw-items-center tw-gap-1.5">
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
          </svg>
          Winners Bracket
          <%= if @winners_day do %>
            <span class="tw-ml-1.5 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-sky-500/15 tw-text-sky-300 tw-border tw-border-sky-500/30 tw-normal-case tw-tracking-normal">
              {@winners_day}
            </span>
          <% end %>
        </div>
        <span class="tw-text-[11px] tw-text-slate-400">
          Winner of Winners Match advances as 1st Seed
        </span>
      </div>

      <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-6 tw-items-center tw-bg-[#181d1d]/70 tw-border tw-border-slate-700/50 tw-rounded-xl tw-p-4">
        <!-- Round 1: Opening Matches -->
        <div class="tw-space-y-4">
          <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider">
            Round 1: Opening Matches
          </div>
          <%= if @m_op1 do %>
            <.match_card
              match={@m_op1}
              node={Map.get(@nodes_map, @m_op1.match_identifier)}
              interactive={@interactive}
              predict_scores={@predict_scores}
              admin_mode={@admin_mode}
              on_pick={@on_pick}
              on_score_change={@on_score_change}
              show_pick_stats={@show_pick_stats}
              pick_stats={Map.get(@match_pick_stats, @m_op1.match_identifier)}
              on_open_champion_picks={@on_open_champion_picks}
            />
          <% end %>
          <%= if @m_op2 do %>
            <.match_card
              match={@m_op2}
              node={Map.get(@nodes_map, @m_op2.match_identifier)}
              interactive={@interactive}
              predict_scores={@predict_scores}
              admin_mode={@admin_mode}
              on_pick={@on_pick}
              on_score_change={@on_score_change}
              show_pick_stats={@show_pick_stats}
              pick_stats={Map.get(@match_pick_stats, @m_op2.match_identifier)}
              on_open_champion_picks={@on_open_champion_picks}
            />
          <% end %>
        </div>

        <!-- Round 2: Winners Match -->
        <div class="tw-space-y-4 tw-flex tw-flex-col tw-justify-center">
          <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider">
            Round 2: Winners Match
          </div>
          <%= if @m_win do %>
            <div>
              <.match_card
                match={@m_win}
                node={Map.get(@nodes_map, @m_win.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, @m_win.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
              <div class="tw-text-[11px] tw-text-emerald-400 tw-mt-1.5 tw-font-medium tw-flex tw-items-center tw-gap-1">
                <span>★</span> Winner advances as 1st Seed (Loser drops to Decider)
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>

    <!-- Divider between Winners and Elimination Brackets -->
    <div class="tw-relative tw-py-1">
      <div class="tw-border-t tw-border-slate-700/70"></div>
    </div>

    <!-- 2. Elimination Bracket (Lower Bracket) -->
    <div class="tw-space-y-3">
      <div class="tw-flex tw-items-center tw-justify-between">
        <div class="tw-text-xs tw-font-bold tw-text-amber-400 tw-uppercase tw-tracking-wider tw-flex tw-items-center tw-gap-1.5">
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
          </svg>
          Elimination Bracket
          <%= if @elim_day do %>
            <span class="tw-ml-1.5 tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-amber-500/15 tw-text-amber-300 tw-border tw-border-amber-500/30 tw-normal-case tw-tracking-normal">
              {@elim_day}
            </span>
          <% end %>
        </div>
        <span class="tw-text-[11px] tw-text-slate-400">
          Winner of Decider Match advances as 2nd Seed
        </span>
      </div>

      <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-6 tw-items-center tw-bg-[#181d1d]/70 tw-border tw-border-slate-700/50 tw-rounded-xl tw-p-4">
        <!-- Round 1: Elimination Match -->
        <div class="tw-space-y-4">
          <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider">
            Round 1: Elimination Match
          </div>
          <%= if @m_elim do %>
            <div>
              <.match_card
                match={@m_elim}
                node={Map.get(@nodes_map, @m_elim.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, @m_elim.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
              <div class="tw-text-[11px] tw-text-rose-400 tw-mt-1.5 tw-font-medium tw-flex tw-items-center tw-gap-1">
                <span>✕</span> Loser is eliminated (4th place)
              </div>
            </div>
          <% end %>
        </div>

        <!-- Round 2: Decider Match -->
        <div class="tw-space-y-4">
          <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider">
            Round 2: Decider Match
          </div>
          <%= if @m_dec do %>
            <div>
              <.match_card
                match={@m_dec}
                node={Map.get(@nodes_map, @m_dec.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, @m_dec.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
              <div class="tw-text-[11px] tw-text-sky-400 tw-mt-1.5 tw-font-medium tw-flex tw-items-center tw-gap-1">
                <span>★</span> Winner advances as 2nd Seed (Loser is 3rd place)
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  # --- Single-Elimination Playoff Bracket ---

  attr :matches, :list, required: true
  attr :title, :string, default: "Playoff Bracket"
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :has_third_place, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false
  attr :collapsible, :boolean, default: false
  attr :default_open, :boolean, default: true
  attr :qf_day, :string, default: nil
  attr :sf_day, :string, default: nil
  attr :finals_day, :string, default: nil
  attr :ro16_day, :string, default: nil
  attr :days_label, :string, default: nil
  attr :show_pick_stats, :boolean, default: false
  attr :match_pick_stats, :map, default: %{}
  attr :on_open_champion_picks, :string, default: nil

  def single_elim_bracket(assigns) do
    matches = assigns.matches || []

    third_place =
      Enum.find(matches, fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.contains?(id, "third_place") or
          String.contains?(id, "3rd") or
          String.contains?(id, "third") or
          String.contains?(name, "3rd") or
          String.contains?(name, "third") or
          String.contains?(name, "bronze")
      end)

    ro16 =
      matches
      |> Enum.reject(&(&1 == third_place))
      |> Enum.filter(fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.contains?(id, "r16") or
          String.contains?(id, "ro16") or
          String.contains?(name, "round of 16") or
          String.contains?(name, "ro16") or
          String.contains?(name, "round 16")
      end)
      |> Enum.sort_by(&Map.get(&1, :match_order, 0))

    qfs =
      matches
      |> Enum.reject(&(&1 == third_place or &1 in ro16))
      |> Enum.filter(fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.contains?(id, "qf") or
          String.contains?(id, "quarter") or
          String.contains?(name, "quarter") or
          String.starts_with?(name, "qf")
      end)
      |> Enum.sort_by(&Map.get(&1, :match_order, 0))

    sfs =
      matches
      |> Enum.reject(&(&1 == third_place or &1 in ro16 or &1 in qfs))
      |> Enum.filter(fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.contains?(id, "sf") or
          String.contains?(id, "semi") or
          String.contains?(name, "semi") or
          String.starts_with?(name, "sf")
      end)
      |> Enum.sort_by(&Map.get(&1, :match_order, 0))

    remaining_finals =
      matches
      |> Enum.reject(&(&1 in [third_place | ro16 ++ qfs ++ sfs]))

    finals =
      Enum.find(remaining_finals, fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.contains?(id, "final") or
          String.contains?(name, "final") or
          String.contains?(name, "championship")
      end) ||
        if Enum.any?(ro16) or Enum.any?(qfs) or Enum.any?(sfs) do
          List.last(remaining_finals)
        else
          nil
        end

    has_recognized_rounds? =
      Enum.any?(ro16) or Enum.any?(qfs) or Enum.any?(sfs) or not is_nil(finals)

    rounds_by_number =
      if has_recognized_rounds? do
        []
      else
        matches
        |> Enum.group_by(&Map.get(&1, :round_number, 1))
        |> Enum.sort_by(fn {r, _} -> r end)
      end

    depth =
      cond do
        has_recognized_rounds? ->
          cond do
            Enum.any?(ro16) -> 4
            Enum.any?(qfs) -> 3
            Enum.any?(sfs) -> 2
            not is_nil(finals) -> 1
            true -> 1
          end

        Enum.any?(rounds_by_number) ->
          length(rounds_by_number)

        true ->
          1
      end

    grid_cols_class =
      case depth do
        1 -> "md:tw-grid-cols-1 md:tw-max-w-md md:tw-mx-auto"
        2 -> "md:tw-grid-cols-2"
        3 -> "md:tw-grid-cols-3"
        4 -> "md:tw-grid-cols-4"
        _ -> "md:tw-grid-cols-3"
      end

    assigns =
      assigns
      |> assign(:ro16_matches, ro16)
      |> assign(:qf_matches, qfs)
      |> assign(:sf_matches, sfs)
      |> assign(:finals_match, finals)
      |> assign(:third_place_match, third_place)
      |> assign(:has_third_place, assigns[:has_third_place] || not is_nil(third_place))
      |> assign(:depth, depth)
      |> assign(:has_recognized_rounds, has_recognized_rounds?)
      |> assign(:rounds_by_number, rounds_by_number)
      |> assign(:grid_cols_class, grid_cols_class)

    if assigns.collapsible do
      ~H"""
      <details class="tw-group tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-4 sm:tw-p-5 tw-shadow-xl tw-transition-all tw-duration-200" open={@default_open}>
        <summary class="tw-flex tw-items-center tw-justify-between tw-cursor-pointer tw-select-none hover:tw-opacity-95 tw-border-b tw-border-slate-700/70 tw-pb-3">
          <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2.5">
            <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">{@title}</h3>
            <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/60 tw-px-2.5 tw-py-1 tw-rounded-md">
              Single Elimination Knockout
            </span>
            <%= if @days_label do %>
              <span class="tw-text-xs tw-text-amber-300 tw-bg-amber-950/60 tw-border tw-border-amber-800/40 tw-px-2.5 tw-py-0.5 tw-rounded-md tw-font-medium">
                {@days_label}
              </span>
            <% end %>
          </div>
          <svg class="tw-w-5 tw-h-5 tw-text-slate-400 group-open:tw-rotate-180 tw-transition-transform tw-duration-200 tw-flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
          </svg>
        </summary>

        <div class="tw-pt-6">
          <.single_elim_body
            depth={@depth}
            has_recognized_rounds={@has_recognized_rounds}
            grid_cols_class={@grid_cols_class}
            ro16_matches={@ro16_matches}
            qf_matches={@qf_matches}
            sf_matches={@sf_matches}
            finals_match={@finals_match}
            third_place_match={@third_place_match}
            has_third_place={@has_third_place}
            rounds_by_number={@rounds_by_number}
            nodes_map={@nodes_map}
            interactive={@interactive}
            predict_scores={@predict_scores}
            admin_mode={@admin_mode}
            on_pick={@on_pick}
            on_score_change={@on_score_change}
            qf_day={@qf_day}
            sf_day={@sf_day}
            finals_day={@finals_day}
            ro16_day={@ro16_day}
            show_pick_stats={@show_pick_stats}
            match_pick_stats={@match_pick_stats}
            on_open_champion_picks={@on_open_champion_picks}
          />
        </div>
      </details>
      """
    else
      ~H"""
      <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-5 tw-shadow-xl">
        <!-- Title -->
        <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3 tw-mb-5">
          <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2.5">
            <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">{@title}</h3>
            <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/60 tw-px-2.5 tw-py-1 tw-rounded-md">
              Single Elimination Knockout
            </span>
            <%= if @days_label do %>
              <span class="tw-text-xs tw-text-amber-300 tw-bg-amber-950/60 tw-border tw-border-amber-800/40 tw-px-2.5 tw-py-0.5 tw-rounded-md tw-font-medium">
                {@days_label}
              </span>
            <% end %>
          </div>
        </div>

        <.single_elim_body
          depth={@depth}
          has_recognized_rounds={@has_recognized_rounds}
          grid_cols_class={@grid_cols_class}
          ro16_matches={@ro16_matches}
          qf_matches={@qf_matches}
          sf_matches={@sf_matches}
          finals_match={@finals_match}
          third_place_match={@third_place_match}
          has_third_place={@has_third_place}
          rounds_by_number={@rounds_by_number}
          nodes_map={@nodes_map}
          interactive={@interactive}
          predict_scores={@predict_scores}
          admin_mode={@admin_mode}
          on_pick={@on_pick}
          on_score_change={@on_score_change}
          qf_day={@qf_day}
          sf_day={@sf_day}
          finals_day={@finals_day}
          ro16_day={@ro16_day}
          show_pick_stats={@show_pick_stats}
          match_pick_stats={@match_pick_stats}
          on_open_champion_picks={@on_open_champion_picks}
        />
      </div>
      """
    end
  end

  attr :depth, :integer, required: true
  attr :has_recognized_rounds, :boolean, required: true
  attr :grid_cols_class, :string, required: true
  attr :ro16_matches, :list, default: []
  attr :qf_matches, :list, default: []
  attr :sf_matches, :list, default: []
  attr :finals_match, :map, default: nil
  attr :third_place_match, :map, default: nil
  attr :has_third_place, :boolean, default: false
  attr :rounds_by_number, :list, default: []
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :admin_mode, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :qf_day, :string, default: nil
  attr :sf_day, :string, default: nil
  attr :finals_day, :string, default: nil
  attr :ro16_day, :string, default: nil
  attr :show_pick_stats, :boolean, default: false
  attr :match_pick_stats, :map, default: %{}
  attr :on_open_champion_picks, :string, default: nil

  defp single_elim_body(assigns) do
    ~H"""
    <%= if @depth <= 3 and @has_recognized_rounds do %>
      <div class={["tw-grid tw-grid-cols-1 tw-gap-6 tw-items-stretch", @grid_cols_class]}>
        <!-- Quarterfinals Column if present -->
        <%= if Enum.any?(@qf_matches) do %>
          <div class="tw-space-y-4">
            <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>Quarterfinals</span>
              <%= if @qf_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-amber-500/15 tw-text-amber-300 tw-border tw-border-amber-500/30 tw-normal-case tw-tracking-normal">
                  {@qf_day}
                </span>
              <% end %>
            </div>
            <%= for qf <- @qf_matches do %>
              <.match_card
                match={qf}
                node={Map.get(@nodes_map, qf.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, qf.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
            <% end %>
          </div>
        <% end %>

        <!-- Semifinals Column if present -->
        <%= if Enum.any?(@sf_matches) do %>
          <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
            <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>Semifinals</span>
              <%= if @sf_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-emerald-500/15 tw-text-emerald-300 tw-border tw-border-emerald-500/30 tw-normal-case tw-tracking-normal">
                  {@sf_day}
                </span>
              <% end %>
            </div>
            <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex-1 md:tw-flex md:tw-flex-col md:tw-justify-around">
              <%= for sf <- @sf_matches do %>
                <div class="md:tw-py-2">
                  <.match_card
                    match={sf}
                    node={Map.get(@nodes_map, sf.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                    show_pick_stats={@show_pick_stats}
                    pick_stats={Map.get(@match_pick_stats, sf.match_identifier)}
                    on_open_champion_picks={@on_open_champion_picks}
                  />
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <!-- Finals Column -->
        <div class="tw-space-y-6 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
          <!-- Championship Match -->
          <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex-1 md:tw-flex md:tw-flex-col md:tw-justify-center">
            <div class="tw-text-xs tw-font-bold tw-text-amber-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>🏆 Championship Final</span>
              <%= if @finals_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-emerald-500/15 tw-text-emerald-300 tw-border tw-border-emerald-500/30 tw-normal-case tw-tracking-normal">
                  {@finals_day}
                </span>
              <% end %>
            </div>
            <%= if @finals_match do %>
              <div class="md:tw-py-2">
                <.match_card
                  match={@finals_match}
                  node={Map.get(@nodes_map, @finals_match.match_identifier)}
                  interactive={@interactive}
                  predict_scores={@predict_scores}
                  admin_mode={@admin_mode}
                  on_pick={@on_pick}
                  on_score_change={@on_score_change}
                  show_pick_stats={@show_pick_stats}
                  pick_stats={Map.get(@match_pick_stats, @finals_match.match_identifier)}
                  on_open_champion_picks={@on_open_champion_picks}
                />
              </div>
            <% end %>
          </div>

          <!-- Optional 3rd Place Match -->
          <%= if @has_third_place && @third_place_match do %>
            <div class="tw-border-t tw-border-slate-700/60 tw-pt-4 md:tw-pt-3 tw-mt-4">
              <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                3rd Place Match
              </div>
              <.match_card
                match={@third_place_match}
                node={Map.get(@nodes_map, @third_place_match.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, @third_place_match.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
            </div>
          <% end %>
        </div>
      </div>
    <% else %>
      <!-- Standard / Multi-round bracket fallback -->
      <div class={["tw-grid tw-grid-cols-1 tw-gap-6 tw-items-stretch", @grid_cols_class]}>
        <%= if Enum.any?(@ro16_matches) do %>
          <div class="tw-space-y-4">
            <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>Round of 16</span>
              <%= if @ro16_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-sky-500/15 tw-text-sky-300 tw-border tw-border-sky-500/30 tw-normal-case tw-tracking-normal">
                  {@ro16_day}
                </span>
              <% end %>
            </div>
            <%= for m <- @ro16_matches do %>
              <.match_card
                match={m}
                node={Map.get(@nodes_map, m.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, m.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
            <% end %>
          </div>
        <% end %>

        <%= if Enum.any?(@qf_matches) do %>
          <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
            <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>Quarterfinals</span>
              <%= if @qf_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-amber-500/15 tw-text-amber-300 tw-border tw-border-amber-500/30 tw-normal-case tw-tracking-normal">
                  {@qf_day}
                </span>
              <% end %>
            </div>
            <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex-1 md:tw-flex md:tw-flex-col md:tw-justify-around">
              <%= for qf <- @qf_matches do %>
                <div class="md:tw-py-2">
                  <.match_card
                    match={qf}
                    node={Map.get(@nodes_map, qf.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                    show_pick_stats={@show_pick_stats}
                    pick_stats={Map.get(@match_pick_stats, qf.match_identifier)}
                    on_open_champion_picks={@on_open_champion_picks}
                  />
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <%= if Enum.any?(@sf_matches) do %>
          <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
            <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>Semifinals</span>
              <%= if @sf_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-emerald-500/15 tw-text-emerald-300 tw-border tw-border-emerald-500/30 tw-normal-case tw-tracking-normal">
                  {@sf_day}
                </span>
              <% end %>
            </div>
            <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex-1 md:tw-flex md:tw-flex-col md:tw-justify-around">
              <%= for sf <- @sf_matches do %>
                <div class="md:tw-py-2">
                  <.match_card
                    match={sf}
                    node={Map.get(@nodes_map, sf.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                    show_pick_stats={@show_pick_stats}
                    pick_stats={Map.get(@match_pick_stats, sf.match_identifier)}
                    on_open_champion_picks={@on_open_champion_picks}
                  />
                </div>
              <% end %>
            </div>
          </div>
        <% end %>

        <div class="tw-space-y-6 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
          <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex-1 md:tw-flex md:tw-flex-col md:tw-justify-center">
            <div class="tw-text-xs tw-font-bold tw-text-amber-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2 tw-flex tw-items-center tw-justify-center tw-gap-1.5">
              <span>🏆 Championship Final</span>
              <%= if @finals_day do %>
                <span class="tw-px-2 tw-py-0.5 tw-rounded-md tw-text-[11px] tw-font-semibold tw-bg-emerald-500/15 tw-text-emerald-300 tw-border tw-border-emerald-500/30 tw-normal-case tw-tracking-normal">
                  {@finals_day}
                </span>
              <% end %>
            </div>
            <%= if @finals_match do %>
              <div class="md:tw-py-2">
                <.match_card
                  match={@finals_match}
                  node={Map.get(@nodes_map, @finals_match.match_identifier)}
                  interactive={@interactive}
                  predict_scores={@predict_scores}
                  admin_mode={@admin_mode}
                  on_pick={@on_pick}
                  on_score_change={@on_score_change}
                  show_pick_stats={@show_pick_stats}
                  pick_stats={Map.get(@match_pick_stats, @finals_match.match_identifier)}
                  on_open_champion_picks={@on_open_champion_picks}
                />
              </div>
            <% end %>
          </div>

          <%= if @has_third_place && @third_place_match do %>
            <div class="tw-border-t tw-border-slate-700/60 tw-pt-4 md:tw-pt-3 tw-mt-4">
              <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                3rd Place Match
              </div>
              <.match_card
                match={@third_place_match}
                node={Map.get(@nodes_map, @third_place_match.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, @third_place_match.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
            </div>
          <% end %>
        </div>
      </div>
    <% end %>
    """
  end

  # --- Double-Elimination Tournament Bracket ---

  attr :matches, :list, required: true
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false
  attr :collapsible, :boolean, default: false
  attr :default_open, :boolean, default: true
  attr :show_pick_stats, :boolean, default: false
  attr :match_pick_stats, :map, default: %{}
  attr :on_open_champion_picks, :string, default: nil

  def double_elim_bracket(assigns) do
    matches = assigns.matches || []

    wb_matches =
      matches
      |> Enum.filter(fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.starts_with?(id, "wb_") or
          String.contains?(id, "winner") or
          String.contains?(name, "winner") or
          String.contains?(name, "upper") or
          String.contains?(name, "wb")
      end)
      |> Enum.sort_by(&Map.get(&1, :match_order, 0))

    lb_matches =
      matches
      |> Enum.filter(fn m ->
        id = String.downcase(Map.get(m, :match_identifier) || "")
        name = String.downcase(Map.get(m, :round_name) || "")

        String.starts_with?(id, "lb_") or
          String.contains?(id, "loser") or
          String.contains?(name, "loser") or
          String.contains?(name, "lower") or
          String.contains?(name, "elim") or
          String.contains?(name, "lb")
      end)
      |> Enum.sort_by(&Map.get(&1, :match_order, 0))

    gf_matches =
      matches
      |> Enum.reject(&(&1 in wb_matches or &1 in lb_matches))
      |> Enum.sort_by(&Map.get(&1, :match_order, 0))

    assigns =
      assigns
      |> assign(:wb_matches, wb_matches)
      |> assign(:lb_matches, lb_matches)
      |> assign(:gf_matches, gf_matches)

    ~H"""
    <div class="tw-space-y-8">
      <!-- Upper / Winners Bracket -->
      <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-5 tw-shadow-xl tw-space-y-4">
        <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3">
          <div class="tw-flex tw-items-center tw-gap-2.5">
            <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">Upper Bracket</h3>
            <span class="tw-text-xs tw-text-sky-400 tw-bg-sky-950/60 tw-border tw-border-sky-800/40 tw-px-2.5 tw-py-0.5 tw-rounded-full">
              Winners
            </span>
          </div>
          <span class="tw-text-xs tw-text-slate-400">
            Losers drop to Lower Bracket
          </span>
        </div>

        <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 lg:tw-grid-cols-3 tw-gap-4">
          <%= for m <- @wb_matches do %>
            <.match_card
              match={m}
              node={Map.get(@nodes_map, m.match_identifier)}
              interactive={@interactive}
              predict_scores={@predict_scores}
              admin_mode={@admin_mode}
              on_pick={@on_pick}
              on_score_change={@on_score_change}
              show_pick_stats={@show_pick_stats}
              pick_stats={Map.get(@match_pick_stats, m.match_identifier)}
              on_open_champion_picks={@on_open_champion_picks}
            />
          <% end %>
        </div>
      </div>

      <!-- Lower / Losers Bracket -->
      <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-5 tw-shadow-xl tw-space-y-4">
        <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3">
          <div class="tw-flex tw-items-center tw-gap-2.5">
            <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">Lower Bracket</h3>
            <span class="tw-text-xs tw-text-amber-400 tw-bg-amber-950/60 tw-border tw-border-amber-800/40 tw-px-2.5 tw-py-0.5 tw-rounded-full">
              Elimination
            </span>
          </div>
          <span class="tw-text-xs tw-text-rose-400">
            Losers are eliminated
          </span>
        </div>

        <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 lg:tw-grid-cols-3 tw-gap-4">
          <%= for m <- @lb_matches do %>
            <.match_card
              match={m}
              node={Map.get(@nodes_map, m.match_identifier)}
              interactive={@interactive}
              predict_scores={@predict_scores}
              admin_mode={@admin_mode}
              on_pick={@on_pick}
              on_score_change={@on_score_change}
              show_pick_stats={@show_pick_stats}
              pick_stats={Map.get(@match_pick_stats, m.match_identifier)}
              on_open_champion_picks={@on_open_champion_picks}
            />
          <% end %>
        </div>
      </div>

      <!-- Grand Finals -->
      <%= if Enum.any?(@gf_matches) do %>
        <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-5 tw-shadow-xl tw-space-y-4">
          <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3">
            <div class="tw-flex tw-items-center tw-gap-2.5">
              <h3 class="tw-text-lg tw-font-bold tw-text-amber-400 tw-tracking-wide">Grand Finals</h3>
              <span class="tw-text-xs tw-text-amber-300 tw-bg-amber-950/80 tw-border tw-border-amber-700/60 tw-px-2.5 tw-py-0.5 tw-rounded-full">
                Championship
              </span>
            </div>
          </div>

          <div class="tw-max-w-md tw-mx-auto tw-space-y-4">
            <%= for m <- @gf_matches do %>
              <.match_card
                match={m}
                node={Map.get(@nodes_map, m.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
                show_pick_stats={@show_pick_stats}
                pick_stats={Map.get(@match_pick_stats, m.match_identifier)}
                on_open_champion_picks={@on_open_champion_picks}
              />
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
