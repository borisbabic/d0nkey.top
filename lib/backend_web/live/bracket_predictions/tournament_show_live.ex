defmodule BackendWeb.BracketPredictions.TournamentShowLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament
  alias Backend.UserManager.User
  alias FunctionComponents.BracketPredictionComponents

  data(user, :any)
  data(tournament, :any)
  data(active_tab, :string, default: "bracket")
  data(entries, :list, default: [])
  data(user_entry, :any, default: nil)
  data(stage_1, :any, default: nil)
  data(stage_2, :any, default: nil)
  data(groups, :list, default: [])

  def mount(%{"id" => id_or_slug}, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> put_user_in_context()

    case BracketPredictions.get_tournament_by_slug_or_id(id_or_slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Tournament not found")
         |> push_navigate(to: "/bracket-predictions")}

      tournament ->
        user = socket.assigns[:user]
        entries = BracketPredictions.list_entries_for_tournament(tournament.id)
        user_entry = if user, do: BracketPredictions.get_user_entry(tournament.id, user.id), else: nil

        s1 = Enum.find(tournament.stages, &(&1.sequence == 1))
        s2 = Enum.find(tournament.stages, &(&1.sequence == 2))

        groups = groups(s1)

        {:ok,
         socket
         |> assign(:tournament, tournament)
         |> assign(:entries, entries)
         |> assign(:user_entry, user_entry)
         |> assign(:stage_1, s1)
         |> assign(:stage_2, s2)
         |> assign(:groups, groups)
         |> assign(:active_tab, "bracket")}
    end
  end

  defp groups(s1) do
    if s1 do
      s1.matches
      |> Enum.group_by(& &1.group_name)
      |> Enum.sort_by(fn {name, _} -> name end)
    else
      []
    end
  end

  def handle_event("switch_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-7xl tw-mx-auto tw-px-4 tw-py-8 tw-space-y-6">
      <!-- Breadcrumb & Nav -->
      <div class="tw-flex tw-items-center tw-justify-between">
        <.link
          navigate="/bracket-predictions"
          class="tw-text-sm tw-text-slate-400 hover:tw-text-slate-200 tw-inline-flex tw-items-center tw-gap-1.5"
        >
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
          Back to Tournaments
        </.link>

        <.link
          :if={Tournament.can_manage?(@tournament, @user)}
          navigate={"/bracket-predictions/tournaments/#{@tournament.id}/manage"}
          class="tw-inline-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-semibold tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-200 tw-px-3.5 tw-py-1.5 tw-rounded-lg tw-border tw-border-slate-700"
        >
          <svg class="tw-w-4 tw-h-4 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
          </svg>
          Admin Management
        </.link>
      </div>

      <!-- Tournament Hero Header -->
      <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-shadow-2xl">
        <div class="tw-flex tw-flex-col md:tw-flex-row md:tw-items-center md:tw-justify-between tw-gap-6">
          <div class="tw-space-y-2">
            <div class="tw-flex tw-flex-wrap tw-items-center tw-gap-2.5">
              <span class={[
                "tw-px-3 tw-py-1 tw-rounded-full tw-text-xs tw-font-bold tw-uppercase tw-tracking-wider",
                case @tournament.status do
                  "open" -> "tw-bg-emerald-950/90 tw-text-emerald-400 tw-border tw-border-emerald-700"
                  "locked" -> "tw-bg-amber-950/90 tw-text-amber-400 tw-border tw-border-amber-700"
                  "completed" -> "tw-bg-slate-800 tw-text-slate-300"
                  _ -> "tw-bg-slate-800 tw-text-slate-300"
                end
              ]}>
                {@tournament.status}
              </span>
              <span :if={@tournament.predict_scores} class="tw-text-xs tw-bg-sky-950/60 tw-text-sky-300 tw-border tw-border-sky-700/50 tw-px-2.5 tw-py-1 tw-rounded-full">
                Exact Score Bonus Enabled
              </span>
              <span :if={@tournament.prediction_deadline && Tournament.open_for_predictions?(@tournament)} class="tw-text-xs tw-bg-sky-950/60 tw-text-sky-300 tw-border tw-border-sky-700/50 tw-px-2.5 tw-py-1 tw-rounded-full tw-inline-flex tw-items-center tw-gap-1.5">
                <svg class="tw-w-3.5 tw-h-3.5 tw-text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Picks close: {BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)}
              </span>
              <span :if={@tournament.prediction_deadline && Tournament.deadline_passed?(@tournament)} class="tw-text-xs tw-bg-rose-950/70 tw-text-rose-400 tw-border tw-border-rose-700/50 tw-px-2.5 tw-py-1 tw-rounded-full tw-inline-flex tw-items-center tw-gap-1.5">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Deadline passed ({BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)})
              </span>
            </div>

            <h1 class="tw-text-3xl tw-font-black text-white tw-tracking-tight">
              {@tournament.name}
            </h1>

            <p class="tw-text-slate-400 tw-text-sm tw-max-w-2xl">
              {@tournament.description || "Pick the winners of each group, advance your favorites to the single elimination playoffs, and see if your bracket reigns supreme!"}
            </p>
          </div>

          <!-- User Prediction Status CTA -->
          <div class="tw-bg-[#1b2020] tw-border tw-border-slate-700/80 tw-rounded-xl tw-p-4 tw-min-w-[260px] tw-text-center tw-space-y-3">
            <div :if={@user_entry} class="tw-space-y-3">
              <div class="tw-space-y-1">
                <div class="tw-text-xs tw-text-slate-400 tw-uppercase tw-tracking-wider">Your Performance</div>
                <div class="tw-flex tw-items-center tw-justify-center tw-gap-4">
                  <div>
                    <span class="tw-text-xs tw-text-slate-500 tw-block">Score</span>
                    <span class="tw-text-xl tw-font-bold tw-text-emerald-400 tw-font-mono">{@user_entry.total_score} pts</span>
                  </div>
                  <div class="tw-h-8 tw-w-px tw-bg-slate-700/70"></div>
                  <div>
                    <span class="tw-text-xs tw-text-slate-500 tw-block">Rank</span>
                    <span class="tw-text-xl tw-font-bold text-white tw-font-mono">
                      #{if @user_entry.rank, do: @user_entry.rank, else: "-"}
                    </span>
                  </div>
                </div>
              </div>

              <.link
                :if={Tournament.open_for_predictions?(@tournament)}
                navigate={"/bracket-predictions/tournaments/#{@tournament.id}/predict"}
                class="tw-block tw-w-full tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-200 tw-text-xs tw-font-semibold tw-py-2 tw-rounded-lg tw-transition-colors"
              >
                Edit My Predictions
              </.link>
              <div :if={!Tournament.open_for_predictions?(@tournament)} class="tw-text-xs tw-text-slate-500 tw-pt-1">
                {#if Tournament.deadline_passed?(@tournament)}
                  Predictions closed (deadline passed).
                {#else}
                  Predictions locked.
                {/if}
              </div>
            </div>

            <div :if={!@user_entry}>
              <div :if={Tournament.open_for_predictions?(@tournament)} class="tw-space-y-2">
                <div class="tw-text-xs tw-text-emerald-400 tw-font-medium">Predictions are OPEN!</div>
                <.link
                  navigate={"/bracket-predictions/tournaments/#{@tournament.id}/predict"}
                  class="tw-block tw-w-full tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-sm tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95"
                >
                  Enter Your Bracket Picks
                </.link>
              </div>
              <div :if={!Tournament.open_for_predictions?(@tournament)} class="tw-text-xs tw-text-slate-500 tw-py-2">
                {#if Tournament.deadline_passed?(@tournament)}
                  Predictions closed. The deadline was {BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)}.
                {#else}
                  Predictions are currently locked for this tournament.
                {/if}
              </div>
            </div>
          </div>
        </div>

        <!-- Navigation Tabs -->
        <div class="tw-flex tw-gap-2 tw-border-t tw-border-slate-700/80 tw-mt-6 tw-pt-4">
          <button
            phx-click="switch_tab"
            phx-value-tab="bracket"
            class={[
              "tw-px-4 tw-py-2 tw-rounded-xl tw-text-sm tw-font-semibold tw-transition-all",
              if(@active_tab == "bracket",
                do: "tw-bg-sky-600 tw-text-white tw-shadow-md",
                else: "tw-text-slate-400 hover:tw-text-slate-200 hover:tw-bg-slate-700/50"
              )
            ]}
          >
            Tournament & Bracket
          </button>
          <button
            phx-click="switch_tab"
            phx-value-tab="leaderboard"
            class={[
              "tw-px-4 tw-py-2 tw-rounded-xl tw-text-sm tw-font-semibold tw-transition-all tw-flex tw-items-center tw-gap-1.5",
              if(@active_tab == "leaderboard",
                do: "tw-bg-sky-600 tw-text-white tw-shadow-md",
                else: "tw-text-slate-400 hover:tw-text-slate-200 hover:tw-bg-slate-700/50"
              )
            ]}
          >
            Leaderboard
            <span class="tw-bg-black/40 tw-text-xs tw-px-2 tw-py-0.5 tw-rounded-full">
              {length(@entries)}
            </span>
          </button>
          <button
            phx-click="switch_tab"
            phx-value-tab="rules"
            class={[
              "tw-px-4 tw-py-2 tw-rounded-xl tw-text-sm tw-font-semibold tw-transition-all",
              if(@active_tab == "rules",
                do: "tw-bg-sky-600 tw-text-white tw-shadow-md",
                else: "tw-text-slate-400 hover:tw-text-slate-200 hover:tw-bg-slate-700/50"
              )
            ]}
          >
            Rules & Scoring
          </button>
        </div>
      </div>

      <!-- Tab 1: Bracket Overview -->
      <div :if={@active_tab == "bracket"} class="tw-space-y-8">
        <!-- Stage 1: GSL Groups -->
        <div :if={@stage_1 && @stage_1.stage_type == "double_elimination_groups"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">1</span>
              Stage 1: {@stage_1.name} (GSL Double Elimination)
            </h2>
          </div>

          <div class="tw-space-y-6">
            <div :for={{group_name, matches} <- @groups}>
              <BracketPredictionComponents.gsl_group_bracket
                group_name={group_name}
                matches={matches}
                interactive={false}
                predict_scores={@tournament.predict_scores}
              />
            </div>
          </div>
        </div>

        <!-- Stage 1: Single Elimination (if Stage 1 is Single Elimination) -->
        <div :if={@stage_1 && @stage_1.stage_type == "single_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">1</span>
              Stage 1: {@stage_1.name} (Single Elimination)
            </h2>
          </div>

          <BracketPredictionComponents.single_elim_bracket
            matches={@stage_1.matches}
            interactive={false}
            predict_scores={@tournament.predict_scores}
          />
        </div>

        <!-- Stage 1: Double Elimination (if Stage 1 is Double Elimination) -->
        <div :if={@stage_1 && @stage_1.stage_type == "double_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">1</span>
              Stage 1: {@stage_1.name} (Double Elimination)
            </h2>
          </div>

          <BracketPredictionComponents.double_elim_bracket
            matches={@stage_1.matches}
            interactive={false}
            predict_scores={@tournament.predict_scores}
          />
        </div>

        <!-- Stage 2: Single Elimination Playoffs -->
        <div :if={@stage_2 && @stage_2.stage_type == "single_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">2</span>
              Stage 2: {@stage_2.name} (Single Elimination)
            </h2>
          </div>

          <BracketPredictionComponents.single_elim_bracket
            matches={@stage_2.matches}
            interactive={false}
            predict_scores={@tournament.predict_scores}
          />
        </div>

        <!-- Stage 2: Double Elimination -->
        <div :if={@stage_2 && @stage_2.stage_type == "double_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">2</span>
              Stage 2: {@stage_2.name} (Double Elimination)
            </h2>
          </div>

          <BracketPredictionComponents.double_elim_bracket
            matches={@stage_2.matches}
            interactive={false}
            predict_scores={@tournament.predict_scores}
          />
        </div>
      </div>

      <!-- Tab 2: Leaderboard -->
      <div :if={@active_tab == "leaderboard"} class="tw-space-y-4">
        <div class="tw-flex tw-items-center tw-justify-between">
          <h2 class="tw-text-xl tw-font-bold text-white">Tournament Leaderboard</h2>
          <div class="tw-text-xs tw-text-slate-400">
            Rankings update automatically after each completed match.
          </div>
        </div>

        <BracketPredictionComponents.leaderboard_table
          entries={@entries}
          current_user_id={if(@user, do: @user.id, else: nil)}
          predict_scores={@tournament.predict_scores}
        />
      </div>

      <!-- Tab 3: Rules & Scoring -->
      <div :if={@active_tab == "rules"} class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-space-y-6 text-slate-300">
        <div>
          <h2 class="tw-text-xl tw-font-bold text-white tw-mb-2">Tournament Scoring System</h2>
          <p class="tw-text-sm tw-text-slate-400">
            This tournament uses a configurable points system rewarding both accurate winner picks and precision score predictions.
          </p>
        </div>

        <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-6">
          <div class="tw-bg-[#1b2020] tw-border tw-border-slate-700/70 tw-rounded-xl tw-p-4 tw-space-y-2">
            <div class="tw-text-sky-400 tw-font-semibold tw-text-sm">✓ Match Winner Prediction</div>
            <p class="tw-text-xs tw-text-slate-400">
              You earn <strong class="text-white">{Map.get(@tournament.scoring_config || %{}, "flat_points", 1)} point</strong> for each match where you correctly predict the winner, regardless of who their opponent was!
            </p>
          </div>

          <div :if={@tournament.predict_scores} class="tw-bg-[#1b2020] tw-border tw-border-slate-700/70 tw-rounded-xl tw-p-4 tw-space-y-2">
            <div class="tw-text-amber-400 tw-font-semibold tw-text-sm">★ Exact Score Prediction Bonus</div>
            <p class="tw-text-xs tw-text-slate-400">
              If you correctly predict the exact match score (e.g. 3-1, 3-2), you receive an additional <strong class="text-white">+{Map.get(@tournament.scoring_config || %{}, "exact_score_bonus", 1)} bonus point</strong>!
            </p>
          </div>

          <div :if={@tournament.prediction_deadline} class="tw-bg-[#1b2020] tw-border tw-border-slate-700/70 tw-rounded-xl tw-p-4 tw-space-y-2">
            <div class="tw-text-cyan-400 tw-font-semibold tw-text-sm">⏱ Prediction Deadline</div>
            <p class="tw-text-xs tw-text-slate-400">
              Predictions close on <strong class="tw-text-white">{BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)}</strong>. After this time, no brackets can be submitted or edited.
            </p>
          </div>
        </div>

        <div class="tw-border-t tw-border-slate-700/70 tw-pt-4 tw-space-y-3">
          <h3 class="tw-text-base tw-font-bold text-white">How the Bracket Works</h3>
          <ul class="tw-list-disc tw-list-inside tw-text-sm tw-text-slate-400 tw-space-y-2">
            <li><strong>GSL Group Stage:</strong> 4 players compete in a double-elimination format without a grand finals match. The first player to 2 wins finishes 1st. The winner of the decider match finishes 2nd. Both advance to playoffs.</li>
            <li><strong>Playoff Stage:</strong> The top 2 from each group advance to a single elimination playoff tree. Group 1st seeds are matched against opposite group 2nd seeds in the playoffs.</li>
            <li>
              <strong>Leaderboard Tiebreakers:</strong> If two or more predictors have identical total points, ties are broken by:
              <span :if={@tournament.predict_scores}>1) Most exact scores predicted, 2) Most correct match winners, 3) Earliest bracket submission time.</span>
              <span :if={!@tournament.predict_scores}>1) Most correct match winners, 2) Earliest bracket submission time.</span>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
