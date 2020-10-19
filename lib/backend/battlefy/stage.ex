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
  end

  @spec from_raw_map(map) :: __MODULE__.t()
  def from_raw_map(map = %{"startTime" => _}) do
    Recase.Enumerable.convert_keys(
      map,
      &Recase.to_snake/1
    )
    |> from_raw_map
  end

  def from_raw_map(
        map = %{
          "start_time" => start_time,
          "has_started" => has_started,
          "name" => name,
          "standing_ids" => standing_ids
        }
      ) do
    %__MODULE__{
      id: map["id"] || map["_id"],
      start_time: NaiveDateTime.from_iso8601!(start_time),
      has_started: has_started,
      standing_ids: standing_ids,
      name: name,
      current_round: map["current_round"],
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
    snake_case =
      Recase.Enumerable.convert_keys(
        map,
        &Recase.to_snake/1
      )

    %__MODULE__{
      type: snake_case["type"],
      style: snake_case["style"],
      tiebreaker_method: snake_case["tiebreaker_method"],
      rounds_count: snake_case["rounds_count"],
      teams_count: snake_case["teams_count"],
      current_round_number: snake_case["current_round_number"]
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
