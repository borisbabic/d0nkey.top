defmodule Backend.Fantasy.LeagueTeamPick do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.Fantasy.LeagueTeam

  schema "league_team_picks" do
    field :pick, :string
    belongs_to :team, LeagueTeam
    field :round, :integer, default: 1

    timestamps()
  end

  @doc false
  def changeset(league_team_pick, attrs) do
    league_team_pick
    |> cast(attrs, [:pick])
    |> set_league_team(attrs)
    |> validate_required([:pick, :team])
  end

  defp set_league_team(c, %{team: league_team}), do: set_league_team(c, league_team)
  defp set_league_team(c, %{"team" => league_team}), do: set_league_team(c, league_team)

  defp set_league_team(c, league_team = %{id: _}) do
    c
    |> put_assoc(:team, league_team)
    |> foreign_key_constraint(:team)
  end

  defp set_league_team(c, _), do: c
end
