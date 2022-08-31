defmodule Hearthstone.Leaderboards.Api do
  require Logger
  alias Hearthstone.Leaderboards.Response
  alias Hearthstone.Leaderboards.Season

  use Tesla
  plug Tesla.Middleware.BaseUrl, "https://hearthstone.blizzard.com"
  @default_page 1
  @ldb_id_map %{
    "STD" => "standard",
    "WLD" => "wild",
    "CLS" => "classic",
    "MRC" => "mercenaries",
    "BG" => "battlegrounds"
  }

  @spec get_page(Season.t(), integer() | nil) :: {:ok, Response.t()} | {:error, any()}
  def get_page(raw_season, page \\ @default_page) do
    season =
      raw_season
      |> Season.ensure_region()
      |> Season.ensure_leaderboard_id()

    url = create_link(season, page)

    with {:ok, %{body: body}} <- get(url),
         {:ok, decoded} <- Jason.decode(body) do
      Response.from_raw_map(decoded, season)
    else
      r = {:error, _reason} -> r
      _ -> {:error, :unknown_error_getting_leaderboard_page}
    end
  end

  def create_link(season, page \\ @default_page) do
    base_link = base_link(season, page)

    case season do
      %{season_id: season_id} when is_binary(season_id) ->
        base_link <> "&seasonId=#{season_id}"

      _ ->
        base_link
    end
  end

  defp base_link(%{region: region, leaderboard_id: leaderboard_id}, page) do
    "/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{ldb_id(leaderboard_id)}&page=#{page}"
  end

  defp ldb_id(ldb_id) do
    Map.get(@ldb_id_map, ldb_id, ldb_id)
  end
end
