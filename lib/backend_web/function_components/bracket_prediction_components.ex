defmodule FunctionComponents.BracketPredictionComponents do
  @moduledoc """
  Reusable UI components for bracket prediction tournaments:
  - Match cards with interactive pick handlers and result statuses
  - GSL double-elimination group visualization
  - Single-elimination playoff tree with optional 3rd place match
  - Leaderboard table with ranks, points, and score accuracy badges
  """
  use Phoenix.Component
  alias FunctionComponents.TournamentBrackets
  alias Components.Helper

  # Delegate bracket display components to generic TournamentBrackets

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
    TournamentBrackets.match_card(assigns)
  end

  attr :name, :string, required: true
  attr :banned_class, :string, default: nil
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
    TournamentBrackets.contestant_row(assigns)
  end

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
    TournamentBrackets.gsl_group_bracket(assigns)
  end

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
    TournamentBrackets.double_elim_bracket(assigns)
  end

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
    TournamentBrackets.single_elim_bracket(assigns)
  end

  @doc """
  Renders the Championship Win Prediction statistics breakdown.
  """
  attr :champion_stats, :map, required: true
  attr :tournament_name, :string, default: nil

  def champion_pick_stats(assigns) do
    total_picks = Map.get(assigns.champion_stats || %{}, :total_final_picks, 0)
    stats = Map.get(assigns.champion_stats || %{}, :stats, [])
    final_match = Map.get(assigns.champion_stats || %{}, :final_match)

    assigns =
      assigns
      |> assign(:total_picks, total_picks)
      |> assign(:stats, stats)
      |> assign(:final_match, final_match)

    ~H"""
    <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-shadow-2xl tw-space-y-6">
      <div class="tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-gap-4 tw-border-b tw-border-slate-700/80 tw-pb-4">
        <div>
          <h2 class="tw-text-xl tw-font-black tw-text-white tw-flex tw-items-center tw-gap-2">
            <span>🏆 Tournament Winner Predictions</span>
          </h2>
          <p class="tw-text-xs tw-text-slate-400 tw-mt-1">
            Percentage of participants who picked each player to win the whole championship (out of {@total_picks} participants who submitted a prediction for the Grand Finals).
          </p>
        </div>
        <div class="tw-flex tw-items-center tw-gap-2">
          <span class="tw-bg-sky-950/80 tw-text-sky-300 tw-border tw-border-sky-800/60 tw-px-3 tw-py-1.5 tw-rounded-xl tw-text-xs tw-font-mono tw-font-bold">
            {@total_picks} Finals Predictions
          </span>
        </div>
      </div>

      <%= if Enum.empty?(@stats) do %>
        <div class="tw-py-8 tw-text-center tw-text-slate-500 tw-italic">
          No predictions submitted for the final match yet.
        </div>
      <% else %>
        <div class="tw-space-y-3">
          <%= for {stat, idx} <- Enum.with_index(@stats, 1) do %>
            <div class={[
              "tw-p-4 tw-rounded-xl tw-border tw-transition-all",
              stat.is_actual_winner && "tw-bg-emerald-950/40 tw-border-emerald-600/60 tw-shadow-[0_0_15px_rgba(16,185,129,0.15)]",
              !stat.is_actual_winner && idx == 1 && "tw-bg-amber-950/20 tw-border-amber-600/40",
              !stat.is_actual_winner && idx > 1 && "tw-bg-[#191e1e] tw-border-slate-700/60 hover:tw-border-slate-600"
            ]}>
              <div class="tw-flex tw-items-center tw-justify-between tw-gap-4 tw-mb-2">
                <div class="tw-flex tw-items-center tw-gap-3 tw-min-w-0">
                  <span class={[
                    "tw-w-7 tw-h-7 tw-rounded-lg tw-flex tw-items-center tw-justify-center tw-text-xs tw-font-bold tw-font-mono tw-flex-shrink-0",
                    idx == 1 && "tw-bg-amber-400/20 tw-text-amber-300 tw-border tw-border-amber-400/40",
                    idx == 2 && "tw-bg-slate-300/20 tw-text-slate-200 tw-border tw-border-slate-300/40",
                    idx == 3 && "tw-bg-amber-700/20 tw-text-amber-500 tw-border tw-border-amber-700/40",
                    idx > 3 && "tw-bg-slate-800 tw-text-slate-400"
                  ]}>
                    {idx}
                  </span>
                  <span class="tw-text-base tw-font-bold tw-text-white tw-truncate">
                    {stat.player_name}
                  </span>
                  <%= if stat.is_actual_winner do %>
                    <span class="tw-inline-flex tw-items-center tw-gap-1 tw-bg-emerald-500/20 tw-text-emerald-300 tw-border tw-border-emerald-500/50 tw-text-[11px] tw-font-bold tw-px-2 tw-py-0.5 tw-rounded-md">
                      <span>👑 Champion</span>
                    </span>
                  <% end %>
                </div>

                <div class="tw-flex tw-items-center tw-gap-4 tw-flex-shrink-0">
                  <span class="tw-text-xs tw-text-slate-400 tw-font-mono">
                    {stat.count} {if stat.count == 1, do: "pick", else: "picks"}
                  </span>
                  <span class="tw-text-lg tw-font-black tw-font-mono tw-text-sky-400 tw-w-16 tw-text-right">
                    {stat.percentage}%
                  </span>
                </div>
              </div>

              <!-- Visual Percentage Bar -->
              <div class="tw-w-full tw-bg-black/40 tw-rounded-full tw-h-2 tw-overflow-hidden">
                <div
                  class={[
                    "tw-h-2 tw-rounded-full tw-transition-all tw-duration-500",
                    stat.is_actual_winner && "tw-bg-emerald-500",
                    !stat.is_actual_winner && idx == 1 && "tw-bg-amber-400",
                    !stat.is_actual_winner && idx > 1 && "tw-bg-sky-500"
                  ]}
                  style={"width: #{stat.percentage}%"}
                ></div>
              </div>
            </div>
          <% end %>
        </div>
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
  attr :can_manage, :boolean, default: false
  attr :tournament_id, :any, default: nil

  def leaderboard_table(assigns) do
    ~H"""
    <div class="tw-overflow-x-auto tw-rounded-xl tw-border tw-border-slate-700">
      <table class="tw-w-full tw-text-left tw-border-collapse tw-text-sm tw-text-slate-300">
        <thead>
          <tr class="tw-border-b tw-border-slate-700 tw-bg-black/30 tw-text-xs tw-uppercase tw-tracking-wider tw-text-slate-300">
            <th class="tw-py-3.5 tw-px-4">Rank</th>
            <th class="tw-py-3.5 tw-px-4">User</th>
            <th class="tw-py-3.5 tw-px-4 tw-text-right">Points</th>
            <th class="tw-py-3.5 tw-px-4 tw-text-center">Correct Picks</th>
            <th :if={@predict_scores} class="tw-py-3.5 tw-px-4 tw-text-center">Exact Scores</th>
            <th class="tw-py-3.5 tw-px-4 tw-text-right">Submitted</th>
            <th :if={@tournament_id} class="tw-py-3.5 tw-px-4 tw-text-right">Action</th>
          </tr>
        </thead>
        <tbody class="tw-divide-y tw-divide-slate-700/50 tw-bg-[#1f2424]">
          <%= if Enum.empty?(@entries) do %>
            <tr>
              <td colspan={5 + if(@predict_scores, do: 1, else: 0) + if(@tournament_id, do: 1, else: 0)} class="tw-py-8 tw-text-center tw-text-slate-500 tw-italic">
                No prediction entries yet. Be the first to enter!
              </td>
            </tr>
          <% end %>
          <%= for entry <- @entries do %>
            <%
              is_me? = entry.user_id && entry.user_id == @current_user_id
              correct_count = Enum.count(entry.picks || [], &(&1.is_correct == true))
              exact_score_count = Enum.count(entry.picks || [], &(&1.exact_score_correct == true))
              user_display =
                if entry.user do
                  if @can_manage do
                    entry.user.battletag || "User ##{entry.user.id}"
                  else
                    Backend.UserManager.User.display_name(entry.user)
                  end
                else
                  "Anonymous"
                end
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
                <%= if @tournament_id do %>
                  <.link
                    navigate={"/bracket-predictions/tournaments/#{@tournament_id}/entries/#{entry.id}"}
                    class="tw-text-white hover:tw-text-sky-400 tw-transition-colors hover:tw-underline"
                  >
                    {user_display}
                  </.link>
                <% else %>
                  {user_display}
                <% end %>
                <%= if is_me? do %>
                  <span class="tw-ml-2 tw-bg-sky-500/20 tw-text-sky-300 tw-text-[11px] tw-px-1.5 tw-py-0.5 tw-rounded tw-border tw-border-sky-500/30">You</span>
                <% end %>
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
              <td :if={@tournament_id} class="tw-py-3.5 tw-px-4 tw-text-right">
                <.link
                  navigate={"/bracket-predictions/tournaments/#{@tournament_id}/entries/#{entry.id}"}
                  class="tw-inline-flex tw-items-center tw-gap-1 tw-text-xs tw-font-semibold tw-text-sky-400 hover:tw-text-sky-300 tw-bg-sky-950/40 hover:tw-bg-sky-900/60 tw-border tw-border-sky-800/50 tw-px-2.5 tw-py-1 tw-rounded-lg tw-transition-all"
                >
                  View Bracket
                  <svg class="tw-w-3 tw-h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                  </svg>
                </.link>
              </td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end

  @doc """
  Renders a tournament prediction deadline in the user's local time via LocalDateTime hook,
  with a formatted UTC fallback for server-rendered HTML.
  """
  attr :datetime, :any, default: nil
  attr :class, :any, default: ""
  slot :inner_block

  def deadline(%{datetime: nil} = assigns) do
    ~H""
  end

  def deadline(assigns) do
    ~H"""
    <Helper.datetime datetime={@datetime} class={@class}>
      {if @inner_block != [], do: render_slot(@inner_block), else: format_deadline(@datetime)}
    </Helper.datetime>
    """
  end

  def format_deadline(nil), do: nil

  def format_deadline(%NaiveDateTime{} = ndt) do
    # e.g., "Nov 4, 18:00 UTC"
    Calendar.strftime(ndt, "%b %-d, %H:%M UTC")
  end

  def format_datetime_local(nil), do: ""

  def format_datetime_local(%NaiveDateTime{} = ndt) do
    Calendar.strftime(ndt, "%Y-%m-%dT%H:%M")
  end
end
