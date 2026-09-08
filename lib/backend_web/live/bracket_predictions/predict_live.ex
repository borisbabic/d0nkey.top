defmodule BackendWeb.BracketPredictions.PredictLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Match
  alias Backend.BracketPredictions.DAG
  alias FunctionComponents.BracketPredictionComponents

  data(user, :any)
  data(tournament, :any)
  data(matches, :list, default: [])
  data(current_picks, :map, default: %{})
  data(scores_map, :map, default: %{})
  data(evaluated_nodes, :map, default: %{})
  data(entry_name, :string, default: "My Bracket")
  data(is_saving, :boolean, default: false)
  data(predictions_closed, :boolean, default: false)
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
        user_entry = if user, do: BracketPredictions.get_user_entry(tournament.id, user.id), else: nil
        predictions_open? = Tournament.open_for_predictions?(tournament)

        if not predictions_open? and is_nil(user_entry) do
          error_msg =
            if Tournament.deadline_passed?(tournament) do
              "The prediction deadline for this tournament has passed."
            else
              "Predictions for this tournament are closed."
            end

          {:ok,
           socket
           |> put_flash(:error, error_msg)
           |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}
        else
          matches = tournament.matches

          {initial_picks, initial_scores, entry_name} =
            if user_entry do
              matches_by_id = Map.new(matches, &{&1.id, &1.match_identifier})

              picks =
                (user_entry.picks || [])
                |> Enum.map(fn p ->
                  m_id = (p.match && Match.match_identifier(p.match)) || Map.get(matches_by_id, p.match_id)
                  {m_id, p.picked_winner_name}
                end)
                |> Enum.reject(fn {m_id, _} -> is_nil(m_id) end)
                |> Map.new()

              scores =
                (user_entry.picks || [])
                |> Enum.filter(&is_integer(&1.predicted_top_score))
                |> Enum.map(fn p ->
                  m_id = (p.match && Match.match_identifier(p.match)) || Map.get(matches_by_id, p.match_id)
                  {m_id, {p.predicted_top_score, p.predicted_bottom_score}}
                end)
                |> Enum.reject(fn {m_id, _} -> is_nil(m_id) end)
                |> Map.new()

              scores =
                if tournament.predict_scores do
                  evaluated = DAG.evaluate_matches(matches, picks)

                  Enum.reduce(picks, scores, fn {m_id, winner}, acc ->
                    if Map.has_key?(acc, m_id) do
                      acc
                    else
                      node = Enum.find(evaluated, &(&1.match.match_identifier == m_id))
                      match = Enum.find(matches, &(&1.match_identifier == m_id))
                      top_name = (node && node.predicted_top) || (match && match.top_name)
                      bottom_name = (node && node.predicted_bottom) || (match && match.bottom_name)

                      default_score =
                        cond do
                          winner == top_name -> {3, 2}
                          winner == bottom_name -> {2, 3}
                          true -> {3, 2}
                        end

                      Map.put(acc, m_id, default_score)
                    end
                  end)
                else
                  scores
                end

              {picks, scores, user_entry.name}
            else
              {%{}, %{}, if(user && user.battletag, do: "#{user.battletag}'s Bracket", else: "My Bracket")}
            end

          nodes = evaluate_bracket(matches, initial_picks, initial_scores)

          s1 = Enum.find(tournament.stages, &(&1.sequence == 1))
          s2 = Enum.find(tournament.stages, &(&1.sequence == 2))

          grps =
            if s1 do
              s1.matches
              |> Enum.group_by(& &1.group_name)
              |> Enum.sort_by(fn {name, _} -> name end)
            else
              []
            end

          {:ok,
           socket
           |> assign(:tournament, tournament)
           |> assign(:matches, matches)
           |> assign(:current_picks, initial_picks)
           |> assign(:scores_map, initial_scores)
           |> assign(:evaluated_nodes, nodes)
           |> assign(:entry_name, entry_name)
           |> assign(:predictions_closed, not predictions_open?)
           |> assign(:stage_1, s1)
           |> assign(:stage_2, s2)
           |> assign(:groups, grps)}
        end
    end
  end

  def handle_event("pick_winner", %{"match_id" => match_id, "winner" => winner}, socket) do
    if socket.assigns.predictions_closed or not Tournament.open_for_predictions?(socket.assigns.tournament) do
      {:noreply, socket}
    else
      matches = socket.assigns.matches
      current_picks = socket.assigns.current_picks
      scores_map = socket.assigns.scores_map

      new_picks = DAG.apply_pick(matches, current_picks, match_id, winner)

      valid_keys = Map.keys(new_picks)
      new_scores = Map.take(scores_map, valid_keys)

      # For the winner put the default of 3 right away, and for the loser default to 2
      new_scores =
        if socket.assigns.tournament.predict_scores do
          evaluated = DAG.evaluate_matches(matches, new_picks)
          node = Enum.find(evaluated, &(&1.match.match_identifier == match_id))
          match = Enum.find(matches, &(&1.match_identifier == match_id))

          top_name = (node && node.predicted_top) || (match && match.top_name)
          bottom_name = (node && node.predicted_bottom) || (match && match.bottom_name)

          default_score =
            cond do
              winner == top_name -> {3, 2}
              winner == bottom_name -> {2, 3}
              true -> {3, 2}
            end

          if Map.get(current_picks, match_id) != winner or not Map.has_key?(new_scores, match_id) do
            Map.put(new_scores, match_id, default_score)
          else
            new_scores
          end
        else
          new_scores
        end

      nodes = evaluate_bracket(matches, new_picks, new_scores)

      {:noreply,
       socket
       |> assign(:current_picks, new_picks)
       |> assign(:scores_map, new_scores)
       |> assign(:evaluated_nodes, nodes)}
    end
  end

  def handle_event("change_score", params, socket) do
    if socket.assigns.predictions_closed or not Tournament.open_for_predictions?(socket.assigns.tournament) do
      {:noreply, socket}
    else
      val =
        case params do
          %{"_target" => [target_name]} ->
            params[target_name]

          _ ->
            Enum.find_value(params, fn {k, v} ->
              if String.starts_with?(to_string(k), "score_select"), do: v
            end)
        end

      case String.split(to_string(val), ":") do
        [match_id, top_s, bot_s] ->
          top_score = String.to_integer(top_s)
          bot_score = String.to_integer(bot_s)

          new_scores = Map.put(socket.assigns.scores_map, match_id, {top_score, bot_score})
          nodes = evaluate_bracket(socket.assigns.matches, socket.assigns.current_picks, new_scores)

          {:noreply,
           socket
           |> assign(:scores_map, new_scores)
           |> assign(:evaluated_nodes, nodes)}

        _ ->
          {:noreply, socket}
      end
    end
  end

  def handle_event("update_entry_name", %{"entry_name" => name}, socket) do
    if socket.assigns.predictions_closed do
      {:noreply, socket}
    else
      {:noreply, assign(socket, :entry_name, name)}
    end
  end

  def handle_event("submit_predictions", _, socket) do
    user = socket.assigns[:user]
    tournament = socket.assigns.tournament

    if socket.assigns.predictions_closed or not Tournament.open_for_predictions?(tournament) do
      {:noreply,
       socket
       |> put_flash(
         :error,
         "The prediction deadline has passed. Predictions can no longer be submitted or updated."
       )
       |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}
    else
      if is_nil(user) do
        {:noreply, put_flash(socket, :error, "You must be logged in to submit your predictions.")}
      else
        picks_map = socket.assigns.current_picks
        scores_map = socket.assigns.scores_map

        formatted_picks =
          Map.new(picks_map, fn {m_id, winner} ->
            case Map.get(scores_map, m_id) do
              {top_s, bot_s} ->
                {m_id, %{winner: winner, top_score: top_s, bottom_score: bot_s}}

              _ ->
                if tournament.predict_scores do
                  node = Map.get(socket.assigns.evaluated_nodes, m_id)
                  match = Enum.find(socket.assigns.matches, &(&1.match_identifier == m_id))
                  top_name = (node && node.predicted_top) || (match && match.top_name)
                  bottom_name = (node && node.predicted_bottom) || (match && match.bottom_name)

                  default_score =
                    cond do
                      winner == top_name -> {3, 2}
                      winner == bottom_name -> {2, 3}
                      true -> {3, 2}
                    end

                  {top_s, bot_s} = default_score
                  {m_id, %{winner: winner, top_score: top_s, bottom_score: bot_s}}
                else
                  {m_id, winner}
                end
            end
          end)

        case BracketPredictions.save_entry_predictions(tournament, user, formatted_picks, socket.assigns.entry_name) do
          {:ok, _entry} ->
            {:noreply,
             socket
             |> put_flash(:info, "Your predictions have been submitted successfully! Good luck!")
             |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}

          {:error, :predictions_closed} ->
            {:noreply,
             socket
             |> put_flash(
               :error,
               "The prediction deadline has passed. Predictions can no longer be submitted or updated."
             )
             |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, "Could not save predictions: #{inspect(reason)}")}
        end
      end
    end
  end

  defp evaluate_bracket(matches, picks, scores) do
    nodes = DAG.evaluate_matches(matches, picks)

    nodes
    |> Enum.map(fn node ->
      case Map.get(scores, node.match.match_identifier) do
        {top_s, bot_s} ->
          %{node | predicted_top_score: top_s, predicted_bottom_score: bot_s}

        _ ->
          node
      end
    end)
    |> Map.new(&{&1.match.match_identifier, &1})
  end

  def render(assigns) do
    total_matches = length(assigns.matches)
    picked_count = map_size(assigns.current_picks)
    pct = if total_matches > 0, do: round(picked_count / total_matches * 100), else: 0

    assigns =
      assigns
      |> assign(:total_matches, total_matches)
      |> assign(:picked_count, picked_count)
      |> assign(:pct, pct)

    ~F"""
    <div class="tw-max-w-7xl tw-mx-auto tw-px-4 tw-py-8 tw-space-y-6">
      <!-- Breadcrumbs -->
      <div class="tw-flex tw-items-center tw-justify-between">
        <.link
          navigate={"/bracket-predictions/tournaments/#{@tournament.id}"}
          class="tw-text-sm tw-text-slate-400 hover:tw-text-slate-200 tw-inline-flex tw-items-center tw-gap-1.5"
        >
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
          Back to {@tournament.name}
        </.link>
      </div>

      <!-- Prediction Instructions & Control Bar -->
      <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-shadow-2xl tw-space-y-5">
        <div class="tw-flex tw-flex-col md:tw-flex-row md:tw-items-center md:tw-justify-between tw-gap-4">
          <div>
            <h1 class="tw-text-2xl tw-font-black text-white tw-flex tw-items-center tw-gap-2.5">
              <span :if={@predictions_closed}>My Bracket: {@tournament.name}</span>
              <span :if={!@predictions_closed}>Predict: {@tournament.name}</span>
            </h1>
            <p class="tw-text-sm tw-text-slate-400 tw-mt-1">
              <span :if={@predictions_closed}>Predictions for this tournament are closed. Viewing your submitted bracket and results.</span>
              <span :if={!@predictions_closed}>Click on any player to select them as the winner. Their victory will automatically advance them to the next round in your bracket!</span>
            </p>
            <div :if={@tournament.prediction_deadline} class="tw-mt-2.5 tw-inline-flex tw-items-center tw-gap-1.5 tw-bg-sky-950/60 tw-border tw-border-sky-800/60 tw-text-sky-300 tw-text-xs tw-px-3 tw-py-1 tw-rounded-lg">
              <svg class="tw-w-4 tw-h-4 tw-text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span>Prediction Deadline: <strong class="tw-text-white">{BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)}</strong></span>
            </div>
          </div>

          <!-- Submit Button & Entry Name (if open) / Status Badge & Bracket Name (if closed) -->
          <div :if={!@predictions_closed} class="tw-flex tw-flex-col sm:tw-flex-row tw-items-stretch sm:tw-items-center tw-gap-3">
            <input
              type="text"
              name="entry_name"
              value={@entry_name}
              phx-blur="update_entry_name"
              placeholder="Bracket Name"
              class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-3.5 tw-py-2 tw-text-sm tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
            />
            <button
              id="header_submit_bracket_btn"
              phx-click="submit_predictions"
              disabled={@is_saving}
              class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-sm tw-px-6 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95 disabled:tw-opacity-50"
            >
              Save & Submit Bracket
            </button>
          </div>
          <div :if={@predictions_closed} class="tw-flex tw-flex-col sm:tw-flex-row tw-items-stretch sm:tw-items-center tw-gap-3">
            <span class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-4 tw-py-2 tw-text-sm tw-font-bold text-white">
              {@entry_name}
            </span>
            <span class="tw-bg-amber-950/80 tw-text-amber-300 tw-border tw-border-amber-700/60 tw-px-3.5 tw-py-2 tw-rounded-xl tw-text-xs tw-font-semibold tw-inline-flex tw-items-center tw-gap-1.5">
              <svg class="tw-w-4 tw-h-4 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
              Predictions Closed
            </span>
          </div>
        </div>

        <!-- Progress Bar -->
        <div class="tw-space-y-1.5 tw-pt-2 tw-border-t tw-border-slate-700/70">
          <div class="tw-flex tw-items-center tw-justify-between tw-text-xs tw-text-slate-400">
            <span>Prediction Progress</span>
            <span class="tw-font-mono tw-text-sky-400 font-bold">
              {@picked_count} / {@total_matches} matches selected ({@pct}%)
            </span>
          </div>
          <div class="tw-w-full tw-bg-[#191e1e] tw-rounded-full tw-h-2 tw-overflow-hidden">
            <div
              class="tw-bg-sky-500 tw-h-2 tw-rounded-full tw-transition-all tw-duration-300"
              style={"width: #{@pct}%"}
            ></div>
          </div>
        </div>
      </div>

      <!-- Interactive Brackets Area -->
      <div class="tw-space-y-8">
        <!-- Stage 1: GSL Groups -->
        <div :if={@stage_1 && @stage_1.stage_type == "double_elimination_groups"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">1</span>
              Stage 1: {@stage_1.name} (GSL Groups)
            </h2>
            <span :if={!@predictions_closed} class="tw-text-xs tw-text-slate-400">
              Click a contestant to pick them to win
            </span>
          </div>

          <div class="tw-space-y-6">
            <div :for={{group_name, matches} <- @groups}>
              <BracketPredictionComponents.gsl_group_bracket
                group_name={group_name}
                matches={matches}
                nodes_map={@evaluated_nodes}
                interactive={not @predictions_closed}
                predict_scores={@tournament.predict_scores}
                on_pick="pick_winner"
                on_score_change="change_score"
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
            <span :if={!@predictions_closed} class="tw-text-xs tw-text-slate-400">
              Click a contestant to pick them to win
            </span>
          </div>

          <BracketPredictionComponents.single_elim_bracket
            matches={@stage_1.matches}
            nodes_map={@evaluated_nodes}
            interactive={not @predictions_closed}
            predict_scores={@tournament.predict_scores}
            on_pick="pick_winner"
            on_score_change="change_score"
          />
        </div>

        <!-- Stage 1: Double Elimination (if Stage 1 is Double Elimination) -->
        <div :if={@stage_1 && @stage_1.stage_type == "double_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">1</span>
              Stage 1: {@stage_1.name} (Double Elimination)
            </h2>
            <span :if={!@predictions_closed} class="tw-text-xs tw-text-slate-400">
              Click a contestant to pick them to win
            </span>
          </div>

          <BracketPredictionComponents.double_elim_bracket
            matches={@stage_1.matches}
            nodes_map={@evaluated_nodes}
            interactive={not @predictions_closed}
            predict_scores={@tournament.predict_scores}
            on_pick="pick_winner"
            on_score_change="change_score"
          />
        </div>

        <!-- Stage 2: Single Elimination Playoffs -->
        <div :if={@stage_2 && @stage_2.stage_type == "single_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">2</span>
              Stage 2: {@stage_2.name} (Single Elimination)
            </h2>
            <span :if={!@predictions_closed} class="tw-text-xs tw-text-slate-400">
              Playoff participants advance automatically based on your group picks!
            </span>
          </div>

          <BracketPredictionComponents.single_elim_bracket
            matches={@stage_2.matches}
            nodes_map={@evaluated_nodes}
            interactive={not @predictions_closed}
            predict_scores={@tournament.predict_scores}
            on_pick="pick_winner"
            on_score_change="change_score"
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
            nodes_map={@evaluated_nodes}
            interactive={not @predictions_closed}
            predict_scores={@tournament.predict_scores}
            on_pick="pick_winner"
            on_score_change="change_score"
          />
        </div>
      </div>

      <!-- Bottom Floating Submit Bar -->
      <div :if={!@predictions_closed} class="tw-sticky tw-bottom-4 tw-z-30 tw-bg-[#232a2a]/95 tw-backdrop-blur-md tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-4 tw-shadow-2xl tw-flex tw-items-center tw-justify-between">
        <div class="tw-text-sm tw-text-slate-300">
          <span class="tw-font-bold text-white">Ready to lock in your predictions?</span>
          <span class="tw-text-slate-400 tw-ml-2">({@picked_count} / {@total_matches} matches picked)</span>
        </div>
        <button
          id="bottom_submit_bracket_btn"
          phx-click="submit_predictions"
          disabled={@is_saving}
          class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-sm tw-px-6 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95 disabled:tw-opacity-50"
        >
          Save & Submit Bracket
        </button>
      </div>
    </div>
    """
  end
end
