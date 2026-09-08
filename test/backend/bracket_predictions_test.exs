defmodule Backend.BracketPredictionsTest do
  use Backend.DataCase
  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament
  alias Backend.BracketPredictions.Entry
  alias Backend.BracketPredictions.Pick
  alias Backend.UserManager.User

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

  describe "Tournament.can_manage?/2 and creator?/2" do
    test "creator can manage the tournament" do
      creator = %User{id: 42, admin_roles: []}
      tournament = %Tournament{creator_id: 42}

      assert Tournament.creator?(tournament, creator) == true
      assert Tournament.can_manage?(tournament, creator) == true
    end

    test "super admin can manage any tournament" do
      super_user = %User{id: 99, admin_roles: ["super"]}
      tournament = %Tournament{creator_id: 42}

      assert Tournament.creator?(tournament, super_user) == false
      assert Tournament.can_manage?(tournament, super_user) == true
    end

    test "regular user cannot manage another user's tournament" do
      other_user = %User{id: 10, admin_roles: []}
      tournament = %Tournament{creator_id: 42}

      assert Tournament.creator?(tournament, other_user) == false
      assert Tournament.can_manage?(tournament, other_user) == false
    end

    test "user with only bracket_predictions role cannot manage another user's tournament" do
      bp_user = %User{id: 10, admin_roles: ["bracket_predictions"]}
      tournament = %Tournament{creator_id: 42}

      assert Tournament.creator?(tournament, bp_user) == false
      assert Tournament.can_manage?(tournament, bp_user) == false
    end

    test "unauthenticated visitor (nil user) cannot manage" do
      tournament = %Tournament{creator_id: 42}

      assert Tournament.creator?(tournament, nil) == false
      assert Tournament.can_manage?(tournament, nil) == false
    end

    test "tournament without creator_id cannot be managed by regular user" do
      user = %User{id: 42, admin_roles: []}
      tournament = %Tournament{creator_id: nil}

      assert Tournament.creator?(tournament, user) == false
      assert Tournament.can_manage?(tournament, user) == false
    end
  end

  describe "pick statistics and champion pick calculations" do
    test "get_match_pick_stats/1 aggregates contestant picks and computes percentages", %{user: creator} do
      {:ok, tournament} =
        BracketPredictions.create_gsl_into_single_elim_tournament(
          %{name: "Stats Tour", creator_id: creator.id},
          [%{name: "Group A", participants: ["P1", "P2", "P3", "P4"]}],
          has_third_place_match: false
        )

      user1 = create_temp_user(%{battletag: "User1#1111"})
      user2 = create_temp_user(%{battletag: "User2#2222"})
      user3 = create_temp_user(%{battletag: "User3#3333"})

      # user1 and user2 pick P1, user3 picks P2 for g1_opening_1
      BracketPredictions.save_entry_predictions(tournament, user1, %{"g1_opening_1" => "P1"})
      BracketPredictions.save_entry_predictions(tournament, user2, %{"g1_opening_1" => "P1"})
      BracketPredictions.save_entry_predictions(tournament, user3, %{"g1_opening_1" => "P2"})

      stats = BracketPredictions.get_match_pick_stats(tournament.id)
      opening_stats = Map.get(stats, "g1_opening_1")

      assert opening_stats != nil
      assert opening_stats.total_picks == 3
      assert opening_stats.by_player["P1"].count == 2
      assert opening_stats.by_player["P1"].percentage == 66.7
      assert opening_stats.by_player["P2"].count == 1
      assert opening_stats.by_player["P2"].percentage == 33.3
    end

    test "get_champion_pick_stats/1 calculates champion pick % out of all who submitted final match pick", %{
      user: creator
    } do
      {:ok, tournament} =
        BracketPredictions.create_gsl_into_single_elim_tournament(
          %{name: "Champ Tour", creator_id: creator.id},
          [
            %{name: "Group A", participants: ["A1", "A2", "A3", "A4"]},
            %{name: "Group B", participants: ["B1", "B2", "B3", "B4"]}
          ],
          has_third_place_match: false
        )

      user1 = create_temp_user(%{battletag: "ChampU1#1111"})
      user2 = create_temp_user(%{battletag: "ChampU2#2222"})
      user3 = create_temp_user(%{battletag: "ChampU3#3333"})
      user_no_final = create_temp_user(%{battletag: "Incomplete#4444"})

      final_match = BracketPredictions.get_final_match(tournament)
      opening_match = Enum.find(tournament.matches, &(&1.match_identifier == "g1_opening_1"))

      entry1 = %Entry{tournament_id: tournament.id, user_id: user1.id, name: "U1"} |> Repo.insert!()
      entry2 = %Entry{tournament_id: tournament.id, user_id: user2.id, name: "U2"} |> Repo.insert!()
      entry3 = %Entry{tournament_id: tournament.id, user_id: user3.id, name: "U3"} |> Repo.insert!()
      entry_no_final = %Entry{tournament_id: tournament.id, user_id: user_no_final.id, name: "U4"} |> Repo.insert!()

      # user1 and user2 pick A1 to win the finals
      %Pick{entry_id: entry1.id, match_id: final_match.id, picked_winner_name: "A1"} |> Repo.insert!()
      %Pick{entry_id: entry2.id, match_id: final_match.id, picked_winner_name: "A1"} |> Repo.insert!()
      # user3 picks B1 to win the finals
      %Pick{entry_id: entry3.id, match_id: final_match.id, picked_winner_name: "B1"} |> Repo.insert!()
      # user_no_final only picked group match, didn't pick finals
      %Pick{entry_id: entry_no_final.id, match_id: opening_match.id, picked_winner_name: "A1"} |> Repo.insert!()

      champ_stats = BracketPredictions.get_champion_pick_stats(tournament.id)

      # Only 3 submitted a final match pick!
      assert champ_stats.total_final_picks == 3
      assert length(champ_stats.stats) == 2

      [first, second] = champ_stats.stats
      assert first.player_name == "A1"
      assert first.count == 2
      assert first.percentage == 66.7

      assert second.player_name == "B1"
      assert second.count == 1
      assert second.percentage == 33.3
    end
  end
end
