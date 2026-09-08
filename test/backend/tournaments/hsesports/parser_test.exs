defmodule Backend.Tournaments.HSEsports.ParserTest do
  use ExUnit.Case, async: false
  alias Backend.Tournaments.HSEsports.Parser
  alias Backend.Tournaments.MatchStats
  alias Backend.Hearthstone.Lineup
  alias Backend.Hearthstone.Deck

  alias Backend.Tournaments.HSEsportsFixtures

  @test_csv HSEsportsFixtures.sample_csv()

  describe "parse/2 on sample CSV" do
    test "successfully parses tournament groups, playoffs, and all 27 matches" do
      assert {:ok, parsed} = Parser.parse(@test_csv)

      assert length(parsed.groups) == 4
      assert length(parsed.playoffs) == 7
      assert length(parsed.matches) == 27

      group_names = Enum.map(parsed.groups, & &1.name)
      assert group_names == ["Group A", "Group B", "Group C", "Group D"]

      for group <- parsed.groups do
        assert length(group.matches) == 5
      end
    end

    test "parses match details, scores, and Bo5 winner correctly for completed matches" do
      {:ok, parsed} = Parser.parse(@test_csv)
      g1_op1 = Enum.find(parsed.matches, &(&1.match_identifier == "g1_opening_1"))

      assert g1_op1.top_name == "McBanterFace"
      assert g1_op1.bottom_name == "Soyorin"
      assert g1_op1.top_score == 2
      assert g1_op1.bottom_score == 3
      assert g1_op1.actual_winner_name == "Soyorin"
      assert g1_op1.is_complete == true
      assert length(g1_op1.completed_games) == 5
    end

    test "parses bans: class below P1 Ban is P1's ban (P2 deck), class below P2 Ban is P2's ban (P1 deck)" do
      {:ok, parsed} = Parser.parse(@test_csv)
      g1_op1 = Enum.find(parsed.matches, &(&1.match_identifier == "g1_opening_1"))

      # In test.csv for g1_op1, both players banned Warrior
      assert g1_op1.p1_banned_class == "Warrior"
      assert g1_op1.p2_banned_class == "Warrior"
    end

    test "propagates bracket sources (winners advance to winners match, losers drop to elim match)" do
      {:ok, parsed} = Parser.parse(@test_csv)

      g1_win = Enum.find(parsed.matches, &(&1.match_identifier == "g1_winners"))
      g1_elim = Enum.find(parsed.matches, &(&1.match_identifier == "g1_elim"))

      # g1_op1 winner was Soyorin -> propagates to top of g1_winners
      assert g1_win.top_name == "Soyorin"
      # g1_op1 loser was McBanterFace -> propagates to top of g1_elim
      assert g1_elim.top_name == "McBanterFace"
    end

    test "terminates Bo5 at 3 wins even if subsequent rows exist" do
      # Synthetic CSV where p1 wins 3-0, but 5 games are listed
      synthetic_csv = """
      Stage,Match #,Game #,Player 1,P1 Deck Used,Player 2,P2 Deck Used,Winner,Bans
      Group A,Initial Match 1,1,Alice,Mage,Bob,Warrior,Alice,P1 Ban
      ,,2,Alice,Mage,Bob,Warrior,Alice,Hunter
      ,,3,Alice,Mage,Bob,Warrior,Alice,P2 Ban
      ,,4,Alice,Mage,Bob,Warrior,Bob,Paladin
      ,,5,Alice,Mage,Bob,Warrior,Bob,
      """

      {:ok, parsed} = Parser.parse(synthetic_csv)
      match = Enum.find(parsed.matches, &(&1.match_identifier == "g1_opening_1"))

      assert match.top_score == 3
      assert match.bottom_score == 0
      assert match.actual_winner_name == "Alice"
      assert match.is_complete == true
      # Only 3 completed games recorded before halting
      assert length(match.completed_games) == 3
      assert match.p1_banned_class == "Hunter"
      assert match.p2_banned_class == "Paladin"
    end

    test "generates MatchStats with resolved archetypes when lineups are provided" do
      dummy_lineup_soyorin = %Lineup{
        name: "Soyorin#1234",
        decks: [
          %Deck{class: :warrior, archetype: "Control Warrior"},
          %Deck{class: :demonhunter, archetype: "Shopper Demon Hunter"},
          %Deck{class: :druid, archetype: "Dragon Druid"},
          %Deck{class: :warlock, archetype: "Insanity Warlock"}
        ]
      }

      dummy_lineup_mcbanter = %Lineup{
        name: "McBanterFace#5678",
        decks: [
          %Deck{class: :warrior, archetype: "Odyn Warrior"},
          %Deck{class: :demonhunter, archetype: "Shopper Demon Hunter"},
          %Deck{class: :druid, archetype: "Highlander Druid"},
          %Deck{class: :warlock, archetype: "Pain Warlock"}
        ]
      }

      {:ok, parsed} = Parser.parse(@test_csv, [dummy_lineup_soyorin, dummy_lineup_mcbanter])

      assert Enum.any?(parsed.match_stats)
      stat = List.first(parsed.match_stats)

      assert %MatchStats{} = stat
      assert is_list(stat.banned)
      assert is_list(stat.not_banned)
      assert is_list(stat.results)

      # Odyn Warrior and Control Warrior were banned
      assert "Odyn Warrior" in stat.banned or "Control Warrior" in stat.banned
      assert length(stat.results) == 5
    end

    test "extracts won and lost decks and enriches completed games for matches" do
      {:ok, parsed} = Parser.parse(@test_csv)
      g1_op1 = Enum.find(parsed.matches, &(&1.match_identifier == "g1_opening_1"))

      assert g1_op1.top_won_decks == ["Demon Hunter", "Druid"]
      assert g1_op1.top_lost_decks == ["Demon Hunter", "Druid", "Warlock"]
      assert g1_op1.bottom_won_decks == ["Demon Hunter", "Druid", "Warlock"]
      assert g1_op1.bottom_lost_decks == ["Druid", "Warlock"]

      [g1, g2, g3, g4, g5] = g1_op1.completed_games

      assert g1.game_number == 1
      assert g1.top_deck == "Demon Hunter"
      assert g1.bottom_deck == "Demon Hunter"
      assert g1.top_won? == false
      assert g1.bottom_won? == true
      assert g1.winning_deck == "Demon Hunter"
      assert g1.losing_deck == "Demon Hunter"

      assert g2.game_number == 2
      assert g2.top_deck == "Demon Hunter"
      assert g2.bottom_deck == "Druid"
      assert g2.top_won? == true
      assert g2.bottom_won? == false
      assert g2.winning_deck == "Demon Hunter"
      assert g2.losing_deck == "Druid"

      assert g3.game_number == 3
      assert g3.top_won? == false
      assert g3.bottom_won? == true
      assert g3.winning_deck == "Druid"

      assert g4.game_number == 4
      assert g4.top_won? == true
      assert g4.bottom_won? == false
      assert g4.winning_deck == "Druid"
      assert g4.losing_deck == "Warlock"

      assert g5.game_number == 5
      assert g5.top_deck == "Warlock"
      assert g5.bottom_deck == "Warlock"
      assert g5.top_won? == false
      assert g5.bottom_won? == true
      assert g5.winning_deck == "Warlock"

      # Deck statuses with class slugs and won/lost/banned status
      assert length(g1_op1.top_deck_statuses) == 4
      assert Enum.map(g1_op1.top_deck_statuses, & &1.status) == [:won, :won, :lost, :banned]
      assert Enum.map(g1_op1.top_deck_statuses, & &1.class_slug) == ["demonhunter", "druid", "warlock", "warrior"]

      assert length(g1_op1.bottom_deck_statuses) == 4
      assert Enum.map(g1_op1.bottom_deck_statuses, & &1.status) == [:won, :won, :won, :banned]
      assert Enum.map(g1_op1.bottom_deck_statuses, & &1.class_slug) == ["demonhunter", "druid", "warlock", "warrior"]

      # Game-by-game results (same deck can appear multiple times with won/lost for each game)
      assert length(g1_op1.top_game_decks) == 5
      assert Enum.map(g1_op1.top_game_decks, & &1.status) == [:lost, :won, :lost, :won, :lost]

      assert Enum.map(g1_op1.top_game_decks, & &1.class_slug) == [
               "demonhunter",
               "demonhunter",
               "druid",
               "druid",
               "warlock"
             ]

      assert g1_op1.top_banned_deck.status == :banned
      assert g1_op1.top_banned_deck.class_slug == "warrior"

      assert length(g1_op1.bottom_game_decks) == 5
      assert Enum.map(g1_op1.bottom_game_decks, & &1.status) == [:won, :lost, :won, :lost, :won]

      assert Enum.map(g1_op1.bottom_game_decks, & &1.class_slug) == [
               "demonhunter",
               "druid",
               "druid",
               "warlock",
               "warlock"
             ]

      assert g1_op1.bottom_banned_deck.status == :banned
      assert g1_op1.bottom_banned_deck.class_slug == "warrior"
    end

    test "marks matches as ongoing when games/bans exist but match is not complete" do
      ongoing_csv = HSEsportsFixtures.sample_ongoing_csv()
      assert {:ok, parsed} = Parser.parse(ongoing_csv)

      g1_op1 = Enum.find(parsed.matches, &(&1.match_identifier == "g1_opening_1"))
      assert g1_op1.is_complete == false
      assert g1_op1.is_ongoing == true
      assert g1_op1.top_score == 0
      assert g1_op1.bottom_score == 1
    end
  end
end
