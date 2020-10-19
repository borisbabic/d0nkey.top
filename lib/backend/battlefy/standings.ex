defmodule Backend.Battlefy.Standings do
  @moduledoc false
  use TypedStruct
  alias Backend.Battlefy.Team

  typedstruct do
    field :place, integer, enforce: true
    field :team, Team.t(), enforce: true
    field :wins, integer
    field :auto_wins, integer
    field :auto_losses, integer
    field :losses, integer
  end

  def from_raw_map_list(map_list) do
    if Enum.all?(map_list, fn m -> m["place"] end) do
      map_list
      |> Enum.map(fn raw = %{"team" => team, "place" => place} ->
        %__MODULE__{
          place: place,
          team: Team.from_raw_map(team)
        }
        |> add_win_loss(raw)
      end)
    else
      map_list
      |> Enum.with_index()
      |> Enum.map(fn {raw = %{"team" => team}, index} ->
        %__MODULE__{
          place: index + 1,
          team: Team.from_raw_map(team)
        }
        |> add_win_loss(raw)
      end)
    end
  end

  defp add_win_loss(standings = %__MODULE__{}, raw_map) do
    %__MODULE__{standings | wins: raw_map["wins"], losses: raw_map["losses"]}
  end
end

defimpl Backend.TournamentStats.Standings, for: Backend.Battlefy.Standings do
  alias Backend.TournamentStats.TeamStandings

  def create_team_standings(s) do
    %TeamStandings{
      position: s.place,
      name: s.team.name,
      wins: s.wins || 0,
      losses: s.losses || 0,
      auto_wins: s.auto_wins || 0,
      auto_losses: s.auto_losses || 0
    }
  end
end
