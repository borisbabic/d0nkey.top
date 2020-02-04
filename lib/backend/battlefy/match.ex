defmodule Backend.Battlefy.Match do
  use TypedStruct
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.MatchTeam

  typedstruct enforce: true do
    field :id, Backend.Battlefy.match_id()
    field :top, MatchTeam.t()
    field :bottom, MatchTeam.t()
    field :round_number, integer
    field :match_number, integer
    field :stage_id, Backend.Battlefy.stage_id()
    field :is_bye, boolean
    # field :is_complete, boolean
  end

  def from_raw_map(map = %{"roundNumber" => _}) do
    Recase.Enumerable.convert_keys(
      map,
      &Recase.to_snake/1
    )
    |> from_raw_map
  end

  def from_raw_map(
        map = %{
          "round_number" => round_number,
          "match_number" => match_number,
          "bottom" => bottom,
          "top" => top,
          "is_bye" => is_bye,
          "stage_id" => stage_id
          # "is_complete" => is_complete
        }
      ) do
    %__MODULE__{
      id: map["id"] || map["_id"],
      top: MatchTeam.from_raw_map(top),
      bottom: MatchTeam.from_raw_map(bottom),
      round_number: round_number,
      match_number: match_number,
      is_bye: is_bye,
      stage_id: stage_id
      # is_complete: is_complete
    }
  end
end

defmodule Backend.Battlefy.MatchTeam do
  use TypedStruct
  alias Backend.Battlefy.Team

  typedstruct do
    field :winner, boolean
    field :disqualified, boolean
    field :team, Team.t() | nil
    field :score, integer
    field :name, String.t()
  end

  def from_raw_map(map) do
    team =
      case map["team"] do
        nil -> nil
        team_map -> Team.from_raw_map(team_map)
      end

    %__MODULE__{
      disqualified: map["disqualified"],
      winner: map["winner"],
      name: map["name"],
      team: team,
      score: map["score"] || 0
    }
  end

  def get_name(%__MODULE__{} = mt) do
    cond do
      mt.team && mt.team.name && mt.team.name != "" -> mt.team.name
      mt.name && mt.name != "" -> mt.name
      true -> nil
    end
  end
end

defmodule Backend.Battlefy.MatchDeckstrings do
  use TypedStruct

  typedstruct enforce: true do
    field :top, [String.t()]
    field :bottom, [String.t()]
  end

  def from_raw_map(%{"top" => top, "bottom" => bottom}) do
    %__MODULE__{
      top: top,
      bottom: bottom
    }
  end

  # todo move to blizzard or hearthstone
  def remove_comments(deckstring) do
    deckstring
    |> String.split("\n")
    |> Enum.filter(fn line -> line && line != "" && String.at(line, 0) != "#" end)
    |> Enum.at(0)
  end
end
