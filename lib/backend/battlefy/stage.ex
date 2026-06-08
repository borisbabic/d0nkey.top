defmodule Backend.Battlefy.Stage do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy
  alias Backend.Battlefy.Stage.Bracket
  alias Backend.Battlefy.Match

  typedstruct enforce: true do
    field :id, Battlefy.stage_id()
    field :name, String.t()
    field :current_round, integer | nil
    field :start_time, Calendar.datetime()
    field :standing_ids, Battlefy.battlefy_id()
    field :has_started, boolean
    field :bracket, Bracket.t()
    field :matches, [Match.t()]
  end

  @spec from_raw_map(Map.t()) :: __MODULE__.t()

  def from_raw_map(map) when is_map(map) do
    %__MODULE__{
      id: map["id"] || map["_id"],
      start_time: start_time(map),
      has_started: map["hasStarted"],
      standing_ids: map["standingIDs"] || [],
      name: map["name"],
      current_round: map["currentRound"],
      matches:
        if(is_list(map["matches"]),
          do: map["matches"] |> Enum.map(&Battlefy.Match.from_raw_map/1),
          else: []
        ),
      bracket: Bracket.from_raw_map(map["bracket"])
    }
  end

  @spec start_time(Map.t()) :: NaiveDateTime.t() | nil
  defp start_time(%{"startTime" => start_time}) when is_binary(start_time) do
    NaiveDateTime.from_iso8601(start_time)
    |> Util.nilify()
  end

  defp start_time(_), do: nil

  @doc "Can we display the stage as a bracket"
  @spec bracketable?(__MODULE__) :: boolean()
  def bracketable?(%{bracket: %{type: "elimination"}}), do: true
  def bracketable?(_), do: false

  @spec bracket_type(__MODULE__) :: Backend.Tournaments.bracket_type()
  def bracket_type(stage), do: stage.bracket |> Bracket.bracket_type()
end

defmodule Backend.Battlefy.Stage.Bracket do
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

  @spec bracket_type(__MODULE__) :: Backend.Tournaments.bracket_type()
  def bracket_type(%{type: "elimination", style: "single"}), do: :single_elimination
  def bracket_type(%{type: "elimination", style: "double"}), do: :double_elimination

  # why tf isn't there a type for swiss. Dunno if I need the tiebreaker method, but just in case it's there
  def bracket_type(%{type: "custom", tiebreaker_method: "hct"}), do: :swiss
  def bracket_type(%{type: "roundrobin"}), do: :round_robin
  def bracket_type(_), do: :unknown
end
