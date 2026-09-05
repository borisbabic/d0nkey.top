defmodule Backend.BracketPredictions.BattlefySyncTest do
  use Backend.DataCase
  alias Backend.BracketPredictions
  alias Backend.BracketPredictions.BattlefySync
  alias Backend.BracketPredictions.Match, as: BracketMatch
  alias Backend.Battlefy.Match, as: BfMatch
  alias Backend.Battlefy.MatchTeam
  alias Backend.Battlefy.Bracket
  alias Backend.Battlefy.Bracket.Round

  defmodule MockBattlefyCommunicator do
    def get_tournament("bf_tour_123") do
      %{
        id: "bf_tour_123",
        name: "Hearthstone World Championship",
        slug: "hs-world-champ",
        status: "complete",
        stages: [
          %{
            id: "bf_group_stage_id",
            name: "Group Stage",
            bracket: %{type: "roundrobin", style: nil}
          },
          %{
            id: "bf_playoff_stage_id",
            name: "Playoffs Single Elimination",
            bracket: %{type: "elimination", style: "single"}
          }
        ]
      }
    end

    def get_tournament(_), do: nil

    def get_stage_bracket("bf_playoff_stage_id") do
      # 4 QFs in Round 1, 2 SFs in Round 2, 1 Final in Round 3, plus 3rd Place Round
      qfs = [
        %BfMatch{
          id: "bf_qf_1",
          round_number: 1,
          match_number: 1,
          is_complete: true,
          top: %MatchTeam{name: "XiaoT", winner: true, score: 3},
          bottom: %MatchTeam{name: "Definition", winner: false, score: 1},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 10:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        },
        %BfMatch{
          id: "bf_qf_2",
          round_number: 1,
          match_number: 2,
          is_complete: true,
          top: %MatchTeam{name: "PocketTrain", winner: true, score: 3},
          bottom: %MatchTeam{name: "Tansoku", winner: false, score: 2},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 11:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        },
        %BfMatch{
          id: "bf_qf_3",
          round_number: 1,
          match_number: 3,
          is_complete: true,
          top: %MatchTeam{name: "Furyhunter", winner: true, score: 3},
          bottom: %MatchTeam{name: "posesi", winner: false, score: 0},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 12:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        },
        %BfMatch{
          id: "bf_qf_4",
          round_number: 1,
          match_number: 4,
          is_complete: true,
          top: %MatchTeam{name: "Gaby", winner: true, score: 3},
          bottom: %MatchTeam{name: "habugabu", winner: false, score: 1},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 13:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        }
      ]

      sfs = [
        %BfMatch{
          id: "bf_sf_1",
          round_number: 2,
          match_number: 1,
          is_complete: true,
          # Inverted top and bottom orientation test: PocketTrain as top, XiaoT as bottom!
          top: %MatchTeam{name: "PocketTrain", winner: false, score: 2},
          bottom: %MatchTeam{name: "XiaoT", winner: true, score: 3},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 14:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        },
        %BfMatch{
          id: "bf_sf_2",
          round_number: 2,
          match_number: 2,
          is_complete: true,
          top: %MatchTeam{name: "Furyhunter", winner: true, score: 3},
          bottom: %MatchTeam{name: "Gaby", winner: false, score: 1},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 15:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        }
      ]

      finals = [
        %BfMatch{
          id: "bf_finals",
          round_number: 3,
          match_number: 1,
          is_complete: true,
          top: %MatchTeam{name: "XiaoT", winner: true, score: 3},
          bottom: %MatchTeam{name: "Furyhunter", winner: false, score: 2},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 17:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        }
      ]

      third_place = [
        %BfMatch{
          id: "bf_third",
          round_number: 3,
          match_number: 2,
          is_complete: true,
          top: %MatchTeam{name: "PocketTrain", winner: true, score: 3},
          bottom: %MatchTeam{name: "Gaby", winner: false, score: 1},
          stage_id: "bf_playoff_stage_id",
          double_loss: false,
          is_bye: false,
          completed_at: ~N[2026-09-01 16:00:00],
          updated_at: nil,
          stats: nil,
          next: nil
        }
      ]

      %Bracket{
        stage_id: "bf_playoff_stage_id",
        started?: true,
        style: "single",
        broadcast_url: nil,
        edit_bracket_url: nil,
        full_screen_url: nil,
        consolation: nil,
        final: nil,
        championship: %{
          total_rounds: 3,
          rounds: [
            %Round{round_number: 1, num_games: 5, series_style: "bo5", matches: qfs},
            %Round{round_number: 2, num_games: 5, series_style: "bo5", matches: sfs},
            %Round{round_number: 3, num_games: 5, series_style: "bo5", matches: finals}
          ],
          third_place_round: %Round{round_number: 3, num_games: 5, series_style: "bo5", matches: third_place}
        }
      }
    end

    def get_stage_bracket(_), do: nil

    def get_matches(stage_id, opts \\ [])

    def get_matches("bf_playoff_stage_id", _opts) do
      bracket = get_stage_bracket("bf_playoff_stage_id")
      champ_matches = Enum.flat_map(bracket.championship.rounds, & &1.matches)
      third_matches = bracket.championship.third_place_round.matches
      champ_matches ++ third_matches
    end

    def get_matches(_, _opts), do: []
  end

  setup do
    previous_comm = Application.get_env(:backend, :battlefy_communicator)
    Application.put_env(:backend, :battlefy_communicator, MockBattlefyCommunicator)

    on_exit(fn ->
      if previous_comm do
        Application.put_env(:backend, :battlefy_communicator, previous_comm)
      else
        Application.delete_env(:backend, :battlefy_communicator)
      end
    end)

    user = create_temp_user(%{battletag: "Admin#1234"})
    predictor = create_temp_user(%{battletag: "Predictor#5678"})

    groups_data = [
      %{name: "Group A", participants: ["XiaoT", "Definition", "P1", "P2"]},
      %{name: "Group B", participants: ["PocketTrain", "Tansoku", "P3", "P4"]},
      %{name: "Group C", participants: ["Furyhunter", "posesi", "P5", "P6"]},
      %{name: "Group D", participants: ["Gaby", "habugabu", "P7", "P8"]}
    ]

    {:ok, tournament} =
      BracketPredictions.create_gsl_into_single_elim_tournament(
        %{
          name: "Championship 2026",
          creator_id: user.id,
          predict_scores: true,
          battlefy_tournament_id: "bf_tour_123",
          scoring_strategy: "flat",
          scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 1}
        },
        groups_data,
        has_third_place_match: true,
        playoff_battlefy_stage_id: "bf_playoff_stage_id"
      )

    {:ok, user: user, predictor: predictor, tournament: tournament}
  end

  describe "align_scores_and_names/5" do
    test "preserves scores when orientation matches" do
      target = %BracketMatch{top_name: "XiaoT", bottom_name: "Definition"}
      assert {"XiaoT", "Definition", 3, 1} = BattlefySync.align_scores_and_names(target, "XiaoT", "Definition", 3, 1)
    end

    test "swaps scores when Battlefy orientation is inverted" do
      target = %BracketMatch{top_name: "XiaoT", bottom_name: "Definition"}
      # Battlefy had Definition as top (score 1) and XiaoT as bottom (score 3)
      assert {"XiaoT", "Definition", 3, 1} = BattlefySync.align_scores_and_names(target, "Definition", "XiaoT", 1, 3)
    end

    test "populates nil names in normal orientation" do
      target = %BracketMatch{top_name: nil, bottom_name: nil}
      assert {"XiaoT", "Definition", 3, 1} = BattlefySync.align_scores_and_names(target, "XiaoT", "Definition", 3, 1)
    end

    test "populates nil top name with inverted orientation" do
      target = %BracketMatch{top_name: nil, bottom_name: "XiaoT"}
      # Battlefy has top "XiaoT" (3) and bottom "Definition" (1)
      # Since local bottom is "XiaoT" (matching Battlefy top), orientation is inverted
      assert {"Definition", "XiaoT", 1, 3} = BattlefySync.align_scores_and_names(target, "XiaoT", "Definition", 3, 1)
    end
  end

  describe "auto_detect_playoff_stage_id/1" do
    test "detects single elimination playoff stage from Battlefy tournament", %{tournament: tournament} do
      assert BattlefySync.auto_detect_playoff_stage_id(tournament) == "bf_playoff_stage_id"
    end
  end

  describe "sync_tournament_results/1 for single elimination playoffs" do
    test "syncs completed playoff matches, cascades winners, and updates scores", %{
      tournament: tournament,
      predictor: predictor
    } do
      # 1. First, make predictions for user across groups and playoffs
      picks_map = %{
        # Group A
        "g1_opening_1" => "XiaoT",
        "g1_opening_2" => "P1",
        "g1_winners" => "XiaoT",
        "g1_elim" => "Definition",
        "g1_decider" => "Definition",
        # Group B
        "g2_opening_1" => "PocketTrain",
        "g2_opening_2" => "P3",
        "g2_winners" => "PocketTrain",
        "g2_elim" => "Tansoku",
        "g2_decider" => "Tansoku",
        # Group C
        "g3_opening_1" => "Furyhunter",
        "g3_opening_2" => "P5",
        "g3_winners" => "Furyhunter",
        "g3_elim" => "posesi",
        "g3_decider" => "posesi",
        # Group D
        "g4_opening_1" => "Gaby",
        "g4_opening_2" => "P7",
        "g4_winners" => "Gaby",
        "g4_elim" => "habugabu",
        "g4_decider" => "habugabu",
        # Playoffs
        "playoffs_qf_1" => "XiaoT",
        "playoffs_qf_2" => "Furyhunter",
        "playoffs_qf_3" => "PocketTrain",
        "playoffs_qf_4" => "Gaby",
        "playoffs_sf_1" => "XiaoT",
        "playoffs_sf_2" => "Furyhunter",
        "playoffs_finals" => "XiaoT",
        "playoffs_third_place" => "PocketTrain"
      }

      assert {:ok, entry} = BracketPredictions.save_entry_predictions(tournament, predictor, picks_map)
      assert entry.total_score == 0

      # 2. Sync all tournament results from Battlefy (Stage 2 Playoffs)
      assert {:ok, updated_count} = BattlefySync.sync_tournament_results(tournament)
      # 4 QFs + 2 SFs + 1 Final + 1 3rd place = 8 playoff matches updated
      assert updated_count >= 8

      # 3. Verify Quarterfinals
      refreshed = BracketPredictions.get_tournament!(tournament.id)
      qf1 = Enum.find(refreshed.matches, &(&1.match_identifier == "playoffs_qf_1"))
      assert qf1.is_complete == true
      assert qf1.actual_winner_name == "XiaoT"
      assert qf1.top_name == "XiaoT"
      assert qf1.bottom_name == "Definition"
      assert qf1.top_score == 3
      assert qf1.bottom_score == 1
      assert qf1.battlefy_match_id == "bf_qf_1"

      # 4. Verify Semifinals (which had inverted orientation in MockBattlefyCommunicator!)
      sf1 = Enum.find(refreshed.matches, &(&1.match_identifier == "playoffs_sf_1"))
      assert sf1.is_complete == true
      assert sf1.actual_winner_name == "XiaoT"
      # Top was winner of QF 1 (XiaoT), bottom was winner of QF 2 (PocketTrain)
      assert sf1.top_name == "XiaoT"
      assert sf1.bottom_name == "PocketTrain"
      # In Mock, XiaoT had 3, PocketTrain had 2
      assert sf1.top_score == 3
      assert sf1.bottom_score == 2
      assert sf1.battlefy_match_id == "bf_sf_1"

      # 5. Verify Grand Finals
      finals = Enum.find(refreshed.matches, &(&1.match_identifier == "playoffs_finals"))
      assert finals.is_complete == true
      assert finals.actual_winner_name == "XiaoT"
      assert finals.top_name == "XiaoT"
      assert finals.bottom_name == "Furyhunter"
      assert finals.top_score == 3
      assert finals.bottom_score == 2
      assert finals.battlefy_match_id == "bf_finals"

      # 6. Verify 3rd Place Match
      third = Enum.find(refreshed.matches, &(&1.match_identifier == "playoffs_third_place"))
      assert third.is_complete == true
      assert third.actual_winner_name == "PocketTrain"
      assert third.top_name == "PocketTrain"
      assert third.bottom_name == "Gaby"
      assert third.top_score == 3
      assert third.bottom_score == 1
      assert third.battlefy_match_id == "bf_third"

      # 7. Rescore leaderboard
      BracketPredictions.recalculate_leaderboard(tournament.id)
      [ranked] = BracketPredictions.list_entries_for_tournament(tournament.id)
      assert ranked.total_score == 4
      assert ranked.rank == 1
    end
  end
end
