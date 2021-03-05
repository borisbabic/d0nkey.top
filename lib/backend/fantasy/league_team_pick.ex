defmodule Backend.Fantasy.LeagueTeamPick do
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Fantasy.LeagueTeam

  schema "league_team_picks" do
    field :pick, :string
    belongs_to :team, LeagueTeam

    timestamps()
  end

  @doc false
  def changeset(league_team_pick, attrs) do
    league_team_pick
    |> cast(attrs, [:pick])
    |> validate_required([:pick])
  end
end
