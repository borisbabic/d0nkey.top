defmodule Backend.Battlefy.Stage do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy

  typedstruct enforce: true do
    field :id, Battlefy.stage_id()
    field :name, String.t()
    field :current_round, integer | nil
    field :start_time, Calendar.datetime()
    field :standing_ids, Battlefy.battlefy_id()
    field :has_started, bool
    field :bracket, Battlefy.Bracket.t()
    field :matches, [Battlefy.Match.t()]
  end

  @spec from_raw_map(map) :: __MODULE__.t()

  def from_raw_map(
        map = %{
          "startTime" => start_time,
          "hasStarted" => has_started,
          "name" => name,
          "standingIDs" => standing_ids
        }
      ) do
    %__MODULE__{
      id: map["id"] || map["_id"],
      start_time: NaiveDateTime.from_iso8601!(start_time),
      has_started: has_started,
      standing_ids: standing_ids,
      name: name,
      current_round: map["currentRound"],
      matches:
        if(is_list(map["matches"]),
          do: map["matches"] |> Enum.map(&Battlefy.Match.from_raw_map/1),
          else: []
        ),
      bracket: Battlefy.Bracket.from_raw_map(map["bracket"])
    }
  end

  @spec bracket_type(__MODULE__) :: Backend.Tournament.bracket_type()
  def bracket_type(stage), do: stage.bracket |> Battlefy.Bracket.bracket_type()
end

defmodule Backend.Battlefy.Bracket do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :type, String.t()
    field :style, String.t()
    field :rounds_count, integer
    field :teams_count, integer
    field :current_round_number, integer
    field :tiebreaker_method, String.t()
  end

  def from_raw_map(nil) do
    %__MODULE__{}
  end

  def from_raw_map(map) do

    %__MODULE__{
      type: map["type"],
      style: map["style"],
      tiebreaker_method: map["tiebreakerMethod"],
      rounds_count: map["roundsCount"],
      teams_count: map["teamsCount"],
      current_round_number: map["currentRoundNumber"]
    }
  end

  @spec bracket_type(__MODULE__) :: Backend.Tournament.bracket_type()
  def bracket_type(%{type: "elimination", style: "single"}), do: :single_elimination
  def bracket_type(%{type: "elimination", style: "double"}), do: :double_elimination

  # why tf isn't there a type for swiss. Dunno if I need the tiebreaker method, but just in case it's there
  def bracket_type(%{type: "custom", tiebreaker_method: "hct"}), do: :swiss
  def bracket_type(%{type: "roundrobin"}), do: :round_robin
  def bracket_type(_), do: :unknown
end
