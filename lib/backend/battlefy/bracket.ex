defmodule Backend.Battlefy.Bracket do
  @moduledoc false

  use TypedStruct
  alias Backend.Battlefy
  alias Backend.Battlefy.Bracket.Round

  @type sub_bracket :: %{
          rounds: [Round.t()],
          total_rounds: integer(),
          third_place_round: Round.t() | nil
        }

  typedstruct enforce: true do
    field :stage_id, Battlefy.stage_id()
    field :started?, boolean
    field :style, String.t()
    field :championship, sub_bracket()
    field :consolation, sub_bracket()
    field :final, sub_bracket()
    field :full_screen_url, String.t()
    field :broadcast_url, String.t()
    field :edit_bracket_url, String.t()
  end

  def from_raw_map(map) do
    stage_id = map["stageID"] || map["stageId"]

    %__MODULE__{
      stage_id: stage_id,
      started?: map["hasStarted"],
      style: map["style"],
      championship: parse_sub_bracket(map["championship"], stage_id),
      consolation: parse_sub_bracket(map["consolation"], stage_id),
      final: parse_sub_bracket(map["final"], stage_id),
      full_screen_url: map["fullScreenUrl"],
      broadcast_url: map["broadcast_url"],
      edit_bracket_url: map["edit_bracket_url"]
    }
  end

  def parse_sub_bracket(map, stage_id) do
    third_place_round =
      with %{} = tpr <- map["thirdPlaceRound"] do
        Round.from_raw_map(tpr, stage_id)
      end

    %{
      rounds: Round.parse_list(map["rounds"], stage_id),
      total_rounds: map["totalRounds"],
      third_place_round: third_place_round
    }
  end

  @spec all_players(__MODULE__) :: [String.t()]
  def all_players(bracket) do
    [:championship, :final, :consolation]
    |> Enum.flat_map(fn a -> Map.get(bracket, a, []) |> sub_bracket_players() end)
    |> Enum.uniq()
  end

  def sub_bracket_players(%{rounds: rounds}) do
    Enum.flat_map(rounds, &Round.all_players/1)
    |> Enum.uniq()
  end
end

defmodule Backend.Battlefy.Bracket.Round do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Match
  alias Backend.Battlefy.MatchTeam

  typedstruct enforce: true do
    field :round_number, integer()
    field :num_games, integer()
    field :series_style, String.t()
    field :matches, [Match.t()]
  end

  def all_players(%{matches: matches}) do
    Enum.flat_map(matches, fn
      %{top: top, bottom: bottom} ->
        [MatchTeam.get_name(top), MatchTeam.get_name(bottom)]

      _ ->
        []
    end)
    |> Enum.uniq()
  end

  @spec from_raw_map([Map.t()], String.t() | nil) :: [__MODULE__]
  def parse_list(list, stage_id \\ nil)

  def parse_list(list, stage_id) when is_list(list) do
    Enum.map(list, fn round_map ->
      from_raw_map(round_map, stage_id)
    end)
  end

  def parse_list(_, _stage_id), do: []

  @spec from_raw_map(Map.t(), String.t() | nil) :: __MODULE__
  def from_raw_map(%{} = map, stage_id \\ nil) do
    %__MODULE__{
      round_number: map["roundNumber"],
      num_games: map["numGames"],
      series_style: map["seriesStyle"],
      matches: map["matches"] |> add_stage_id(stage_id) |> Enum.map(&Match.from_raw_map/1)
    }
  end

  def add_stage_id([_ | _] = matches, stage_id) when is_binary(stage_id) do
    Enum.map(matches, &Map.put_new(&1, "stageID", stage_id))
  end

  def add_stage_id(_, _), do: []
end
