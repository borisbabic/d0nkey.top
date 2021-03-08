defmodule Backend.Fantasy.LeagueTeam do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.Fantasy.League

  schema "league_teams" do
    belongs_to :owner, User
    belongs_to :league, League

    timestamps()
  end

  @doc false
  def changeset(league_team, league, owner) do
    league_team
    |> cast(%{}, [])
    |> set_league(league)
    |> set_owner(owner)
    |> validate_required([])
  end

  @doc false
  def changeset(league_team, attrs) do
    league_team
    |> cast(attrs, [])
    |> validate_required([])
  end

  defp set_owner(c, owner = %{id: _}) do
    c
    |> put_assoc(:owner, owner)
    |> foreign_key_constraint(:owner)
  end

  defp set_league(c, league = %{id: _}) do
    c
    |> put_assoc(:league, league)
    |> foreign_key_constraint(:league)
  end

  @spec display_name(__MODULE__) :: String.t()
  def display_name(%{owner: owner = %{id: _}}), do: owner |> User.display_name()
end
