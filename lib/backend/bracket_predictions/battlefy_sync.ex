defmodule Backend.BracketPredictions.BattlefySync do
  @moduledoc """
  Service module to sync tournament structures, participants, and match results from Battlefy.
  """
  require Logger
  import Ecto.Query, warn: false

  alias Backend.Infrastructure.BattlefyCommunicator
  alias Backend.Battlefy.MatchTeam
  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.FuzzyMatcher
  alias Backend.BracketPredictions.Match
  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Stage
  alias Backend.Repo

  defp communicator do
    Application.get_env(:backend, :battlefy_communicator, BattlefyCommunicator)
  end

  @doc """
  Fetches tournament summary and stages list from Battlefy.
  """
  @spec fetch_battlefy_tournament(String.t()) :: {:ok, map()} | {:error, any()}
  def fetch_battlefy_tournament(tournament_id) do
    case communicator().get_tournament(tournament_id) do
      nil ->
        {:error, :not_found}

      tournament ->
        stages =
          Enum.map(tournament.stages || [], fn stage ->
            %{
              id: stage.id,
              name: stage.name,
              bracket_type: stage.bracket && stage.bracket.type,
              style: stage.bracket && stage.bracket.style
            }
          end)

        {:ok,
         %{
           id: tournament.id,
           name: tournament.name,
           slug: tournament.slug,
           status: tournament.status,
           stages: stages
         }}
    end
  rescue
    e ->
      Logger.error("[BattlefySync] Failed to fetch tournament #{tournament_id}: #{inspect(e)}")
      {:error, e}
  end

  @doc """
  Fetches completed match results for all mapped Battlefy stage IDs,
  and updates matching local `bracket_matches`.
  Supports both multi-group GSL double elimination and single elimination playoffs.
  Returns `{:ok, updated_count}`.
  """
  @spec sync_tournament_results(Tournament.t()) :: {:ok, integer()} | {:error, any()}
  def sync_tournament_results(%Tournament{} = tournament) do
    tournament = Repo.preload(tournament, stages: :matches)
    mappings = tournament.participant_mappings || %{}
    sorted_stages = Enum.sort_by(tournament.stages, & &1.sequence)

    total_updates =
      Enum.reduce(sorted_stages, 0, fn stage, acc ->
        count =
          if stage.stage_type == "single_elimination" do
            sync_single_elim_stage(stage, mappings, tournament)
          else
            sync_group_stage(stage, mappings)
          end

        # Propagate after each stage so downstream stages have populated contestant names
        BracketPredictions.propagate_actual_results(tournament.id)
        acc + count
      end)

    {:ok, total_updates}
  end

  @doc """
  Syncs matches for a group stage (e.g. GSL Double Elimination groups).
  """
  def sync_group_stage(%Stage{} = stage, mappings) do
    stage_ids = extract_group_stage_ids(stage)

    Enum.reduce(stage_ids, 0, fn {group_name, battlefy_stage_id}, stage_acc ->
      case fetch_stage_matches(battlefy_stage_id) do
        {:ok, bf_matches} when is_list(bf_matches) ->
          apply_battlefy_matches_to_local(stage.matches, bf_matches, group_name, mappings) + stage_acc

        _ ->
          stage_acc
      end
    end)
  end

  @doc """
  Syncs matches for a single elimination playoff stage (Quarterfinals, Semifinals, Grand Finals, 3rd Place).
  """
  def sync_single_elim_stage(%Stage{} = stage, mappings, tournament) do
    battlefy_stage_id =
      (stage.config && (stage.config["battlefy_stage_id"] || stage.config[:battlefy_stage_id])) ||
        auto_detect_playoff_stage_id(tournament)

    if is_nil(battlefy_stage_id) || battlefy_stage_id == "" do
      0
    else
      case fetch_playoff_data(battlefy_stage_id) do
        {:ok, playoff_data} ->
          apply_playoff_results(stage, playoff_data, mappings, tournament)

        _ ->
          0
      end
    end
  end

  @doc """
  Attempts to auto-detect the single elimination playoff stage ID from the Battlefy tournament.
  """
  def auto_detect_playoff_stage_id(%Tournament{battlefy_tournament_id: bf_tour_id})
      when is_binary(bf_tour_id) and bf_tour_id != "" do
    case communicator().get_tournament(bf_tour_id) do
      %{stages: stages} when is_list(stages) ->
        playoff_stage =
          Enum.find(stages, fn s ->
            (s.bracket && s.bracket.type == "elimination" && s.bracket.style == "single") or
              String.contains?(String.downcase(s.name || ""), "playoff") or
              String.contains?(String.downcase(s.name || ""), "bracket") or
              String.contains?(String.downcase(s.name || ""), "single")
          end)

        if playoff_stage, do: playoff_stage.id, else: nil

      _ ->
        nil
    end
  rescue
    _ -> nil
  end

  def auto_detect_playoff_stage_id(_), do: nil

  defp extract_group_stage_ids(%Stage{config: config}) when is_map(config) do
    group_map = Map.get(config, "group_battlefy_stage_ids") || Map.get(config, :group_battlefy_stage_ids) || %{}
    Enum.map(group_map, fn {group, sid} -> {group, sid} end)
  end

  defp extract_group_stage_ids(_), do: []

  defp fetch_stage_matches(stage_id) do
    matches = communicator().get_matches(stage_id)
    {:ok, matches}
  rescue
    e ->
      Logger.warning("[BattlefySync] Error fetching matches for stage #{stage_id}: #{inspect(e)}")
      {:error, e}
  end

  defp fetch_stage_bracket(stage_id) do
    bracket = communicator().get_stage_bracket(stage_id)
    {:ok, bracket}
  rescue
    e ->
      Logger.warning("[BattlefySync] Error fetching bracket for stage #{stage_id}: #{inspect(e)}")
      {:error, e}
  end

  defp fetch_playoff_data(stage_id) do
    bracket_res = fetch_stage_bracket(stage_id)
    matches_res = fetch_stage_matches(stage_id)

    case {bracket_res, matches_res} do
      {{:ok, bracket}, {:ok, matches}} when not is_nil(bracket) and is_list(matches) ->
        {:ok, %{bracket: bracket, matches: matches}}

      {{:ok, bracket}, _} when not is_nil(bracket) ->
        {:ok, %{bracket: bracket, matches: []}}

      {_, {:ok, matches}} when is_list(matches) and matches != [] ->
        {:ok, %{bracket: nil, matches: matches}}

      _ ->
        {:error, :not_found}
    end
  end

  defp apply_playoff_results(%Stage{} = stage, playoff_data, mappings, tournament) do
    {bf_rounds, bf_third_place} = extract_playoff_rounds(playoff_data)

    local_matches =
      Match
      |> where([m], m.stage_id == ^stage.id)
      |> order_by([m], asc: m.match_order)
      |> Repo.all()

    local_ro16 = Enum.filter(local_matches, &String.contains?(&1.match_identifier, "ro16"))
    local_qfs = Enum.filter(local_matches, &String.contains?(&1.match_identifier, "qf"))
    local_sfs = Enum.filter(local_matches, &String.contains?(&1.match_identifier, "sf"))
    local_finals = Enum.filter(local_matches, &String.contains?(&1.match_identifier, "finals"))
    local_third = Enum.filter(local_matches, &String.contains?(&1.match_identifier, "third_place"))

    # Match each bracket tier to its corresponding Battlefy round by match count or round position
    bf_ro16 = Enum.find(bf_rounds, fn r -> length(r) == 8 end)
    bf_qfs = Enum.find(bf_rounds, fn r -> length(r) == 4 end)
    bf_sfs = Enum.find(bf_rounds, fn r -> length(r) == 2 end)
    bf_finals = Enum.find(bf_rounds, fn r -> length(r) == 1 end) || List.last(bf_rounds)

    champ_updates =
      0
      |> maybe_sync_round(local_ro16, bf_ro16, mappings, tournament.id)
      |> maybe_sync_round(local_qfs, bf_qfs, mappings, tournament.id)
      |> maybe_sync_round(local_sfs, bf_sfs, mappings, tournament.id)
      |> maybe_sync_round(local_finals, bf_finals, mappings, tournament.id)

    # Sync third place match if present in both local bracket and Battlefy
    third_updates =
      maybe_sync_round(0, local_third, bf_third_place, mappings, tournament.id)

    champ_updates + third_updates
  end

  defp maybe_sync_round(acc, local_matches, bf_matches, mappings, tournament_id) do
    if (Enum.any?(local_matches) and bf_matches) && Enum.any?(bf_matches) do
      round_ids = Enum.map(local_matches, & &1.id)

      current_loc_round =
        Match
        |> where([m], m.id in ^round_ids)
        |> order_by([m], asc: m.match_order)
        |> Repo.all()

      updated = sync_round_matches(current_loc_round, bf_matches, mappings)
      BracketPredictions.propagate_actual_results(tournament_id)
      acc + updated
    else
      acc
    end
  end

  defp extract_playoff_rounds(%{bracket: bracket, matches: matches}) when not is_nil(bracket) do
    rounds =
      if bracket.championship && bracket.championship.rounds do
        Enum.map(bracket.championship.rounds, & &1.matches)
      else
        []
      end

    third_place =
      if bracket.championship && bracket.championship.third_place_round do
        bracket.championship.third_place_round.matches || []
      else
        []
      end

    if Enum.empty?(rounds) and is_list(matches) and Enum.any?(matches) do
      extract_rounds_from_matches_list(matches)
    else
      {rounds, third_place}
    end
  end

  defp extract_playoff_rounds(%{matches: matches}) when is_list(matches) do
    extract_rounds_from_matches_list(matches)
  end

  defp extract_playoff_rounds(_), do: {[], []}

  defp extract_rounds_from_matches_list(matches) do
    third_place_ids =
      matches
      |> Enum.flat_map(fn m ->
        if m.next && m.next.loser && m.next.loser.match_id, do: [m.next.loser.match_id], else: []
      end)
      |> MapSet.new()

    {third_place_matches, championship_matches} =
      Enum.split_with(matches, fn m -> MapSet.member?(third_place_ids, m.id) end)

    rounds =
      championship_matches
      |> Enum.group_by(& &1.round_number)
      |> Enum.sort_by(fn {r_num, _} -> r_num end)
      |> Enum.map(fn {_, r_matches} -> Enum.sort_by(r_matches, & &1.match_number) end)

    {rounds, third_place_matches}
  end

  defp sync_round_matches(local_round_matches, bf_round_matches, mappings) do
    completed_bf =
      Enum.filter(bf_round_matches, fn m ->
        m.is_complete || (m.top && m.top.winner) || (m.bottom && m.bottom.winner)
      end)

    Enum.reduce(completed_bf, 0, fn bf_match, acc ->
      top_raw = MatchTeam.get_name(bf_match.top)
      bottom_raw = MatchTeam.get_name(bf_match.bottom)

      top_resolved = FuzzyMatcher.resolve_name(top_raw, mappings)
      bottom_resolved = FuzzyMatcher.resolve_name(bottom_raw, mappings)

      winner_resolved =
        cond do
          bf_match.top && bf_match.top.winner -> top_resolved
          bf_match.bottom && bf_match.bottom.winner -> bottom_resolved
          true -> nil
        end

      top_score = (bf_match.top && bf_match.top.score) || 0
      bottom_score = (bf_match.bottom && bf_match.bottom.score) || 0

      # Match selection order:
      # 1. Existing battlefy_match_id link
      # 2. Participant pairing match
      # 3. Bracket position index match (if uncompleted)
      match_idx = (bf_match.match_number || 1) - 1

      target_match =
        Enum.find(local_round_matches, fn lm ->
          lm.battlefy_match_id == bf_match.id or
            (match_participants_align?(lm, top_resolved, bottom_resolved) and !lm.is_complete)
        end) ||
          Enum.at(local_round_matches, match_idx)

      if target_match && winner_resolved do
        {new_top_name, new_bottom_name, aligned_top_score, aligned_bot_score} =
          align_scores_and_names(target_match, top_resolved, bottom_resolved, top_score, bottom_score)

        canonical_winner =
          cond do
            Util.equal_case_insensitive?(winner_resolved, new_top_name) -> new_top_name
            Util.equal_case_insensitive?(winner_resolved, new_bottom_name) -> new_bottom_name
            true -> winner_resolved
          end

        changes = %{
          actual_winner_name: canonical_winner,
          top_name: new_top_name,
          bottom_name: new_bottom_name,
          top_score: aligned_top_score,
          bottom_score: aligned_bot_score,
          is_complete: true,
          battlefy_match_id: bf_match.id
        }

        target_match
        |> Match.changeset(changes)
        |> Repo.update()
        |> case do
          {:ok, _} -> acc + 1
          _ -> acc
        end
      else
        acc
      end
    end)
  end

  defp apply_battlefy_matches_to_local(local_matches, bf_matches, group_name, mappings) do
    filtered_local =
      if group_name not in [nil, "", "playoffs"] do
        Enum.filter(local_matches, &(&1.group_name == group_name))
      else
        local_matches
      end

    completed_bf =
      Enum.filter(bf_matches, fn m ->
        m.is_complete || (m.top && m.top.winner) || (m.bottom && m.bottom.winner)
      end)

    Enum.reduce(completed_bf, 0, fn bf_match, acc ->
      top_raw = MatchTeam.get_name(bf_match.top)
      bottom_raw = MatchTeam.get_name(bf_match.bottom)

      top_resolved = FuzzyMatcher.resolve_name(top_raw, mappings)
      bottom_resolved = FuzzyMatcher.resolve_name(bottom_raw, mappings)

      winner_resolved =
        cond do
          bf_match.top && bf_match.top.winner -> top_resolved
          bf_match.bottom && bf_match.bottom.winner -> bottom_resolved
          true -> nil
        end

      top_score = (bf_match.top && bf_match.top.score) || 0
      bottom_score = (bf_match.bottom && bf_match.bottom.score) || 0

      target_match =
        Enum.find(filtered_local, fn lm ->
          lm.battlefy_match_id == bf_match.id or
            (match_participants_align?(lm, top_resolved, bottom_resolved) and !lm.is_complete)
        end)

      if target_match && winner_resolved do
        {new_top_name, new_bottom_name, aligned_top_score, aligned_bot_score} =
          align_scores_and_names(target_match, top_resolved, bottom_resolved, top_score, bottom_score)

        canonical_winner =
          cond do
            Util.equal_case_insensitive?(winner_resolved, new_top_name) -> new_top_name
            Util.equal_case_insensitive?(winner_resolved, new_bottom_name) -> new_bottom_name
            true -> winner_resolved
          end

        changes = %{
          actual_winner_name: canonical_winner,
          top_name: new_top_name,
          bottom_name: new_bottom_name,
          top_score: aligned_top_score,
          bottom_score: aligned_bot_score,
          is_complete: true,
          battlefy_match_id: bf_match.id
        }

        target_match
        |> Match.changeset(changes)
        |> Repo.update()
        |> case do
          {:ok, _} -> acc + 1
          _ -> acc
        end
      else
        acc
      end
    end)
  end

  @doc """
  Aligns scores and names between Battlefy and a local match, accounting for
  possible inversion of top and bottom positions.
  """
  def align_scores_and_names(target_match, top_resolved, bottom_resolved, top_score, bottom_score) do
    cond do
      Util.equal_case_insensitive?(target_match.top_name, bottom_resolved) or
          Util.equal_case_insensitive?(target_match.bottom_name, top_resolved) ->
        new_top = target_match.top_name || bottom_resolved
        new_bottom = target_match.bottom_name || top_resolved
        {new_top, new_bottom, bottom_score, top_score}

      true ->
        new_top = target_match.top_name || top_resolved
        new_bottom = target_match.bottom_name || bottom_resolved
        {new_top, new_bottom, top_score, bottom_score}
    end
  end

  defp match_participants_align?(local_match, top_res, bottom_res) do
    lt = local_match.top_name
    lb = local_match.bottom_name

    (Util.equal_case_insensitive?(lt, top_res) and Util.equal_case_insensitive?(lb, bottom_res)) or
      (Util.equal_case_insensitive?(lt, bottom_res) and Util.equal_case_insensitive?(lb, top_res)) or
      (is_nil(lt) and (Util.equal_case_insensitive?(lb, top_res) or Util.equal_case_insensitive?(lb, bottom_res)) and
         not is_nil(lb)) or
      (is_nil(lb) and (Util.equal_case_insensitive?(lt, top_res) or Util.equal_case_insensitive?(lt, bottom_res)) and
         not is_nil(lt))
  end
end
