defmodule Backend.Tournaments.HSEsportsTest do
  use BackendWeb.ConnCase
  alias Backend.Tournaments
  alias Backend.Tournaments.HSEsports
  alias Backend.Tournaments.HSEsports.Tournament
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

      # Set up a test bracket prediction tournament
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
  end
end
