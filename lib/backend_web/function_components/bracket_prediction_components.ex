defmodule FunctionComponents.BracketPredictionComponents do
  @moduledoc """
  Reusable UI components for bracket prediction tournaments:
  - Match cards with interactive pick handlers and result statuses
  - GSL double-elimination group visualization
  - Single-elimination playoff tree with optional 3rd place match
  - Leaderboard table with ranks, points, and score accuracy badges
  """
  use Phoenix.Component
  alias Phoenix.LiveView.JS

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

  def match_card(assigns) do
    # Resolve top and bottom contestant names depending on whether we're in prediction mode (from node) or actual mode
    top_name = (assigns.node && assigns.node.predicted_top) || assigns.predicted_top || assigns.match.top_name || "TBD"

    bottom_name =
      (assigns.node && assigns.node.predicted_bottom) || assigns.predicted_bottom || assigns.match.bottom_name || "TBD"

    picked_winner = (assigns.node && assigns.node.picked_winner) || assigns.picked_winner
    top_score = (assigns.node && assigns.node.predicted_top_score) || assigns.predicted_top_score
    bot_score = (assigns.node && assigns.node.predicted_bottom_score) || assigns.predicted_bottom_score

    # Default to 3 for winner and 2 for loser if not set
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

    show_score_selection =
      assigns.interactive &&
        (assigns.predict_scores || assigns.admin_mode) &&
        not is_nil(picked_winner) &&
        top_name != "TBD" &&
        bottom_name != "TBD" &&
        not assigns.match.is_complete

    assigns =
      assigns
      |> assign(:display_top, top_name)
      |> assign(:display_bottom, bottom_name)
      |> assign(:active_winner, picked_winner)
      |> assign(:active_top_score, resolved_top_score)
      |> assign(:active_bottom_score, resolved_bottom_score)
      |> assign(:show_score_selection, show_score_selection)

    ~H"""
    <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-xl tw-p-3.5 tw-shadow-lg tw-transition-all tw-duration-200 hover:tw-border-slate-600">
      <!-- Match Header -->
      <div class="tw-flex tw-justify-between tw-items-center tw-mb-2.5 tw-text-xs tw-font-semibold tw-text-slate-400">
        <span class="tw-tracking-wide tw-truncate">{@match.round_name}</span>
        <%= if @match.is_complete do %>
          <span class="tw-bg-emerald-950/80 tw-text-emerald-400 tw-border tw-border-emerald-700/60 tw-px-2 tw-py-0.5 tw-rounded-full tw-font-mono tw-text-[11px]">
            Final
          </span>
        <% else %>
          <span class="tw-text-slate-500 tw-font-mono tw-text-[11px]">Upcoming</span>
        <% end %>
      </div>

      <!-- Contestants -->
      <div class="tw-space-y-2">
        <!-- Top Contestant -->
        <.contestant_row
          name={@display_top}
          is_picked={@active_winner == @display_top and @display_top != "TBD"}
          is_actual_winner={@match.is_complete and @match.actual_winner_name == @display_top and @display_top != "TBD"}
          actual_score={@match.top_score}
          predicted_score={@active_top_score}
          is_clickable={@interactive and @display_top != "TBD"}
          phx_click={if @interactive and @display_top != "TBD", do: JS.push(@on_pick, value: %{match_id: @match.match_identifier, winner: @display_top}), else: nil}
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
              <div onclick="event.stopPropagation()" class="tw-flex tw-items-center">
                <select
                  id={"score_select_#{@match.match_identifier}"}
                  name={"score_select_#{@match.match_identifier}"}
                  phx-change={@on_score_change}
                  aria-label={"Score prediction for #{@display_top}"}
                  class="tw-w-10 tw-h-7 tw-px-1 tw-text-center tw-rounded-md tw-bg-[#2a2a2a] tw-border tw-border-slate-600 hover:tw-border-sky-500/70 tw-text-slate-200 tw-font-mono tw-font-bold tw-text-xs focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/40 tw-cursor-pointer tw-transition-colors"
                >
                  <option value={"#{@match.match_identifier}:2:3"} selected={@active_top_score == 2}>2</option>
                  <option value={"#{@match.match_identifier}:1:3"} selected={@active_top_score == 1}>1</option>
                  <option value={"#{@match.match_identifier}:0:3"} selected={@active_top_score == 0}>0</option>
                </select>
              </div>
            <% end %>
          </:score_element>
        </.contestant_row>

        <div class="tw-h-px tw-bg-slate-700/70 tw-my-1"></div>

        <!-- Bottom Contestant -->
        <.contestant_row
          name={@display_bottom}
          is_picked={@active_winner == @display_bottom and @display_bottom != "TBD"}
          is_actual_winner={@match.is_complete and @match.actual_winner_name == @display_bottom and @display_bottom != "TBD"}
          actual_score={@match.bottom_score}
          predicted_score={@active_bottom_score}
          is_clickable={@interactive and @display_bottom != "TBD"}
          phx_click={if @interactive and @display_bottom != "TBD", do: JS.push(@on_pick, value: %{match_id: @match.match_identifier, winner: @display_bottom}), else: nil}
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
              <div onclick="event.stopPropagation()" class="tw-flex tw-items-center">
                <select
                  id={"score_select_#{@match.match_identifier}"}
                  name={"score_select_#{@match.match_identifier}"}
                  phx-change={@on_score_change}
                  aria-label={"Score prediction for #{@display_bottom}"}
                  class="tw-w-10 tw-h-7 tw-px-1 tw-text-center tw-rounded-md tw-bg-[#2a2a2a] tw-border tw-border-slate-600 hover:tw-border-sky-500/70 tw-text-slate-200 tw-font-mono tw-font-bold tw-text-xs focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/40 tw-cursor-pointer tw-transition-colors"
                >
                  <option value={"#{@match.match_identifier}:3:2"} selected={@active_bottom_score == 2}>2</option>
                  <option value={"#{@match.match_identifier}:3:1"} selected={@active_bottom_score == 1}>1</option>
                  <option value={"#{@match.match_identifier}:3:0"} selected={@active_bottom_score == 0}>0</option>
                </select>
              </div>
            <% end %>
          </:score_element>
        </.contestant_row>
      </div>

      <!-- Completed Match Status Indicator for Picks (when not in admin mode) -->
      <%= if not @admin_mode && @match.is_complete && not is_nil(@active_winner) do %>
        <div class="tw-mt-2.5 tw-pt-2 tw-border-t tw-border-slate-700/50 tw-flex tw-items-center tw-justify-between tw-text-xs">
          <%= if @active_winner == @match.actual_winner_name do %>
            <span class="tw-flex tw-items-center tw-gap-1 tw-text-emerald-400 tw-font-medium">
              <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              Correct Pick!
            </span>
          <% else %>
            <span class="tw-flex tw-items-center tw-gap-1 tw-text-rose-400 tw-font-medium">
              <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
              Incorrect
            </span>
          <% end %>

          <%= if @predict_scores && is_integer(@active_top_score) and is_integer(@active_bottom_score) do %>
            <%= if @active_top_score == @match.top_score and @active_bottom_score == @match.bottom_score do %>
              <span class="tw-text-amber-300 tw-font-semibold tw-text-[11px] tw-bg-amber-950/60 tw-px-1.5 tw-py-0.5 tw-rounded tw-border tw-border-amber-700/50">
                Exact Score!
              </span>
            <% end %>
          <% end %>
        </div>
      <% end %>

      <!-- Admin Status Indicator -->
      <%= if @admin_mode && not is_nil(@active_winner) && @display_top != "TBD" && @display_bottom != "TBD" do %>
        <div class="tw-mt-2.5 tw-pt-2 tw-border-t tw-border-slate-700/50 tw-flex tw-items-center tw-justify-between tw-text-xs">
          <%= if @match.is_complete && @active_winner == @match.actual_winner_name && @active_top_score == @match.top_score && @active_bottom_score == @match.bottom_score do %>
            <span class="tw-flex tw-items-center tw-gap-1 tw-text-emerald-400 tw-font-semibold">
              <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              Result Saved ({@match.top_score}-{@match.bottom_score})
            </span>
          <% else %>
            <span class="tw-text-amber-400 tw-font-semibold tw-flex tw-items-center tw-gap-1">
              <span class="tw-w-1.5 tw-h-1.5 tw-rounded-full tw-bg-amber-400 tw-animate-pulse"></span>
              Unsaved: {@active_winner}
            </span>
            <button
              type="button"
              phx-click="save_single_match"
              phx-value-match_id={@match.id}
              phx-value-identifier={@match.match_identifier}
              class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-scale-95 tw-transition-all tw-text-white tw-text-[11px] tw-font-semibold tw-px-2.5 tw-py-0.5 tw-rounded-lg tw-shadow"
            >
              Save Result
            </button>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :is_picked, :boolean, default: false
  attr :is_actual_winner, :boolean, default: false
  attr :actual_score, :integer, default: nil
  attr :predicted_score, :integer, default: nil
  attr :is_clickable, :boolean, default: false
  attr :phx_click, :any, default: nil
  slot :score_element

  defp contestant_row(assigns) do
    row_classes = [
      "tw-flex tw-items-center tw-justify-between tw-px-3 tw-py-2 tw-rounded-lg tw-transition-all tw-duration-150",
      if(assigns.is_clickable, do: "tw-cursor-pointer hover:tw-bg-slate-700/50", else: ""),
      cond do
        assigns.is_actual_winner ->
          "tw-bg-emerald-900/40 tw-border tw-border-emerald-600/70 tw-text-emerald-100 tw-font-bold"

        assigns.is_picked ->
          "tw-bg-sky-950/60 tw-border tw-border-sky-500/80 tw-text-sky-100 tw-font-semibold tw-shadow-inner"

        assigns.name == "TBD" ->
          "tw-bg-black/20 tw-text-slate-500 tw-italic"

        true ->
          "tw-bg-[#1c2222] tw-text-slate-200"
      end
    ]

    assigns = assign(assigns, :row_classes, row_classes)

    ~H"""
    <div class={@row_classes} phx-click={@phx_click}>
      <div class="tw-flex tw-items-center tw-gap-2 tw-truncate">
        <%= if @is_picked do %>
          <span class="tw-flex tw-h-2 tw-w-2 tw-rounded-full tw-bg-sky-400 tw-shadow"></span>
        <% end %>
        <span class="tw-truncate">{@name}</span>
      </div>

      <div class="tw-flex tw-items-center tw-gap-2 tw-font-mono tw-text-xs">
        <%= if @score_element != [] do %>
          {render_slot(@score_element)}
        <% else %>
          <%= if is_integer(@predicted_score) and not @is_actual_winner do %>
            <span class="tw-text-sky-300/90" title="Predicted Score">({@predicted_score})</span>
          <% end %>
          <%= if is_integer(@actual_score) do %>
            <span class="tw-font-bold text-white">{@actual_score}</span>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a GSL 4-player double elimination group.
  Matches are arranged as:
  Column 1: Opening 1 & 2
  Column 2: Winners Match & Elimination Match
  Column 3: Decider Match
  """
  attr :group_name, :string, required: true
  attr :matches, :list, required: true
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false

  def gsl_group_bracket(assigns) do
    # Group matches into opening, winners, elim, decider
    opening_1 = Enum.find(assigns.matches, &String.ends_with?(&1.match_identifier, "opening_1"))
    opening_2 = Enum.find(assigns.matches, &String.ends_with?(&1.match_identifier, "opening_2"))
    winners = Enum.find(assigns.matches, &String.ends_with?(&1.match_identifier, "winners"))
    elim = Enum.find(assigns.matches, &String.ends_with?(&1.match_identifier, "elim"))
    decider = Enum.find(assigns.matches, &String.ends_with?(&1.match_identifier, "decider"))

    assigns =
      assigns
      |> assign(:m_op1, opening_1)
      |> assign(:m_op2, opening_2)
      |> assign(:m_win, winners)
      |> assign(:m_elim, elim)
      |> assign(:m_dec, decider)

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

      <!-- 1. Winners Bracket (Upper Bracket) -->
      <div class="tw-space-y-3">
        <div class="tw-flex tw-items-center tw-justify-between">
          <div class="tw-text-xs tw-font-bold tw-text-sky-400 tw-uppercase tw-tracking-wider tw-flex tw-items-center tw-gap-1.5">
            <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
            </svg>
            Winners Bracket
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

      <!-- 2. Elimination Bracket (Lower Bracket) - Displayed BELOW Winners Bracket -->
      <div class="tw-space-y-3">
        <div class="tw-flex tw-items-center tw-justify-between">
          <div class="tw-text-xs tw-font-bold tw-text-amber-400 tw-uppercase tw-tracking-wider tw-flex tw-items-center tw-gap-1.5">
            <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
            </svg>
            Elimination Bracket
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
                />
                <div class="tw-text-[11px] tw-text-sky-400 tw-mt-1.5 tw-font-medium tw-flex tw-items-center tw-gap-1">
                  <span>★</span> Winner advances as 2nd Seed (Loser is 3rd place)
                </div>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a full double-elimination tournament bracket with Winners Bracket on top,
  Elimination Bracket below, and optional Grand Finals.
  """
  attr :matches, :list, required: true
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false

  def double_elim_bracket(assigns) do
    grand_finals =
      Enum.filter(assigns.matches, fn m ->
        id = String.downcase(m.match_identifier || "")
        name = String.downcase(m.round_name || "")

        String.contains?(id, "grand_final") or
          String.contains?(name, "grand final")
      end)

    elim_matches =
      assigns.matches
      |> Enum.reject(&(&1 in grand_finals))
      |> Enum.filter(fn m ->
        String.contains?(m.match_identifier, "loser") or
          String.contains?(m.match_identifier, "elim") or
          String.contains?(m.match_identifier, "decider") or
          String.contains?(m.round_name, "Elimination") or
          String.contains?(m.round_name, "Loser") or
          String.contains?(m.round_name, "Decider") or
          m.top_source_type == "loser_of" or
          m.bottom_source_type == "loser_of"
      end)

    winners_matches =
      assigns.matches
      |> Enum.reject(&(&1 in grand_finals or &1 in elim_matches))

    winners_by_round =
      winners_matches
      |> Enum.group_by(& &1.round_number)
      |> Enum.sort_by(fn {round_num, _} -> round_num end)

    elim_by_round =
      elim_matches
      |> Enum.group_by(& &1.round_number)
      |> Enum.sort_by(fn {round_num, _} -> round_num end)

    winners_depth = length(winners_by_round)
    elim_depth = length(elim_by_round)

    winners_grid_class =
      case winners_depth do
        1 -> "md:tw-grid-cols-1 md:tw-max-w-md md:tw-mx-auto"
        2 -> "md:tw-grid-cols-2"
        3 -> "md:tw-grid-cols-3"
        _ -> nil
      end

    elim_grid_class =
      case elim_depth do
        1 -> "md:tw-grid-cols-1 md:tw-max-w-md md:tw-mx-auto"
        2 -> "md:tw-grid-cols-2"
        3 -> "md:tw-grid-cols-3"
        _ -> nil
      end

    assigns =
      assigns
      |> assign(:grand_finals, grand_finals)
      |> assign(:winners_rounds, winners_by_round)
      |> assign(:elim_rounds, elim_by_round)
      |> assign(:winners_grid_class, winners_grid_class)
      |> assign(:elim_grid_class, elim_grid_class)

    ~H"""
    <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-6 tw-shadow-xl tw-space-y-6">
      <!-- Title -->
      <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3">
        <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">Double Elimination Bracket</h3>
        <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/60 tw-px-2.5 tw-py-1 tw-rounded-md">
          Upper & Lower Brackets
        </span>
      </div>

      <!-- 1. Winners Bracket (Upper Bracket) -->
      <div class="tw-space-y-3">
        <div class="tw-text-xs tw-font-bold tw-text-sky-400 tw-uppercase tw-tracking-wider tw-flex tw-items-center tw-gap-1.5">
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 3v4M3 5h4M6 17v4m-2-2h4m5-16l2.286 6.857L21 12l-5.714 2.143L13 21l-2.286-6.857L5 12l5.714-2.143L13 3z"/>
          </svg>
          Winners Bracket
        </div>

        <%= if @winners_grid_class do %>
          <div class={["tw-grid tw-grid-cols-1 tw-gap-6 tw-p-2", @winners_grid_class]}>
            <%= for {_round_num, matches} <- @winners_rounds do %>
              <div class="tw-space-y-4">
                <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center">
                  {List.first(matches).round_name}
                </div>
                <%= for match <- matches do %>
                  <.match_card
                    match={match}
                    node={Map.get(@nodes_map, match.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                  />
                <% end %>
              </div>
            <% end %>
          </div>
        <% else %>
          <div class="tw-flex tw-flex-col md:tw-flex-row tw-gap-6 md:tw-overflow-x-auto tw-p-2">
            <%= for {_round_num, matches} <- @winners_rounds do %>
              <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-4">
                <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center">
                  {List.first(matches).round_name}
                </div>
                <%= for match <- matches do %>
                  <.match_card
                    match={match}
                    node={Map.get(@nodes_map, match.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                  />
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

      <!-- Divider -->
      <div class="tw-border-t tw-border-slate-700/70 tw-my-4"></div>

      <!-- 2. Elimination Bracket (Lower Bracket) - Displayed BELOW Winners -->
      <div class="tw-space-y-3">
        <div class="tw-text-xs tw-font-bold tw-text-amber-400 tw-uppercase tw-tracking-wider tw-flex tw-items-center tw-gap-1.5">
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"/>
          </svg>
          Elimination Bracket
        </div>

        <%= if @elim_grid_class do %>
          <div class={["tw-grid tw-grid-cols-1 tw-gap-6 tw-p-2", @elim_grid_class]}>
            <%= for {_round_num, matches} <- @elim_rounds do %>
              <div class="tw-space-y-4">
                <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center">
                  {List.first(matches).round_name}
                </div>
                <%= for match <- matches do %>
                  <.match_card
                    match={match}
                    node={Map.get(@nodes_map, match.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                  />
                <% end %>
              </div>
            <% end %>
          </div>
        <% else %>
          <div class="tw-flex tw-flex-col md:tw-flex-row tw-gap-6 md:tw-overflow-x-auto tw-p-2">
            <%= for {_round_num, matches} <- @elim_rounds do %>
              <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-4">
                <div class="tw-text-[11px] tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center">
                  {List.first(matches).round_name}
                </div>
                <%= for match <- matches do %>
                  <.match_card
                    match={match}
                    node={Map.get(@nodes_map, match.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                  />
                <% end %>
              </div>
            <% end %>
          </div>
        <% end %>
      </div>

      <!-- 3. Grand Finals (if present) -->
      <%= if Enum.any?(@grand_finals) do %>
        <div class="tw-border-t tw-border-slate-700/70 tw-pt-4 tw-space-y-3">
          <div class="tw-text-xs tw-font-bold tw-text-emerald-400 tw-uppercase tw-tracking-wider tw-text-center">
            🏆 Grand Finals
          </div>
          <div class="tw-max-w-sm tw-mx-auto">
            <%= for match <- @grand_finals do %>
              <.match_card
                match={match}
                node={Map.get(@nodes_map, match.match_identifier)}
                interactive={@interactive}
                predict_scores={@predict_scores}
                admin_mode={@admin_mode}
                on_pick={@on_pick}
                on_score_change={@on_score_change}
              />
            <% end %>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders Single Elimination Playoff tree (Quarterfinals, Semifinals, 3rd Place Match, Grand Finals).
  Brackets up to 3 depth are displayed side-by-side on desktop, and as a vertical list on mobile.
  """
  attr :matches, :list, required: true
  attr :nodes_map, :map, default: %{}
  attr :interactive, :boolean, default: false
  attr :predict_scores, :boolean, default: false
  attr :has_third_place, :boolean, default: false
  attr :on_pick, :string, default: "pick_winner"
  attr :on_score_change, :string, default: "change_score"
  attr :admin_mode, :boolean, default: false

  def single_elim_bracket(assigns) do
    third_place =
      Enum.find(assigns.matches, fn m ->
        id = String.downcase(m.match_identifier || "")
        name = String.downcase(m.round_name || "")

        String.contains?(id, "third_place") or
          String.contains?(id, "3rd") or
          String.contains?(id, "third") or
          String.contains?(name, "3rd") or
          String.contains?(name, "third") or
          String.contains?(name, "bronze")
      end)

    ro16 =
      assigns.matches
      |> Enum.reject(&(&1 == third_place))
      |> Enum.filter(fn m ->
        id = String.downcase(m.match_identifier || "")
        name = String.downcase(m.round_name || "")

        String.contains?(id, "r16") or
          String.contains?(id, "ro16") or
          String.contains?(name, "round of 16") or
          String.contains?(name, "ro16") or
          String.contains?(name, "round 16")
      end)
      |> Enum.sort_by(& &1.match_order)

    qfs =
      assigns.matches
      |> Enum.reject(&(&1 == third_place or &1 in ro16))
      |> Enum.filter(fn m ->
        id = String.downcase(m.match_identifier || "")
        name = String.downcase(m.round_name || "")

        String.contains?(id, "qf") or
          String.contains?(id, "quarter") or
          String.contains?(name, "quarter") or
          String.starts_with?(name, "qf")
      end)
      |> Enum.sort_by(& &1.match_order)

    sfs =
      assigns.matches
      |> Enum.reject(&(&1 == third_place or &1 in ro16 or &1 in qfs))
      |> Enum.filter(fn m ->
        id = String.downcase(m.match_identifier || "")
        name = String.downcase(m.round_name || "")

        String.contains?(id, "sf") or
          String.contains?(id, "semi") or
          String.contains?(name, "semi") or
          String.starts_with?(name, "sf")
      end)
      |> Enum.sort_by(& &1.match_order)

    remaining_finals =
      assigns.matches
      |> Enum.reject(&(&1 in [third_place | ro16 ++ qfs ++ sfs]))

    finals =
      Enum.find(remaining_finals, fn m ->
        id = String.downcase(m.match_identifier || "")
        name = String.downcase(m.round_name || "")

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
        assigns.matches
        |> Enum.group_by(& &1.round_number)
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
      |> assign(:depth, depth)
      |> assign(:has_recognized_rounds, has_recognized_rounds?)
      |> assign(:rounds_by_number, rounds_by_number)
      |> assign(:grid_cols_class, grid_cols_class)

    ~H"""
    <div class="tw-bg-[#1f2424] tw-border tw-border-slate-700/70 tw-rounded-2xl tw-p-5 tw-shadow-xl">
      <!-- Title -->
      <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3 tw-mb-5">
        <h3 class="tw-text-lg tw-font-bold tw-text-white tw-tracking-wide">Playoff Bracket</h3>
        <span class="tw-text-xs tw-text-slate-400 tw-bg-slate-800/60 tw-px-2.5 tw-py-1 tw-rounded-md">
          Single Elimination Knockout
        </span>
      </div>

      <%= if @depth <= 3 and @has_recognized_rounds do %>
        <div class={["tw-grid tw-grid-cols-1 tw-gap-6 tw-items-stretch", @grid_cols_class]}>
          <!-- Quarterfinals Column if present -->
          <%= if Enum.any?(@qf_matches) do %>
            <div class="tw-space-y-4">
              <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                Quarterfinals
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
                />
              <% end %>
            </div>
          <% end %>

          <!-- Semifinals Column if present -->
          <%= if Enum.any?(@sf_matches) do %>
            <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
              <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                Semifinals
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
                    />
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>

          <!-- Finals & 3rd Place Column -->
          <%= if @finals_match || @third_place_match do %>
            <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex md:tw-flex-col md:tw-h-full">
              <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                Championship
              </div>
              <div class="tw-space-y-4 md:tw-space-y-0 md:tw-flex-1 md:tw-flex md:tw-flex-col md:tw-justify-center md:tw-gap-6">
                <%= if @finals_match do %>
                  <div>
                    <div class="tw-text-center tw-mb-1.5 tw-text-xs tw-font-bold tw-text-amber-400 tw-flex tw-items-center tw-justify-center tw-gap-1">
                      <span>🏆</span> Grand Finals
                    </div>
                    <.match_card
                      match={@finals_match}
                      node={Map.get(@nodes_map, @finals_match.match_identifier)}
                      interactive={@interactive}
                      predict_scores={@predict_scores}
                      admin_mode={@admin_mode}
                      on_pick={@on_pick}
                      on_score_change={@on_score_change}
                    />
                  </div>
                <% end %>

                <%= if @third_place_match do %>
                  <div class="tw-mt-4 md:tw-mt-0">
                    <div class="tw-text-center tw-mb-1.5 tw-text-xs tw-font-semibold tw-text-slate-400 tw-flex tw-items-center tw-justify-center tw-gap-1">
                      <span>🥉</span> 3rd Place Match
                    </div>
                    <.match_card
                      match={@third_place_match}
                      node={Map.get(@nodes_map, @third_place_match.match_identifier)}
                      interactive={@interactive}
                      predict_scores={@predict_scores}
                      admin_mode={@admin_mode}
                      on_pick={@on_pick}
                      on_score_change={@on_score_change}
                    />
                  </div>
                <% end %>
              </div>
            </div>
          <% end %>
        </div>
      <% else %>
        <%= if @has_recognized_rounds do %>
          <!-- Depth > 3 with recognized rounds (e.g. Round of 16 + QF + SF + Finals) -->
          <div class="tw-flex tw-flex-col md:tw-flex-row tw-gap-6 md:tw-overflow-x-auto tw-p-2">
            <%= if Enum.any?(@ro16_matches) do %>
              <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-4">
                <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                  Round of 16
                </div>
                <%= for r16 <- @ro16_matches do %>
                  <.match_card
                    match={r16}
                    node={Map.get(@nodes_map, r16.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                  />
                <% end %>
              </div>
            <% end %>

            <%= if Enum.any?(@qf_matches) do %>
              <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-4">
                <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                  Quarterfinals
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
                  />
                <% end %>
              </div>
            <% end %>

            <%= if Enum.any?(@sf_matches) do %>
              <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-4">
                <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                  Semifinals
                </div>
                <%= for sf <- @sf_matches do %>
                  <.match_card
                    match={sf}
                    node={Map.get(@nodes_map, sf.match_identifier)}
                    interactive={@interactive}
                    predict_scores={@predict_scores}
                    admin_mode={@admin_mode}
                    on_pick={@on_pick}
                    on_score_change={@on_score_change}
                  />
                <% end %>
              </div>
            <% end %>

            <%= if @finals_match || @third_place_match do %>
              <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-6">
                <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                  Championship
                </div>
                <%= if @finals_match do %>
                  <div>
                    <div class="tw-text-center tw-mb-1.5 tw-text-xs tw-font-bold tw-text-amber-400">🏆 Grand Finals</div>
                    <.match_card
                      match={@finals_match}
                      node={Map.get(@nodes_map, @finals_match.match_identifier)}
                      interactive={@interactive}
                      predict_scores={@predict_scores}
                      admin_mode={@admin_mode}
                      on_pick={@on_pick}
                      on_score_change={@on_score_change}
                    />
                  </div>
                <% end %>

                <%= if @third_place_match do %>
                  <div class="tw-mt-6">
                    <div class="tw-text-center tw-mb-1.5 tw-text-xs tw-font-semibold tw-text-slate-400">🥉 3rd Place Match</div>
                    <.match_card
                      match={@third_place_match}
                      node={Map.get(@nodes_map, @third_place_match.match_identifier)}
                      interactive={@interactive}
                      predict_scores={@predict_scores}
                      admin_mode={@admin_mode}
                      on_pick={@on_pick}
                      on_score_change={@on_score_change}
                    />
                  </div>
                <% end %>
              </div>
            <% end %>
          </div>
        <% else %>
          <!-- Generic rounds grouped by round_number -->
          <%= if @depth <= 3 do %>
            <div class={["tw-grid tw-grid-cols-1 tw-gap-6 tw-items-stretch", @grid_cols_class]}>
              <%= for {round_num, matches} <- @rounds_by_number do %>
                <div class="tw-space-y-4">
                  <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                    {List.first(matches).round_name || "Round #{round_num}"}
                  </div>
                  <%= for match <- matches do %>
                    <.match_card
                      match={match}
                      node={Map.get(@nodes_map, match.match_identifier)}
                      interactive={@interactive}
                      predict_scores={@predict_scores}
                      admin_mode={@admin_mode}
                      on_pick={@on_pick}
                      on_score_change={@on_score_change}
                    />
                  <% end %>
                </div>
              <% end %>
            </div>
          <% else %>
            <div class="tw-flex tw-flex-col md:tw-flex-row tw-gap-6 md:tw-overflow-x-auto tw-p-2">
              <%= for {round_num, matches} <- @rounds_by_number do %>
                <div class="tw-min-w-[260px] tw-flex-1 tw-space-y-4">
                  <div class="tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider tw-text-center tw-mb-2">
                    {List.first(matches).round_name || "Round #{round_num}"}
                  </div>
                  <%= for match <- matches do %>
                    <.match_card
                      match={match}
                      node={Map.get(@nodes_map, match.match_identifier)}
                      interactive={@interactive}
                      predict_scores={@predict_scores}
                      admin_mode={@admin_mode}
                      on_pick={@on_pick}
                      on_score_change={@on_score_change}
                    />
                  <% end %>
                </div>
              <% end %>
            </div>
          <% end %>
        <% end %>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders the tournament Leaderboard table.
  """
  attr :entries, :list, required: true
  attr :current_user_id, :integer, default: nil
  attr :predict_scores, :boolean, default: true

  def leaderboard_table(assigns) do
    ~H"""
    <div class="tw-overflow-x-auto tw-rounded-xl tw-border tw-border-slate-700">
      <table class="tw-w-full tw-text-left tw-border-collapse tw-text-sm tw-text-slate-300">
        <thead>
          <tr class="tw-border-b tw-border-slate-700 tw-bg-black/30 tw-text-xs tw-uppercase tw-tracking-wider tw-text-slate-300">
            <th class="tw-py-3.5 tw-px-4">Rank</th>
            <th class="tw-py-3.5 tw-px-4">User</th>
            <th class="tw-py-3.5 tw-px-4">Bracket Name</th>
            <th class="tw-py-3.5 tw-px-4 tw-text-right">Points</th>
            <th class="tw-py-3.5 tw-px-4 tw-text-center">Correct Picks</th>
            <th :if={@predict_scores} class="tw-py-3.5 tw-px-4 tw-text-center">Exact Scores</th>
            <th class="tw-py-3.5 tw-px-4 tw-text-right">Submitted</th>
          </tr>
        </thead>
        <tbody class="tw-divide-y tw-divide-slate-700/50 tw-bg-[#1f2424]">
          <%= if Enum.empty?(@entries) do %>
            <tr>
              <td colspan={if(@predict_scores, do: 7, else: 6)} class="tw-py-8 tw-text-center tw-text-slate-500 tw-italic">
                No prediction entries yet. Be the first to enter!
              </td>
            </tr>
          <% end %>
          <%= for entry <- @entries do %>
            <%
              is_me? = entry.user_id && entry.user_id == @current_user_id
              correct_count = Enum.count(entry.picks || [], &(&1.is_correct == true))
              exact_score_count = Enum.count(entry.picks || [], &(&1.exact_score_correct == true))
            %>
            <tr class={[
              "tw-transition-colors",
              if(is_me?, do: "tw-bg-sky-950/40 hover:tw-bg-sky-900/40", else: "hover:tw-bg-slate-800/40")
            ]}>
              <td class="tw-py-3.5 tw-px-4 tw-font-mono">
                <%= case entry.rank do %>
                  <% 1 -> %>
                    <span class="tw-inline-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-full tw-bg-amber-400/20 tw-text-amber-300 tw-font-bold">1</span>
                  <% 2 -> %>
                    <span class="tw-inline-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-full tw-bg-slate-300/20 tw-text-slate-200 tw-font-bold">2</span>
                  <% 3 -> %>
                    <span class="tw-inline-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-full tw-bg-amber-700/20 tw-text-amber-500 tw-font-bold">3</span>
                  <% r when is_integer(r) -> %>
                    <span class="tw-text-slate-400">{r}</span>
                  <% _ -> %>
                    <span class="tw-text-slate-600">-</span>
                <% end %>
              </td>
              <td class="tw-py-3.5 tw-px-4 tw-font-medium text-white">
                <%= if entry.user do %>
                  {entry.user.battletag || "User ##{entry.user.id}"}
                <% else %>
                  Anonymous
                <% end %>
                <%= if is_me? do %>
                  <span class="tw-ml-2 tw-bg-sky-500/20 tw-text-sky-300 tw-text-[11px] tw-px-1.5 tw-py-0.5 tw-rounded tw-border tw-border-sky-500/30">You</span>
                <% end %>
              </td>
              <td class="tw-py-3.5 tw-px-4 tw-text-slate-300">
                {entry.name}
              </td>
              <td class="tw-py-3.5 tw-px-4 tw-text-right tw-font-mono tw-text-base tw-font-bold tw-text-emerald-400">
                {entry.total_score}
              </td>
              <td class="tw-py-3.5 tw-px-4 tw-text-center tw-font-mono">
                <span class="tw-bg-slate-800 tw-px-2 tw-py-0.5 tw-rounded tw-text-slate-300">
                  {correct_count}
                </span>
              </td>
              <td :if={@predict_scores} class="tw-py-3.5 tw-px-4 tw-text-center tw-font-mono">
                <%= if exact_score_count > 0 do %>
                  <span class="tw-bg-amber-950/60 tw-border tw-border-amber-700/50 tw-text-amber-300 tw-px-2 tw-py-0.5 tw-rounded">
                    {exact_score_count}
                  </span>
                <% else %>
                  <span class="tw-text-slate-600">0</span>
                <% end %>
              </td>
              <td class="tw-py-3.5 tw-px-4 tw-text-right tw-text-xs tw-text-slate-500 tw-font-mono">
                <%= if entry.submitted_at do %>
                  {Calendar.strftime(entry.submitted_at, "%b %d, %H:%M")}
                <% else %>
                  -
                <% end %>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  @doc "Formats a NaiveDateTime for display, e.g. 'Sep 06, 2026 at 14:00 UTC'"
  def format_deadline(nil), do: nil

  def format_deadline(%NaiveDateTime{} = ndt) do
    Calendar.strftime(ndt, "%b %d, %Y at %H:%M UTC")
  end

  @doc "Formats a NaiveDateTime for datetime-local inputs, e.g. '2026-09-06T14:00'"
  def format_datetime_local(nil), do: ""

  def format_datetime_local(%NaiveDateTime{} = ndt) do
    Calendar.strftime(ndt, "%Y-%m-%dT%H:%M")
  end
end
