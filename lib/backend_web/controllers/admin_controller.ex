defmodule BackendWeb.AdminController do
  use BackendWeb, :controller

  def get_all_leaderboards(conn, _params) do
    current_season = Date.utc_today() |> Backend.Blizzard.get_season_id()

    for ldb <- ["WLD", "STD"],
        season_id <- 63..current_season,
        region <- Backend.Blizzard.qualifier_regions() do
      Backend.Leaderboards.get_leaderboard(region, ldb, season_id)
    end

    "Success!"
  end
end
