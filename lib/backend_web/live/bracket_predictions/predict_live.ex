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
  data(save_status, :atom, default: :saved)
  data(predictions_closed, :boolean, default: false)
  data(stage_1, :any, default: nil)
  data(stage_2, :any, default: nil)
  data(groups, :list, default: [])
  data(viewing_entry, :any, default: nil)
  data(viewing_other, :boolean, default: false)
  data(entry_owner_name, :string, default: "")
  data(can_edit, :boolean, default: false)
  data(user_has_entry, :boolean, default: false)
  data(show_champion_modal, :boolean, default: false)
  data(match_pick_stats, :map, default: %{})
  data(champion_pick_stats, :map, default: %{total_final_picks: 0, stats: []})

  def mount(params, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> put_user_in_context()

    id_or_slug = params["id"]

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
        entry_id_param = params["entry_id"]

        entry =
          if entry_id_param && entry_id_param != "" do
            BracketPredictions.get_entry(entry_id_param)
          else
            user_entry
          end

        cond do
          entry_id_param && entry_id_param != "" && (is_nil(entry) || entry.tournament_id != tournament.id) ->
            {:ok,
             socket
             |> put_flash(:error, "Bracket prediction entry not found")
             |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}

          not predictions_open? and is_nil(entry) ->
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

          true ->
            is_owner? = not is_nil(user) and not is_nil(entry) and entry.user_id == user.id
            can_edit? = (is_nil(entry) or is_owner?) and predictions_open? and not is_nil(user)
            viewing_other? = not is_nil(entry) and not is_owner?
            can_manage? = Tournament.can_manage?(tournament, user)

            entry_owner_name =
              cond do
                is_nil(entry) ->
                  if user && user.battletag, do: user.battletag, else: "User"

                entry.user ->
                  if can_manage? do
                    entry.user.battletag || "User ##{entry.user.id}"
                  else
                    Backend.UserManager.User.display_name(entry.user)
                  end

                true ->
                  "Anonymous"
              end

            matches = tournament.matches

            {initial_picks, initial_scores, entry_name} =
              if entry do
                matches_by_id = Map.new(matches, &{&1.id, &1.match_identifier})

                picks =
                  (entry.picks || [])
                  |> Enum.map(fn p ->
                    m_id = (p.match && Match.match_identifier(p.match)) || Map.get(matches_by_id, p.match_id)
                    {m_id, p.picked_winner_name}
                  end)
                  |> Enum.reject(fn {m_id, _} -> is_nil(m_id) end)
                  |> Map.new()

                scores =
                  (entry.picks || [])
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

                {picks, scores, entry.name}
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

            {match_pick_stats, champion_pick_stats} =
              if predictions_open? do
                {%{}, %{total_final_picks: 0, stats: []}}
              else
                {BracketPredictions.get_match_pick_stats(tournament.id),
                 BracketPredictions.get_champion_pick_stats(tournament.id)}
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
             |> assign(:match_pick_stats, match_pick_stats)
             |> assign(:champion_pick_stats, champion_pick_stats)
             |> assign(:show_champion_modal, false)
             |> assign(:stage_1, s1)
             |> assign(:stage_2, s2)
             |> assign(:groups, grps)
             |> assign(:viewing_entry, entry)
             |> assign(:viewing_other, viewing_other?)
             |> assign(:entry_owner_name, entry_owner_name)
             |> assign(:can_edit, can_edit?)
             |> assign(:user_has_entry, not is_nil(user_entry))}
        end
    end
  end

  def handle_event("open_champion_modal", _, socket) do
    {:noreply, assign(socket, :show_champion_modal, true)}
  end

  def handle_event("close_champion_modal", _, socket) do
    {:noreply, assign(socket, :show_champion_modal, false)}
  end

  def handle_event("open_champion_picks", _, socket) do
    {:noreply, assign(socket, :show_champion_modal, true)}
  end

  def handle_event("pick_winner", %{"match_id" => match_id, "winner" => winner}, socket) do
    user = socket.assigns[:user]

    cond do
      is_nil(user) ->
        {:noreply, put_flash(socket, :error, "You must be logged in to make predictions.")}

      not socket.assigns.can_edit ->
        {:noreply, socket}

      true ->
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

        socket =
          socket
          |> assign(:current_picks, new_picks)
          |> assign(:scores_map, new_scores)
          |> assign(:evaluated_nodes, nodes)

        case auto_save_predictions(
               socket,
               socket.assigns.tournament,
               user,
               new_picks,
               new_scores,
               nodes,
               socket.assigns.entry_name
             ) do
          {:ok, socket} -> {:noreply, socket}
          {:error, _reason, socket} -> {:noreply, socket}
        end
    end
  end

  def handle_event("change_score", params, socket) do
    user = socket.assigns[:user]

    cond do
      is_nil(user) ->
        {:noreply, put_flash(socket, :error, "You must be logged in to change scores.")}

      not socket.assigns.can_edit ->
        {:noreply, socket}

      true ->
        val =
          case params do
            %{"_target" => [target_name]} ->
              params[target_name]

            %{"score" => score} ->
              score

            %{"value" => value} ->
              value

            _ ->
              Enum.find_value(params, fn {k, v} ->
                if String.starts_with?(to_string(k), "score_select"), do: v
              end)
          end

        score_parsed =
          with [match_id, top_s, bot_s] <- String.split(to_string(val), ":"),
               {top_score, ""} <- Integer.parse(top_s),
               {bot_score, ""} <- Integer.parse(bot_s) do
            {match_id, top_score, bot_score}
          else
            _ -> nil
          end

        case score_parsed do
          {match_id, top_score, bot_score} ->
            new_scores = Map.put(socket.assigns.scores_map, match_id, {top_score, bot_score})
            nodes = evaluate_bracket(socket.assigns.matches, socket.assigns.current_picks, new_scores)

            socket =
              socket
              |> assign(:scores_map, new_scores)
              |> assign(:evaluated_nodes, nodes)

            case auto_save_predictions(
                   socket,
                   socket.assigns.tournament,
                   user,
                   socket.assigns.current_picks,
                   new_scores,
                   nodes,
                   socket.assigns.entry_name
                 ) do
              {:ok, socket} -> {:noreply, socket}
              {:error, _reason, socket} -> {:noreply, socket}
            end

          _ ->
            {:noreply, socket}
        end
    end
  end

  def handle_event("update_entry_name", params, socket) do
    user = socket.assigns[:user]

    cond do
      is_nil(user) ->
        {:noreply, put_flash(socket, :error, "You must be logged in to update your bracket name.")}

      not socket.assigns.can_edit ->
        {:noreply, socket}

      true ->
        raw_name = params["entry_name"] || params["value"] || ""
        trimmed = String.trim(raw_name)
        name = if trimmed != "", do: trimmed, else: socket.assigns.entry_name

        socket = assign(socket, :entry_name, name)

        case auto_save_predictions(
               socket,
               socket.assigns.tournament,
               user,
               socket.assigns.current_picks,
               socket.assigns.scores_map,
               socket.assigns.evaluated_nodes,
               name
             ) do
          {:ok, socket} -> {:noreply, socket}
          {:error, _reason, socket} -> {:noreply, socket}
        end
    end
  end

  def handle_event("submit_predictions", _, socket) do
    user = socket.assigns[:user]
    tournament = socket.assigns.tournament

    cond do
      is_nil(user) ->
        {:noreply, put_flash(socket, :error, "You must be logged in to submit your predictions.")}

      not socket.assigns.can_edit ->
        {:noreply,
         socket
         |> put_flash(
           :error,
           "The prediction deadline has passed. Predictions can no longer be submitted or updated."
         )
         |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}

      true ->
        case auto_save_predictions(
               socket,
               tournament,
               user,
               socket.assigns.current_picks,
               socket.assigns.scores_map,
               socket.assigns.evaluated_nodes,
               socket.assigns.entry_name
             ) do
          {:ok, socket} ->
            {:noreply,
             socket
             |> put_flash(:info, "Your predictions have been submitted successfully! Good luck!")
             |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}

          {:error, :predictions_closed, socket} ->
            {:noreply, push_navigate(socket, to: "/bracket-predictions/tournaments/#{tournament.id}")}

          {:error, _reason, socket} ->
            {:noreply, socket}
        end
    end
  end

  defp auto_save_predictions(socket, tournament, user, picks_map, scores_map, nodes, entry_name) do
    formatted_picks = format_picks_for_save(tournament, picks_map, scores_map, nodes, socket.assigns.matches)

    case BracketPredictions.save_entry_predictions(tournament, user, formatted_picks, entry_name) do
      {:ok, _entry} ->
        {:ok, assign(socket, :save_status, :saved)}

      {:error, :predictions_closed} ->
        {:error, :predictions_closed,
         socket
         |> assign(:predictions_closed, true)
         |> put_flash(
           :error,
           "The prediction deadline has passed. Predictions can no longer be submitted or updated."
         )}

      {:error, reason} ->
        {:error, reason,
         socket
         |> assign(:save_status, :error)
         |> put_flash(:error, "Could not save predictions: #{inspect(reason)}")}
    end
  end

  defp format_picks_for_save(tournament, picks_map, scores_map, evaluated_nodes, matches) do
    Map.new(picks_map, fn {m_id, winner} ->
      case Map.get(scores_map, m_id) do
        {top_s, bot_s} ->
          {m_id, %{winner: winner, top_score: top_s, bottom_score: bot_s}}

        _ ->
          if tournament.predict_scores do
            node = Map.get(evaluated_nodes, m_id)
            match = Enum.find(matches, &(&1.match_identifier == m_id))
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
              <span :if={@viewing_other}>{@entry_owner_name}'s Bracket: {@tournament.name}</span>
              <span :if={!@viewing_other and @predictions_closed}>My Bracket: {@tournament.name}</span>
              <span :if={!@viewing_other and !@predictions_closed}>Predict: {@tournament.name}</span>
            </h1>
            <p class="tw-text-sm tw-text-slate-400 tw-mt-1">
              <span :if={@viewing_other}>Viewing {@entry_owner_name}'s submitted bracket and predictions.</span>
              <span :if={!@viewing_other and @predictions_closed}>Predictions for this tournament are closed. Viewing your submitted bracket and results.</span>
              <span :if={!@viewing_other and !@predictions_closed and not is_nil(@user)}>Click on any player to select them as the winner. Their victory will automatically advance them to the next round in your bracket!</span>
              <span :if={!@viewing_other and !@predictions_closed and is_nil(@user)}>Sign in with your Battle.net account to make bracket predictions and compete on the leaderboard.</span>
            </p>
            <div :if={@tournament.prediction_deadline} class="tw-mt-2.5 tw-inline-flex tw-items-center tw-gap-1.5 tw-bg-sky-950/60 tw-border tw-border-sky-800/60 tw-text-sky-300 tw-text-xs tw-px-3 tw-py-1 tw-rounded-lg">
              <svg class="tw-w-4 tw-h-4 tw-text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span>Prediction Deadline: <strong class="tw-text-white">{BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)}</strong></span>
            </div>
          </div>

          <!-- Entry Name & Auto-save Status (if editable) -->
          <div :if={@can_edit} class="tw-flex tw-items-center tw-gap-2">
            <input
              type="text"
              name="entry_name"
              value={@entry_name}
              phx-blur="update_entry_name"
              placeholder="Bracket Name"
              class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-3.5 tw-py-2 tw-text-sm tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
            />
            <div :if={@save_status == :saved} class="tw-flex tw-items-center tw-gap-1 tw-text-xs tw-font-medium tw-text-emerald-400 tw-bg-emerald-950/40 tw-border tw-border-emerald-800/50 tw-px-2.5 tw-py-2 tw-rounded-xl" title="All changes saved automatically">
              <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
              </svg>
              <span class="tw-hidden sm:tw-inline">Saved</span>
            </div>
            <div :if={@save_status == :saving} class="tw-flex tw-items-center tw-gap-1 tw-text-xs tw-font-medium tw-text-sky-400 tw-bg-sky-950/40 tw-border tw-border-sky-800/50 tw-px-2.5 tw-py-2 tw-rounded-xl">
              <svg class="tw-w-3.5 tw-h-3.5 tw-animate-spin" fill="none" viewBox="0 0 24 24">
                <circle class="tw-opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="tw-opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
              </svg>
              <span class="tw-hidden sm:tw-inline">Saving...</span>
            </div>
            <div :if={@save_status == :error} class="tw-flex tw-items-center tw-gap-1 tw-text-xs tw-font-medium tw-text-rose-400 tw-bg-rose-950/40 tw-border tw-border-rose-800/50 tw-px-2.5 tw-py-2 tw-rounded-xl" title="Failed to save">
              <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4m0 4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
              </svg>
              <span class="tw-hidden sm:tw-inline">Save error</span>
            </div>
          </div>

          <!-- Sign In CTA (if open and not logged in) -->
          <div :if={!@viewing_other and !@predictions_closed and is_nil(@user)} class="tw-flex tw-flex-col sm:tw-flex-row tw-items-stretch sm:tw-items-center tw-gap-3">
            <a
              id="header_login_to_predict_btn"
              href={"/auth/bnet?redirect_to=/bracket-predictions/tournaments/#{@tournament.id}/predict"}
              class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-sm tw-px-6 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95 tw-inline-flex tw-items-center tw-justify-center tw-gap-2"
            >
              <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 16l-4-4m0 0l4-4m-4 4h14m-5 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h7a3 3 0 013 3v1"/>
              </svg>
              Sign in with Battle.net
            </a>
          </div>

          <!-- Status Badges & Bracket Name (if read-only entry) -->
          <div :if={!@can_edit and not is_nil(@viewing_entry)} class="tw-flex tw-flex-wrap tw-items-center tw-gap-2.5">
            <span class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-px-4 tw-py-2 tw-text-sm tw-font-bold text-white">
              {@entry_name}
            </span>
            <span :if={@viewing_entry.total_score} class="tw-bg-emerald-950/80 tw-text-emerald-300 tw-border tw-border-emerald-700/60 tw-px-3.5 tw-py-2 tw-rounded-xl tw-text-xs tw-font-bold tw-font-mono">
              {@viewing_entry.total_score} pts
            </span>
            <span :if={@viewing_entry.rank} class="tw-bg-slate-800 tw-text-slate-200 tw-border tw-border-slate-700 tw-px-3 tw-py-2 tw-rounded-xl tw-text-xs tw-font-bold tw-font-mono">
              Rank #{if @viewing_entry.rank, do: @viewing_entry.rank, else: "-"}
            </span>
            <span :if={@predictions_closed} class="tw-bg-amber-950/80 tw-text-amber-300 tw-border tw-border-amber-700/60 tw-px-3.5 tw-py-2 tw-rounded-xl tw-text-xs tw-font-semibold tw-inline-flex tw-items-center tw-gap-1.5">
              <svg class="tw-w-4 tw-h-4 text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
              Predictions Closed
            </span>
            <button
              :if={@predictions_closed}
              type="button"
              phx-click="open_champion_modal"
              class="tw-bg-amber-500/20 hover:tw-bg-amber-500/30 tw-text-amber-300 tw-border tw-border-amber-500/40 tw-px-3.5 tw-py-2 tw-rounded-xl tw-text-xs tw-font-semibold tw-inline-flex tw-items-center tw-gap-1.5 tw-transition-all"
            >
              🏆 Champion Pick %
            </button>
          </div>
        </div>

        <!-- Read-only View Banner for viewing other users -->
        <div :if={@viewing_other} class="tw-bg-slate-800/60 tw-border tw-border-slate-700 tw-rounded-xl tw-p-4 tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-gap-4">
          <div class="tw-flex tw-items-center tw-gap-3">
            <div class="tw-w-8 tw-h-8 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-flex tw-items-center tw-justify-center tw-shrink-0">
              <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
              </svg>
            </div>
            <div>
              <div class="tw-text-sm tw-font-semibold text-white">Viewing {@entry_owner_name}'s Bracket</div>
              <div class="tw-text-xs tw-text-slate-400">Viewing another participant's bracket in read-only mode.</div>
            </div>
          </div>
          <div class="tw-flex tw-items-center tw-gap-3">
            <.link
              :if={@user && @user_has_entry}
              navigate={"/bracket-predictions/tournaments/#{@tournament.id}/predict"}
              class="tw-text-xs tw-font-bold tw-text-sky-400 hover:tw-text-sky-300 tw-whitespace-nowrap"
            >
              View your own bracket &rarr;
            </.link>
            <.link
              :if={@user && !@user_has_entry && !@predictions_closed}
              navigate={"/bracket-predictions/tournaments/#{@tournament.id}/predict"}
              class="tw-text-xs tw-font-bold tw-text-sky-400 hover:tw-text-sky-300 tw-whitespace-nowrap"
            >
              Create your bracket &rarr;
            </.link>
          </div>
        </div>

        <!-- Read-only View Banner for unauthenticated visitors -->
        <div :if={!@viewing_other and !@predictions_closed and is_nil(@user)} class="tw-bg-sky-950/50 tw-border tw-border-sky-800/60 tw-rounded-xl tw-p-4 tw-flex tw-items-center tw-justify-between tw-gap-4">
          <div class="tw-flex tw-items-center tw-gap-3">
            <div class="tw-w-8 tw-h-8 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-flex tw-items-center tw-justify-center tw-shrink-0">
              <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
              </svg>
            </div>
            <div>
              <div class="tw-text-sm tw-font-semibold tw-text-white">Viewing bracket in read-only mode</div>
              <div class="tw-text-xs tw-text-slate-400">You must be logged in to fill out predictions. Please sign in to pick winners and predict scores.</div>
            </div>
          </div>
          <a
            href={"/auth/bnet?redirect_to=/bracket-predictions/tournaments/#{@tournament.id}/predict"}
            class="tw-text-xs tw-font-bold tw-text-sky-400 hover:tw-text-sky-300 tw-whitespace-nowrap"
          >
            Sign in now &rarr;
          </a>
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
            <span :if={@can_edit} class="tw-text-xs tw-text-slate-400">
              Click a contestant to pick them to win
            </span>
          </div>

          <div class="tw-space-y-6">
            <div :for={{group_name, matches} <- @groups}>
              <BracketPredictionComponents.gsl_group_bracket
                group_name={group_name}
                matches={matches}
                nodes_map={@evaluated_nodes}
                interactive={@can_edit}
                predict_scores={@tournament.predict_scores}
                show_pick_stats={@predictions_closed}
                match_pick_stats={@match_pick_stats}
                on_pick="pick_winner"
                on_score_change="change_score"
                on_open_champion_picks="open_champion_picks"
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
            <span :if={@can_edit} class="tw-text-xs tw-text-slate-400">
              Click a contestant to pick them to win
            </span>
          </div>

          <BracketPredictionComponents.single_elim_bracket
            matches={@stage_1.matches}
            nodes_map={@evaluated_nodes}
            interactive={@can_edit}
            predict_scores={@tournament.predict_scores}
            show_pick_stats={@predictions_closed}
            match_pick_stats={@match_pick_stats}
            on_pick="pick_winner"
            on_score_change="change_score"
            on_open_champion_picks="open_champion_picks"
          />
        </div>

        <!-- Stage 1: Double Elimination (if Stage 1 is Double Elimination) -->
        <div :if={@stage_1 && @stage_1.stage_type == "double_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">1</span>
              Stage 1: {@stage_1.name} (Double Elimination)
            </h2>
            <span :if={@can_edit} class="tw-text-xs tw-text-slate-400">
              Click a contestant to pick them to win
            </span>
          </div>

          <BracketPredictionComponents.double_elim_bracket
            matches={@stage_1.matches}
            nodes_map={@evaluated_nodes}
            interactive={@can_edit}
            predict_scores={@tournament.predict_scores}
            show_pick_stats={@predictions_closed}
            match_pick_stats={@match_pick_stats}
            on_pick="pick_winner"
            on_score_change="change_score"
            on_open_champion_picks="open_champion_picks"
          />
        </div>

        <!-- Stage 2: Single Elimination Playoffs -->
        <div :if={@stage_2 && @stage_2.stage_type == "single_elimination"} class="tw-space-y-6">
          <div class="tw-flex tw-items-center tw-justify-between">
            <h2 class="tw-text-xl tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <span class="tw-flex tw-items-center tw-justify-center tw-w-7 tw-h-7 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-sm">2</span>
              Stage 2: {@stage_2.name} (Single Elimination)
            </h2>
            <span :if={@can_edit} class="tw-text-xs tw-text-slate-400">
              Playoff participants advance automatically based on your group picks!
            </span>
          </div>

          <BracketPredictionComponents.single_elim_bracket
            matches={@stage_2.matches}
            nodes_map={@evaluated_nodes}
            interactive={@can_edit}
            predict_scores={@tournament.predict_scores}
            show_pick_stats={@predictions_closed}
            match_pick_stats={@match_pick_stats}
            on_pick="pick_winner"
            on_score_change="change_score"
            on_open_champion_picks="open_champion_picks"
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
            interactive={@can_edit}
            predict_scores={@tournament.predict_scores}
            show_pick_stats={@predictions_closed}
            match_pick_stats={@match_pick_stats}
            on_pick="pick_winner"
            on_score_change="change_score"
            on_open_champion_picks="open_champion_picks"
          />
        </div>
      </div>

      <!-- Bottom Floating Submit Bar (if open and logged in) -->
      <div :if={@can_edit} class="tw-sticky tw-bottom-4 tw-z-30 tw-bg-[#232a2a]/95 tw-backdrop-blur-md tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-4 tw-shadow-2xl tw-flex tw-items-center tw-justify-between">
        <div class="tw-text-sm tw-text-slate-300 tw-flex tw-items-center tw-gap-3">
          <div class="tw-flex tw-items-center tw-gap-1.5 tw-text-xs tw-font-medium tw-text-emerald-400 tw-bg-emerald-950/60 tw-border tw-border-emerald-800/60 tw-px-2.5 tw-py-1 tw-rounded-lg">
            <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"/>
            </svg>
            <span>Auto-saving</span>
          </div>
          <span class="tw-text-slate-400">({@picked_count} / {@total_matches} matches picked)</span>
        </div>
        <.link
          navigate={"/bracket-predictions/tournaments/#{@tournament.id}"}
          class="tw-bg-slate-700 hover:tw-bg-slate-600 active:tw-bg-slate-800 text-white tw-font-bold tw-text-sm tw-px-5 tw-py-2 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95 tw-inline-flex tw-items-center tw-gap-2"
        >
          Back to Tournament
        </.link>
      </div>

      <!-- Bottom Floating Bar for viewing other user -->
      <div :if={@viewing_other} class="tw-sticky tw-bottom-4 tw-z-30 tw-bg-[#232a2a]/95 tw-backdrop-blur-md tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-4 tw-shadow-2xl tw-flex tw-items-center tw-justify-between">
        <div class="tw-text-sm tw-text-slate-300">
          <span class="tw-font-bold text-white">Viewing {@entry_owner_name}'s Bracket</span>
          <span :if={@viewing_entry && @viewing_entry.total_score} class="tw-text-emerald-400 tw-font-bold tw-ml-2">({@viewing_entry.total_score} pts)</span>
        </div>
        <div class="tw-flex tw-items-center tw-gap-3">
          <.link
            :if={@user && @user_has_entry}
            navigate={"/bracket-predictions/tournaments/#{@tournament.id}/predict"}
            class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 text-white tw-font-bold tw-text-xs tw-px-4 tw-py-2 tw-rounded-xl tw-shadow-md tw-transition-all active:tw-scale-95"
          >
            My Bracket
          </.link>
          <.link
            navigate={"/bracket-predictions/tournaments/#{@tournament.id}"}
            class="tw-bg-slate-700 hover:tw-bg-slate-600 active:tw-bg-slate-800 text-white tw-font-bold tw-text-sm tw-px-5 tw-py-2 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95"
          >
            Back to Tournament
          </.link>
        </div>
      </div>

      <!-- Bottom Floating Bar (if open and not logged in) -->
      <div :if={!@viewing_other and !@can_edit and is_nil(@user) and !@predictions_closed} class="tw-sticky tw-bottom-4 tw-z-30 tw-bg-[#232a2a]/95 tw-backdrop-blur-md tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-4 tw-shadow-2xl tw-flex tw-items-center tw-justify-between">
        <div class="tw-text-sm tw-text-slate-300">
          <span class="tw-font-bold text-white">Sign in to participate</span>
          <span class="tw-text-slate-400 tw-ml-2">Make your picks and compete on the leaderboard!</span>
        </div>
        <a
          id="bottom_login_btn"
          href={"/auth/bnet?redirect_to=/bracket-predictions/tournaments/#{@tournament.id}/predict"}
          class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-sm tw-px-6 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95"
        >
          Sign in with Battle.net
        </a>
      </div>

      <!-- Champion Pick % Modal -->
      <div :if={@show_champion_modal} class="tw-fixed tw-inset-0 tw-z-50 tw-flex tw-items-center tw-justify-center tw-p-4 tw-bg-black/80 tw-backdrop-blur-sm">
        <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-max-w-xl tw-w-full tw-shadow-2xl tw-space-y-4 tw-relative tw-max-h-[90vh] tw-overflow-y-auto">
          <div class="tw-flex tw-items-center tw-justify-between tw-border-b tw-border-slate-700/80 tw-pb-3">
            <h3 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              🏆 Champion Pick %
            </h3>
            <button
              type="button"
              phx-click="close_champion_modal"
              class="tw-text-slate-400 hover:tw-text-slate-200 tw-p-1 tw-rounded-lg hover:tw-bg-slate-700/50"
            >
              <svg class="tw-w-5 tw-h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <BracketPredictionComponents.champion_pick_stats champion_stats={@champion_pick_stats} />

          <div class="tw-pt-3 tw-flex tw-justify-end">
            <button
              type="button"
              phx-click="close_champion_modal"
              class="tw-bg-slate-700 hover:tw-bg-slate-600 tw-text-slate-200 tw-text-xs tw-font-semibold tw-px-4 tw-py-2 tw-rounded-xl tw-transition-colors"
            >
              Close
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
