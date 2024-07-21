defmodule BackendWeb.LeaderboardControllerTest do
  use BackendWeb.ConnCase
  import Ecto.Query
  alias Backend.Leaderboards.Entry
  alias Backend.Leaderboards

  defp create_entries(rows, season) do
    rows
    |> Enum.sort_by(fn
      %{inserted_at: %NaiveDateTime{} = ia} -> to_string(ia)
      _ -> "99999"
    end)
    |> Enum.map(&Backend.Leaderboards.create_entries([&1], season))
  end

  defp update_inserted_at(rows, season) do
    for %{inserted_at: %NaiveDateTime{} = ia, rank: rank, account_id: account_id, rating: rating} <-
          rows do
      query =
        from e in Entry,
          where:
            e.season_id == ^season.id and e.rank == ^rank and e.account_id == ^account_id and
              e.rating == ^rating

      Backend.Repo.update_all(query, set: [inserted_at: ia])
    end
  end

  ##### PLAYER STATS #####
  describe "/leaderboard/player-stats" do
    @describetag :ldb_player_stats
    test "GET /leaderboard/player-stats works with nil account id", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 50,
        region: "EU"
      }

      rows = [
        %{
          account_id: nil,
          rank: 2,
          rating: 1.0
        },
        %{
          account_id: "D0nkeyHot",
          rank: 1,
          rating: 3.0
        }
      ]

      create_entries(rows, s)

      params = %{"min" => 1}

      url = Routes.leaderboard_path(conn, :player_stats, params)
      conn = get(conn, url)
      assert html_response(conn, 200) =~ "D0nkeyHot"
    end

    test "GET /leaderboard/player-stats BG Doesn't include STD D0nkeyHot", %{conn: conn} do
      params = %{
        "leaderboards" => %{"BG" => true},
        "min" => 1
      }

      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 50,
        region: "EU"
      }

      rows = [
        %{
          account_id: "D0nkeyHot",
          rank: 3,
          rating: 91.0
        }
      ]

      create_entries(rows, s)

      url = Routes.leaderboard_path(conn, :player_stats, params)
      conn = get(conn, url)
      refute html_response(conn, 200) =~ "D0nkeyHot"
    end
  end

  ##### LEADERBOARD #####

  describe "/leaderboards" do
    @describetag :leaderboards
    @tag :external
    test "Save all and GET /leaderboard/region=EU&season_id=84&leaderboard_id=BG INCLUDES D0nkey",
         %{conn: conn} do
      season = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 123,
        region: "EU"
      }

      Backend.Leaderboards.save_all(season, 25)

      url = Routes.leaderboard_path(conn, :index, Map.from_struct(season))
      conn = get(conn, url)
      assert html_response(conn, 200) =~ "/player-profile/D0nkey"
    end

    test "return ldb with nil account id", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "BG",
        season_id: 50,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)

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

      create_entries(rows, s)

      params = Map.from_struct(s)

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)
      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)

      Backend.Repo.delete_all(
        from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id
      )

      Backend.Repo.delete(season)
      assert html_response(conn, 200) =~ "D0nkeyHot"
    end

    test "compare to return the right diff", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "BG",
        season_id: 50,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -1, :minute)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 334.0,
          inserted_at: NaiveDateTime.add(now, -15, :minute)
        },
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 88.0,
          inserted_at: NaiveDateTime.add(now, -80, :minute)
        }
      ]

      create_entries(rows, s)
      update_inserted_at(rows, season)

      params =
        Map.from_struct(s)
        |> Map.put("compare_to", "min_ago_10")
        |> Map.put("show_ratings", "yes")

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)
      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)

      Backend.Repo.delete_all(
        from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id
      )

      Backend.Repo.delete(season)
      assert html_response(conn, 200) =~ "↓243"
      refute html_response(conn, 200) =~ "334"
    end

    test "until and compare to return the right diff", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "BG",
        season_id: 50,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)

      now = NaiveDateTime.utc_now()

      rows = [
        %{
          account_id: "D0nkey",
          rank: 1,
          rating: 91.0,
          inserted_at: NaiveDateTime.add(now, -1, :minute)
        },
        %{
          account_id: "D0nkey",
          rank: 6,
          rating: 334.0,
          inserted_at: NaiveDateTime.add(now, -12, :minute)
        },
        %{
          account_id: "D0nkey",
          rank: 3,
          rating: 34.0,
          inserted_at: NaiveDateTime.add(now, -22, :minute)
        }
      ]

      create_entries(rows, s)
      update_inserted_at(rows, season)

      params =
        Map.from_struct(s)
        |> Map.put("compare_to", "min_ago_10")
        |> Map.put("up_to", NaiveDateTime.add(now, -3, :minute) |> NaiveDateTime.to_iso8601())
        |> Map.put("show_ratings", "yes")

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)

      Backend.Repo.delete_all(from e in Entry, where: e.season_id == ^season.id)

      Backend.Repo.delete_all(
        from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id
      )

      Backend.Repo.delete(season)
      refute html_response(conn, 200) =~ ">91</td>"
      assert html_response(conn, 200) =~ "↑300"
    end

    test "player rating history returns the right diff", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "BG",
        season_id: 50,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)

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

      create_entries(rows, s)

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

      Backend.Repo.delete_all(
        from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id
      )

      Backend.Repo.delete(season)
      assert html_response(conn, 200) =~ "↓243"
      assert html_response(conn, 200) =~ "↑246"
    end

    test "player rating returns other ladder", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "BG",
        # Orgrimmar
        season_id: 666,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)
      {:ok, other_season} = s |> Map.put(:region, "AP") |> Leaderboards.get_season()

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

      create_entries(rows, s)

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

      create_entries(other_rows, other_season)

      params = Map.from_struct(s)

      url = Routes.leaderboard_path(conn, :index, params)
      conn = get(conn, url)

      Backend.Repo.delete_all(
        from e in Entry, where: e.season_id in [^season.id, ^other_season.id]
      )

      Backend.Repo.delete_all(
        from e in {"leaderboards_current_entries", Entry},
          where: e.season_id in [^season.id, ^other_season.id]
      )

      Backend.Repo.delete(season)
      Backend.Repo.delete(other_season)
      assert html_response(conn, 200) =~ "D0nley"
      refute html_response(conn, 200) =~ "PLEASE NO"
      # refute html_response(conn, 200) =~ "AP #3"
      # assert html_response(conn, 200) =~ "AP #2"
    end
  end
end
