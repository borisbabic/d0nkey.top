defmodule Backend.Battlefy.Standings do
  use TypedStruct
  alias Backend.Battlefy.Team

  typedstruct do
    field :place, integer, enforce: true
    field :team, Team.t(), enforce: true
    field :wins, integer
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
