defmodule Backend.Fantasy.LeagueTeam do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.UserManager.League

  schema "league_teams" do
    belongs_to :owner, User
    belongs_to :league, League

    timestamps()
  end

  @doc false
  def changeset(league_team, attrs) do
    league_team
    |> cast(attrs, [])
    |> validate_required([])
  end
end
