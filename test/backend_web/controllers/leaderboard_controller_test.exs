defmodule BackendWeb.LeaderboardControllerTest do
  use BackendWeb.ConnCase
  import Ecto.Query
  alias Backend.Leaderboards.Entry

  ##### PLAYER STATS #####
  describe "/leaderboard/player-stats" do
    @describetag :ldb_player_stats
    test "GET /leaderboard/player-stats works with nil account id", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 50,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: nil,
          rank: 2,
          rating: 1.0
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)
      Backend.Leaderboards.refresh_latest()

      params = %{}

      url = Routes.leaderboard_path(conn, :player_stats, params)
      conn = get(conn, url)
      assert html_response(conn, 200) =~ "D0nkey"
    end

    test "GET /leaderboard/player-stats INCLUDES D0nkeyHot", %{conn: conn} do
      params = %{
        "country" => %{"HR" => true}
      }

      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 50,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkeyHot",
          rank: 1,
          rating: 91.0
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)
      Backend.Leaderboards.refresh_latest()

      url = Routes.leaderboard_path(conn, :player_stats, params)
      conn = get(conn, url)
      assert html_response(conn, 200) =~ "/player-profile/D0nkeyHot"
    end
  end

  ##### LEADERBOARD #####

  describe "/leaderboards" do
    @describetag :leaderboards
    test "Save all and GET /leaderboard/region=EU&season_id=84&leaderboard_id=STD INCLUDES D0nkey",
         %{conn: conn} do
      season = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 84,
        region: "EU"
      }

      Backend.Leaderboards.save_all(season)

      url = Routes.leaderboard_path(conn, :index, Map.from_struct(season))
      conn = get(conn, url)
      assert html_response(conn, 200) =~ "/player-profile/D0nkey"
    end

    test "return ldb with nil account id", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: -50,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkeyHot",
          rank: 1,
          rating: 91.0
        },
        %{
          account_id: nil,
          rank: 2,
          rating: 1.0
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)

      params = Map.from_struct(s)

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)
      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)
      Backend.Repo.delete(season)
      assert html_response(conn, 200) =~ "D0nkeyHot"
    end

    test "compare to return the right diff", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: -50,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -60)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 334.0,
          inserted_at: NaiveDateTime.add(now, -60 * 12)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 1.0,
          inserted_at: NaiveDateTime.add(now, -60 * 22)
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)

      params =
        Map.from_struct(s)
        |> Map.put("compare_to", "min_ago_10")
        |> Map.put("show_ratings", "yes")

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)
      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)
      Backend.Repo.delete(season)
      assert html_response(conn, 200) =~ "↓243"
      refute html_response(conn, 200) =~ "334"
    end

    test "until and compare to return the right diff", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: -50,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -60)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 334.0,
          inserted_at: NaiveDateTime.add(now, -60 * 12)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 88.0,
          inserted_at: NaiveDateTime.add(now, -60 * 22)
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)

      params =
        Map.from_struct(s)
        |> Map.put("compare_to", "min_ago_10")
        |> Map.put("up_to", NaiveDateTime.add(now, -240) |> to_string())
        |> Map.put("show_ratings", "yes")

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)
      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)
      Backend.Repo.delete(season)
      refute html_response(conn, 200) =~ "91"
      assert html_response(conn, 200) =~ "↑246"
    end

    test "player rating history returns the right diff", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: -50,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -60)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 334.0,
          inserted_at: NaiveDateTime.add(now, -60 * 12)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 88.0,
          inserted_at: NaiveDateTime.add(now, -60 * 22)
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)

      url =
        Routes.leaderboard_path(
          conn,
          :player_history,
          s.region,
          "past_weeks_1",
          s.leaderboard_id,
          "D0nkey",
          %{"attr" => "rating"}
        )

      conn = get(conn, url)
      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)
      Backend.Repo.delete(season)
      assert html_response(conn, 200) =~ "↓243"
      assert html_response(conn, 200) =~ "↑246"
    end

    test "player rating returns other ladder", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        # Orgrimmar
        season_id: 88,
        region: "EU"
      }

      {:ok, season} = Backend.Leaderboards.SeasonBag.get(s)
      {:ok, other_season} = s |> Map.put(:region, "AP") |> Backend.Leaderboards.SeasonBag.get()

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nley",
          rank: 1,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -60)
        },
        %{
          account_id: "BlaBLa",
          rank: 3,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -60)
        }
      ]

      Backend.Leaderboards.create_entries(rows, s)

      other_rows = [
        %{
          account_id: "AAAAAAAAAAAAAAAAAAAaa",
          rank: 1,
          rating: 61.0,
          inserted_at: NaiveDateTime.add(now, -90)
        },
        %{
          account_id: "D0nley",
          rank: 2,
          rating: 61.0,
          inserted_at: NaiveDateTime.add(now, -90)
        },
        %{
          account_id: "AAAAAAA",
          rank: 3,
          rating: 61.0,
          inserted_at: NaiveDateTime.add(now, -90)
        },
        %{
          account_id: "PLEASE NO",
          rank: 4,
          rating: 66.0,
          inserted_at: NaiveDateTime.add(now, -90)
        }
      ]

      Backend.Leaderboards.create_entries(other_rows, other_season)

      params = Map.from_struct(s)

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)

      Backend.Repo.delete_all(
        from e in Entry, where: e.season_id in [^season.id, ^other_season.id]
      )

      Backend.Repo.delete(season)
      Backend.Repo.delete(other_season)
      assert html_response(conn, 200) =~ "D0nley"
      refute html_response(conn, 200) =~ "PLEASE NO"
      refute html_response(conn, 200) =~ "AP #3"
      assert html_response(conn, 200) =~ "AP #2"
    end
  end
end
