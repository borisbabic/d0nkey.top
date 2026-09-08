defmodule BackendWeb.BracketPredictionsLiveTest do
  use BackendWeb.ConnCase
  use BackendWeb, :verified_routes
  import Phoenix.LiveViewTest

  alias Backend.BracketPredictions
  import Backend.UserFixtures

  setup do
    creator = user_fixture(%{battletag: "Creator#1234", admin_roles: ["bracket_predictions"]})

    groups_data = [
      %{name: "Group A", participants: ["XiaoT", "Definition", "PocketTrain", "Tansoku"]},
      %{name: "Group B", participants: ["Furyhunter", "posesi", "habugabu", "Gaby"]}
    ]

    {:ok, tournament} =
      BracketPredictions.create_gsl_into_single_elim_tournament(
        %{
          name: "Masters Tour Predictions",
          creator_id: creator.id,
          predict_scores: true,
          scoring_strategy: "flat",
          scoring_config: %{"flat_points" => 1, "exact_score_bonus" => 1}
        },
        groups_data,
        has_third_place_match: true
      )

    {:ok, creator: creator, tournament: tournament}
  end

  test "visitor can view tournaments list on /bracket-predictions but cannot create", %{
    conn: conn,
    tournament: tournament
  } do
    {:ok, view, html} = live(conn, ~p"/bracket-predictions")

    assert html =~ "Bracket Predictions"
    assert html =~ tournament.name
    refute html =~ "Create Tournament"
    assert html =~ "Exact Scores Bonus"

    # Attempting to toggle create modal without permission returns flash error
    assert render_click(view, "toggle_create_modal") =~
             "You do not have permission to create bracket prediction tournaments."

    # Attempting to submit creation without permission returns flash error
    assert render_submit(view, "create_tournament", %{
             "tournament" => %{"name" => "Unauthorized Champ"}
           }) =~ "You do not have permission to create bracket prediction tournaments."
  end

  test "regular user without bracket_predictions role cannot create tournament" do
    regular_user = user_fixture(%{battletag: "Regular#1234", admin_roles: []})
    conn = BackendWeb.ConnCase.build_conn_with_user(regular_user)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions")
    refute html =~ "Create Tournament"

    assert render_click(view, "toggle_create_modal") =~
             "You do not have permission to create bracket prediction tournaments."

    assert render_submit(view, "create_tournament", %{
             "tournament" => %{"name" => "Regular User Champ"}
           }) =~ "You do not have permission to create bracket prediction tournaments."

    assert Backend.BracketPredictions.list_tournaments()
           |> Enum.filter(&(&1.name == "Regular User Champ"))
           |> Enum.empty?()
  end

  test "super admin can create tournament" do
    super_user = user_fixture(%{battletag: "SuperAdmin#1234", admin_roles: ["super"]})
    conn = BackendWeb.ConnCase.build_conn_with_user(super_user)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions")
    assert html =~ "Create Tournament"

    render_click(view, "toggle_create_modal")

    render_submit(view, "create_tournament", %{
      "tournament" => %{
        "name" => "Super Championship",
        "predict_scores" => "false",
        "has_third_place" => "false",
        "group_count" => "2",
        "flat_points" => "1",
        "group_a" => "S1\nS2\nS3\nS4",
        "group_b" => "S5\nS6\nS7\nS8"
      }
    })

    assert [_] =
             Backend.BracketPredictions.list_tournaments()
             |> Enum.filter(&(&1.name == "Super Championship"))
  end

  test "visitor can view tournament show page and tabs", %{conn: conn, tournament: tournament} do
    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}")

    assert html =~ tournament.name
    assert html =~ "Stage 1: Group Stage (GSL Double Elimination)"
    assert html =~ "Stage 2: Playoffs (Single Elimination)"
    assert html =~ "Tournament &amp; Bracket"
    assert html =~ "Leaderboard"
    assert html =~ "Rules &amp; Scoring"

    # Switch to Leaderboard tab
    html_lb = render_click(view, "switch_tab", %{"tab" => "leaderboard"})
    assert html_lb =~ "Tournament Leaderboard"

    # Switch to Rules tab
    html_rules = render_click(view, "switch_tab", %{"tab" => "rules"})
    assert html_rules =~ "Tournament Scoring System"
    assert html_rules =~ "Exact Score Prediction Bonus"
  end

  test "visitor sees shortened battletags and no bracket names on leaderboard tab, while manager sees full battletags",
       %{conn: conn, tournament: tournament, creator: creator} do
    user = user_fixture(%{battletag: "Leader#1234"})

    entry =
      %Backend.BracketPredictions.Entry{}
      |> Backend.BracketPredictions.Entry.changeset(%{
        tournament_id: tournament.id,
        user_id: user.id,
        name: "Winning Bracket",
        total_score: 42,
        rank: 1,
        submitted_at: NaiveDateTime.utc_now()
      })
      |> Backend.Repo.insert!()

    # Add a pick
    match = tournament.stages |> hd() |> Map.get(:matches) |> hd()

    %Backend.BracketPredictions.Pick{}
    |> Backend.BracketPredictions.Pick.changeset(%{
      entry_id: entry.id,
      match_id: match.id,
      picked_winner_name: "XiaoT",
      is_correct: true,
      exact_score_correct: true,
      points_awarded: 2
    })
    |> Backend.Repo.insert!()

    # 1. Visitor view (cannot manage)
    {:ok, view, _html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}")

    html_lb = render_click(view, "switch_tab", %{"tab" => "leaderboard"})
    assert html_lb =~ "Tournament Leaderboard"
    assert html_lb =~ "Leader"
    refute html_lb =~ "Leader#1234"
    refute html_lb =~ "Winning Bracket"
    refute html_lb =~ "Bracket Name"
    assert html_lb =~ "42"

    # 2. Manager view (creator can manage)
    manager_conn = BackendWeb.ConnCase.build_conn_with_user(creator)
    {:ok, manager_view, _} = live(manager_conn, ~p"/bracket-predictions/tournaments/#{tournament.id}")

    manager_lb = render_click(manager_view, "switch_tab", %{"tab" => "leaderboard"})
    assert manager_lb =~ "Tournament Leaderboard"
    assert manager_lb =~ "Leader#1234"
    refute manager_lb =~ "Winning Bracket"
    refute manager_lb =~ "Bracket Name"
    assert manager_lb =~ "42"
  end

  test "authenticated user can make interactive picks and submit bracket", %{tournament: tournament} do
    user = user_fixture(%{battletag: "Predictor#5678"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    assert html =~ "Predict: #{tournament.name}"
    assert html =~ "XiaoT"
    assert html =~ "Definition"

    # Pick XiaoT in Group A Opening 1
    html_after_pick =
      render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    assert html_after_pick =~ "XiaoT"

    # Pick PocketTrain in Group A Opening 2
    render_click(view, "pick_winner", %{"match_id" => "g1_opening_2", "winner" => "PocketTrain"})

    # Set exact score for opening 1
    render_change(view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:3:1"
    })

    # Verify submit buttons are not shown (auto-saving mode)
    refute has_element?(view, "#header_submit_bracket_btn")
    refute has_element?(view, "#bottom_submit_bracket_btn")

    # Verify entry exists
    entry = BracketPredictions.get_user_entry(tournament.id, user.id)
    assert entry != nil
    assert length(entry.picks) >= 2

    # Opening 1 has explicit 3-1 score
    p1 = Enum.find(entry.picks, &(&1.picked_winner_name == "XiaoT"))
    assert p1.predicted_top_score == 3
    assert p1.predicted_bottom_score == 1

    # Opening 2 defaults to 3 for winner (PocketTrain) and 2 for loser (Tansoku)
    p2 = Enum.find(entry.picks, &(&1.picked_winner_name == "PocketTrain"))
    assert p2.predicted_top_score == 3
    assert p2.predicted_bottom_score == 2
  end

  test "when editing partially saved bracket predictions, previous scores and picks are populated and selected", %{
    tournament: tournament
  } do
    user = user_fixture(%{battletag: "Editor#9999"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    # 1. First session: Partially save predictions with custom score
    {:ok, view, _html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    # Pick XiaoT as winner for Opening 1
    render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    # Set score for Opening 1 to 3-1
    render_change(view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:3:1"
    })

    # Leave Opening 2 and rest of bracket unpicked (partially saved automatically)
    refute has_element?(view, "#header_submit_bracket_btn")

    # 2. Second session: Navigate back to edit predictions
    {:ok, edit_view, edit_html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    # XiaoT should still be picked as winner
    assert edit_html =~ "XiaoT"
    assert has_element?(edit_view, "#score_select_g1_opening_1")

    # Previous score (3-1) must be populated and selected
    assert has_element?(
             edit_view,
             "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:3:1'][selected]"
           )

    # 3. Continue editing: pick Opening 2
    render_click(edit_view, "pick_winner", %{"match_id" => "g1_opening_2", "winner" => "PocketTrain"})

    # Opening 1 must STILL retain 3-1
    assert has_element?(
             edit_view,
             "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:3:1'][selected]"
           )

    # Opening 2 dropdown should be present and default to 3-2
    assert has_element?(
             edit_view,
             "select[name='score_select_g1_opening_2'] option[value='g1_opening_2:3:2'][selected]"
           )

    # 4. Verify both picks are automatically saved in database
    refute has_element?(edit_view, "#header_submit_bracket_btn")

    entry = BracketPredictions.get_user_entry(tournament.id, user.id)
    assert entry != nil
    assert length(entry.picks) == 2

    p1 = Enum.find(entry.picks, &(&1.match.match_identifier == "g1_opening_1"))
    assert p1.picked_winner_name == "XiaoT"
    assert p1.predicted_top_score == 3
    assert p1.predicted_bottom_score == 1

    p2 = Enum.find(entry.picks, &(&1.match.match_identifier == "g1_opening_2"))
    assert p2.picked_winner_name == "PocketTrain"
    assert p2.predicted_top_score == 3
    assert p2.predicted_bottom_score == 2
  end

  test "when editing predictions with bottom contestant as winner, previous score (e.g. 0-3) is populated", %{
    tournament: tournament
  } do
    user = user_fixture(%{battletag: "BottomWinner#9999"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    {:ok, view, _html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    # Pick Definition (bottom) as winner for Opening 1
    render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "Definition"})

    # Set score to 0-3 (loser XiaoT gets 0)
    render_change(view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:0:3"
    })

    refute has_element?(view, "#header_submit_bracket_btn")

    # Re-open for editing
    {:ok, edit_view, _edit_html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    # 0-3 option must be selected
    assert has_element?(
             edit_view,
             "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:0:3'][selected]"
           )
  end

  test "score submission UI is placed next to players with default 3 for winner and 2 for loser", %{
    tournament: tournament
  } do
    user = user_fixture(%{battletag: "ScoreTester#9999"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    # Score selection is NOT beneath players
    refute html =~ "Score Prediction:"

    # Pick XiaoT as winner for Opening 1
    html_after_pick =
      render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    # Still no score selector beneath players
    refute html_after_pick =~ "Score Prediction:"

    # Score selection dropdown is present for Definition (loser) with 2 selected as default
    assert has_element?(view, "select[name='score_select_g1_opening_1']")

    # Winner XiaoT displays default score of 3
    assert html_after_pick =~ "title=\"Winner score\""
    assert html_after_pick =~ "3"

    # Default score 2 is selected for the loser in the dropdown
    assert has_element?(view, "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:3:2'][selected]")

    # Switch winner to Definition
    _html_after_switch =
      render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "Definition"})

    # Definition is now the winner with 3, and XiaoT is loser defaulting to 2
    assert has_element?(view, "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:2:3'][selected]")

    # Change loser score to 0 (so 0:3)
    render_change(view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:0:3"
    })

    assert has_element?(view, "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:0:3'][selected]")
  end

  test "creator can access admin management and enter manual result interactively", %{
    creator: creator,
    tournament: tournament
  } do
    conn = BackendWeb.ConnCase.build_conn_with_user(creator)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/manage")

    assert html =~ "Tournament Administration: #{tournament.name}"
    assert html =~ "Manual Result Submission"
    assert html =~ "Battlefy Live Integration"

    # Pick winner interactively on the bracket card just like the prediction interface
    render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    # Set score
    render_change(view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:3:1"
    })

    # Save results
    view
    |> element("#header_save_results_btn")
    |> render_click()

    # Verify match is marked complete in DB
    opening_match = Enum.find(tournament.matches, &(&1.match_identifier == "g1_opening_1"))
    updated_match = BracketPredictions.get_tournament!(tournament.id).matches |> Enum.find(&(&1.id == opening_match.id))
    assert updated_match.is_complete == true
    assert updated_match.actual_winner_name == "XiaoT"
    assert updated_match.top_score == 3
    assert updated_match.bottom_score == 1

    # Verify XiaoT propagated to downstream Winners match
    winners_match =
      BracketPredictions.get_tournament!(tournament.id).matches |> Enum.find(&(&1.match_identifier == "g1_winners"))

    assert winners_match.top_name == "XiaoT"
  end

  test "creator can configure playoff Battlefy stage ID and save Battlefy configuration", %{
    creator: creator,
    tournament: tournament
  } do
    conn = BackendWeb.ConnCase.build_conn_with_user(creator)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/manage")

    assert html =~ "Playoffs (Single Elimination) Stage ID"
    assert html =~ "Auto-detect Stages from Battlefy"

    # Submit Battlefy config form with playoff stage ID
    render_submit(view, "save_battlefy_config", %{
      "config" => %{
        "battlefy_tournament_id" => "bf_champ_999",
        "playoff_stage_id" => "bf_playoff_stage_888",
        "stage_id_Group_A" => "bf_grp_a_777",
        "stage_id_Group_B" => "bf_grp_b_666"
      }
    })

    # Verify stage 2 config updated in database
    refreshed = BracketPredictions.get_tournament!(tournament.id)
    stage_2 = Enum.find(refreshed.stages, &(&1.sequence == 2))
    assert stage_2.config["battlefy_stage_id"] == "bf_playoff_stage_888"
    assert refreshed.battlefy_tournament_id == "bf_champ_999"
  end

  test "creator can create a new bracket prediction tournament without exact score bonus", %{creator: creator} do
    conn = BackendWeb.ConnCase.build_conn_with_user(creator)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions")
    assert html =~ "Create Tournament"

    # Toggle modal open
    render_click(view, "toggle_create_modal")

    # Uncheck predict_scores in form
    render_change(view, "update_form", %{
      "tournament" => %{
        "name" => "No Bonus Championship",
        "predict_scores" => "false",
        "has_third_place" => "true",
        "group_count" => "2",
        "flat_points" => "1",
        "group_a" => "XiaoT\nDefinition\nPocketTrain\nTansoku",
        "group_b" => "Furyhunter\nposesi\nhabugabu\nGaby"
      }
    })

    # Submit creation form without exact score bonus
    render_submit(view, "create_tournament", %{
      "tournament" => %{
        "name" => "No Bonus Championship",
        "predict_scores" => "false",
        "has_third_place" => "true",
        "group_count" => "2",
        "flat_points" => "1",
        "exact_score_bonus" => "",
        "group_a" => "XiaoT\nDefinition\nPocketTrain\nTansoku",
        "group_b" => "Furyhunter\nposesi\nhabugabu\nGaby"
      }
    })

    [created_tour] =
      Backend.BracketPredictions.list_tournaments()
      |> Enum.filter(&(&1.name == "No Bonus Championship"))

    assert created_tour.predict_scores == false
    assert created_tour.scoring_config["exact_score_bonus"] == 0
    assert created_tour.scoring_config["flat_points"] == 1

    # Verify show page does not show exact score bonus
    {:ok, show_view, show_html} = live(conn, ~p"/bracket-predictions/tournaments/#{created_tour.id}")
    assert show_html =~ "No Bonus Championship"
    refute show_html =~ "Exact Score Bonus Enabled"

    # Rules tab does not mention exact score prediction bonus
    rules_html = render_click(show_view, "switch_tab", %{"tab" => "rules"})
    refute rules_html =~ "Exact Score Prediction Bonus"

    # User enters predictions
    predictor = user_fixture(%{battletag: "UserNoBonus#9999"})
    pred_conn = BackendWeb.ConnCase.build_conn_with_user(predictor)

    {:ok, pred_view, pred_html} = live(pred_conn, ~p"/bracket-predictions/tournaments/#{created_tour.id}/predict")
    assert pred_html =~ "Predict: No Bonus Championship"
    refute pred_html =~ "score_select_g1_opening_1"

    # Pick winner
    render_click(pred_view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    refute has_element?(pred_view, "#header_submit_bracket_btn")

    # Verify entry saved with nil predicted scores
    entry = BracketPredictions.get_user_entry(created_tour.id, predictor.id)
    assert entry != nil
    created_tour = BracketPredictions.get_tournament!(created_tour.id)
    opening_match = Enum.find(created_tour.matches, &(&1.match_identifier == "g1_opening_1"))
    pick = Enum.find(entry.picks, &(&1.match_id == opening_match.id))
    assert pick.picked_winner_name == "XiaoT"
    assert is_nil(pick.predicted_top_score)
    assert is_nil(pick.predicted_bottom_score)

    # Complete match with score 3-1: XiaoT wins
    BracketPredictions.enter_manual_match_result(opening_match.id, "XiaoT", 3, 1)

    # Leaderboard score should be exactly 1 base point (no score bonus)
    [ranked] = BracketPredictions.list_entries_for_tournament(created_tour.id)
    assert ranked.total_score == 1

    # Leaderboard tab on show page should not have Exact Scores column
    lb_html = render_click(show_view, "switch_tab", %{"tab" => "leaderboard"})
    refute lb_html =~ "<th class=\"tw-py-3.5 tw-px-4 tw-text-center\">Exact Scores</th>"
  end

  test "creator can create a tournament with a prediction deadline and manage it in admin", %{creator: creator} do
    conn = BackendWeb.ConnCase.build_conn_with_user(creator)

    {:ok, index_view, _html} = live(conn, ~p"/bracket-predictions")

    # Create tournament with deadline
    render_submit(index_view, "create_tournament", %{
      "tournament" => %{
        "name" => "Deadline Championship",
        "prediction_deadline" => "2026-10-15T18:00",
        "predict_scores" => "true",
        "has_third_place" => "false",
        "group_count" => "2",
        "flat_points" => "1",
        "exact_score_bonus" => "1",
        "group_a" => "A1\nA2\nA3\nA4",
        "group_b" => "B1\nB2\nB3\nB4"
      }
    })

    [created] =
      Backend.BracketPredictions.list_tournaments()
      |> Enum.filter(&(&1.name == "Deadline Championship"))

    assert created.prediction_deadline != nil
    assert created.prediction_deadline.year == 2026
    assert created.prediction_deadline.month == 10
    assert created.prediction_deadline.day == 15
    assert created.prediction_deadline.hour == 18

    # Verify admin manage page has the deadline and allows updating it
    {:ok, admin_view, admin_html} = live(conn, ~p"/bracket-predictions/tournaments/#{created.id}/manage")
    assert admin_html =~ "Prediction Deadline (UTC)"
    assert admin_html =~ "2026-10-15T18:00"
    assert admin_html =~ "Open until deadline"

    # Admin updates deadline to new date
    render_submit(admin_view, "update_deadline", %{
      "prediction_deadline" => "2026-11-20T20:00"
    })

    refreshed = Backend.BracketPredictions.get_tournament!(created.id)
    assert refreshed.prediction_deadline.month == 11
    assert refreshed.prediction_deadline.day == 20

    # Admin clears deadline
    admin_view
    |> element("#clear_deadline_btn")
    |> render_click()

    cleared = Backend.BracketPredictions.get_tournament!(created.id)
    assert is_nil(cleared.prediction_deadline)
  end

  test "locks out predictions when deadline has passed", %{tournament: tournament} do
    # Set deadline in the past
    past_deadline = NaiveDateTime.utc_now() |> NaiveDateTime.add(-3600, :second)

    {:ok, expired_tour} =
      Backend.BracketPredictions.update_tournament(tournament, %{prediction_deadline: past_deadline})

    predictor = user_fixture(%{battletag: "LateGuy#1234"})
    conn = BackendWeb.ConnCase.build_conn_with_user(predictor)

    # 1. Attempting to mount /predict when deadline passed redirects to tournament show
    assert {:error, {:live_redirect, %{to: redirect_to, flash: flash}}} =
             live(conn, ~p"/bracket-predictions/tournaments/#{expired_tour.id}/predict")

    assert redirect_to == ~p"/bracket-predictions/tournaments/#{expired_tour.id}"
    assert flash["error"] =~ "The prediction deadline for this tournament has passed"

    # 2. Show page displays deadline passed notice and hides prediction entry CTA
    {:ok, _show_view, show_html} = live(conn, ~p"/bracket-predictions/tournaments/#{expired_tour.id}")
    assert show_html =~ "Deadline passed"
    assert show_html =~ "Predictions closed"
    refute show_html =~ "Enter Your Bracket Picks"
    refute show_html =~ "Edit My Predictions"
  end

  test "bracket with depth <= 3 renders side-by-side on desktop (md:tw-grid-cols-X) and vertical list on mobile (tw-grid-cols-1)",
       %{conn: conn, creator: creator, tournament: tournament} do
    # 1. Depth 2 (4-player single elim: Semifinals + Finals)
    # The default setup tournament has 2 GSL groups -> 4 playoff players (SF + Finals + 3rd place)
    {:ok, _show_view, show_html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}")
    assert show_html =~ "md:tw-grid-cols-2"
    assert show_html =~ "tw-grid-cols-1"
    assert show_html =~ "Semifinal 1"
    assert show_html =~ "Semifinal 2"
    assert show_html =~ "Grand Finals"
    assert show_html =~ "3rd Place Match"

    [sf_col, champ_col] = String.split(show_html, "Championship", parts: 2)
    assert sf_col =~ "Semifinal 1"
    assert sf_col =~ "Semifinal 2"
    refute champ_col =~ "Semifinal"
    assert champ_col =~ "Grand Finals"
    assert champ_col =~ "3rd Place Match"

    # 2. Depth 3 (8-player single elim: 4 GSL groups -> 8 playoff players: QF + SF + Finals)
    groups_4 = [
      %{name: "Group A", participants: ["A1", "A2", "A3", "A4"]},
      %{name: "Group B", participants: ["B1", "B2", "B3", "B4"]},
      %{name: "Group C", participants: ["C1", "C2", "C3", "C4"]},
      %{name: "Group D", participants: ["D1", "D2", "D3", "D4"]}
    ]

    {:ok, tour_8} =
      BracketPredictions.create_gsl_into_single_elim_tournament(
        %{
          name: "Top 8 Single Elim Tournament",
          creator_id: creator.id,
          predict_scores: false
        },
        groups_4,
        has_third_place_match: true
      )

    {:ok, _view, html_8} = live(conn, ~p"/bracket-predictions/tournaments/#{tour_8.id}")

    # Depth 3 playoff bracket:
    # Desktop: side-by-side grid with 3 columns (md:tw-grid-cols-3)
    # Mobile: vertical list with 1 column (tw-grid-cols-1)
    assert html_8 =~ "md:tw-grid-cols-3"
    assert html_8 =~ "tw-grid-cols-1"
    assert html_8 =~ "Quarterfinals"
    assert html_8 =~ "Semifinals"
    assert html_8 =~ "Championship"
    assert html_8 =~ "Grand Finals"
    assert html_8 =~ "3rd Place Match"

    # Verify all 4 Quarterfinals, both Semifinals, Grand Finals, and 3rd Place match cards are rendered
    assert html_8 =~ "Quarterfinal 1"
    assert html_8 =~ "Quarterfinal 2"
    assert html_8 =~ "Quarterfinal 3"
    assert html_8 =~ "Quarterfinal 4"
    assert html_8 =~ "Semifinal 1"
    assert html_8 =~ "Semifinal 2"

    # Make sure Quarterfinal 1 is in Quarterfinals, not in Championship
    [qf_section, rest_after_qf] = String.split(html_8, "Semifinals", parts: 2)
    assert qf_section =~ "Quarterfinal 1"
    assert qf_section =~ "Quarterfinal 2"
    assert qf_section =~ "Quarterfinal 3"
    assert qf_section =~ "Quarterfinal 4"
    refute qf_section =~ "Grand Finals"

    [_sf_section, champ_section] = String.split(rest_after_qf, "Championship", parts: 2)
    refute champ_section =~ "Quarterfinal"
    assert champ_section =~ "Grand Finals"
    assert champ_section =~ "3rd Place Match"

    # Also check the prediction page for predictor
    predictor = user_fixture(%{battletag: "Player#0001"})
    pred_conn = BackendWeb.ConnCase.build_conn_with_user(predictor)
    {:ok, _pred_view, pred_html} = live(pred_conn, ~p"/bracket-predictions/tournaments/#{tour_8.id}/predict")
    assert pred_html =~ "md:tw-grid-cols-3"
    assert pred_html =~ "tw-grid-cols-1"
    assert pred_html =~ "Quarterfinal 1"
    assert pred_html =~ "Quarterfinal 2"
    assert pred_html =~ "Quarterfinal 3"
    assert pred_html =~ "Quarterfinal 4"
    assert pred_html =~ "Semifinal 1"
    assert pred_html =~ "Semifinal 2"
  end

  test "battlefy connected badge is only shown to those who can manage the bracket", %{
    creator: creator,
    conn: visitor_conn
  } do
    groups = [
      %{name: "Group A", participants: ["P1", "P2", "P3", "P4"]}
    ]

    {:ok, bf_tour} =
      BracketPredictions.create_gsl_into_single_elim_tournament(
        %{
          name: "Battlefy Linked Championship",
          creator_id: creator.id,
          battlefy_tournament_id: "bf_tour_12345"
        },
        groups,
        has_third_place_match: false
      )

    # 1. Creator can see "Battlefy Connected" on index and show pages
    creator_conn = BackendWeb.ConnCase.build_conn_with_user(creator)

    {:ok, _view, creator_index_html} = live(creator_conn, ~p"/bracket-predictions")
    assert creator_index_html =~ "Battlefy Connected"
    assert creator_index_html =~ "Manage"

    {:ok, _view, creator_show_html} = live(creator_conn, ~p"/bracket-predictions/tournaments/#{bf_tour.id}")
    assert creator_show_html =~ "Battlefy Connected"
    assert creator_show_html =~ "Admin Management"

    # 2. Super admin can see "Battlefy Connected" on index and show pages
    super_admin = user_fixture(%{battletag: "SuperAdmin#9999", admin_roles: ["super"]})
    super_conn = BackendWeb.ConnCase.build_conn_with_user(super_admin)

    {:ok, _view, super_index_html} = live(super_conn, ~p"/bracket-predictions")
    assert super_index_html =~ "Battlefy Connected"
    assert super_index_html =~ "Manage"

    {:ok, _view, super_show_html} = live(super_conn, ~p"/bracket-predictions/tournaments/#{bf_tour.id}")
    assert super_show_html =~ "Battlefy Connected"
    assert super_show_html =~ "Admin Management"

    # 3. Regular user CANNOT see "Battlefy Connected" on index or show pages
    regular_user = user_fixture(%{battletag: "RegularPlayer#5678", admin_roles: []})
    regular_conn = BackendWeb.ConnCase.build_conn_with_user(regular_user)

    {:ok, _view, regular_index_html} = live(regular_conn, ~p"/bracket-predictions")
    assert regular_index_html =~ bf_tour.name
    refute regular_index_html =~ "Battlefy Connected"
    refute regular_index_html =~ ~p"/bracket-predictions/tournaments/#{bf_tour.id}/manage"

    {:ok, _view, regular_show_html} = live(regular_conn, ~p"/bracket-predictions/tournaments/#{bf_tour.id}")
    refute regular_show_html =~ "Battlefy Connected"
    refute regular_show_html =~ "Admin Management"

    # 4. Unauthenticated visitor CANNOT see "Battlefy Connected" on index or show pages
    {:ok, _view, visitor_index_html} = live(visitor_conn, ~p"/bracket-predictions")
    assert visitor_index_html =~ bf_tour.name
    refute visitor_index_html =~ "Battlefy Connected"
    refute visitor_index_html =~ ~p"/bracket-predictions/tournaments/#{bf_tour.id}/manage"

    {:ok, _view, visitor_show_html} = live(visitor_conn, ~p"/bracket-predictions/tournaments/#{bf_tour.id}")
    refute visitor_show_html =~ "Battlefy Connected"
    refute visitor_show_html =~ "Admin Management"
  end

  test "user who submitted predictions can view their bracket after the deadline has passed", %{
    tournament: tournament
  } do
    user = user_fixture(%{battletag: "TimelyPredictor#1111"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    # 1. User enters and submits predictions while tournament is open
    {:ok, pred_view, _} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    render_click(pred_view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    render_change(pred_view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:3:1"
    })

    refute has_element?(pred_view, "#header_submit_bracket_btn")

    # 2. Prediction deadline passes
    past_deadline = NaiveDateTime.utc_now() |> NaiveDateTime.add(-3600, :second)

    {:ok, expired_tour} =
      Backend.BracketPredictions.update_tournament(tournament, %{prediction_deadline: past_deadline})

    # 3. User visits /predict after deadline: successfully loads in read-only mode
    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{expired_tour.id}/predict")

    assert html =~ "My Bracket: #{expired_tour.name}"
    assert html =~ "Predictions Closed"
    refute html =~ "Save &amp; Submit Bracket"
    refute has_element?(view, "#header_submit_bracket_btn")
    refute has_element?(view, "#bottom_submit_bracket_btn")
    refute has_element?(view, "input[name='entry_name']")

    # 4. Show page displays "View My Predictions" button and "My Bracket" tab
    {:ok, show_view, show_html} = live(conn, ~p"/bracket-predictions/tournaments/#{expired_tour.id}")
    assert show_html =~ "View My Predictions"
    assert show_html =~ "My Bracket"
    refute show_html =~ "Edit My Predictions"

    # Switch to "My Bracket" tab on tournament show page
    my_bracket_html = render_click(show_view, "switch_tab", %{"tab" => "my_bracket"})
    assert my_bracket_html =~ "My Bracket Predictions:"
    assert my_bracket_html =~ "XiaoT"
  end

  test "shows both actual score and predicted score when they differ, and shows wrong winner as wrong", %{
    tournament: tournament
  } do
    user = user_fixture(%{battletag: "AccuracyTester#2222"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    # 1. User picks XiaoT (3-2) in Opening 1, and PocketTrain (3-1) in Opening 2
    {:ok, pred_view, _} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    render_click(pred_view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    render_change(pred_view, "change_score", %{
      "_target" => ["score_select_g1_opening_1"],
      "score_select_g1_opening_1" => "g1_opening_1:3:2"
    })

    render_click(pred_view, "pick_winner", %{"match_id" => "g1_opening_2", "winner" => "PocketTrain"})

    render_change(pred_view, "change_score", %{
      "_target" => ["score_select_g1_opening_2"],
      "score_select_g1_opening_2" => "g1_opening_2:3:1"
    })

    refute has_element?(pred_view, "#header_submit_bracket_btn")

    # 2. Enter actual results:
    # Opening 1: XiaoT wins 3-1 against Definition
    # - User picked XiaoT (Correct winner!)
    # - XiaoT score: actual 3, predicted 3 (matches -> displays 3 without pred badge)
    # - Definition score: actual 1, predicted 2 (differs! -> displays 1 AND pred: 2)
    op1_match = Enum.find(tournament.matches, &(&1.match_identifier == "g1_opening_1"))
    BracketPredictions.enter_manual_match_result(op1_match.id, "XiaoT", 3, 1)

    # Opening 2: Tansoku wins 3-0 against PocketTrain
    # - User picked PocketTrain (Wrong winner! User picked wrong, Tansoku is actual winner)
    # - PocketTrain: Wrong pick!
    # - Tansoku: Winner!
    # - PocketTrain score: actual 0, predicted 3 (differs! -> displays 0 AND pred: 3)
    # - Tansoku score: actual 3, predicted 1 (differs! -> displays 3 AND pred: 1)
    op2_match = Enum.find(tournament.matches, &(&1.match_identifier == "g1_opening_2"))
    BracketPredictions.enter_manual_match_result(op2_match.id, "Tansoku", 0, 3)

    # 3. View bracket post-deadline
    past_deadline = NaiveDateTime.utc_now() |> NaiveDateTime.add(-3600, :second)

    {:ok, expired_tour} =
      Backend.BracketPredictions.update_tournament(tournament, %{prediction_deadline: past_deadline})

    {:ok, _view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{expired_tour.id}/predict")

    # Correct pick indicator on Opening 1
    assert html =~ "Correct"
    assert html =~ "title=\"Correct pick\""

    # In Opening 1: Definition actual score is 1, predicted was 2 -> both shown, pred to the left of actual
    assert html =~ "pred: 2"
    assert html =~ ~r/pred:\s*2.*Actual score:\s*1/s

    # Predicted (wrong pick) indicator on Opening 2: PocketTrain was predicted but lost
    assert html =~ "Predicted"
    assert html =~ "title=\"Predicted winner\""

    # Actual winner indicator on Opening 2: Tansoku was the actual winner
    assert html =~ "Winner"
    assert html =~ "title=\"Actual winner\""

    # In Opening 2: Tansoku score 3 and pred: 1 differ -> both shown
    assert html =~ "pred: 1"
    # In Opening 2: PocketTrain score 0 and pred: 3 differ -> both shown
    assert html =~ "pred: 3"
  end

  test "unauthenticated visitor cannot fill out bracket predictions on /predict", %{
    conn: conn,
    tournament: tournament
  } do
    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    assert html =~ "Viewing bracket in read-only mode"
    assert html =~ "Sign in with Battle.net"
    assert html =~ "/auth/bnet?redirect_to=/bracket-predictions/tournaments/#{tournament.id}/predict"
    refute html =~ "phx-click=\"pick_winner\""
    refute html =~ "id=\"header_submit_bracket_btn\""

    # Attempting to pick a winner as unauthenticated visitor returns flash error
    assert render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"}) =~
             "You must be logged in to make predictions."

    # Attempting to change score as unauthenticated visitor returns flash error
    assert render_change(view, "change_score", %{
             "_target" => ["score_select_g1_opening_1"],
             "score_select_g1_opening_1" => "g1_opening_1:3:1"
           }) =~ "You must be logged in to change scores."

    # Attempting to update entry name as unauthenticated visitor returns flash error
    assert render_change(view, "update_entry_name", %{"entry_name" => "Hacker Bracket"}) =~
             "You must be logged in to update your bracket name."

    # Attempting to submit as unauthenticated visitor returns flash error
    assert render_click(view, "submit_predictions") =~
             "You must be logged in to submit your predictions."

    # Verify no entries were created in database
    assert BracketPredictions.list_entries_for_tournament(tournament.id) == []
  end

  test "authenticated user changes auto-save immediately to database without clicking submit", %{
    tournament: tournament
  } do
    user = user_fixture(%{battletag: "AutoSaver#1111"})
    conn = BackendWeb.ConnCase.build_conn_with_user(user)

    {:ok, view, html} = live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    assert html =~ "Predict: #{tournament.name}"
    assert html =~ "XiaoT"
    assert html =~ "Saved"

    # Verify submit buttons are NOT shown in auto-saving mode
    refute has_element?(view, "#header_submit_bracket_btn")
    refute has_element?(view, "#bottom_submit_bracket_btn")
    refute html =~ "Save &amp; Submit Bracket"

    # 1. Pick a winner -> auto-saved immediately to database without clicking submit
    render_click(view, "pick_winner", %{"match_id" => "g1_opening_1", "winner" => "XiaoT"})

    entry = BracketPredictions.get_user_entry(tournament.id, user.id)
    assert entry != nil
    assert length(entry.picks) == 1
    p1 = hd(entry.picks)
    assert p1.picked_winner_name == "XiaoT"
    assert p1.predicted_top_score == 3
    assert p1.predicted_bottom_score == 2

    # 2. Change predicted score via form dropdown -> auto-saved immediately to database
    assert has_element?(view, "#score_form_g1_opening_1")
    assert has_element?(view, "#score_select_g1_opening_1")

    form(view, "#score_form_g1_opening_1")
    |> render_change(%{"score_select_g1_opening_1" => "g1_opening_1:3:0"})

    entry = BracketPredictions.get_user_entry(tournament.id, user.id)
    p1 = hd(entry.picks)
    assert p1.predicted_top_score == 3
    assert p1.predicted_bottom_score == 0

    # 3. Change bracket name -> auto-saved immediately to database without clicking submit
    render_change(view, "update_entry_name", %{"entry_name" => "Auto Saved Champion"})

    entry = BracketPredictions.get_user_entry(tournament.id, user.id)
    assert entry.name == "Auto Saved Champion"

    # 4. Reload the page -> all auto-saved picks, scores, and name are restored
    {:ok, reload_view, reload_html} =
      live(conn, ~p"/bracket-predictions/tournaments/#{tournament.id}/predict")

    assert reload_html =~ "Auto Saved Champion"
    assert has_element?(
             reload_view,
             "select[name='score_select_g1_opening_1'] option[value='g1_opening_1:3:0'][selected]"
           )

    # 5. Change score to 3-1 on reloaded view -> persists 3-1 in DB
    form(reload_view, "#score_form_g1_opening_1")
    |> render_change(%{"score_select_g1_opening_1" => "g1_opening_1:3:1"})

    entry = BracketPredictions.get_user_entry(tournament.id, user.id)
    p1 = hd(entry.picks)
    assert p1.predicted_top_score == 3
    assert p1.predicted_bottom_score == 1
  end
end
