defmodule BackendWeb.BracketPredictions.TournamentAdminLive do
  @moduledoc false
  use BackendWeb, :surface_live_view

  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.DAG
  alias Backend.BracketPredictions.FuzzyMatcher
  alias Backend.Battlefy
  alias FunctionComponents.BracketPredictionComponents

  data(user, :any)
  data(tournament, :any)
  data(matches, :list, default: [])
  data(current_results, :map, default: %{})
  data(scores_map, :map, default: %{})
  data(evaluated_nodes, :map, default: %{})
  data(stage_1, :any, default: nil)
  data(stage_2, :any, default: nil)
  data(groups, :list, default: [])
  data(selected_match_id, :integer, default: nil)
  data(manual_winner, :string, default: nil)
  data(manual_top_score, :string, default: "3")
  data(manual_bottom_score, :string, default: "0")
  data(battlefy_id, :string, default: "")
  data(group_stage_ids, :map, default: %{})
  data(playoff_stage_id, :string, default: "")
  data(participant_mappings, :map, default: %{})
  data(suggested_mappings, :map, default: %{})
  data(is_syncing, :boolean, default: false)
  data(group_names, :list, default: [])
  data(selected_match, :any, default: nil)
  data(local_contestants, :list, default: [])

  def mount(%{"id" => id_or_slug}, session, socket) do
    socket =
      socket
      |> assign_defaults(session)
      |> put_user_in_context()

    user = socket.assigns[:user]

    case BracketPredictions.get_tournament_by_slug_or_id(id_or_slug) do
      nil ->
        {:ok,
         socket
         |> put_flash(:error, "Tournament not found")
         |> push_navigate(to: "/bracket-predictions")}

      tournament ->
        if Tournament.can_manage?(tournament, user) do
          {
            :ok,
            socket
            |> assign_tournament_attrs(tournament)
          }
        else
          {:ok,
           socket
           |> put_flash(:error, "You do not have permission to manage this tournament.")
           |> push_navigate(to: "/bracket-predictions/tournaments/#{tournament.id}")}
        end
    end
  end

  defp assign_tournament_attrs(socket, tournament) do
    stage_1 = Enum.find(tournament.stages, &(&1.sequence == 1))
    stage_2 = Enum.find(tournament.stages, &(&1.sequence == 2))
    stage_ids = (stage_1 && stage_1.config && stage_1.config["group_battlefy_stage_ids"]) || %{}
    grps = Map.keys(stage_ids)

    groups =
      if stage_1 do
        stage_1.matches
        |> Enum.group_by(& &1.group_name)
        |> Enum.sort_by(fn {name, _} -> name end)
      else
        []
      end

    [first_match | _] = matches = tournament.matches

    contestants = Tournament.contestants(tournament)

    {initial_results, initial_scores, nodes} = init_bracket_state(matches)

    playoff_sid =
      (stage_2 && stage_2.config && (stage_2.config["battlefy_stage_id"] || stage_2.config[:battlefy_stage_id])) ||
        ""

    socket
    |> assign(:tournament, tournament)
    |> assign(:matches, matches)
    |> assign(:current_results, initial_results)
    |> assign(:scores_map, initial_scores)
    |> assign(:evaluated_nodes, nodes)
    |> assign(:battlefy_id, tournament.battlefy_tournament_id || "")
    |> assign(:group_stage_ids, stage_ids)
    |> assign(:playoff_stage_id, playoff_sid)
    |> assign(:participant_mappings, tournament.participant_mappings || %{})
    |> assign(:stage_1, stage_1)
    |> assign(:stage_2, stage_2)
    |> assign(:groups, groups)
    |> assign(:group_names, grps)
    |> assign(:local_contestants, contestants)
    |> assign(:selected_match_id, if(first_match, do: first_match.id, else: nil))
    |> assign(:selected_match, first_match)
    |> assign(:manual_winner, if(first_match, do: first_match.top_name, else: nil))
  end

  def handle_event("change_status", %{"status" => new_status}, socket) do
    case BracketPredictions.update_tournament(socket.assigns.tournament, %{status: new_status}) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(:tournament, updated)
         |> put_flash(:info, "Tournament status changed to #{new_status}.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to change tournament status.")}
    end
  end

  def handle_event("update_deadline", %{"prediction_deadline" => deadline_str}, socket) do
    deadline = parse_deadline(deadline_str)

    case BracketPredictions.update_tournament(socket.assigns.tournament, %{prediction_deadline: deadline}) do
      {:ok, updated} ->
        msg =
          if deadline do
            "Prediction deadline updated to #{BracketPredictionComponents.format_deadline(deadline)}."
          else
            "Prediction deadline cleared."
          end

        {:noreply,
         socket
         |> assign(:tournament, updated)
         |> put_flash(:info, msg)}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to update prediction deadline.")}
    end
  end

  def handle_event("clear_deadline", _, socket) do
    case BracketPredictions.update_tournament(socket.assigns.tournament, %{prediction_deadline: nil}) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(:tournament, updated)
         |> put_flash(:info, "Prediction deadline cleared.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to clear prediction deadline.")}
    end
  end

  def handle_event("pick_winner", %{"match_id" => match_id, "winner" => winner}, socket) do
    matches = socket.assigns.matches
    current_results = socket.assigns.current_results
    scores_map = socket.assigns.scores_map

    new_results = DAG.apply_pick(matches, current_results, match_id, winner)

    valid_keys = Map.keys(new_results)
    new_scores = Map.take(scores_map, valid_keys)

    evaluated = DAG.evaluate_matches(matches, new_results)
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

    new_scores =
      if Map.get(current_results, match_id) != winner or not Map.has_key?(new_scores, match_id) do
        Map.put(new_scores, match_id, default_score)
      else
        new_scores
      end

    nodes = evaluate_bracket(matches, new_results, new_scores)

    {:noreply,
     socket
     |> assign(:current_results, new_results)
     |> assign(:scores_map, new_scores)
     |> assign(:evaluated_nodes, nodes)}
  end

  def handle_event("change_score", params, socket) do
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
        nodes = evaluate_bracket(socket.assigns.matches, socket.assigns.current_results, new_scores)

        {:noreply,
         socket
         |> assign(:scores_map, new_scores)
         |> assign(:evaluated_nodes, nodes)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("save_single_match", %{"identifier" => match_identifier} = params, socket) do
    matches = socket.assigns.matches
    current_results = socket.assigns.current_results
    scores_map = socket.assigns.scores_map

    match = Enum.find(matches, &(&1.match_identifier == match_identifier or to_string(&1.id) == params["match_id"]))

    if is_nil(match) do
      {:noreply, put_flash(socket, :error, "Match not found.")}
    else
      winner = Map.get(current_results, match.match_identifier)
      default_score = if match.top_name == winner, do: {3, 2}, else: {2, 3}
      {top_s, bot_s} = Map.get(scores_map, match.match_identifier, default_score)

      if is_nil(winner) do
        {:noreply, put_flash(socket, :error, "Please select a winner first.")}
      else
        case BracketPredictions.enter_manual_match_result(match.id, winner, top_s, bot_s) do
          {:ok, _updated_match} ->
            refreshed = BracketPredictions.get_tournament!(socket.assigns.tournament.id)
            {new_results, new_scores, nodes} = init_bracket_state(refreshed.matches)

            {:noreply,
             socket
             |> assign(:tournament, refreshed)
             |> assign(:matches, refreshed.matches)
             |> assign(:current_results, new_results)
             |> assign(:scores_map, new_scores)
             |> assign(:evaluated_nodes, nodes)
             |> put_flash(:info, "Match result for #{match.round_name} saved! Leaderboard rescored.")}

          {:error, reason} ->
            {:noreply, put_flash(socket, :error, "Error saving result: #{inspect(reason)}")}
        end
      end
    end
  end

  def handle_event("save_all_results", _, socket) do
    tournament = socket.assigns.tournament
    matches = socket.assigns.matches
    current_results = socket.assigns.current_results
    scores_map = socket.assigns.scores_map

    matches_to_save =
      Enum.filter(matches, fn m ->
        winner = Map.get(current_results, m.match_identifier)
        {top_s, bot_s} = Map.get(scores_map, m.match_identifier, {nil, nil})

        winner != nil &&
          (!m.is_complete || m.actual_winner_name != winner || m.top_score != top_s || m.bottom_score != bot_s)
      end)

    if Enum.empty?(matches_to_save) do
      {:noreply, put_flash(socket, :info, "All match results are already up to date.")}
    else
      sorted_matches = Enum.sort_by(matches_to_save, & &1.match_order)

      result =
        Enum.reduce_while(sorted_matches, :ok, fn m, :ok ->
          winner = Map.get(current_results, m.match_identifier)
          default_score = if m.top_name == winner, do: {3, 2}, else: {2, 3}
          {top_s, bot_s} = Map.get(scores_map, m.match_identifier, default_score)

          case BracketPredictions.enter_manual_match_result(m.id, winner, top_s, bot_s) do
            {:ok, _} -> {:cont, :ok}
            {:error, err} -> {:halt, {:error, err}}
          end
        end)

      case result do
        :ok ->
          refreshed = BracketPredictions.get_tournament!(tournament.id)
          {new_results, new_scores, nodes} = init_bracket_state(refreshed.matches)

          {:noreply,
           socket
           |> assign(:tournament, refreshed)
           |> assign(:matches, refreshed.matches)
           |> assign(:current_results, new_results)
           |> assign(:scores_map, new_scores)
           |> assign(:evaluated_nodes, nodes)
           |> put_flash(
             :info,
             "Successfully saved #{length(matches_to_save)} match result(s) and rescored leaderboard!"
           )}

        {:error, reason} ->
          {:noreply, put_flash(socket, :error, "Error saving results: #{inspect(reason)}")}
      end
    end
  end

  def handle_event("select_match", %{"match_id" => id_str}, socket) do
    m_id = String.to_integer(id_str)
    match = Enum.find(socket.assigns.matches, &(&1.id == m_id))

    winner =
      cond do
        match && match.actual_winner_name -> match.actual_winner_name
        match && match.top_name -> match.top_name
        match && match.bottom_name -> match.bottom_name
        true -> nil
      end

    top_s = if match && is_integer(match.top_score), do: to_string(match.top_score), else: "3"
    bot_s = if match && is_integer(match.bottom_score), do: to_string(match.bottom_score), else: "0"

    {:noreply,
     socket
     |> assign(:selected_match_id, m_id)
     |> assign(:selected_match, match)
     |> assign(:manual_winner, winner)
     |> assign(:manual_top_score, top_s)
     |> assign(:manual_bottom_score, bot_s)}
  end

  def handle_event("update_manual_winner", %{"winner" => winner}, socket) do
    {:noreply, assign(socket, :manual_winner, winner)}
  end

  def handle_event("save_manual_result", %{"result" => params}, socket) do
    m_id = socket.assigns.selected_match_id || (params["match_id"] && String.to_integer(params["match_id"]))
    winner = params["winner"]
    top_s = String.to_integer(params["top_score"] || "0")
    bot_s = String.to_integer(params["bottom_score"] || "0")

    case BracketPredictions.enter_manual_match_result(m_id, winner, top_s, bot_s) do
      {:ok, _match} ->
        refreshed_tournament = BracketPredictions.get_tournament!(socket.assigns.tournament.id)
        current_match = Enum.find(refreshed_tournament.matches, &(&1.id == m_id))
        {new_results, new_scores, nodes} = init_bracket_state(refreshed_tournament.matches)

        {:noreply,
         socket
         |> assign(:tournament, refreshed_tournament)
         |> assign(:matches, refreshed_tournament.matches)
         |> assign(:current_results, new_results)
         |> assign(:scores_map, new_scores)
         |> assign(:evaluated_nodes, nodes)
         |> assign(:selected_match, current_match)
         |> put_flash(:info, "Match result saved! Downstream brackets and leaderboard rescored.")}

      {:error, reason} ->
        {:noreply, put_flash(socket, :error, "Error saving result: #{inspect(reason)}")}
    end
  end

  def handle_event("save_battlefy_config", %{"config" => params}, socket) do
    bf_id = String.trim(params["battlefy_tournament_id"] || "")
    bf_id = if bf_id == "", do: nil, else: bf_id

    stage_1 = Enum.find(socket.assigns.tournament.stages, &(&1.sequence == 1))
    stage_2 = Enum.find(socket.assigns.tournament.stages, &(&1.sequence == 2))

    existing_group_stage_ids = (stage_1 && stage_1.config && stage_1.config["group_battlefy_stage_ids"]) || %{}

    updated_group_stage_ids =
      Enum.reduce(existing_group_stage_ids, %{}, fn {grp_name, _}, acc ->
        clean_key = "stage_id_#{String.replace(grp_name, " ", "_")}"
        val = String.trim(params[clean_key] || "")
        val = if val == "", do: nil, else: val
        Map.put(acc, grp_name, val)
      end)

    playoff_sid = String.trim(params["playoff_stage_id"] || "")
    playoff_val = if playoff_sid == "", do: nil, else: playoff_sid

    {:ok, updated_tour} =
      BracketPredictions.update_tournament(socket.assigns.tournament, %{battlefy_tournament_id: bf_id})

    if stage_1 do
      new_config = Map.put(stage_1.config || %{}, "group_battlefy_stage_ids", updated_group_stage_ids)
      BracketPredictions.update_stage(stage_1, %{config: new_config})
    end

    if stage_2 do
      new_stage_2_config = Map.put(stage_2.config || %{}, "battlefy_stage_id", playoff_val)
      BracketPredictions.update_stage(stage_2, %{config: new_stage_2_config})
    end

    refreshed = BracketPredictions.get_tournament!(updated_tour.id)
    refreshed_stage_2 = Enum.find(refreshed.stages, &(&1.sequence == 2))

    {:noreply,
     socket
     |> assign(:tournament, refreshed)
     |> assign(:stage_2, refreshed_stage_2)
     |> assign(:battlefy_id, bf_id || "")
     |> assign(:group_stage_ids, updated_group_stage_ids)
     |> assign(:playoff_stage_id, playoff_sid)
     |> put_flash(:info, "Battlefy configuration updated successfully.")}
  end

  def handle_event("auto_detect_battlefy_stages", _, socket) do
    bf_id = socket.assigns.battlefy_id
    playoff_stage_id = socket.assigns.playoff_stage_id
    group_names = socket.assigns.group_names
    group_stage_ids = socket.assigns.group_stage_ids

    if is_nil(bf_id) || bf_id == "" do
      {:noreply, put_flash(socket, :error, "Please enter and save a Battlefy Tournament ID first.")}
    else
      case auto_detect_battlefy_stages(bf_id, playoff_stage_id, group_names, group_stage_ids) do
        {:ok, {new_playoff_id, updated_group_stage_ids}} ->
          {:noreply,
           socket
           |> assign(:playoff_stage_id, new_playoff_id)
           |> assign(:group_stage_ids, updated_group_stage_ids)
           |> put_flash(:info, "Stages auto-detected from Battlefy! Click 'Save Battlefy Configuration' to persist.")}

        _ ->
          {:noreply, put_flash(socket, :error, "Could not retrieve stages for Battlefy Tournament ID: #{bf_id}")}
      end
    end
  end

  def handle_event("fetch_and_suggest_participants", _, socket) do
    bf_id = socket.assigns.battlefy_id

    if is_nil(bf_id) || bf_id == "" do
      {:noreply, put_flash(socket, :error, "Please enter and save a Battlefy Tournament ID first.")}
    else
      case Battlefy.get_participants(bf_id) do
        participants when is_list(participants) ->
          bf_player_names = Enum.map(participants, & &1.name)

          local_contestants =
            Tournament.contestants(socket.assigns.tournament)

          suggestions = FuzzyMatcher.suggest_mappings(bf_player_names, local_contestants)

          {:noreply,
           socket
           |> assign(:suggested_mappings, suggestions)
           |> put_flash(:info, "Loaded #{length(bf_player_names)} Battlefy players. Suggestions generated below!")}

        _ ->
          {:noreply, put_flash(socket, :error, "Could not fetch participants from Battlefy for ID: #{bf_id}")}
      end
    end
  end

  def handle_event("save_participant_mapping", %{"mapping" => params}, socket) do
    bf_name = params["battlefy_name"]
    local_name = params["local_name"]

    current_mappings = socket.assigns.participant_mappings

    new_mappings =
      if local_name == "" or local_name == "ignore" do
        Map.delete(current_mappings, bf_name)
      else
        Map.put(current_mappings, bf_name, local_name)
      end

    case BracketPredictions.update_tournament(socket.assigns.tournament, %{participant_mappings: new_mappings}) do
      {:ok, updated} ->
        {:noreply,
         socket
         |> assign(:tournament, updated)
         |> assign(:participant_mappings, new_mappings)
         |> put_flash(:info, "Participant mapping saved.")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Failed to save mapping.")}
    end
  end

  def handle_event("sync_battlefy_results", _, socket) do
    {:noreply, assign(socket, :is_syncing, true)}

    case BracketPredictions.sync_battlefy_and_rescore(socket.assigns.tournament.id) do
      {:ok, updated_count} ->
        refreshed = BracketPredictions.get_tournament!(socket.assigns.tournament.id)
        {new_results, new_scores, nodes} = init_bracket_state(refreshed.matches)

        {:noreply,
         socket
         |> assign(:tournament, refreshed)
         |> assign(:matches, refreshed.matches)
         |> assign(:current_results, new_results)
         |> assign(:scores_map, new_scores)
         |> assign(:evaluated_nodes, nodes)
         |> assign(:is_syncing, false)
         |> put_flash(
           :info,
           "Successfully synced #{updated_count} match results from Battlefy and rescored leaderboard!"
         )}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:is_syncing, false)
         |> put_flash(:error, "Battlefy sync encountered an issue: #{inspect(reason)}")}
    end
  end

  defp auto_detect_battlefy_stages(bf_id, playoff_stage_id, group_names, group_stage_ids) do
    with {:ok, %{stages: [_ | _] = stages}} <- Backend.BracketPredictions.BattlefySync.fetch_battlefy_tournament(bf_id) do
      detected_playoff =
        Enum.find(stages, fn s ->
          (s.bracket_type == "elimination" and s.style == "single") or
            String.contains?(String.downcase(s.name || ""), "playoff") or
            String.contains?(String.downcase(s.name || ""), "bracket")
        end)

      new_playoff_id =
        if detected_playoff, do: detected_playoff.id, else: playoff_stage_id

      updated_group_stage_ids =
        Enum.reduce(group_names, group_stage_ids, fn grp, acc ->
          letter = String.replace(grp, ~r/[^A-Za-z0-9]/, "") |> String.last()

          matching_stage =
            Enum.find(stages, fn s ->
              s_name = String.downcase(s.name || "")

              String.contains?(s_name, String.downcase(grp)) or
                (letter && String.contains?(s_name, "group #{String.downcase(letter)}"))
            end)

          if matching_stage do
            Map.put(acc, grp, matching_stage.id)
          else
            acc
          end
        end)

      {:ok, {new_playoff_id, updated_group_stage_ids}}
    end
  end

  defp init_bracket_state(matches) do
    results =
      matches
      |> Enum.filter(&(&1.is_complete && &1.actual_winner_name))
      |> Map.new(fn m -> {m.match_identifier, m.actual_winner_name} end)

    scores =
      matches
      |> Enum.filter(&is_integer(&1.top_score))
      |> Map.new(fn m -> {m.match_identifier, {m.top_score, m.bottom_score}} end)

    nodes = evaluate_bracket(matches, results, scores)
    {results, scores, nodes}
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

  defp parse_deadline(val) when is_binary(val) do
    trimmed = String.trim(val)

    if trimmed == "" do
      nil
    else
      case NaiveDateTime.from_iso8601(trimmed) do
        {:ok, ndt} ->
          ndt

        {:error, _} ->
          case NaiveDateTime.from_iso8601("#{trimmed}:00") do
            {:ok, ndt} -> ndt
            {:error, _} -> nil
          end
      end
    end
  end

  defp parse_deadline(_), do: nil

  def render(assigns) do
    ~F"""
    <div class="tw-max-w-7xl tw-mx-auto tw-px-4 tw-py-8 tw-space-y-8">
      <!-- Breadcrumb -->
      <div class="tw-flex tw-items-center tw-justify-between">
        <.link
          navigate={"/bracket-predictions/tournaments/#{@tournament.id}"}
          class="tw-text-sm tw-text-slate-400 hover:tw-text-slate-200 tw-inline-flex tw-items-center tw-gap-1.5"
        >
          <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
          </svg>
          Back to Tournament
        </.link>
      </div>

      <!-- Admin Header & Tournament Settings -->
      <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-shadow-2xl tw-space-y-5">
        <div>
          <h1 class="tw-text-2xl tw-font-black text-white tw-mb-1">
            Tournament Administration: {@tournament.name}
          </h1>
          <p class="tw-text-sm tw-text-slate-400">
            Manage status, configure prediction deadlines, enter match results, or synchronize with Battlefy.
          </p>
        </div>

        <div class="tw-grid tw-grid-cols-1 md:tw-grid-cols-2 tw-gap-4 tw-pt-4 tw-border-t tw-border-slate-700/70">
          <!-- Status Control -->
          <div class="tw-bg-[#1b2020] tw-border tw-border-slate-700/70 tw-rounded-xl tw-p-4 tw-space-y-2">
            <label class="tw-block tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider">
              Tournament Status
            </label>
            <select
              id="tournament_status_select"
              class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-lg tw-px-3 tw-py-2 tw-text-xs tw-font-semibold tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20 tw-w-full"
              phx-change="change_status"
              name="status"
            >
              <option value="open" selected={@tournament.status == "open"}>🟢 Open for Predictions</option>
              <option value="locked" selected={@tournament.status == "locked"}>🟡 Locked (In Progress)</option>
              <option value="completed" selected={@tournament.status == "completed"}>⚪ Completed</option>
            </select>
            <p class="tw-text-[11px] tw-text-slate-500">
              When status is locked or completed, predictions are locked regardless of deadline.
            </p>
          </div>

          <!-- Prediction Deadline Control -->
          <div class="tw-bg-[#1b2020] tw-border tw-border-slate-700/70 tw-rounded-xl tw-p-4 tw-space-y-2">
            <div class="tw-flex tw-items-center tw-justify-between">
              <label class="tw-block tw-text-xs tw-font-semibold tw-text-slate-400 tw-uppercase tw-tracking-wider">
                Prediction Deadline (UTC)
              </label>
              <span :if={@tournament.prediction_deadline && Tournament.deadline_passed?(@tournament)} class="tw-text-[11px] tw-font-bold tw-text-rose-400 tw-bg-rose-950/60 tw-border tw-border-rose-800/60 tw-px-2 tw-py-0.5 tw-rounded">
                Deadline Passed
              </span>
              <span :if={@tournament.prediction_deadline && !Tournament.deadline_passed?(@tournament)} class="tw-text-[11px] tw-font-bold tw-text-emerald-400 tw-bg-emerald-950/60 tw-border tw-border-emerald-800/60 tw-px-2 tw-py-0.5 tw-rounded">
                Open until deadline
              </span>
            </div>

            <form id="deadline_form" phx-submit="update_deadline" class="tw-flex tw-items-center tw-gap-2">
              <input
                type="datetime-local"
                name="prediction_deadline"
                id="prediction_deadline_input"
                value={BracketPredictionComponents.format_datetime_local(@tournament.prediction_deadline)}
                class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-lg tw-px-3 tw-py-1.5 tw-text-xs tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20 tw-flex-1"
              />
              <button
                type="submit"
                id="save_deadline_btn"
                class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-semibold tw-text-xs tw-px-3.5 tw-py-1.5 tw-rounded-lg tw-transition-colors"
              >
                Save
              </button>
              <button
                :if={@tournament.prediction_deadline}
                type="button"
                id="clear_deadline_btn"
                phx-click="clear_deadline"
                class="tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-300 tw-font-semibold tw-text-xs tw-px-3 tw-py-1.5 tw-rounded-lg tw-border tw-border-slate-700 tw-transition-colors"
              >
                Clear
              </button>
            </form>

            <p class="tw-text-[11px] tw-text-slate-500">
              {#if @tournament.prediction_deadline}
                Current: <span class="tw-text-slate-300 tw-font-mono">{BracketPredictionComponents.format_deadline(@tournament.prediction_deadline)}</span>
              {#else}
                No deadline set. Predictions remain open until manually changed.
              {/if}
            </p>
          </div>
        </div>
      </div>

      <!-- Section 1: Manual Result Entry (Interactive Prediction-Style Bracket) -->
      <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-shadow-2xl tw-space-y-6">
        <div class="tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-4 tw-gap-4">
          <div>
            <h2 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <svg class="tw-w-5 tw-h-5 tw-text-sky-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"/>
              </svg>
              Manual Result Submission
            </h2>
            <p class="tw-text-xs tw-text-slate-400 tw-mt-0.5">
              Click any contestant directly on the bracket to designate them as match winner and set the final score. Winners propagate downstream automatically!
            </p>
          </div>

          <button
            id="header_save_results_btn"
            type="button"
            phx-click="save_all_results"
            class="tw-inline-flex tw-items-center tw-gap-2 tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-xs tw-px-5 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95"
          >
            Save Results & Rescore
          </button>
        </div>

        <!-- Interactive Brackets Area -->
        <div class="tw-space-y-8">
          <!-- Stage 1: GSL Groups -->
          <div :if={@stage_1 && @stage_1.stage_type == "double_elimination_groups"} class="tw-space-y-6">
            <div class="tw-flex tw-items-center tw-justify-between">
              <h3 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
                <span class="tw-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-xs">1</span>
                Stage 1: {@stage_1.name} (GSL Groups)
              </h3>
              <span class="tw-text-xs tw-text-slate-400">
                Click contestant to set winner, select score, and save
              </span>
            </div>

            <div class="tw-space-y-6">
              <div :for={{group_name, matches} <- @groups}>
                <BracketPredictionComponents.gsl_group_bracket
                  group_name={group_name}
                  matches={matches}
                  nodes_map={@evaluated_nodes}
                  interactive={true}
                  admin_mode={true}
                  on_pick="pick_winner"
                  on_score_change="change_score"
                />
              </div>
            </div>
          </div>

          <!-- Stage 1: Single Elimination (if Stage 1 is Single Elimination) -->
          <div :if={@stage_1 && @stage_1.stage_type == "single_elimination"} class="tw-space-y-6">
            <div class="tw-flex tw-items-center tw-justify-between">
              <h3 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
                <span class="tw-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-xs">1</span>
                Stage 1: {@stage_1.name} (Single Elimination)
              </h3>
              <span class="tw-text-xs tw-text-slate-400">
                Click contestant to set winner, select score, and save
              </span>
            </div>

            <BracketPredictionComponents.single_elim_bracket
              matches={@stage_1.matches}
              nodes_map={@evaluated_nodes}
              interactive={true}
              admin_mode={true}
              on_pick="pick_winner"
              on_score_change="change_score"
            />
          </div>

          <!-- Stage 1: Double Elimination (if Stage 1 is Double Elimination) -->
          <div :if={@stage_1 && @stage_1.stage_type == "double_elimination"} class="tw-space-y-6">
            <div class="tw-flex tw-items-center tw-justify-between">
              <h3 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
                <span class="tw-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-xs">1</span>
                Stage 1: {@stage_1.name} (Double Elimination)
              </h3>
              <span class="tw-text-xs tw-text-slate-400">
                Click contestant to set winner, select score, and save
              </span>
            </div>

            <BracketPredictionComponents.double_elim_bracket
              matches={@stage_1.matches}
              nodes_map={@evaluated_nodes}
              interactive={true}
              admin_mode={true}
              on_pick="pick_winner"
              on_score_change="change_score"
            />
          </div>

          <!-- Stage 2: Single Elimination Playoffs -->
          <div :if={@stage_2 && @stage_2.stage_type == "single_elimination"} class="tw-space-y-6">
            <div class="tw-flex tw-items-center tw-justify-between">
              <h3 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
                <span class="tw-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-xs">2</span>
                Stage 2: {@stage_2.name} (Playoffs)
              </h3>
              <span class="tw-text-xs tw-text-slate-400">
                Playoff participants advance automatically based on your group results
              </span>
            </div>

            <BracketPredictionComponents.single_elim_bracket
              matches={@stage_2.matches}
              nodes_map={@evaluated_nodes}
              interactive={true}
              admin_mode={true}
              on_pick="pick_winner"
              on_score_change="change_score"
            />
          </div>

          <!-- Stage 2: Double Elimination -->
          <div :if={@stage_2 && @stage_2.stage_type == "double_elimination"} class="tw-space-y-6">
            <div class="tw-flex tw-items-center tw-justify-between">
              <h3 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
                <span class="tw-flex tw-items-center tw-justify-center tw-w-6 tw-h-6 tw-rounded-lg tw-bg-sky-500/20 tw-text-sky-400 tw-text-xs">2</span>
                Stage 2: {@stage_2.name} (Double Elimination)
              </h3>
              <span class="tw-text-xs tw-text-slate-400">
                Double elimination participants and results
              </span>
            </div>

            <BracketPredictionComponents.double_elim_bracket
              matches={@stage_2.matches}
              nodes_map={@evaluated_nodes}
              interactive={true}
              admin_mode={true}
              on_pick="pick_winner"
              on_score_change="change_score"
            />
          </div>
        </div>

        <!-- Bottom Save Bar -->
        <div class="tw-pt-4 tw-border-t tw-border-slate-700/70 tw-flex tw-items-center tw-justify-between">
          <span class="tw-text-xs tw-text-slate-400">
            Recorded matches automatically rescore all user predictions and update the tournament leaderboard.
          </span>
          <button
            id="bottom_save_results_btn"
            type="button"
            phx-click="save_all_results"
            class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-bold tw-text-xs tw-px-5 tw-py-2.5 tw-rounded-xl tw-shadow-lg tw-transition-all active:tw-scale-95"
          >
            Save Results & Rescore
          </button>
        </div>
      </div>

      <!-- Section 2: Battlefy Integration & Group Stage Mapping -->
      <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-space-y-5">
        <div class="tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3 tw-gap-3">
          <div>
            <h2 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <svg class="tw-w-5 tw-h-5 tw-text-cyan-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"/>
              </svg>
              Battlefy Live Integration
            </h2>
            <p class="tw-text-xs tw-text-slate-400 tw-mt-0.5">
              Battlefy uses distinct stage IDs per group. Map each group to its Battlefy stage ID to automate scoring.
            </p>
          </div>

          <button
            phx-click="sync_battlefy_results"
            disabled={@is_syncing || is_nil(@battlefy_id) || @battlefy_id == ""}
            class="tw-inline-flex tw-items-center tw-gap-2 tw-bg-emerald-600 hover:tw-bg-emerald-500 tw-text-white tw-font-semibold tw-text-xs tw-px-4 tw-py-2.5 tw-rounded-xl tw-shadow-lg disabled:tw-opacity-50"
          >
            <span :if={@is_syncing} class="tw-inline-flex tw-items-center tw-gap-2">
              <svg class="tw-animate-spin tw-w-4 tw-h-4" fill="none" viewBox="0 0 24 24">
                <circle class="tw-opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="tw-opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
              </svg>
              Syncing...
            </span>
            <span :if={!@is_syncing} class="tw-inline-flex tw-items-center tw-gap-2">
              <svg class="tw-w-4 tw-h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
              </svg>
              Sync Results from Battlefy Now
            </span>
          </button>
        </div>

        <form id="battlefy_config_form" phx-submit="save_battlefy_config" class="tw-space-y-4">
          <div>
            <div class="tw-flex tw-items-center tw-justify-between tw-mb-1">
              <label class="tw-block tw-text-xs tw-font-semibold tw-text-slate-400">Battlefy Tournament ID</label>
              <button
                type="button"
                phx-click="auto_detect_battlefy_stages"
                disabled={is_nil(@battlefy_id) || @battlefy_id == ""}
                class="tw-text-[11px] tw-text-cyan-400 hover:tw-text-cyan-300 tw-font-medium tw-inline-flex tw-items-center tw-gap-1 disabled:tw-opacity-50"
              >
                <svg class="tw-w-3.5 tw-h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z"/>
                </svg>
                Auto-detect Stages from Battlefy
              </button>
            </div>
            <input
              type="text"
              name="config[battlefy_tournament_id]"
              value={@battlefy_id}
              placeholder="e.g. 64de188fa98895018cf411..."
              class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-p-2.5 tw-text-sm tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
            />
          </div>

          <!-- Per-group Stage IDs -->
          <div :if={Enum.any?(@group_names)} class="tw-space-y-2">
            <div class="tw-text-xs tw-font-semibold tw-text-slate-400">Battlefy Stage ID per Group:</div>
            <div class="tw-grid tw-grid-cols-1 sm:tw-grid-cols-2 md:tw-grid-cols-4 tw-gap-3">
              <div :for={grp <- @group_names}>
                <label class="tw-block tw-text-[11px] tw-text-slate-400 tw-mb-1">{grp} Stage ID</label>
                <input
                  type="text"
                  name={"config[stage_id_#{String.replace(grp, " ", "_")}]"}
                  value={Map.get(@group_stage_ids, grp, "")}
                  placeholder="e.g. 64de1890..."
                  class="tw-w-full tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-lg tw-p-2 tw-text-xs tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                />
              </div>
            </div>
          </div>

          <!-- Playoffs Single Elimination Stage ID -->
          <div :if={@stage_2} class="tw-space-y-2 tw-pt-2 tw-border-t tw-border-slate-700/70">
            <div class="tw-flex tw-items-center tw-justify-between">
              <label class="tw-block tw-text-xs tw-font-semibold tw-text-slate-400">
                Playoffs (Single Elimination) Stage ID
              </label>
              <span class="tw-text-[11px] tw-text-slate-500">
                Required to sync Quarterfinals, Semifinals, 3rd Place, and Finals
              </span>
            </div>
            <input
              type="text"
              name="config[playoff_stage_id]"
              value={@playoff_stage_id}
              placeholder="e.g. 64de1895... (Battlefy Stage ID for Single Elimination Playoffs)"
              class="tw-w-full sm:tw-w-1/2 tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded-xl tw-p-2.5 tw-text-xs tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
            />
          </div>

          <div class="tw-flex tw-justify-end">
            <button
              type="submit"
              class="tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-200 tw-font-semibold tw-text-xs tw-px-4 tw-py-2.5 tw-rounded-xl tw-border tw-border-slate-700 tw-transition-colors"
            >
              Save Battlefy Configuration
            </button>
          </div>
        </form>
      </div>

      <!-- Section 3: Fuzzy Participant Mapping -->
      <div class="tw-bg-[#232a2a] tw-border tw-border-slate-700/80 tw-rounded-2xl tw-p-6 tw-space-y-5">
        <div class="tw-flex tw-flex-col sm:tw-flex-row sm:tw-items-center sm:tw-justify-between tw-border-b tw-border-slate-700/70 tw-pb-3 tw-gap-3">
          <div>
            <h2 class="tw-text-lg tw-font-bold text-white tw-flex tw-items-center tw-gap-2">
              <svg class="tw-w-5 tw-h-5 tw-text-amber-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
              </svg>
              Participant Name Mapping & Suggestions
            </h2>
            <p class="tw-text-xs tw-text-slate-400 tw-mt-0.5">
              If player names in Battlefy (e.g. XiaoT#1234) differ from tournament names (e.g. XiaoT), review and map them here.
            </p>
          </div>

          <button
            phx-click="fetch_and_suggest_participants"
            class="tw-bg-sky-600 hover:tw-bg-sky-500 active:tw-bg-sky-700 tw-text-white tw-font-semibold tw-text-xs tw-px-3.5 tw-py-2 tw-rounded-xl tw-shadow"
          >
            Generate Match Suggestions from Battlefy
          </button>
        </div>

        <!-- Mappings Table -->
        <div class="tw-space-y-3">
          <div :if={map_size(@suggested_mappings) > 0} class="tw-overflow-x-auto tw-rounded-xl tw-border tw-border-slate-700/70">
            <table class="tw-w-full tw-text-left tw-border-collapse tw-text-xs tw-text-slate-300">
              <thead>
                <tr class="tw-bg-black/30 tw-text-slate-400 tw-uppercase">
                  <th class="tw-p-3">Battlefy Player Name</th>
                  <th class="tw-p-3">Suggested Bracket Contestant</th>
                  <th class="tw-p-3">Confidence</th>
                  <th class="tw-p-3">Assigned Mapping</th>
                  <th class="tw-p-3 tw-text-right">Action</th>
                </tr>
              </thead>
              <tbody class="tw-divide-y tw-divide-slate-700/70 tw-bg-[#1f2424]">
                {#for {bf_name, suggestion} <- @suggested_mappings}
                  <tr class="hover:tw-bg-slate-700/30">
                    <td class="tw-p-3 tw-font-mono text-white">{bf_name}</td>
                    <td class="tw-p-3 tw-font-medium tw-text-sky-300">
                      {suggestion.suggested_local_name || "(No match found)"}
                    </td>
                    <td class="tw-p-3">
                      <span class={[
                        "tw-px-2 tw-py-0.5 tw-rounded tw-text-[11px] tw-font-bold",
                        if(suggestion.confidence >= 0.9,
                          do: "tw-bg-emerald-950/80 tw-text-emerald-400",
                          else: "tw-bg-amber-950/80 tw-text-amber-400"
                        )
                      ]}>
                        {round(suggestion.confidence * 100)}%
                      </span>
                    </td>
                    <td class="tw-p-3">
                      <form id={"mapping_form_#{bf_name}"} phx-submit="save_participant_mapping" class="tw-flex tw-items-center tw-gap-2">
                        <input type="hidden" name="mapping[battlefy_name]" value={bf_name} />
                        <select
                          name="mapping[local_name]"
                          class="tw-bg-[#2a2a2a] tw-border tw-border-slate-700 tw-rounded tw-px-2 tw-py-1 tw-text-xs tw-text-white focus:tw-outline-none focus:tw-border-sky-500 focus:tw-ring-1 focus:tw-ring-sky-500/20"
                        >
                          <option value="">-- Unmapped --</option>
                          <option
                            :for={contestant <- @local_contestants}
                            value={contestant}
                            selected={Map.get(@participant_mappings, bf_name) == contestant || (is_nil(Map.get(@participant_mappings, bf_name)) && suggestion.suggested_local_name == contestant)}
                          >
                            {contestant}
                          </option>
                        </select>
                        <button
                          type="submit"
                          class="tw-bg-slate-800 hover:tw-bg-slate-700 tw-text-slate-200 tw-px-2.5 tw-py-1 tw-rounded tw-text-[11px] tw-font-semibold"
                        >
                          Save
                        </button>
                      </form>
                    </td>
                    <td class="tw-p-3 tw-text-right text-slate-500">
                      -
                    </td>
                  </tr>
                {/for}
              </tbody>
            </table>
          </div>

          <div :if={map_size(@suggested_mappings) == 0} class="tw-text-center tw-py-8 tw-bg-[#1b2020] tw-border tw-border-slate-700/70 tw-rounded-xl tw-text-slate-500 tw-text-xs">
            Click "Generate Match Suggestions from Battlefy" above to automatically discover and map participant names.
          </div>
        </div>
      </div>
    </div>
    """
  end
end
