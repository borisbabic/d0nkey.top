defmodule Backend.LeaderboardsPointsTest do
  @moduledoc false
  use Backend.DataCase
  alias Backend.LeaderboardsPoints

  test "TEST PERSON has 8 for january and 6 for february" do
    for {s, rank} <- [{111, 1}, {112, 7}] do
      season = %Hearthstone.Leaderboards.Season{season_id: s, region: "US", leaderboard_id: "STD"}

      Backend.Leaderboards.create_entries(
        [%{rank: rank, account_id: "TEST PERSON", rating: nil}],
        season
      )
    end

    Backend.Leaderboards.refresh_latest()

    points = LeaderboardsPoints.calculate("2023_spring", "STD")

    {"TEST PERSON", season_points, 14} = points |> Enum.find(&(elem(&1, 0) == "TEST PERSON"))
    # January
    assert {_, _, 8} = Enum.find(season_points, &(elem(&1, 0) == 111))
    # February
    assert {_, _, 6} = Enum.find(season_points, &(elem(&1, 0) == 112))
  end
end
