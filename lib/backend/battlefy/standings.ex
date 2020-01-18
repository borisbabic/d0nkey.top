defmodule Backend.Battlefy.Standings do
  use TypedStruct
  alias Backend.Battlefy.Team

  typedstruct enforce: true do
    field :place, integer
    field :team, Team.t()
  end

  def from_raw_map(%{"place" => place, "team" => team}) do
    %__MODULE__{
      place: place,
      team: Team.from_raw_map(team)
    }
  end
end
