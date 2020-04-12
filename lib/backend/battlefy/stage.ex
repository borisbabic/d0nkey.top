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
end

defmodule Backend.Battlefy.Bracket do
  @moduledoc false
  use TypedStruct

  typedstruct do
    field :type, String.t()
    field :style, String.t()
    field :rounds_count, integer
    field :teams_count, integer
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
      rounds_count: snake_case["rounds_count"],
      teams_count: snake_case["teams_count"]
    }
  end
end
