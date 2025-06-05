defmodule Hearthstone.Leaderboards.Api do
  @moduledoc false
  require Logger
  alias Hearthstone.Leaderboards.Response
  alias Hearthstone.Leaderboards.Season

  use Tesla
  # plug(Tesla.Middleware.BaseUrl,)
  @default_page 1
  # @ldb_id_map %{
  #   "STD" => "standard",
  #   "WLD" => "wild",
  #   "CLS" => "classic",
  #   "MRC" => "mercenaries",
  #   "DUO" => "battlegroundsduo",
  #   "BG" => "battlegrounds"
  # }
  @page_size 25

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
      %{season_id: season_id, region: r} when season_id != nil and r in ["CN", :CN] ->
        base_link <> "&season_id=#{season_id}"

      %{season_id: season_id} when season_id != nil ->
        base_link <> "&seasonId=#{season_id}"

      _ ->
        base_link
    end
  end

  defp base_link(%{region: r, leaderboard_id: leaderboard_id}, page) when r in ["CN", :CN] do
    "https://webapi.blizzard.cn/hs-rank-api-server/api/game/ranks?page=#{page}&page_size=25&mode_name=#{ldb_id(leaderboard_id)}"
  end

  defp base_link(%{region: region, leaderboard_id: leaderboard_id}, page) do
    "https://hearthstone.blizzard.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{ldb_id(leaderboard_id)}&page=#{page}"
  end

  @spec ldb_id(String.t() | atom()) :: atom()
  def ldb_id(ldb_id) do
    case get_leaderboard_identifier(ldb_id) do
      {:ok, identifier} -> identifier
      _ -> to_string(ldb_id)
    end
  end

  def offset_to_page(offset) do
    ceil(offset / @page_size)
  end

  @spec get_leaderboard_identifier(atom() | String.t()) :: {:ok, atom()} | {:error, atom()}
  def get_leaderboard_identifier(l)
      when l in [:Standard, "Standard", :standard, "standard", "STD", :STD, :std, "std"],
      do: {:ok, :standard}

  def get_leaderboard_identifier(l)
      when l in [:Wild, "Wild", :wild, "wild", "WLD", :WLD, :std, "std"],
      do: {:ok, :wild}

  def get_leaderboard_identifier(l)
      when l in [:Classic, "Classic", :classic, "classic", :CLS, "CLS", :cls, "cls"],
      do: {:ok, :classic}

  def get_leaderboard_identifier(l)
      when l in [
             :Mercenaries,
             "Mercenaries",
             :mercenaries,
             "mercenaries",
             :MRC,
             "MRC",
             :mrc,
             "mrc"
           ],
      do: {:ok, :mercenaries}

  def get_leaderboard_identifier(l)
      when l in [
             :Battlegrounds,
             "Battlegrounds",
             :battlegrounds,
             "battlegrounds",
             :BG,
             "BG",
             :bg,
             "bg",
             :BGS,
             "BGS",
             :bgs,
             "bgs"
           ],
      do: {:ok, :battlegrounds}

  def get_leaderboard_identifier(l)
      when l in [
             :Battlegroundsduos,
             "Battlegroundsduos",
             :BattlegroundsDuos,
             "BattlegroundsDuos",
             :battlegroundsduos,
             "battlegroundsduos",
             :DUO,
             "DUO",
             :duo,
             "duo",
             :DUOS,
             :duos
           ],
      do: {:ok, :battlegroundsduo}

  def get_leaderboard_identifier(l) when l in [:Arena, "Arena", :arena, "arena"],
    do: {:ok, :arena}

  def get_leaderboard_identifier(l)
      when l in [:"Underground Arena", "Undergound Arena", :undergroundarena, "undergroundarena"],
      do: {:ok, :undergroundarena}

  def get_leaderboard_identifier(l) when l in [:Twist, "Twist", :twist, "twist"],
    do: {:ok, :twist}

  def get_leaderboard_identifier(_), do: {:error, :unknown_leaderboard}
end
