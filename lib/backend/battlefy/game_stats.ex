defmodule Backend.Battlefy.GameStats do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy
  alias Backend.Battlefy.Match.MatchStats.Stats
  alias Backend.Battlefy.Match.MatchStats

  typedstruct enfore: true do
    field :id, String.t()
    field :game_id, Battlefy.game_id()
    field :match_id, Battlefy.match_id()
    field :stage_id, Battlefy.stage_id()
    field :tournament_id, Battlefy.tournament_id()
    field :game_number, integer()
    field :stats, Stats.t()
    field :created_at, NaiveDateTime.t()
  end

  def from_raw_map(%{"stats" => stats} = map) do
    %{
      id: map["_id"],
      game_id: map["gameID"] || map["gameId"] || map["game_id"],
      match_id: map["matchID"] || map["matchId"] || map["match_id"],
      stage_id: map["stageID"] || map["stageId"] || map["stage_id"],
      tournament_id: map["tournamentID"] || map["tournamentId"] || map["tournament_id"],
      created_at: (map["createdAt"] || map["created_at"]) |> Util.naive_date_time_or_nil(),
      game_number: (map["gameNumber"] || map["game_number"]) |> Util.to_int_or_orig(),
      stats: Stats.from_raw_map(stats)
    }
  end

  def to_match_stats(%{
        stats: stats,
        game_id: game_id,
        created_at: created_at,
        game_number: game_number
      }) do
    %MatchStats{
      stats: stats,
      game_number: game_number,
      game_id: game_id,
      created_at: created_at
    }
  end
end
