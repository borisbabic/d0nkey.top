defmodule BackendWeb.LeaderboardControllerTest do
  use BackendWeb.ConnCase
  import Ecto.Query
  alias Backend.Leaderboards.Entry
  alias Backend.Leaderboards.SeasonSize
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

  ######## POINTS ########

  describe "/leaderboard/points" do
    @describetag :ldb_points
    test "GET /leaderboard/points doesn't error", %{conn: conn} do
      url = Routes.leaderboard_path(conn, :points, %{})
      conn = get(conn, url)
      assert html_response(conn, 200)
    end
  end

  ##### PLAYER STATS #####
  describe "/leaderboard/player-stats" do
    @describetag :ldb_player_stats
    test "GET /leaderboard/player-stats returns 401 when not logged in", %{conn: conn} do
      url = Routes.leaderboard_path(conn, :player_stats, %{})
      conn = get(conn, url)
      assert html_response(conn, 401)
    end

    @tag :authenticated
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

    @tag :authenticated
    test "GET /leaderboard/player-stats BG Doesn't include STD D0nkeyHot", %{conn: conn, user: _} do
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
      refute html_response(conn, 200) =~ "d0nkeyhot"
    end

    @tag :authenticated
    test "GET /leaderboard/player-stats doesn't include {@cell}", %{conn: conn} do
      url = Routes.leaderboard_path(conn, :player_stats)
      conn = get(conn, url)
      refute html_response(conn, 200) =~ "{@cell}"
    end
  end

  ##### LEADERBOARD #####

  describe "/leaderboards" do
    @describetag :leaderboards
    @describetag :authenticated
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

      Backend.Repo.delete_all(from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id)

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

      Backend.Repo.delete_all(from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id)

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

      Backend.Repo.delete_all(from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id)

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

      Backend.Repo.delete_all(from e in {"leaderboards_current_entries", Entry}, where: e.season_id == ^season.id)

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

      Backend.Repo.delete_all(from e in Entry, where: e.season_id in [^season.id, ^other_season.id])

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

  describe "/leaderboard/size-history" do
    @describetag :leaderboard_size_history
    @describetag :authenticated

    test "records size history and prevents duplicate entries for same size" do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 150,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      # Record initial size
      {:ok, %SeasonSize{total_size: 500}} =
        Leaderboards.record_season_size(season, 500, NaiveDateTime.add(now, -3600))

      # Record duplicate size - should be noop
      assert {:ok, :noop} =
               Leaderboards.record_season_size(season, 500, NaiveDateTime.add(now, -1800))

      # Record increased size
      {:ok, %SeasonSize{total_size: 1200}} =
        Leaderboards.record_season_size(season, 1200, now)

      sizes = Leaderboards.size_history("EU", "season_150", "STD")
      assert length(sizes) == 2

      [first, second] = sizes
      assert first.total_size == 500
      assert first.prev_total_size == nil
      assert second.total_size == 1200
      assert second.prev_total_size == 500

      Backend.Repo.delete_all(from sz in SeasonSize, where: sz.season_id == ^season.id)
      Backend.Repo.delete(season)
    end

    test "update_total_size updates season and records size history" do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "BG",
        season_id: 60,
        region: "US"
      }

      {:ok, season} = Leaderboards.get_season(s)
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      Leaderboards.update_total_size(season, 800, NaiveDateTime.add(now, -7200))
      {:ok, updated_season} = Leaderboards.get_season(s)
      assert updated_season.total_size == 800

      Leaderboards.update_total_size(season, 1500, now)
      {:ok, updated_season_2} = Leaderboards.get_season(s)
      assert updated_season_2.total_size == 1500

      history = Leaderboards.size_history("US", "season_60", "BG")
      assert length(history) == 2
      assert Enum.map(history, & &1.total_size) == [800, 1500]

      Backend.Repo.delete_all(from sz in SeasonSize, where: sz.season_id == ^season.id)
      Backend.Repo.delete(season)
    end

    test "aggregate_size_history groups by day and hour and computes increases accurately" do
      t1 = ~N[2026-08-20 10:00:00]
      t2 = ~N[2026-08-20 18:30:00]
      t3 = ~N[2026-08-21 09:15:00]

      history = [
        %{total_size: 100, upstream_updated_at: t1, prev_total_size: nil},
        %{total_size: 180, upstream_updated_at: t2, prev_total_size: 100},
        %{total_size: 320, upstream_updated_at: t3, prev_total_size: 180}
      ]

      daily = Leaderboards.aggregate_size_history(history, :day)
      assert length(daily) == 2
      [d1, d2] = daily
      assert d1.period_label == "2026-08-20"
      assert d1.total_size == 180
      assert d1.increase == 80
      assert d2.period_label == "2026-08-21"
      assert d2.total_size == 320
      assert d2.increase == 140
      assert d2.prev_increase == 80

      hourly = Leaderboards.aggregate_size_history(history, :hour)
      assert length(hourly) == 3
      [h1, h2, h3] = hourly
      assert h1.period_label == "2026-08-20 10:00"
      assert h1.increase == 0
      assert h2.period_label == "2026-08-20 18:00"
      assert h2.increase == 80
      assert h3.period_label == "2026-08-21 09:00"
      assert h3.increase == 140
    end

    test "GET /leaderboard/size-history returns 200 and renders daily and hourly increase tables", %{
      conn: conn
    } do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 151,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)
      now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

      Leaderboards.record_season_size(season, 1000, NaiveDateTime.add(now, -86_400))
      Leaderboards.record_season_size(season, 1350, now)

      # Default Total Players snapshot view
      url =
        Routes.leaderboard_path(
          conn,
          :size_history,
          "EU",
          "season_151",
          "STD"
        )

      conn = get(conn, url)
      assert html_response(conn, 200) =~ "Standard Europe Size History"
      assert html_response(conn, 200) =~ "1350"
      assert html_response(conn, 200) =~ "↑350"
      assert html_response(conn, 200) =~ "leaderboard_size_history_table"

      # Daily Increase view
      daily_url =
        Routes.leaderboard_path(
          conn,
          :size_history,
          "EU",
          "season_151",
          "STD",
          %{"attr" => "daily"}
        )

      daily_conn = get(conn, daily_url)
      assert html_response(daily_conn, 200) =~ "Standard Europe Daily Increase"
      assert html_response(daily_conn, 200) =~ "Day"
      assert html_response(daily_conn, 200) =~ "Increase"
      assert html_response(daily_conn, 200) =~ "350"

      # Hourly Increase view
      hourly_url =
        Routes.leaderboard_path(
          conn,
          :size_history,
          "EU",
          "season_151",
          "STD",
          %{"attr" => "hourly"}
        )

      hourly_conn = get(conn, hourly_url)
      assert html_response(hourly_conn, 200) =~ "Standard Europe Hourly Increase"
      assert html_response(hourly_conn, 200) =~ "Hour"
      assert html_response(hourly_conn, 200) =~ "Increase"

      Backend.Repo.delete_all(from sz in SeasonSize, where: sz.season_id == ^season.id)
      Backend.Repo.delete(season)
    end

    test "GET /leaderboard includes size history link when total size exists", %{conn: conn} do
      s = %Hearthstone.Leaderboards.Season{
        leaderboard_id: "STD",
        season_id: 152,
        region: "EU"
      }

      {:ok, season} = Leaderboards.get_season(s)
      Leaderboards.update_total_size(season, 2500)

      url = Routes.leaderboard_path(conn, :index, Map.from_struct(s))
      conn = get(conn, url)

      assert html_response(conn, 200) =~ "Total Players: 2500"
      assert html_response(conn, 200) =~ "/leaderboard/count-history/region/EU/period/season_152/leaderboard_id/STD"

      Backend.Repo.delete_all(from sz in SeasonSize, where: sz.season_id == ^season.id)
      Backend.Repo.delete(season)
    end
  end
end
