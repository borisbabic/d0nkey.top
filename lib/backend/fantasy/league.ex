defmodule Backend.Fantasy.League do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  alias Backend.UserManager.User
  alias Backend.Fantasy.LeagueTeam
  alias Backend.Fantasy.League
  alias Backend.Blizzard

  schema "leagues" do
    field :competition, :string
    field :competition_type, :string
    field :max_teams, :integer
    field :name, :string
    field :point_system, :string
    field :roster_size, :integer
    field :join_code, Ecto.UUID, autogenerate: true
    field :time_per_pick, :integer, default: 0
    field :pick_order, {:array, :integer}, default: []
    field :current_pick_number, :integer, default: 0
    field :last_pick_at, :utc_datetime
    field :real_time_draft, :boolean, default: true
    field :draft_deadline, :utc_datetime, null: true
    field :current_round, :integer, default: 1
    field :changes_between_rounds, :integer, default: 0
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
      :roster_size,
      :real_time_draft,
      :changes_between_rounds,
      :current_round,
      :draft_deadline
    ])
    |> set_owner(attrs, league)
    |> validate_required([
      :name,
      :competition,
      :competition_type,
      :point_system,
      :max_teams,
      :owner,
      :roster_size,
      :changes_between_rounds,
      :current_round,
      :real_time_draft
    ])
  end

  def start_draft(l = %{teams: [_ | _]}) do
    attrs = %{
      pick_order: generate_pick_order(l),
      last_pick_at: NaiveDateTime.utc_now(),
      draft_started: true
    }

    l
    |> cast(attrs, [:pick_order, :last_pick_at])
  end

  def inc_updated_at(l) do
    attrs = %{updated_at: NaiveDateTime.utc_now()}

    l |> cast(attrs, [:updated_at])
  end

  @spec add_pick(__MODULE__, User.t()) ::
          {:ok, Ecto.Changeset.t()} | {:ok, __MODULE__} | {:error, atom()}
  def add_pick(league = %League{real_time_draft: true}, user) do
    with true <- draft_started?(league),
         true <- picked_on_time?(league),
         current_picker when is_integer(current_picker) <-
           league.pick_order |> Enum.at(league.current_pick_number),
         {:ok, picking_team} <- league_team(league, current_picker),
         true <- LeagueTeam.can_manage?(picking_team, user) do
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

  def add_pick(league = %League{real_time_draft: false, roster_size: roster_size}, user) do
    with true <- draft_started?(league),
         true <- picked_on_time?(league),
         picking_team = %{id: id} <- team_for_user(league, user),
         currently_picked when currently_picked < roster_size <-
           picking_team |> LeagueTeam.current_roster_size() do
      {:ok, league |> cast(%{last_pick_at: NaiveDateTime.utc_now()}, [:last_pick_at])}
    else
      false -> {:error, :invalid_pick}
      {:error, r} -> {:error, r}
      num when is_integer(num) and num >= roster_size -> {:error, :out_of_picks}
    end
  end

  @spec right_picker?(__MODULE__, LeagueTeam.t()) :: boolean()
  def right_picker?(league, %{id: id}), do: league.pick_order[league.current_pick_number] == id

  @spec picked_on_time?(__MODULE__) :: boolean()
  def picked_on_time?(%League{time_per_pick: 0, real_time_draft: true}), do: true

  def picked_on_time?(%League{time_per_pick: seconds, last_pick_at: last, real_time_draft: true}) do
    deadline = last |> NaiveDateTime.add(seconds)
    now = NaiveDateTime.utc_now()
    NaiveDateTime.compare(deadline, now) != :lt
  end

  def picked_on_time?(league = %League{real_time_draft: false}),
    do: !draft_deadline_passed?(league)

  def generate_pick_order(%{real_time_draft: false}), do: []

  def generate_pick_order(%{real_time_draft: true, roster_size: roster_size, teams: lt = [_ | _]}) do
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
  def drafting_pos(
        %{current_pick_number: pn, pick_order: pick_order, teams: teams = [_ | _]},
        offset
      ) do
    lt_id = pick_order |> Enum.at(pn + offset)
    teams |> Enum.find(&(&1.id == lt_id))
  end

  def drafting_pos(_, _), do: nil

  def team_for_user(%{teams: teams = [_ | _]}, user) do
    teams
    |> Enum.find(&(&1 |> LeagueTeam.can_manage?(user)))
  end

  def team_for_user(_, _), do: nil

  def league_team!(league, id), do: league_team(league, id) |> Util.bangify()

  def league_team(%{teams: teams}, id) do
    teams
    |> Enum.find(&(&1.id == id))
    |> case do
      nil -> {:error, "League team not found for id #{id}"}
      lt -> {:ok, lt}
    end
  end

  def picked_by(%{teams: teams, current_round: cr}, name),
    do: teams |> Enum.find(&(&1 |> LeagueTeam.has_pick?(name, cr)))

  def pickable?(league = %{real_time_draft: true}, user = %User{}, <<pick::binary>>) do
    picked_by = picked_by(league, pick)
    lt = team_for_user(league, user)
    lt && !picked_by
  end

  def pickable?(league = %{real_time_draft: false}, user = %User{}, <<pick::binary>>) do
    lt = team_for_user(league, user)
    !LeagueTeam.has_pick?(lt, pick, league.current_round)
  end

  def pickable?(_, _, _), do: false

  def draft_deadline_passed?(%{draft_deadline: nil}), do: false

  def draft_deadline_passed?(%{draft_deadline: dd}) do
    now = NaiveDateTime.utc_now()
    NaiveDateTime.compare(dd, now) == :lt
  end

  def scoring_display(%{point_system: ps}), do: ps |> scoring_display()

  def scoring_display(ps) when is_binary(ps) do
    case ps do
      "swiss_wins" -> "Swiss Wins"
      "gm_points_2021" -> "GM Points"
      "total_wins" -> "Total Wins"
      "num_correct" -> "Num Correct"
    end
  end

  def unpickable?(l = %{real_time_draft: false}, lt = %LeagueTeam{}, u = %User{}, pick) do
    !draft_deadline_passed?(l) && lt |> LeagueTeam.can_manage?(u) &&
      lt |> LeagueTeam.can_unpick?(pick)
  end

  def unpickable?(_, _, _, _), do: false

  def any_picks?(%{teams: teams}), do: teams |> Enum.any?(&(&1.picks |> Enum.any?()))

  def min_same(%{roster_size: rs, changes_between_rounds: cbr}), do: rs - cbr

  def round_length(_), do: :week

  def round(_, round) when is_integer(round), do: round
  def round(%{current_round: round}, _), do: round
  def round(_, _), do: 1

  def normalize_pick({pick, val}, %{competition_type: "masters_tour"}),
    do: {pick |> Backend.Battlenet.Battletag.shorten(), val}

  def normalize_pick(pick, %{competition_type: "masters_tour"}),
    do: pick |> Backend.Battlenet.Battletag.shorten()

  def normalize_pick(pick_or_val, _), do: pick_or_val
end
