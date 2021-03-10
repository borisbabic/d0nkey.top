defmodule Backend.Fantasy.League do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.Fantasy.LeagueTeam
  alias Backend.Fantasy.League

  schema "leagues" do
    field :competition, :string
    field :competition_type, :string
    field :max_teams, :integer
    field :name, :string
    field :point_system, :string
    field :roster_size, :integer
    field :join_code, Ecto.UUID, autogenerate: true
    field :time_per_pick, :integer
    field :pick_order, {:array, :integer}, default: []
    field :current_pick_number, :integer, default: 0
    field :last_pick_at, :utc_datetime
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

  def start_draft(l = %{teams: [_ | _]}) do
    attrs = %{
      pick_order: generate_pick_order(l),
      last_pick_at: NaiveDateTime.utc_now()
    }

    l
    |> cast(attrs, [:pick_order, :last_pick_at])
  end

  @spec add_pick(__MODULE__, User.t()) ::
          {:ok, Ecto.Changeset.t()} | {:ok, __MODULE__} | {:error, atom()}
  def add_pick(league = %League{}, user) do
    with true <- picked_on_time?(league),
         current_picker when is_integer(current_picker) <-
           league.pick_order |> Enum.at(league.current_pick_number),
         {:ok, picking_team} <- league_team(league, current_picker),
         true <- picking_team |> LeagueTeam.can_manage?(user) do
      {
        :ok,
        league
        |> cast(
          %{
            current_pick_number: league.current_pick_number + 1,
            last_pick_at: NaiveDateTime.utc_now()
          },
          [:current_pick_number, :last_pick_at]
        )
      }
    else
      nil -> {:error, :out_of_picks}
      false -> {:error, :invalid_pick}
      {:error, r} -> {:error, r}
    end
  end

  @spec right_picker?(__MODULE__, LeagueTeam.t()) :: boolean()
  def right_picker?(league, %{id: id}), do: league.pick_order[league.current_pick_number] == id

  @spec picked_on_time?(__MODULE__) :: boolean()
  def picked_on_time?(%League{time_per_pick: 0}), do: true

  def picked_on_time?(%League{time_per_pick: seconds, last_pick_at: last}) do
    deadline = last |> NaiveDateTime.add(seconds)
    now = NaiveDateTime.utc_now()
    NaiveDateTime.compare(deadline, now) != :lt
  end

  defp generate_pick_order(%{roster_size: roster_size, teams: lt = [_ | _]}) do
    forward = lt |> Enum.map(& &1.id) |> Enum.shuffle()
    reverse = forward |> Enum.reverse()

    1..roster_size
    |> Enum.flat_map(fn i ->
      if rem(i, 2) == 0 do
        forward
      else
        reverse
      end
    end)
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

  @spec can_manage?(League, User.t()) :: boolean()
  def can_manage?(%League{owner: %{id: owner_id}}, %User{id: user_id}) when is_integer(owner_id),
    do: owner_id == user_id

  def can_manage?(_, _), do: false

  def teams(%{teams: teams = [_ | _]}), do: teams
  def teams(_), do: []

  def draft_started?(%{last_pick_at: nil}), do: false
  def draft_started?(_), do: true

  @spec drafting_now(__MODULE__) :: LeagueTeam.t() | nil
  def drafting_now(league), do: drafting_pos(league, 0)
  @spec drafting_next(__MODULE__) :: LeagueTeam.t() | nil
  def drafting_next(league), do: drafting_pos(league, 1)

  @spec drafting_pos(__MODULE__, integer()) :: LeagueTeam.t() | nil
  defp drafting_pos(
         %{current_pick_number: pn, pick_order: pick_order, teams: teams = [_ | _]},
         offset
       ) do
    lt_id = pick_order |> Enum.at(pn + offset)
    teams |> Enum.find(&(&1.id == lt_id))
  end

  defp drafting_pos(_, _), do: nil

  def team_for_user(%{teams: teams = [_ | _]}, user) do
    teams
    |> Enum.find(&(&1 |> LeagueTeam.can_manage?(user)))
  end

  def team_for_user(_, _), do: nil

  defp league_team(%{teams: teams}, id) do
    teams
    |> Enum.find(&(&1.id == id))
    |> case do
      nil -> {:error, "League team not found for id #{id}"}
      lt -> {:ok, lt}
    end
  end

  def picked_by(%{teams: teams}, name),
    do: teams |> Enum.find(&(&1 |> LeagueTeam.has_pick?(name)))
end
