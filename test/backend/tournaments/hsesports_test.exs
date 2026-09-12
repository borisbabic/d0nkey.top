defmodule Backend.Tournaments.HSEsportsTest do
  use BackendWeb.ConnCase
  alias Backend.Tournaments
  alias Backend.Tournaments.HSEsports
  alias Backend.Tournaments.HSEsports.Tournament
  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.Tournament, as: PredTournament
  alias Backend.BracketPredictions.Stage
  alias Backend.BracketPredictions.Match, as: PredMatch
  alias Backend.Repo
  alias Backend.Tournaments.HSEsportsFixtures

  setup do
    HSEsports.load_csv(HSEsportsFixtures.sample_csv(), "wc_2026")
    :ok
  end

  describe "HSEsports in-memory state" do
    test "retrieves the loaded tournament struct" do
      t = HSEsports.get_tournament("wc_2026")

      assert %Tournament{} = t
      assert t.id == "wc_2026"
      assert t.name == "Hearthstone World Championship 2026"
      assert is_list(t.groups)
      assert length(t.groups) == 4
      assert is_list(t.playoffs)
      assert length(t.playoffs) == 7
    end

    test "get_groups/1 and get_playoffs/1 return parsed groups and playoffs" do
      groups = HSEsports.get_groups("wc_2026")
      playoffs = HSEsports.get_playoffs("wc_2026")

      assert length(groups) == 4
      assert length(playoffs) == 7
    end

    test "match_stats/1 returns match stats list" do
      assert {:ok, stats} = HSEsports.match_stats("wc_2026")
      assert is_list(stats)
    end

    test "load_csv/2 dynamically parses and updates the tournament in ETS" do
      csv = """
      Stage,Match #,Game #,Player 1,P1 Deck Used,Player 2,P2 Deck Used,Winner,Bans
      Group A,Initial Match 1,1,PlayerA,Druid,PlayerB,Mage,PlayerA,P1 Ban
      ,,2,PlayerA,Druid,PlayerB,Mage,PlayerA,Hunter
      ,,3,PlayerA,Druid,PlayerB,Mage,PlayerA,P2 Ban
      """

      assert {:ok, _t} = HSEsports.load_csv(csv, "wc_2026_test")

      loaded = HSEsports.get_tournament("wc_2026_test")
      assert loaded.id == "wc_2026_test"
      match = Enum.find(loaded.matches, &(&1.match_identifier == "g1_opening_1"))
      assert match.actual_winner_name == "PlayerA"
      assert match.top_score == 3
      assert match.bottom_score == 0
    end
  end

  describe "HSEsports.Parser 3rd place match handling" do
    test "works when CSV does not contain a 3rd place match (7 playoff matches)" do
      assert {:ok, parsed} = HSEsports.Parser.parse(HSEsportsFixtures.sample_csv())
      assert length(parsed.playoffs) == 7
      match_ids = Enum.map(parsed.playoffs, & &1.match_identifier)
      refute "playoffs_third_place" in match_ids
      assert "playoffs_finals" in match_ids

      finals = Enum.find(parsed.playoffs, &(&1.match_identifier == "playoffs_finals"))
      assert finals.match_order == 108
    end

    test "works when CSV contains a 3rd place match (8 playoff matches)" do
      csv_with_third =
        HSEsportsFixtures.sample_csv() <>
          """
          BlizzCon Finals,3rd Place Match,1,PlayerA,Mage,PlayerB,Druid,PlayerA,P1 Ban
          ,,2,PlayerA,Mage,PlayerB,Druid,PlayerA,
          ,,3,PlayerA,Mage,PlayerB,Druid,PlayerA,P2 Ban
          """

      assert {:ok, parsed} = HSEsports.Parser.parse(csv_with_third)
      assert length(parsed.playoffs) == 8

      third = Enum.find(parsed.playoffs, &(&1.match_identifier == "playoffs_third_place"))
      assert third != nil
      assert third.round_name == "3rd Place Match"
      assert third.match_order == 107
      assert third.top_source_type == "loser_of"
      assert third.top_source_identifier == "playoffs_sf_1"
      assert third.bottom_source_type == "loser_of"
      assert third.bottom_source_identifier == "playoffs_sf_2"

      finals = Enum.find(parsed.playoffs, &(&1.match_identifier == "playoffs_finals"))
      assert finals.match_order == 108
    end
  end

  describe "bracket_prediction_ids parsing" do
    test "parses comma-separated strings of integers" do
      assert HSEsports.bracket_prediction_ids("1, 2, 3") == [1, 2, 3]
      assert HSEsports.bracket_prediction_ids(" 10 , 20 , 30 ") == [10, 20, 30]
    end

    test "handles strings with non-numeric or empty tokens" do
      assert HSEsports.bracket_prediction_ids("10, invalid, , 20") == [10, 20]
    end

    test "handles single integer" do
      assert HSEsports.bracket_prediction_ids(42) == [42]
    end

    test "handles list of integers or numeric strings" do
      assert HSEsports.bracket_prediction_ids([1, "2", 3]) == [1, 2, 3]
    end

    test "handles nil and empty strings" do
      assert HSEsports.bracket_prediction_ids(nil) == []
      assert HSEsports.bracket_prediction_ids("") == []
      assert HSEsports.bracket_prediction_ids("   ") == []
    end
  end

  describe "Tournaments module integration" do
    test "Backend.Tournaments.get_tournament/1 works for hsesports source" do
      t = Tournaments.get_tournament({"hsesports", "wc_2026"})
      assert %Tournament{} = t
      assert t.id == "wc_2026"
    end

    test "Backend.Tournaments.match_stats_and_awt/2 returns stats and :bo5" do
      assert {stats, :bo5} = Tournaments.match_stats_and_awt("hsesports", "wc_2026")
      assert is_list(stats)
    end

    test "Backend.Tournaments.archetype_stats/2 returns archetype stats" do
      assert {:ok, %{archetype_stats: _stats, adjusted_winrate_type: :bo5}} =
               Tournaments.archetype_stats("hsesports", "wc_2026")
    end
  end

  describe "Bracket prediction syncing" do
    test "sync_bracket_prediction/1 updates matching bracket prediction matches" do
      if pid = Process.whereis(Backend.Tournaments.HSEsports) do
        Ecto.Adapters.SQL.Sandbox.allow(Backend.Repo, self(), pid)
      end

      pred_t =
        %PredTournament{
          name: "WC 2026 Test Prediction",
          status: "open",
          slug: "wc-2026-sync-test",
          scoring_strategy: "flat",
          scoring_config: %{"points_per_match" => 1},
          participant_mappings: %{}
        }
        |> Repo.insert!()

      stage =
        %Stage{
          tournament_id: pred_t.id,
          name: "Group A",
          stage_type: "double_elimination_groups",
          sequence: 1
        }
        |> Repo.insert!()

      match =
        %PredMatch{
          tournament_id: pred_t.id,
          stage_id: stage.id,
          match_identifier: "g1_opening_1",
          round_name: "Group A - Opening 1",
          round_number: 1,
          match_order: 1,
          top_name: "McBanterFace",
          bottom_name: "Soyorin",
          top_score: 0,
          bottom_score: 0,
          is_complete: false
        }
        |> Repo.insert!()

      assert {:ok, updated_count} = HSEsports.sync_bracket_prediction(pred_t.id)
      assert updated_count >= 1

      reloaded_match = Repo.get!(PredMatch, match.id)
      assert reloaded_match.top_score == 2
      assert reloaded_match.bottom_score == 3
      assert reloaded_match.actual_winner_name == "Soyorin"
      assert reloaded_match.is_complete == true
    end

    test "sync_bracket_prediction with comma-separated IDs updates multiple tournaments" do
      if pid = Process.whereis(Backend.Tournaments.HSEsports) do
        Ecto.Adapters.SQL.Sandbox.allow(Backend.Repo, self(), pid)
      end

      user = create_temp_user(%{battletag: "Player#1234"})

      # Tournament 1
      pred_t1 =
        %PredTournament{
          name: "Tour 1",
          status: "open",
          slug: "tour-1-sync",
          scoring_strategy: "flat",
          scoring_config: %{"points_per_match" => 1},
          creator_id: user.id
        }
        |> Repo.insert!()

      stage1 =
        %Stage{
          tournament_id: pred_t1.id,
          name: "Group A",
          stage_type: "double_elimination_groups",
          sequence: 1
        }
        |> Repo.insert!()

      match1 =
        %PredMatch{
          tournament_id: pred_t1.id,
          stage_id: stage1.id,
          match_identifier: "g1_opening_1",
          round_name: "Group A - Opening 1",
          round_number: 1,
          match_order: 1,
          top_name: "McBanterFace",
          bottom_name: "Soyorin",
          top_score: 0,
          bottom_score: 0,
          is_complete: false
        }
        |> Repo.insert!()

      # Tournament 2
      pred_t2 =
        %PredTournament{
          name: "Tour 2",
          status: "open",
          slug: "tour-2-sync",
          scoring_strategy: "flat",
          scoring_config: %{"points_per_match" => 1},
          creator_id: user.id
        }
        |> Repo.insert!()

      stage2 =
        %Stage{
          tournament_id: pred_t2.id,
          name: "Group A",
          stage_type: "double_elimination_groups",
          sequence: 1
        }
        |> Repo.insert!()

      match2 =
        %PredMatch{
          tournament_id: pred_t2.id,
          stage_id: stage2.id,
          match_identifier: "g1_opening_1",
          round_name: "Group A - Opening 1",
          round_number: 1,
          match_order: 1,
          top_name: "McBanterFace",
          bottom_name: "Soyorin",
          top_score: 0,
          bottom_score: 0,
          is_complete: false
        }
        |> Repo.insert!()

      id1 = pred_t1.id
      id2 = pred_t2.id

      assert {:ok, results} = HSEsports.sync_bracket_prediction("#{id1}, #{id2}")
      assert %{^id1 => count1, ^id2 => count2} = results
      assert count1 >= 1
      assert count2 >= 1

      reloaded1 = Repo.get!(PredMatch, match1.id)
      reloaded2 = Repo.get!(PredMatch, match2.id)

      assert reloaded1.is_complete == true
      assert reloaded1.top_score == 2
      assert reloaded1.bottom_score == 3
      assert reloaded1.actual_winner_name == "Soyorin"

      assert reloaded2.is_complete == true
      assert reloaded2.top_score == 2
      assert reloaded2.bottom_score == 3
      assert reloaded2.actual_winner_name == "Soyorin"
    end

    test "score predicting works for whole tournament and top-cut only tournament with exact score bonuses, case insensitivity, and inverted slots" do
      if pid = Process.whereis(Backend.Tournaments.HSEsports) do
        Ecto.Adapters.SQL.Sandbox.allow(Backend.Repo, self(), pid)
      end

      user = create_temp_user(%{battletag: "Host#0001"})

      # 1. Whole tournament (GSL groups + Playoffs) with predict_scores: true
      whole_attrs = %{
        name: "WC 2026 Full Tour",
        creator_id: user.id,
        predict_scores: true,
        scoring_strategy: "flat",
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 2}
      }

      groups_data = [
        %{name: "Group A", participants: ["McBanterFace", "Soyorin", "hyosung", "mlYanming"]},
        %{name: "Group B", participants: ["P5", "P6", "P7", "P8"]},
        %{name: "Group C", participants: ["P9", "P10", "P11", "P12"]},
        %{name: "Group D", participants: ["P13", "P14", "P15", "P16"]}
      ]

      assert {:ok, %PredTournament{} = whole_t} =
               BracketPredictions.create_gsl_into_single_elim_tournament(whole_attrs, groups_data)

      # 2. Top-cut only tournament (Single Elimination Top 8) with predict_scores: true
      top_cut_attrs = %{
        name: "WC 2026 Top Cut",
        creator_id: user.id,
        predict_scores: true,
        scoring_strategy: "flat",
        scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 2}
      }

      # Note participant order: Torun top, Hyosung bottom
      participants = ["Torun", "Hyosung", "P3", "P4", "P5", "P6", "P7", "P8"]

      assert {:ok, %PredTournament{} = top_cut_t} =
               BracketPredictions.create_single_elimination_tournament(
                 top_cut_attrs,
                 participants,
                 bracket_size: 8,
                 has_third_place_match: false
               )

      # 3. Create users and picks
      u1 = create_temp_user(%{battletag: "ExactWhole#1"})
      u2 = create_temp_user(%{battletag: "WrongScoreWhole#2"})
      u3 = create_temp_user(%{battletag: "ExactTopCut#3"})
      u4 = create_temp_user(%{battletag: "WrongScoreTopCut#4"})

      # u1 picks exact score (2-3) on whole tournament
      {:ok, _} =
        BracketPredictions.save_entry_predictions(whole_t, u1, %{
          "g1_opening_1" => %{
            "winner" => "Soyorin",
            "top_score" => 2,
            "bottom_score" => 3
          }
        })

      # u2 picks wrong score (1-3) on whole tournament
      {:ok, _} =
        BracketPredictions.save_entry_predictions(whole_t, u2, %{
          "g1_opening_1" => %{
            "winner" => "Soyorin",
            "top_score" => 1,
            "bottom_score" => 3
          }
        })

      # u3 picks exact score on top-cut: Hyosung wins 3-0 against Torun
      # (Torun is top with score 0, Hyosung is bottom with score 3)
      {:ok, _} =
        BracketPredictions.save_entry_predictions(top_cut_t, u3, %{
          "playoffs_qf_1" => %{
            "winner" => "Hyosung",
            "top_score" => 0,
            "bottom_score" => 3
          }
        })

      # u4 picks wrong score on top-cut: Hyosung wins 3-1 against Torun
      {:ok, _} =
        BracketPredictions.save_entry_predictions(top_cut_t, u4, %{
          "playoffs_qf_1" => %{
            "winner" => "Hyosung",
            "top_score" => 1,
            "bottom_score" => 3
          }
        })

      # 4. Load CSV containing results with:
      # - lowercase "soyorin" and "hyosung" (tests case-insensitivity)
      # - inverted top/bottom order in playoffs_qf_1: Player 1 = hyosung, Player 2 = Torun
      csv = """
      Stage,Match #,Game #,Player 1,P1 Deck Used,Player 2,P2 Deck Used,Winner,Bans
      Group A,Initial Match 1,1,McBanterFace,Demon Hunter,soyorin,Demon Hunter,soyorin,P1 Ban
      ,,2,McBanterFace,Demon Hunter,soyorin,Druid,McBanterFace,Warrior
      ,,3,McBanterFace,Druid,soyorin,Druid,soyorin,P2 Ban
      ,,4,McBanterFace,Druid,soyorin,Warlock,McBanterFace,Warrior
      ,,5,McBanterFace,Warlock,soyorin,Warlock,soyorin,
      BlizzCon Finals,Quarterfinals 1,1,hyosung,Mage,Torun,Warrior,hyosung,P1 Ban
      ,,2,hyosung,Mage,Torun,Warrior,hyosung,
      ,,3,hyosung,Mage,Torun,Warrior,hyosung,P2 Ban
      """

      assert {:ok, _} = HSEsports.load_csv(csv, "wc_2026")

      # 5. Sync both tournaments using comma-separated ID string
      assert {:ok, results} = HSEsports.sync_bracket_prediction("#{whole_t.id}, #{top_cut_t.id}")
      id_w = whole_t.id
      id_tc = top_cut_t.id
      assert %{^id_w => count_w, ^id_tc => count_tc} = results
      assert count_w >= 1
      assert count_tc >= 1

      # 6. Verify match fields in top cut tournament:
      # DB match had Torun (top) vs Hyosung (bottom).
      # CSV had Player 1 = hyosung (won 3), Player 2 = Torun (won 0).
      # align_scores_and_names must keep Torun at top with score 0, and Hyosung at bottom with score 3.
      top_cut_match = Repo.get_by!(PredMatch, tournament_id: top_cut_t.id, match_identifier: "playoffs_qf_1")
      assert top_cut_match.is_complete == true
      assert top_cut_match.top_name == "Torun"
      assert top_cut_match.bottom_name == "Hyosung"
      assert top_cut_match.top_score == 0
      assert top_cut_match.bottom_score == 3
      assert top_cut_match.actual_winner_name == "Hyosung"

      # 7. Verify leaderboard in whole tournament:
      # u1 got 1 base + 2 exact score bonus = 3 points
      # u2 got 1 base + 0 bonus = 1 point
      entries_whole = BracketPredictions.list_entries_for_tournament(whole_t.id)
      entry1 = Enum.find(entries_whole, &(&1.user_id == u1.id))
      entry2 = Enum.find(entries_whole, &(&1.user_id == u2.id))

      assert entry1.total_score == 3
      pick1 = Enum.find(entry1.picks, &(&1.picked_winner_name == "Soyorin"))
      assert pick1.is_correct == true
      assert pick1.exact_score_correct == true
      assert pick1.points_awarded == 3

      assert entry2.total_score == 1
      pick2 = Enum.find(entry2.picks, &(&1.picked_winner_name == "Soyorin"))
      assert pick2.is_correct == true
      assert pick2.exact_score_correct == false
      assert pick2.points_awarded == 1

      # 8. Verify leaderboard in top-cut tournament:
      # u3 got 1 base + 2 exact score bonus = 3 points
      # u4 got 1 base + 0 bonus = 1 point
      entries_top_cut = BracketPredictions.list_entries_for_tournament(top_cut_t.id)
      entry3 = Enum.find(entries_top_cut, &(&1.user_id == u3.id))
      entry4 = Enum.find(entries_top_cut, &(&1.user_id == u4.id))

      assert entry3.total_score == 3
      pick3 = Enum.find(entry3.picks, &(&1.picked_winner_name == "Hyosung"))
      assert pick3.is_correct == true
      assert pick3.exact_score_correct == true
      assert pick3.points_awarded == 3

      assert entry4.total_score == 1
      pick4 = Enum.find(entry4.picks, &(&1.picked_winner_name == "Hyosung"))
      assert pick4.is_correct == true
      assert pick4.exact_score_correct == false
      assert pick4.points_awarded == 1
    end
  end
end
