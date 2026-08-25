defmodule Backend.Leaderboards.SeasonsTest do
  use BackendWeb.ConnCase, async: false
  alias Backend.Leaderboards.Seasons
  alias Backend.Blizzard
  alias BackendWeb.LeaderboardView

  setup do
    Seasons.seed_defaults()
    :ok
  end

  describe "default seasons" do
    test "returns expected default seasons for BG" do
      seasons = Seasons.get_seasons(:BG, :EU)
      assert is_list(seasons)
      assert {"Season 14", 19} in seasons
      assert Seasons.get_current_season(:BG, :EU) == 19
      assert Seasons.get_season_name(19, :BG, :EU) == "Season 14"
      assert Seasons.get_season_name(18, :BG, :EU) == "Season 13"
    end

    test "returns expected default seasons for DUO" do
      seasons = Seasons.get_seasons(:DUO, :EU)
      assert is_list(seasons)
      assert {"Season 14", 19} in seasons
      assert Seasons.get_current_season(:DUO, :EU) == 19
      assert Seasons.get_season_name(19, :DUO, :EU) == "Season 14"
    end

    test "returns expected default seasons for undergroundarena" do
      seasons = Seasons.get_seasons(:undergroundarena, :EU)
      assert is_list(seasons)
      assert {"Season 8", 8} in seasons
      assert Seasons.get_current_season(:undergroundarena, :EU) == 8
      assert Seasons.get_season_name(8, :undergroundarena, :EU) == "Season 8"
    end

    test "returns expected default seasons for arena" do
      seasons = Seasons.get_seasons(:arena, :EU)
      assert is_list(seasons)
      assert {"Season 56", 56} in seasons
      assert Seasons.get_current_season(:arena, :EU) == 56
      assert Seasons.get_season_name(56, :arena, :EU) == "Season 56"
    end
  end

  describe "Blizzard module integration" do
    test "Blizzard.get_current_ladder_season/1 returns current season from Seasons" do
      assert Blizzard.get_current_ladder_season(:BG) == Seasons.get_current_season(:BG)
      assert Blizzard.get_current_ladder_season("BG") == Seasons.get_current_season(:BG)
      assert Blizzard.get_current_ladder_season(:DUO) == Seasons.get_current_season(:DUO)
      assert Blizzard.get_current_ladder_season("DUO") == Seasons.get_current_season(:DUO)
      assert Blizzard.get_current_ladder_season(:arena) == Seasons.get_current_season(:arena)
      assert Blizzard.get_current_ladder_season(:undergroundarena) == Seasons.get_current_season(:undergroundarena)
    end

    test "Blizzard.get_season_name/2 returns display name from Seasons" do
      assert Blizzard.get_season_name(19, :BG) == "Season 14"
      assert Blizzard.get_season_name(19, "BG") == "Season 14"
      assert Blizzard.get_season_name(19, :DUO) == "Season 14"
      assert Blizzard.get_season_name(56, :arena) == "Season 56"
      assert Blizzard.get_season_name(8, :undergroundarena) == "Season 8"
    end
  end

  describe "LeaderboardView.create_selectable_seasons/2" do
    test "returns tracked seasons for BG, DUO, arena, and undergroundarena" do
      assert {:ok, bg_seasons} = LeaderboardView.create_selectable_seasons(:BG, :EU)
      assert length(bg_seasons) <= 7
      assert {"Season 14", 19} = hd(bg_seasons)

      assert {:ok, duo_seasons} = LeaderboardView.create_selectable_seasons(:DUO, :EU)
      assert length(duo_seasons) <= 7
      assert {"Season 14", 19} = hd(duo_seasons)

      assert {:ok, ug_seasons} = LeaderboardView.create_selectable_seasons(:undergroundarena, :EU)
      assert length(ug_seasons) <= 7
      assert {"Season 8", 8} = hd(ug_seasons)

      assert {:ok, arena_seasons} = LeaderboardView.create_selectable_seasons(:arena, :EU)
      assert length(arena_seasons) <= 7
      assert {"Season 56", 56} = hd(arena_seasons)
    end

    test "returns monthly seasons for STD" do
      assert {:ok, std_seasons} = LeaderboardView.create_selectable_seasons(:STD, :EU)
      assert length(std_seasons) == 7
      {name, season_id} = hd(std_seasons)
      assert is_binary(to_string(name))
      assert is_integer(season_id)
    end
  end

  describe "update_from_metadata/1" do
    test "updates ETS table with parsed season metadata" do
      raw_metadata = %{
        "EU" => %{
          "battlegrounds" => %{
            "name" => "battlegrounds",
            "ratingId" => 50,
            "seasons" => [
              %{
                "season_id" => 20,
                "display_name" => %{"en_US" => "Season 15"}
              },
              %{
                "season_id" => 19,
                "display_name" => %{"en_US" => "Season 14"}
              }
            ]
          },
          "battlegroundsduo" => %{
            "name" => "battlegroundsduo",
            "ratingId" => 65,
            "seasons" => [
              %{
                "season_id" => 20,
                "display_name" => %{"en_US" => "Season 15"}
              }
            ]
          },
          "arena" => %{
            "name" => "arena",
            "ratingId" => 3,
            "seasons" => [
              %{"season_id" => 57}
            ]
          },
          "undergroundarena" => %{
            "name" => "undergroundarena",
            "ratingId" => 73,
            "seasons" => [
              %{"season_id" => 9}
            ]
          }
        },
        "US" => %{},
        "AP" => %{}
      }

      assert :ok = Seasons.update_from_metadata(raw_metadata)

      assert Seasons.get_current_season(:BG, :EU) == 20
      assert Seasons.get_season_name(20, :BG, :EU) == "Season 15"
      assert Seasons.get_season_name(19, :BG, :EU) == "Season 14"

      assert Seasons.get_current_season(:DUO, :EU) == 20
      assert Seasons.get_season_name(20, :DUO, :EU) == "Season 15"

      assert Seasons.get_current_season(:arena, :EU) == 57
      assert Seasons.get_season_name(57, :arena, :EU) == "Season 57"

      assert Seasons.get_current_season(:undergroundarena, :EU) == 9
      assert Seasons.get_season_name(9, :undergroundarena, :EU) == "Season 9"
    end
  end
end
