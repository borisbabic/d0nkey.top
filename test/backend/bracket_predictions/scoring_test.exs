defmodule Backend.BracketPredictions.ScoringTest do
  use ExUnit.Case, async: true
  alias Backend.BracketPredictions.Scoring
  alias Backend.BracketPredictions.Match
  alias Backend.BracketPredictions.Pick
  alias Backend.BracketPredictions.Entry
  alias Backend.BracketPredictions.Tournament

  describe "grade_pick/3" do
    test "flat scoring awards 1 point for correctly predicting winner regardless of loser" do
      tour = %Tournament{
        scoring_strategy: "flat",
        scoring_config: %{"flat_points" => 1}
      }

      match = %Match{
        id: 1,
        top_name: "XiaoT",
        bottom_name: "Definition",
        top_score: 3,
        bottom_score: 1,
        actual_winner_name: "XiaoT",
        is_complete: true,
        round_number: 1
      }

      # User predicted XiaoT vs Tansoku (different loser), picked XiaoT
      pick = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "XiaoT",
        predicted_bottom_name: "Tansoku"
      }

      result = Scoring.grade_pick(pick, match, tour)
      assert result.is_correct == true
      assert result.points_awarded == 1
    end

    test "awards exact score bonus when user predicted exact scores" do
      tour = %Tournament{
        scoring_strategy: "flat",
        predict_scores: true,
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 2}
      }

      match = %Match{
        id: 1,
        top_name: "XiaoT",
        bottom_name: "Definition",
        top_score: 3,
        bottom_score: 2,
        actual_winner_name: "XiaoT",
        is_complete: true,
        round_number: 1
      }

      # Correct winner AND exact scores (3-2)
      pick_correct_score = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "XiaoT",
        predicted_bottom_name: "Definition",
        predicted_top_score: 3,
        predicted_bottom_score: 2
      }

      result = Scoring.grade_pick(pick_correct_score, match, tour)
      assert result.is_correct == true
      assert result.exact_score_correct == true
      # 1 base + 2 score bonus = 3 points
      assert result.points_awarded == 3

      # Correct winner but WRONG scores (3-0)
      pick_wrong_score = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "XiaoT",
        predicted_bottom_name: "Definition",
        predicted_top_score: 3,
        predicted_bottom_score: 0
      }

      result2 = Scoring.grade_pick(pick_wrong_score, match, tour)
      assert result2.is_correct == true
      assert result2.exact_score_correct == false
      assert result2.points_awarded == 1
    end

    test "awards exact score bonus when user predicted winner on bottom instead of top" do
      tour = %Tournament{
        scoring_strategy: "flat",
        predict_scores: true,
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 2}
      }

      # Actual match: XiaoT (top) won 3-1 against Definition (bottom)
      match = %Match{
        id: 1,
        top_name: "XiaoT",
        bottom_name: "Definition",
        top_score: 3,
        bottom_score: 1,
        actual_winner_name: "XiaoT",
        is_complete: true,
        round_number: 2
      }

      # User predicted XiaoT on bottom with score 3, and Definition on top with score 1
      pick_inverted_same_opponents = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "Definition",
        predicted_bottom_name: "XiaoT",
        predicted_top_score: 1,
        predicted_bottom_score: 3
      }

      result = Scoring.grade_pick(pick_inverted_same_opponents, match, tour)
      assert result.is_correct == true
      assert result.exact_score_correct == true
      assert result.points_awarded == 3

      # User predicted XiaoT on bottom with score 3, but against Tansoku (due to previous results)
      pick_inverted_different_opponent = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "Tansoku",
        predicted_bottom_name: "XiaoT",
        predicted_top_score: 1,
        predicted_bottom_score: 3
      }

      result2 = Scoring.grade_pick(pick_inverted_different_opponent, match, tour)
      assert result2.is_correct == true
      assert result2.exact_score_correct == true
      assert result2.points_awarded == 3
    end

    test "awards exact score bonus when user predicted winner on top and actual winner is on bottom" do
      tour = %Tournament{
        scoring_strategy: "flat",
        predict_scores: true,
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 2}
      }

      # Actual match: Definition (top) lost 1-3 to XiaoT (bottom)
      match = %Match{
        id: 1,
        top_name: "Definition",
        bottom_name: "XiaoT",
        top_score: 1,
        bottom_score: 3,
        actual_winner_name: "XiaoT",
        is_complete: true,
        round_number: 2
      }

      # User predicted XiaoT on top with score 3-1
      pick_top = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "XiaoT",
        predicted_bottom_name: "Tansoku",
        predicted_top_score: 3,
        predicted_bottom_score: 1
      }

      result = Scoring.grade_pick(pick_top, match, tour)
      assert result.is_correct == true
      assert result.exact_score_correct == true
      assert result.points_awarded == 3
    end

    test "does not award exact score bonus when tournament has predict_scores: false" do
      tour = %Tournament{
        scoring_strategy: "flat",
        predict_scores: false,
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 2}
      }

      match = %Match{
        id: 1,
        top_name: "XiaoT",
        bottom_name: "Definition",
        top_score: 3,
        bottom_score: 2,
        actual_winner_name: "XiaoT",
        is_complete: true,
        round_number: 1
      }

      pick = %Pick{
        match_id: 1,
        picked_winner_name: "XiaoT",
        predicted_top_name: "XiaoT",
        predicted_bottom_name: "Definition",
        predicted_top_score: 3,
        predicted_bottom_score: 2
      }

      result = Scoring.grade_pick(pick, match, tour)
      assert result.is_correct == true
      assert result.exact_score_correct == false
      # Only 1 base point, no bonus
      assert result.points_awarded == 1
    end

    test "round-weighted scoring scales points by round" do
      tour = %Tournament{
        scoring_strategy: "round_weighted",
        scoring_config: %{"round_weights" => %{"1" => 1, "2" => 2, "3" => 4, "4" => 8}}
      }

      m_round_3 = %Match{
        id: 2,
        actual_winner_name: "PocketTrain",
        is_complete: true,
        round_number: 3
      }

      pick = %Pick{
        match_id: 2,
        picked_winner_name: "PocketTrain"
      }

      result = Scoring.grade_pick(pick, m_round_3, tour)
      assert result.is_correct == true
      assert result.points_awarded == 4
    end

    test "exact matchup bonus awards extra point when opponents match" do
      tour = %Tournament{
        scoring_strategy: "flat",
        scoring_config: %{"flat_points" => 1, "exact_matchup_bonus" => 1}
      }

      match = %Match{
        id: 3,
        top_name: "PlayerA",
        bottom_name: "PlayerB",
        actual_winner_name: "PlayerA",
        is_complete: true,
        round_number: 1
      }

      pick = %Pick{
        match_id: 3,
        picked_winner_name: "PlayerA",
        predicted_top_name: "PlayerA",
        predicted_bottom_name: "PlayerB"
      }

      result = Scoring.grade_pick(pick, match, tour)
      assert result.is_correct == true
      # 1 base + 1 matchup bonus = 2
      assert result.points_awarded == 2
    end
  end

  describe "rank_entries/1" do
    test "sorts entries by total score and applies tiebreakers" do
      e1 = %Entry{
        id: 1,
        total_score: 10,
        submitted_at: ~N[2026-09-01 12:00:00],
        picks: [%Pick{exact_score_correct: false, is_correct: true}]
      }

      e2 = %Entry{
        id: 2,
        total_score: 12,
        submitted_at: ~N[2026-09-01 13:00:00],
        picks: [%Pick{exact_score_correct: true, is_correct: true}]
      }

      # Same score as e1, but has 1 exact score correct
      e3 = %Entry{
        id: 3,
        total_score: 10,
        submitted_at: ~N[2026-09-01 14:00:00],
        picks: [%Pick{exact_score_correct: true, is_correct: true}]
      }

      ranked = Scoring.rank_entries([e1, e2, e3])
      ids_in_order = Enum.map(ranked, & &1.id)
      ranks = Enum.map(ranked, & &1.rank)

      # e2 has 12 pts (rank 1), e3 has 10 pts + 1 exact score (rank 2), e1 has 10 pts + 0 exact score (rank 3)
      assert ids_in_order == [2, 3, 1]
      assert ranks == [1, 2, 3]
    end
  end
end
