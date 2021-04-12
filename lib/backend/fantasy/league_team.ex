defmodule Backend.Fantasy.LeagueTeam do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.Fantasy.League
  alias Backend.Fantasy.LeagueTeamPick

  schema "league_teams" do
    belongs_to :owner, User
    belongs_to :league, League
    has_many :picks, LeagueTeamPick, foreign_key: :team_id, on_delete: :delete_all

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

  @spec can_manage?(__MODULE__, User.t()) :: boolean()
  def can_manage?(%{owner_id: owner_id}, %{id: user_id}), do: owner_id == user_id
  def can_manage?(_, _), do: false

  def has_pick?(%{picks: picks = [_ | _]}, name, current_round),
    do: picks |> Enum.any?(&(&1.pick == name && &1.round == current_round))

  def has_pick?(_, _, _), do: false

  def round_picks(%{picks: picks}, round), do: picks |> Enum.filter(&(&1.round == round))

  def can_unpick?(%{league: %{current_round: 1}}), do: true

  def can_unpick?(lt = %{league: league = %{current_round: cr}}) do
    current_round_picks = lt |> round_picks(cr) |> Enum.map(& &1.pick)

    removed =
      lt
      |> round_picks(cr - 1)
      |> Enum.filter(&(!(&1.pick in current_round_picks)))
      |> Enum.count()

    min_same = league |> League.min_same()
    removed < min_same
  end

  def current_roster_size(lt), do: lt |> current_picks() |> Enum.count()
  def current_picks(lt = %{league: %{current_round: cr}}), do: lt |> round_picks(cr)
end
