defmodule Backend.Battlefy.Match do
  use TypedStruct
  alias Backend.Battlefy.Team
  alias Backend.Battlefy.MatchTeam

  typedstruct enforce: true do
    field :top, Backend.Battlefy.MatchTeam.t()
    field :bottom, Backend.Battlefy.MatchTeam.t()
    field :round_number, integer
    field :match_number, integer
    field :is_bye, boolean
    field :is_complete, boolean
  end

  def from_raw_map(map = %{"roundNumber" => _}) do
    Recase.Enumerable.convert_keys(
      map,
      &Recase.to_snake/1
    )
    |> from_raw_map
  end

  def from_raw_map(%{
        "round_number" => round_number,
        "match_number" => match_number,
        "bottom" => bottom,
        "top" => top,
        "is_bye" => is_bye,
        "is_complete" => is_complete
      }) do
    %__MODULE__{
      top: MatchTeam.from_raw_map(top),
      bottom: MatchTeam.from_raw_map(bottom),
      round_number: round_number,
      match_number: match_number,
      is_bye: is_bye,
      is_complete: is_complete
    }
  end
end

defmodule Backend.Battlefy.MatchTeam do
  use TypedStruct
  alias Backend.Battlefy.Team

  typedstruct enforce: true do
    field :winner, boolean
    field :disqualified, boolean
    field :team, Team.t() | nil
    field :score, integer
  end

  def from_raw_map(map = %{"winner" => winner, "disqualified" => disqualified, "score" => score}) do
    team =
      case map["team"] do
        nil -> nil
        team_map -> Team.from_raw_map(team_map)
      end

    %__MODULE__{
      disqualified: disqualified,
      winner: winner,
      team: team,
      score: score
    }
  end
end
