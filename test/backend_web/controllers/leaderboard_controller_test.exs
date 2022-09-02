defmodule BackendWeb.LeaderboardControllerTest do
  use BackendWeb.ConnCase
  import Ecto.Query
  alias Backend.Leaderboards.Entry

  ##### PLAYER STATS #####
  test "GET /leaderboard/player-stats?country[HR]=true INCLUDES D0nkey and no flag", %{conn: conn} do
    params = %{
      "country" => %{"HR" => true}
    }

    url = Routes.leaderboard_path(conn, :player_stats, params)
    conn = get(conn, url)
    assert html_response(conn, 200)
  end

  ##### LEADERBOARD #####

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
        rating: 91,
        inserted_at: NaiveDateTime.add(now, -60)
      },
      %{
        account_id: "D0nkey",
        rank: 1,
        rating: 334,
        inserted_at: NaiveDateTime.add(now, -60 * 12)
      },
      %{
        account_id: "D0nkey",
        rank: 1,
        rating: 1,
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
        rating: 91,
        inserted_at: NaiveDateTime.add(now, -60)
      },
      %{
        account_id: "D0nkey",
        rank: 1,
        rating: 334,
        inserted_at: NaiveDateTime.add(now, -60 * 12)
      },
      %{
        account_id: "D0nkey",
        rank: 1,
        rating: 88,
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
    refute html_response(conn, 200) =~ "91.0"
    assert html_response(conn, 200) =~ "↑246.0"
    refute html_response(conn, 200) =~ "88.0"
  end
end
