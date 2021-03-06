defmodule Backend.Fantasy.League do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.Fantasy.LeagueTeam

  schema "leagues" do
    field :competition, :string
    field :competition_type, :string
    field :max_teams, :integer
    field :name, :string
    field :point_system, :string
    field :roster_size, :integer
    belongs_to :owner, User
    has_many :teams, LeagueTeam

    timestamps()
  end

  @doc false
  def changeset(league, attrs) do
    league
    |> cast(attrs, [
      :name,
      :competition,
      :competition_type,
      :point_system,
      :max_teams,
      :roster_size
    ])
    |> set_owner(attrs, league)
    |> validate_required([
      :name,
      :competition,
      :competition_type,
      :point_system,
      :max_teams,
      :owner,
      :roster_size
    ])
  end

  defp set_owner(c, %{owner: owner}, _), do: set_owner(c, owner)
  defp set_owner(c, %{"owner" => owner}, _), do: set_owner(c, owner)
  defp set_owner(c, _, %{owner: owner = %{id: _}}), do: set_owner(c, owner)
  defp set_owner(c, _, _), do: c

  defp set_owner(c, owner = %{id: _}) do
    c
    |> put_assoc(:owner, owner)
    |> foreign_key_constraint(:owner)
  end
end
