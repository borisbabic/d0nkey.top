defmodule Backend.BracketPredictions.Scoring do
  @moduledoc """
  Scoring and leaderboard calculation engine for bracket prediction tournaments.

  Supports:
  - Flat scoring (1 point default per correctly predicted match winner).
  - Round-weighted scoring (points scale with tournament rounds).
  - Exact matchup bonus (bonus for correctly predicting both participants).
  - Exact score prediction bonus (bonus for correctly predicting game scores, e.g. 3-1).
  - Tiebreakers and live leaderboard ranking.
  """

  alias Backend.BracketPredictions.Match
  alias Backend.BracketPredictions.Pick
  alias Backend.BracketPredictions.Entry
  alias Backend.BracketPredictions.Tournament

  @doc """
  Evaluates a single pick against the match's actual result and tournament scoring rules.
  Returns `%{is_correct: boolean, exact_score_correct: boolean, points_awarded: integer}`.
  """
  @spec grade_pick(Pick.t(), Match.t(), Tournament.t()) :: map()
  def grade_pick(pick, match, tournament) do
    if match.is_complete and match.actual_winner_name do
      winner_correct? = pick.picked_winner_name == match.actual_winner_name
      predict_scores? = tournament.predict_scores == true

      exact_score? =
        predict_scores? and
          winner_correct? and
          is_integer(pick.predicted_top_score) and is_integer(pick.predicted_bottom_score) and
          is_integer(match.top_score) and is_integer(match.bottom_score) and
          pick.predicted_top_score == match.top_score and
          pick.predicted_bottom_score == match.bottom_score

      points =
        if winner_correct? do
          base_points = calculate_base_points(match, tournament)
          matchup_bonus = calculate_matchup_bonus(pick, match, tournament)
          score_bonus = if predict_scores? and exact_score?, do: get_config(tournament, "exact_score_bonus", 0), else: 0

          base_points + matchup_bonus + score_bonus
        else
          0
        end

      %{
        is_correct: winner_correct?,
        exact_score_correct: if(predict_scores?, do: exact_score?, else: false),
        points_awarded: points
      }
    else
      %{
        is_correct: nil,
        exact_score_correct: nil,
        points_awarded: 0
      }
    end
  end

  defp calculate_base_points(match, tournament) do
    case tournament.scoring_strategy do
      "round_weighted" ->
        round_weights = get_config(tournament, "round_weights", %{})
        round_key = to_string(match.round_number)
        Map.get(round_weights, round_key) || Map.get(round_weights, match.round_number) || match.round_number || 1

      _ ->
        get_config(tournament, "flat_points", 1)
    end
  end

  defp calculate_matchup_bonus(pick, match, tournament) do
    bonus = get_config(tournament, "exact_matchup_bonus", 0)

    has_matchup_names? =
      not is_nil(pick.predicted_top_name) &&
        not is_nil(pick.predicted_bottom_name) &&
        not is_nil(match.top_name) &&
        not is_nil(match.bottom_name)

    if bonus > 0 && has_matchup_names? do
      matchup_matched? =
        (pick.predicted_top_name == match.top_name && pick.predicted_bottom_name == match.bottom_name) ||
          (pick.predicted_top_name == match.bottom_name && pick.predicted_bottom_name == match.top_name)

      if matchup_matched?, do: bonus, else: 0
    else
      0
    end
  end

  defp get_config(%Tournament{scoring_config: config}, key, default) when is_map(config) do
    Map.get(config, key) || Map.get(config, to_string(key)) || default
  end

  defp get_config(_, _, default), do: default

  @doc """
  Computes the total score and pick stats for an entry given its picks and the tournament matches.
  """
  @spec grade_entry(Entry.t(), [Match.t()], Tournament.t()) :: {integer(), [Pick.t()]}
  def grade_entry(entry, matches, tournament) do
    matches_map = Map.new(matches, &{&1.id, &1})

    graded_picks =
      Enum.map(entry.picks || [], fn pick ->
        match = Map.get(matches_map, pick.match_id)

        if match do
          result = grade_pick(pick, match, tournament)
          Map.merge(pick, result)
        else
          pick
        end
      end)

    total_score = Enum.sum(Enum.map(graded_picks, &(&1.points_awarded || 0)))
    {total_score, graded_picks}
  end

  @doc """
  Ranks a list of entries using tiebreakers:
  1. Total score descending
  2. Exact scores correct count descending
  3. Correct winners count descending
  4. Submitted at ascending (earlier submission wins tie)
  """
  @spec rank_entries([Entry.t()]) :: [Entry.t()]
  def rank_entries(entries) do
    entries
    |> Enum.sort_by(
      fn entry ->
        exact_scores_count = Enum.count(entry.picks || [], &(&1.exact_score_correct == true))
        correct_winners_count = Enum.count(entry.picks || [], &(&1.is_correct == true))
        submitted_time = if entry.submitted_at, do: NaiveDateTime.to_iso8601(entry.submitted_at), else: "9999-99-99"

        {-entry.total_score, -exact_scores_count, -correct_winners_count, submitted_time}
      end,
      :asc
    )
    |> Enum.with_index(1)
    |> Enum.map(fn {entry, rank} ->
      Map.put(entry, :rank, rank)
    end)
  end
end
