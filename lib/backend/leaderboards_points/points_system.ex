defmodule Backend.LeaderboardsPoints.PointsSystem do
  alias Backend.Leaderboards.Entry
  @moduledoc false
  @callback points_for_rank(rank :: integer()) :: {:ok, integer()} | {:error, :reason}
  @callback points_for_rank!(rank :: integer()) :: integer()

  @callback get_relevant_ldb_seasons(
              season_slug :: String.t(),
              leaderboard_id :: String.t(),
              use_current :: boolean
            ) :: [integer()]
  @callback get_relevant_ldb_regions(season_slug :: String.t(), leaderboard_id :: String.t()) :: [
              atom()
            ]
  @callback filter_player_rows(
              Backend.LeaderboardsPoints.player_row(),
              season_slug :: String.t(),
              leadeboard_id :: String.t()
            ) :: boolean()
  @callback points_seasons() :: season_slugs :: [String.t()]

  @callback max_rank(season_slug :: String.t(), leaderboard_id :: String.t()) ::
              max_rank :: integer()

  @callback info_links(season_slug :: String.t()) :: [%{display: String.t(), link: String.t()}]

  @callback replace_entries([Entry.t()], season_slug :: String.t(), leaderboard_id :: String.t()) ::
              [Entry.t()]
end
