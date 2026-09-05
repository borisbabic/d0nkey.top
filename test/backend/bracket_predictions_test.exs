defmodule Backend.BracketPredictionsTest do
  use Backend.DataCase
  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament

  setup do
    user = create_temp_user(%{battletag: "Tester#1234"})
    {:ok, user: user}
  end

  describe "create_gsl_into_single_elim_tournament/3" do
    test "creates complete multi-stage tournament with wired matches", %{user: user} do
      tour_attrs = %{
        name: "Test Championship",
        creator_id: user.id,
        predict_scores: true,
        scoring_strategy: "flat",
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 1}
      }

      groups_data = [
        %{name: "Group A", participants: ["A1", "A2", "A3", "A4"]},
        %{name: "Group B", participants: ["B1", "B2", "B3", "B4"]}
      ]

      assert {:ok, %Tournament{} = tournament} =
               BracketPredictions.create_gsl_into_single_elim_tournament(tour_attrs, groups_data,
                 has_third_place_match: true
               )

      assert length(tournament.stages) == 2

      stage_1 = Enum.find(tournament.stages, &(&1.sequence == 1))
      stage_2 = Enum.find(tournament.stages, &(&1.sequence == 2))

      assert stage_1.stage_type == "double_elimination_groups"
      assert stage_2.stage_type == "single_elimination"

      # Stage 1 has 5 matches per group * 2 groups = 10 matches
      assert length(stage_1.matches) == 10

      # Stage 2 has 2 Semifinals + 1 3rd Place Match + 1 Grand Finals = 4 matches
      assert length(stage_2.matches) == 4

      # Verify seeding (neighboring pairs)
      g1_m1 = Enum.find(stage_1.matches, &(&1.match_identifier == "g1_opening_1"))
      assert g1_m1.top_name == "A1"
      assert g1_m1.bottom_name == "A2"

      g1_m2 = Enum.find(stage_1.matches, &(&1.match_identifier == "g1_opening_2"))
      assert g1_m2.top_name == "A3"
      assert g1_m2.bottom_name == "A4"

      # Verify stage advancement linkage in playoffs
      sf1 = Enum.find(stage_2.matches, &(&1.match_identifier == "playoffs_sf_1"))
      assert sf1.top_source_type == "stage_advancement"
      assert sf1.top_source_identifier == "g1_winners"
      assert sf1.bottom_source_type == "stage_advancement"
      assert sf1.bottom_source_identifier == "g2_decider"

      # Verify 3rd place match linkage
      third = Enum.find(stage_2.matches, &(&1.match_identifier == "playoffs_third_place"))
      assert third.top_source_type == "loser_of"
      assert third.top_source_identifier == "playoffs_sf_1"
    end
  end

  describe "user predictions and scoring flow" do
    test "saves user predictions and grades entries on match completion", %{user: user} do
      assert {:ok, tournament} =
               BracketPredictions.create_gsl_into_single_elim_tournament(
                 %{name: "Spring Clash", creator_id: user.id},
                 [%{name: "Group A", participants: ["Alpha", "Beta", "Gamma", "Delta"]}],
                 has_third_place_match: false
               )

      # User makes picks in Group A
      picks_map = %{
        "g1_opening_1" => "Alpha",
        "g1_opening_2" => "Gamma",
        "g1_winners" => "Alpha",
        "g1_elim" => "Beta",
        "g1_decider" => "Beta"
      }

      assert {:ok, entry} = BracketPredictions.save_entry_predictions(tournament, user, picks_map)
      assert entry.total_score == 0
      assert length(entry.picks) == 5

      # Verify pick content
      opening_pick = Enum.find(entry.picks, &(&1.match.match_identifier == "g1_opening_1"))
      assert opening_pick.picked_winner_name == "Alpha"

      # Manual result: Opening 1 completes with Alpha winning 3-0
      opening_match = Enum.find(tournament.matches, &(&1.match_identifier == "g1_opening_1"))
      BracketPredictions.enter_manual_match_result(opening_match.id, "Alpha", 3, 0)

      # Check leaderboard
      [ranked_entry] = BracketPredictions.list_entries_for_tournament(tournament.id)
      assert ranked_entry.total_score == 1
      assert ranked_entry.rank == 1

      graded_opening_pick = Enum.find(ranked_entry.picks, &(&1.match_id == opening_match.id))
      assert graded_opening_pick.is_correct == true
      assert graded_opening_pick.points_awarded == 1
    end

    test "enforces deadline: prevents new submissions and updates once deadline has passed", %{user: user} do
      future_deadline = NaiveDateTime.utc_now() |> NaiveDateTime.add(3600, :second)

      assert {:ok, tournament} =
               BracketPredictions.create_gsl_into_single_elim_tournament(
                 %{name: "Deadline Cup", creator_id: user.id, prediction_deadline: future_deadline},
                 [%{name: "Group A", participants: ["Alpha", "Beta", "Gamma", "Delta"]}],
                 has_third_place_match: false
               )

      # 1. Predictions succeed before deadline
      picks_map = %{"g1_opening_1" => "Alpha"}
      assert {:ok, entry} = BracketPredictions.save_entry_predictions(tournament, user, picks_map)
      assert length(entry.picks) == 1

      # 2. Advance deadline into the past in the database
      past_deadline = NaiveDateTime.utc_now() |> NaiveDateTime.add(-3600, :second)

      {:ok, expired_tournament} =
        BracketPredictions.update_tournament(tournament, %{prediction_deadline: past_deadline})

      assert Tournament.deadline_passed?(expired_tournament) == true
      assert Tournament.open_for_predictions?(expired_tournament) == false

      # 3. Existing user attempts to update predictions after deadline
      updated_picks = %{"g1_opening_1" => "Beta"}

      assert {:error, :predictions_closed} =
               BracketPredictions.save_entry_predictions(expired_tournament, user, updated_picks)

      # Verify existing picks remain unchanged
      refreshed_entry = BracketPredictions.get_entry!(entry.id)
      opening_pick = Enum.find(refreshed_entry.picks, &(&1.match.match_identifier == "g1_opening_1"))
      assert opening_pick.picked_winner_name == "Alpha"

      # 4. New user attempts to make predictions after deadline
      user2 = create_temp_user(%{battletag: "LatePredictor#9999"})

      assert {:error, :predictions_closed} =
               BracketPredictions.save_entry_predictions(expired_tournament, user2, %{"g1_opening_1" => "Beta"})

      assert is_nil(BracketPredictions.get_user_entry(tournament.id, user2.id))
    end
  end

  describe "Tournament deadline helpers" do
    test "deadline_passed?/1 and open_for_predictions?/1" do
      now = NaiveDateTime.utc_now()
      future = NaiveDateTime.add(now, 3600, :second)
      past = NaiveDateTime.add(now, -3600, :second)

      # Nil deadline: open, not passed
      t_nil = %Tournament{status: "open", prediction_deadline: nil}
      assert Tournament.open_for_predictions?(t_nil) == true
      assert Tournament.deadline_passed?(t_nil) == false

      # Future deadline: open, not passed
      t_future = %Tournament{status: "open", prediction_deadline: future}
      assert Tournament.open_for_predictions?(t_future) == true
      assert Tournament.deadline_passed?(t_future) == false

      # Past deadline: closed, passed
      t_past = %Tournament{status: "open", prediction_deadline: past}
      assert Tournament.open_for_predictions?(t_past) == false
      assert Tournament.deadline_passed?(t_past) == true

      # Locked status even with future deadline: closed, not passed
      t_locked = %Tournament{status: "locked", prediction_deadline: future}
      assert Tournament.open_for_predictions?(t_locked) == false
      assert Tournament.deadline_passed?(t_locked) == false
    end
  end
end
