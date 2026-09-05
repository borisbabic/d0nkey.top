defmodule Backend.BracketPredictions.DAGTest do
  use ExUnit.Case, async: true
  alias Backend.BracketPredictions.DAG
  alias Backend.BracketPredictions.Match

  defp build_match(id, round, order, top_type, top_id, bot_type, bot_id, top_name \\ nil, bot_name \\ nil) do
    %Match{
      id: :erlang.phash2(id),
      match_identifier: id,
      round_number: round,
      match_order: order,
      top_source_type: top_type,
      top_source_identifier: top_id,
      bottom_source_type: bot_type,
      bottom_source_identifier: bot_id,
      top_name: top_name,
      bottom_name: bot_name,
      is_complete: false
    }
  end

  describe "evaluate_matches/2 and apply_pick/5" do
    test "advances winners from opening matches into subsequent rounds" do
      m1 = build_match("m1", 1, 1, "seed", nil, "seed", nil, "XiaoT", "Definition")
      m2 = build_match("m2", 1, 2, "seed", nil, "seed", nil, "PocketTrain", "Tansoku")
      m3 = build_match("m3", 2, 3, "winner_of", "m1", "winner_of", "m2")

      matches = [m1, m2, m3]

      # Initial evaluation with no picks
      nodes = DAG.evaluate_matches(matches, %{})
      m3_node = Enum.find(nodes, &(&1.match.match_identifier == "m3"))
      assert m3_node.predicted_top == nil
      assert m3_node.predicted_bottom == nil

      # User picks XiaoT in m1 and Tansoku in m2
      picks = %{"m1" => "XiaoT", "m2" => "Tansoku"}
      nodes = DAG.evaluate_matches(matches, picks)
      m3_node = Enum.find(nodes, &(&1.match.match_identifier == "m3"))
      assert m3_node.predicted_top == "XiaoT"
      assert m3_node.predicted_bottom == "Tansoku"

      # User picks XiaoT in m3
      picks = Map.put(picks, "m3", "XiaoT")
      nodes = DAG.evaluate_matches(matches, picks)
      m3_node = Enum.find(nodes, &(&1.match.match_identifier == "m3"))
      assert m3_node.picked_winner == "XiaoT"
      assert m3_node.valid? == true
    end

    test "cascade prunes downstream picks when upstream winner changes" do
      m1 = build_match("m1", 1, 1, "seed", nil, "seed", nil, "XiaoT", "Definition")
      m2 = build_match("m2", 1, 2, "seed", nil, "seed", nil, "PocketTrain", "Tansoku")
      m3 = build_match("m3", 2, 3, "winner_of", "m1", "winner_of", "m2")
      m4 = build_match("m4", 3, 4, "winner_of", "m3", "seed", nil, nil, "FinalBoss")

      matches = [m1, m2, m3, m4]

      # Pick XiaoT in m1, PocketTrain in m2, XiaoT in m3, XiaoT in m4
      picks = %{
        "m1" => "XiaoT",
        "m2" => "PocketTrain",
        "m3" => "XiaoT",
        "m4" => "XiaoT"
      }

      nodes = DAG.evaluate_matches(matches, picks)
      assert Enum.all?(nodes, & &1.valid?)

      # User switches m1 from XiaoT to Definition
      new_picks = DAG.apply_pick(matches, picks, "m1", "Definition")

      # m1 is now Definition
      assert new_picks["m1"] == "Definition"
      # m2 is untouched
      assert new_picks["m2"] == "PocketTrain"
      # m3 and m4 picks for XiaoT MUST be pruned
      refute Map.has_key?(new_picks, "m3")
      refute Map.has_key?(new_picks, "m4")
    end

    test "GSL double elimination group with stage advancement" do
      # 4 players in GSL group
      m1 = build_match("g1_opening_1", 1, 1, "seed", nil, "seed", nil, "PlayerA", "PlayerD")
      m2 = build_match("g1_opening_2", 1, 2, "seed", nil, "seed", nil, "PlayerB", "PlayerC")
      m_win = build_match("g1_winners", 2, 3, "winner_of", "g1_opening_1", "winner_of", "g1_opening_2")
      m_elim = build_match("g1_elim", 2, 4, "loser_of", "g1_opening_1", "loser_of", "g1_opening_2")
      m_dec = build_match("g1_decider", 3, 5, "loser_of", "g1_winners", "winner_of", "g1_elim")

      # Stage 2: Playoff match taking 1st place (winner of g1_winners)
      playoff_qf1 =
        build_match("playoffs_qf_1", 4, 6, "stage_advancement", "g1_winners", "seed", nil, nil, "OtherGroup2nd")

      matches = [m1, m2, m_win, m_elim, m_dec, playoff_qf1]

      # Pick PlayerA in m1, PlayerB in m2
      picks = %{
        "g1_opening_1" => "PlayerA",
        "g1_opening_2" => "PlayerB"
      }

      nodes = DAG.evaluate_matches(matches, picks)
      win_node = Enum.find(nodes, &(&1.match.match_identifier == "g1_winners"))
      elim_node = Enum.find(nodes, &(&1.match.match_identifier == "g1_elim"))

      # Winners match has PlayerA vs PlayerB
      assert win_node.predicted_top == "PlayerA"
      assert win_node.predicted_bottom == "PlayerB"

      # Elimination match has Loser of m1 (PlayerD) vs Loser of m2 (PlayerC)
      assert elim_node.predicted_top == "PlayerD"
      assert elim_node.predicted_bottom == "PlayerC"

      # User picks PlayerA to win Winners match (advances as #1 seed)
      # and PlayerC to win Elim match
      picks =
        picks
        |> Map.put("g1_winners", "PlayerA")
        |> Map.put("g1_elim", "PlayerC")

      nodes = DAG.evaluate_matches(matches, picks)
      dec_node = Enum.find(nodes, &(&1.match.match_identifier == "g1_decider"))
      qf_node = Enum.find(nodes, &(&1.match.match_identifier == "playoffs_qf_1"))

      # Decider match has Loser of Winners (PlayerB) vs Winner of Elim (PlayerC)
      assert dec_node.predicted_top == "PlayerB"
      assert dec_node.predicted_bottom == "PlayerC"

      # Playoff QF1 gets PlayerA via stage advancement!
      assert qf_node.predicted_top == "PlayerA"
      assert qf_node.predicted_bottom == "OtherGroup2nd"
    end
  end
end
