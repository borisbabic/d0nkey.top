defmodule BackendWeb.BracketPredictions.TournamentIndexLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament
  alias Backend.UserManager.User
  alias FunctionComponents.BracketPredictionComponents

  data(user, :any)
  data(tournaments, :list, default: [])
  data(show_create_modal, :boolean, default: false)

  data(create_form_data, :map,
    default: %{
      "name" => "",
      "group_count" => "4",
      "prediction_deadline" => "",
      "predict_scores" => true,
      "has_third_place" => true,
      "scoring_strategy" => "flat",
      "flat_points" => "1",
      "exact_score_bonus" => "1",
      "battlefy_tournament_id" => "",
      "group_a" => "XiaoT\nDefinition\nPocketTrain\nTansoku",
      "group_b" => "Furyhunter\nposesi\nhabugabu\nGaby",
      "group_c" => "xBlyzes\nLevik\nreqvam\nDeadDraw",
      "group_d" => "Dizdemon\nFrenetic\nNorwis\nhearthstone"
    }
  )

  def mount(_params, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> put_user_in_context()
      |> assign(:tournaments, BracketPredictions.list_tournaments())

    {:ok, socket}
  end

  def handle_event("toggle_create_modal", _, socket) do
    if User.can_access?(socket.assigns[:user], :bracket_predictions) do
      {:noreply, assign(socket, :show_create_modal, !socket.assigns.show_create_modal)}
    else
      {:noreply, put_flash(socket, :error, "You do not have permission to create bracket prediction tournaments.")}
    end
  end

  def handle_event("update_form", %{"tournament" => params}, socket) do
    predict_scores = Map.get(params, "predict_scores") in [true, "true"]
    has_third_place = Map.get(params, "has_third_place") in [true, "true"]

    merged =
      socket.assigns.create_form_data
      |> Map.merge(params)
      |> Map.put("predict_scores", predict_scores)
      |> Map.put("has_third_place", has_third_place)

    {:noreply, assign(socket, :create_form_data, merged)}
  end

  def handle_event("create_tournament", %{"tournament" => params}, socket) do
    user = socket.assigns[:user]

    if User.can_access?(user, :bracket_predictions) do
      case create_tournament(params, user) do
        {:ok, tournament} ->
          {:noreply,
           socket
           |> put_flash(:info, "Tournament created successfully!")
           |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}

        {:error, _changeset} ->
          {:noreply, put_flash(socket, :error, "Failed to create tournament. Please check your inputs.")}
      end
    else
      {:noreply, put_flash(socket, :error, "You do not have permission to create bracket prediction tournaments.")}
    end
  end

  defp parse_deadline(val) when is_binary(val) do
    trimmed = String.trim(val)

    with {:error, _} <- NaiveDateTime.from_iso8601(trimmed),
         {:error, _} <- NaiveDateTime.from_iso8601("#{trimmed}:00"),
         {:error, _} <- NaiveDateTime.from_iso8601("#{trimmed}:00:00") do
      nil
    else
      {:ok, ndt} -> ndt
    end
  end

  defp parse_deadline(_), do: nil

  defp parse_groups_data(params) do
    group_count = Util.to_int(params["group_count"], 2)

    Enum.map(1..group_count, fn i ->
      letter = <<?A + i - 1>>
      key = "group_#{String.downcase(letter)}"
      raw_text = params[key] || ""

      participants =
        raw_text
        |> String.split("\n", trim: true)
        |> Enum.map(&String.trim/1)
        |> Enum.reject(&(&1 == ""))

      padded =
        case length(participants) do
          l when l >= 4 -> Enum.take(participants, 4)
          l -> participants ++ Enum.map((l + 1)..4, &"Player #{letter}#{&1}")
        end

      %{name: "Group #{letter}", participants: padded}
    end)
  end

  def create_tournament(params, user) do
    predict_scores = Map.get(params, "predict_scores") in [true, "true"]
    has_third_place = Map.get(params, "has_third_place") in [true, "true"]
    flat_pts = Util.to_int(params["flat_points"], 1)

    score_bonus =
      if predict_scores do
        Util.to_int(params["exact_score_bonus"], 1)
      else
        0
      end

    bf_id = String.trim(params["battlefy_tournament_id"] || "")
    bf_id = if bf_id == "", do: nil, else: bf_id

    groups_data =
      parse_groups_data(params)

    tour_attrs = %{
      name:
        if(params["name"] && String.trim(params["name"]) != "",
          do: String.trim(params["name"]),
          else: "New Championship"
        ),
      creator_id: user && user.id,
      predict_scores: predict_scores,
      battlefy_tournament_id: bf_id,
      prediction_deadline: parse_deadline(params["prediction_deadline"]),
      scoring_strategy: params["scoring_strategy"] || "flat",
      scoring_config: %{
        "flat_points" => flat_pts,
        "exact_score_bonus" => score_bonus
      }
    }

    BracketPredictions.create_gsl_into_single_elim_tournament(tour_attrs, groups_data,
      has_third_place_match: has_third_place
    )
  end

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-7xl tw-mx-auto tw-px-4 tw-py-8">
      <.page_header title="Bracket Predictions" />

      <!-- Subheader & Controls -->
      <div class="tw-flex tw-flex-col sm:tw-flex-row tw-items-start sm:tw-items-center tw-justify-between tw-gap-4 tw-my-6">
        <div>
          <p class="tw-text-slate-300 tw-text-base">
            Compete with the Hearthstone community! Predict group stage and playoff outcomes, guess exact match scores, and climb to the top of the leaderboard.
          </p>
        </div>
        <button
          :if={User.can_access?(@user, :bracket_predictions)}
          id="open-create-tournament-modal-btn"
          class="tw-inline-flex tw-items-center tw-gap-2 tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-semibold tw-px-4 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all tw-duration-150 active:tw-scale-95"
          phx-click="toggle_create_modal"
        >
          <svg class="tw-w-5 tw-h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"/>
          </svg>
          Create Tournament
        </button>
      </div>

      <!-- Tournaments Grid -->
      <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 lg:tw-grid-cols-3 tw-gap-6 tw-my-8">
        <div :if={Enum.empty?(@tournaments)} class="tw-col-span-full tw-text-center tw-py-16 tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl">
          <p class="tw-text-slate-400 tw-text-lg tw-mb-4">No tournaments created yet.</p>
          <button
            :if={User.can_access?(@user, :bracket_predictions)}
            id="empty-create-tournament-btn"
            class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-medium tw-px-4 tw-py-2 tw-rounded-lg"
            phx-click="toggle_create_modal"
          >
            Create the First Tournament
          </button>
        </div>

        <div
          :for={tour <- @tournaments}
          class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 hover:tw-border-sky-500/60 tw-rounded-2xl tw-p-5 tw-shadow-xl tw-transition-all tw-duration-200 tw-flex tw-flex-col tw-justify-between"
        >
          <div>
            <!-- Header with Status -->
            <div class="tw-flex tw-items-center tw-justify-between tw-mb-3">
              <span class={[
                "tw-px-2.5 tw-py-1 tw-rounded-full tw-text-xs tw-font-semibold tw-uppercase tw-tracking-wider",
                case tour.status do
                  "open" -> "tw-bg-emerald-950/80 tw-text-emerald-400 tw-border tw-border-emerald-700/60"
                  "locked" -> "tw-bg-amber-950/80 tw-text-amber-400 tw-border tw-border-amber-700/60"
                  "completed" -> "tw-bg-slate-800 tw-text-slate-400"
                  _ -> "tw-bg-slate-800 tw-text-slate-400"
                end
              ]}>
                {tour.status}
              </span>

              <span :if={tour.predict_scores} class="tw-text-[11px] tw-bg-sky-950/60 tw-text-sky-300 tw-border tw-border-sky-700/50 tw-px-2 tw-py-0.5 tw-rounded-md">
                Exact Scores Bonus
              </span>
            </div>

            <!-- Title -->
            <h3 class="tw-text-xl tw-font-bold tw-text-white tw-mb-2 hover:tw-text-sky-400 tw-transition-colors">
              <.link navigate={"/bracket-predictions/tournaments/#{tour.id}"}>
                {tour.name}
              </.link>
            </h3>

            <p class="tw-text-slate-400 tw-text-sm tw-line-clamp-2 tw-mb-4">
              {tour.description || "GSL Group Stage into Single Elimination Playoffs."}
            </p>

            <!-- Rules Badges -->
            <div class="tw-flex tw-flex-wrap tw-gap-1.5 tw-text-xs tw-text-slate-400 tw-mb-4">
              <span class="tw-bg-[#1c2222] tw-px-2 tw-py-1 tw-rounded">
                Scoring: {tour.scoring_strategy} ({Map.get(tour.scoring_config || %{}, "flat_points", 1)} pt/win)
              </span>
              <span :if={tour.battlefy_tournament_id && Tournament.can_manage?(tour, @user)} class="tw-bg-[#1c2222] tw-px-2 tw-py-1 tw-rounded tw-text-cyan-400">
                Battlefy Connected
              </span>
              <span :if={tour.prediction_deadline && Tournament.open_for_predictions?(tour)} class="tw-bg-sky-950/60 tw-border tw-border-sky-700/50 tw-text-sky-300 tw-px-2 tw-py-1 tw-rounded tw-inline-flex tw-items-center tw-gap-1">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Deadline: {BracketPredictionComponents.format_deadline(tour.prediction_deadline)}
              </span>
              <span :if={tour.prediction_deadline && Tournament.deadline_passed?(tour)} class="tw-bg-rose-950/50 tw-border tw-border-rose-800/50 tw-text-rose-400 tw-px-2 tw-py-1 tw-rounded tw-inline-flex tw-items-center tw-gap-1">
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
                Deadline passed
              </span>
            </div>
          </div>

          <!-- Footer Actions -->
          <div class="tw-pt-4 tw-border-t tw-border-slate-700/70 tw-flex tw-items-center tw-justify-between">
            <.link
              navigate={"/bracket-predictions/tournaments/#{tour.id}"}
              class="tw-text-sm tw-font-semibold tw-text-sky-400 hover:tw-text-sky-300 tw-inline-flex tw-items-center tw-gap-1"
            >
              View Bracket & Leaderboard
              <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
              </svg>
            </.link>

            <.link
              :if={Tournament.can_manage?(tour, @user)}
              navigate={"/bracket-predictions/tournaments/#{tour.id}/manage"}
              class="tw-text-xs tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-300 tw-px-2.5 tw-py-1 tw-rounded-lg"
            >
              Manage
            </.link>
          </div>
        </div>
      </div>

      <!-- Creation Modal -->
      <div :if={@show_create_modal && User.can_access?(@user, :bracket_predictions)} class="tw-fixed tw-inset-0 tw-z-50 tw-bg-black/75 tw-backdrop-blur-sm tw-flex tw-items-center tw-justify-center tw-p-4 tw-overflow-y-auto">
        <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-max-w-2xl tw-w-full tw-p-6 tw-shadow-2xl tw-my-8">
          <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/80 tw-pb-4 tw-mb-5">
            <h2 class="tw-text-xl tw-font-bold tw-text-white">Create Bracket Prediction Tournament</h2>
            <button phx-click="toggle_create_modal" class="tw-text-slate-400 hover:tw-text-white">
              <svg class="tw-w-6 tw-h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/>
              </svg>
            </button>
          </div>

          <form id="create-tournament-form" phx-submit="create_tournament" phx-change="update_form" class="tw-space-y-4">
            <div>
              <label class="tw-block tw-text-sm tw-font-semibold tw-text-slate-300 tw-mb-1">Tournament Name</label>
              <input
                type="text"
                name="tournament[name]"
                value={@create_form_data["name"]}
                required
                placeholder="e.g. Hearthstone World Championship 2026"
                class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-3.5 tw-py-2 tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
              />
            </div>

            <div class="tw-grid tw-grid-cols-1 sm:tw-grid-cols-2 tw-gap-4">
              <div>
                <label class="tw-block tw-text-sm tw-font-semibold tw-text-slate-300 tw-mb-1">Number of GSL Groups</label>
                <select
                  name="tournament[group_count]"
                  class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-3.5 tw-py-2 tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                >
                  <option value="2" selected={@create_form_data["group_count"] == "2"}>2 Groups (Top 4 advance to Playoffs)</option>
                  <option value="4" selected={@create_form_data["group_count"] == "4"}>4 Groups (Top 8 advance to Playoffs)</option>
                </select>
              </div>

              <div>
                <label class="tw-block tw-text-sm tw-font-semibold tw-text-slate-300 tw-mb-1">Optional Battlefy Tournament ID</label>
                <input
                  type="text"
                  name="tournament[battlefy_tournament_id]"
                  value={@create_form_data["battlefy_tournament_id"]}
                  placeholder="e.g. 64de18... (optional)"
                  class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-3.5 tw-py-2 tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                />
              </div>
            </div>

            <div>
              <label class="tw-block tw-text-sm tw-font-semibold tw-text-slate-300 tw-mb-1">Prediction Deadline (UTC)</label>
              <input
                type="datetime-local"
                name="tournament[prediction_deadline]"
                value={@create_form_data["prediction_deadline"]}
                class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-3.5 tw-py-2 tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
              />
              <p class="tw-text-xs tw-text-slate-500 tw-mt-1">
                Optional: after this time (UTC), predictions will be locked and cannot be created or updated.
              </p>
            </div>

            <!-- Scoring & Rules Config -->
            <div class="tw-grid tw-grid-cols-1 sm:tw-grid-cols-2 tw-gap-4 tw-p-4 tw-bg-[#1b2020] tw-rounded-xl tw-border tw-border-slate-700/70">
              <div class="tw-flex tw-items-center tw-gap-2">
                <input type="hidden" name="tournament[has_third_place]" value="false" />
                <input
                  type="checkbox"
                  id="has_third_place"
                  name="tournament[has_third_place]"
                  value="true"
                  checked={@create_form_data["has_third_place"]}
                  class="tw-rounded tw-bg-[#2a2a2a] tw-border-slate-700 tw-text-sky-500 focus:tw-ring-sky-500/30"
                />
                <label for="has_third_place" class="tw-text-sm tw-text-slate-300">Playoffs 3rd Place Match</label>
              </div>

              <div class="tw-flex tw-items-center tw-gap-2">
                <input type="hidden" name="tournament[predict_scores]" value="false" />
                <input
                  type="checkbox"
                  id="predict_scores"
                  name="tournament[predict_scores]"
                  value="true"
                  checked={@create_form_data["predict_scores"]}
                  class="tw-rounded tw-bg-[#2a2a2a] tw-border-slate-700 tw-text-sky-500 focus:tw-ring-sky-500/30"
                />
                <label for="predict_scores" class="tw-text-sm tw-text-slate-300">Enable Exact Score Predictions</label>
              </div>

              <div>
                <label class="tw-block tw-text-xs tw-text-slate-400 tw-mb-1">Points per Correct Match</label>
                <input
                  type="number"
                  name="tournament[flat_points]"
                  value={@create_form_data["flat_points"]}
                  min="1"
                  class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-lg tw-px-3 tw-py-1.5 tw-text-white text-sm focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                />
              </div>

              <div :if={@create_form_data["predict_scores"]}>
                <label class="tw-block tw-text-xs tw-text-slate-400 tw-mb-1">Exact Score Bonus Points</label>
                <input
                  type="number"
                  name="tournament[exact_score_bonus]"
                  value={@create_form_data["exact_score_bonus"]}
                  min="0"
                  class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-lg tw-px-3 tw-py-1.5 tw-text-white text-sm focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                />
              </div>
            </div>

            <!-- Contestants per Group -->
            <div class="tw-space-y-3">
              <div class="tw-text-sm tw-font-semibold tw-text-slate-300">
                Contestants (Enter 4 player names per group, one per line):
              </div>

              <div class="tw-grid tw-grid-cols-1 sm:tw-grid-cols-2 tw-gap-4">
                <div>
                  <label class="tw-block tw-text-xs tw-font-medium tw-text-slate-400 tw-mb-1">Group A (Match 1: Line 1 vs 2, Match 2: Line 3 vs 4)</label>
                  <textarea
                    rows="4"
                    name="tournament[group_a]"
                    class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-p-2.5 tw-text-sm tw-text-white tw-font-mono focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                  >{@create_form_data["group_a"]}</textarea>
                </div>

                <div>
                  <label class="tw-block tw-text-xs tw-font-medium tw-text-slate-400 tw-mb-1">Group B (Match 1: Line 1 vs 2, Match 2: Line 3 vs 4)</label>
                  <textarea
                    rows="4"
                    name="tournament[group_b]"
                    class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-p-2.5 tw-text-sm tw-text-white tw-font-mono focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                  >{@create_form_data["group_b"]}</textarea>
                </div>

                <div :if={@create_form_data["group_count"] == "4"}>
                  <label class="tw-block tw-text-xs tw-font-medium tw-text-slate-400 tw-mb-1">Group C (Match 1: Line 1 vs 2, Match 2: Line 3 vs 4)</label>
                  <textarea
                    rows="4"
                    name="tournament[group_c]"
                    class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-p-2.5 tw-text-sm tw-text-white tw-font-mono focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                  >{@create_form_data["group_c"]}</textarea>
                </div>

                <div :if={@create_form_data["group_count"] == "4"}>
                  <label class="tw-block tw-text-xs tw-font-medium tw-text-slate-400 tw-mb-1">Group D (Match 1: Line 1 vs 2, Match 2: Line 3 vs 4)</label>
                  <textarea
                    rows="4"
                    name="tournament[group_d]"
                    class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-p-2.5 tw-text-sm tw-text-white tw-font-mono focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                  >{@create_form_data["group_d"]}</textarea>
                </div>
              </div>
            </div>

            <!-- Submit Buttons -->
            <div class="tw-flex tw-justify-end tw-gap-3 tw-pt-4 tw-border-t tw-border-slate-700/70">
              <button
                type="button"
                phx-click="toggle_create_modal"
                class="tw-px-4 tw-py-2 tw-rounded-xl tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-300 tw-text-sm tw-font-semibold"
              >
                Cancel
              </button>
              <button
                type="submit"
                class="tw-px-5 tw-py-2 tw-rounded-xl tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-text-sm tw-font-semibold tw-shadow-lg"
              >
                Create Tournament & Generate Brackets
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
    """
  end
end
