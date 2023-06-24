defprotocol Backend.TournamentStats.Standings do
  @spec create_team_standings(t) :: Backend.TournamentStats.TeamStandings.t()
  def create_team_standings(standings)
end

defmodule Backend.TournamentStats.TeamStandings do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field(:position, integer)
    field(:name, String.t())
    field(:wins, integer)
    field(:losses, integer)
    field(:auto_wins, integer)
    field(:auto_losses, integer)
  end

  def actual_wins(ts = %__MODULE__{}), do: ts.wins - ts.auto_wins
  def actual_losses(ts = %__MODULE__{}), do: ts.losses - ts.auto_losses
  def only_losses(ts = %__MODULE__{}), do: if(ts |> only_losses?(), do: 1, else: 0)
  def only_losses?(ts = %__MODULE__{}), do: ts |> actual_wins() < 1 && ts |> actual_losses() > 0
  def no_result(ts = %__MODULE__{}), do: if(ts |> no_result?(), do: 1, else: 0)
  def no_result?(ts = %__MODULE__{}), do: ts |> actual_wins() < 1 && ts |> actual_losses() < 1
end

defmodule Backend.TournamentStats.TeamStats do
  @moduledoc false
  use TypedStruct
  alias Backend.TournamentStats.TeamStandings
  @type stats_type :: :actual | :all
  typedstruct enforce: true do
    field(:name, String.t())
    field(:wins, integer)
    field(:losses, integer)
    field(:auto_wins, integer)
    field(:auto_losses, integer)
    field(:only_losses, integer)
    field(:no_results, integer)
    field(:positions, [integer])
  end

  @spec create_collection([TeamStandings.t()]) :: [TeamStats.t()]
  def create_collection(standings) do
    standings
    |> Enum.group_by(fn s -> s.name end)
    |> Enum.map(&calculate_team_stats/1)
  end

  def calculate_team_stats({_, ps}), do: calculate_team_stats(ps)

  def calculate_team_stats([first = %__MODULE__{} | rest]),
    do: rest |> Enum.reduce(first, &update/2)

  def calculate_team_stats([first = %TeamStandings{} | rest]),
    do: rest |> Enum.reduce(create(first), &update/2)

  def calculate_team_stats([]), do: empty("")

  @spec create(TeamStandings.t()) :: TeamStats.t()
  @doc """
  iex> Backend.TournamentStats.TeamStats.create(
  ...>  %Backend.TournamentStats.TeamStandings{
  ...>    name: "Mighty Ducks",
  ...>    position: 8,
  ...>    wins: 20,
  ...>    losses: 4,
  ...>    auto_wins: 5,
  ...>    auto_losses: 2,
  ...>  })
  %Backend.TournamentStats.TeamStats{
    name: "Mighty Ducks",
    wins: 20,
    losses: 4,
    auto_wins: 5,
    auto_losses: 2,
    only_losses: 0,
    no_results: 0,
    positions: [8]
  }
  """
  def create(s) do
    empty(s.name)
    |> update(s)
  end

  def empty(name) do
    %__MODULE__{
      name: name,
      wins: 0,
      losses: 0,
      auto_wins: 0,
      auto_losses: 0,
      only_losses: 0,
      no_results: 0,
      positions: []
    }
  end

  def update(subject = %__MODULE__{}, new = %__MODULE__{}) do
    %__MODULE__{
      name: subject.name,
      wins: subject.wins + new.wins,
      losses: subject.losses + new.losses,
      auto_wins: subject.auto_wins + new.auto_wins,
      auto_losses: subject.auto_losses + new.auto_losses,
      only_losses: subject.only_losses + new.only_losses,
      no_results: subject.no_results + new.no_results,
      positions: new.positions ++ subject.positions
    }
  end

  @doc """
  iex> Backend.TournamentStats.TeamStats.update(
  ...>  %Backend.TournamentStats.TeamStats{
  ...>    name: "Mighty Ducks",
  ...>    wins: 184,
  ...>    losses: 102,
  ...>    auto_wins: 23,
  ...>    auto_losses: 33,
  ...>    only_losses: 20,
  ...>    no_results: 19,
  ...>    positions: [1, 5, 912, 10315, 10, 10, 43256]
  ...>  },
  ...>  %Backend.TournamentStats.TeamStandings{
  ...>    name: "Mighty Ducks",
  ...>    position: 8,
  ...>    wins: 20,
  ...>    losses: 4,
  ...>    auto_wins: 5,
  ...>    auto_losses: 2,
  ...>  })
  %Backend.TournamentStats.TeamStats{
    name: "Mighty Ducks",
    wins: 204,
    losses: 106,
    auto_wins: 28,
    auto_losses: 35,
    only_losses: 20,
    no_results: 19,
    positions: [8, 1, 5, 912, 10315, 10, 10, 43256]
  }
  """
  @spec update(TeamStats.t(), TeamStandings.t()) :: TeamStats.t()
  def update(ts = %__MODULE__{}, s) do
    if ts.name != s.name, do: raise("Team names do not match!")

    %__MODULE__{
      name: ts.name,
      wins: ts.wins + s.wins,
      losses: ts.losses + s.losses,
      auto_wins: ts.auto_wins + s.auto_wins,
      auto_losses: ts.auto_losses + s.auto_losses,
      only_losses: ts.only_losses + (s |> TeamStandings.only_losses()),
      no_results: ts.no_results + (s |> TeamStandings.no_result()),
      positions: [s.position | ts.positions]
    }
  end

  # for use in Enum.reduce()
  @spec update(TeamStandings.t(), TeamStats.t()) :: TeamStats.t()
  def update(s, ts = %__MODULE__{}), do: update(ts, s)

  @doc """
  iex> Backend.TournamentStats.TeamStats.with_result(%{positions: [1,2,3,5], no_results: 2})
  2
  """
  @spec with_result(TeamStats.t()) :: integer()
  def with_result(%{positions: pos, no_results: nr}), do: Enum.count(pos) - nr

  @doc """
  iex> Backend.TournamentStats.TeamStats.best(%{positions: [5,1,2,3], no_results: 2})
  1
  """
  @spec best(TeamStats.t()) :: integer()
  def best(%{positions: pos}), do: pos |> Enum.min()

  @doc """
  iex> Backend.TournamentStats.TeamStats.num_won(%{positions: [5,1,2,3,1], no_results: 2})
  2
  """
  @spec num_won(TeamStats.t()) :: integer()
  def num_won(%{positions: pos}), do: pos |> Enum.filter(fn p -> p == 1 end) |> Enum.count()

  @doc """
  iex> Backend.TournamentStats.TeamStats.worst(%{positions: [2,5,3,1,], no_results: 2})
  5
  """
  @spec worst(TeamStats.t()) :: integer()
  def worst(%{positions: pos}), do: pos |> Enum.max()

  @doc """
  iex> Backend.TournamentStats.TeamStats.median(%{positions: [1,2,3], no_results: 2})
  2
  iex> Backend.TournamentStats.TeamStats.median(%{positions: [1,2,3,5], no_results: 2})
  3
  """
  @spec median(TeamStats.t()) :: integer()
  def median(%{positions: pos}), do: pos |> Util.median()

  @doc """
  iex> Backend.TournamentStats.TeamStats.only_losses_percent(%{positions: [1,2,3,5,257], no_results: 0, only_losses: 1})
  20.0
  """
  @spec only_losses_percent(TeamStats.t()) :: float()
  def only_losses_percent(ps = %{only_losses: ol}), do: Util.percent(ol, with_result(ps))

  @doc """
  iex> Backend.TournamentStats.TeamStats.matches(
  ...> %Backend.TournamentStats.TeamStats{wins: 5, auto_losses: 0, auto_wins: 0, losses: 2, positions: [1],
  ...> no_results: 0, only_losses: 0, name: "AAARRGGHHHH" })
  7
  """
  @spec matches(TeamStats.t(), stats_type) :: integer()
  def matches(ts = %__MODULE__{}, stats_type),
    do: (ts |> wins(stats_type)) + (ts |> losses(stats_type))

  def matches(ts = %__MODULE__{}), do: matches(ts, :actual)

  @doc """
  iex> Backend.TournamentStats.TeamStats.matches_won_percent(%Backend.TournamentStats.TeamStats{wins: 8, losses: 2,
  ...> auto_wins: 5, name: "FUUU", positions: [1], auto_losses: 0, no_results: 0, only_losses: 0}, :actual)
  60.0
  iex> Backend.TournamentStats.TeamStats.matches_won_percent(%Backend.TournamentStats.TeamStats{wins: 8, losses: 2,
  ...> auto_wins: 5, name: "FUUU", positions: [1], auto_losses: 0, no_results: 0, only_losses: 0}, :all)
  80.0
  """
  @spec matches_won_percent(TeamStats.t(), stats_type) :: float
  def matches_won_percent(ts = %__MODULE__{}, stats_type),
    do: Util.percent(ts |> wins(stats_type), ts |> matches(stats_type))

  def matches_won_percent(ts = %__MODULE__{}), do: matches_won_percent(ts, :actual)

  @doc """
  iex> Backend.TournamentStats.TeamStats.wins(%{wins: 8, auto_wins: 2}, :actual)
  6
  iex> Backend.TournamentStats.TeamStats.wins(%{wins: 8, auto_wins: 2}, :all)
  8
  """
  @spec wins(TeamStats.t(), stats_type) :: integer
  def wins(%{wins: wins, auto_wins: auto_wins}, :actual), do: wins - auto_wins
  def wins(%{wins: wins}, :all), do: wins
  def wins(ts), do: ts |> wins(:actual)

  @doc """
  iex> Backend.TournamentStats.TeamStats.losses(%{losses: 8, auto_losses: 2}, :actual)
  6
  iex> Backend.TournamentStats.TeamStats.losses(%{losses: 8, auto_losses: 2}, :all)
  8
  """
  @spec losses(TeamStats.t(), stats_type) :: integer
  def losses(%{losses: losses, auto_losses: auto_losses}, :actual), do: losses - auto_losses
  def losses(%{losses: losses}, :all), do: losses
  def losses(ts), do: ts |> losses(:actual)
end

defmodule Backend.TournamentStats.TournamentTeamStats do
  @moduledoc false
  alias Backend.TournamentStats.TeamStats
  @type stats_type :: :total | Backend.Tournament.bracket_type()
  use TypedStruct

  typedstruct enforce: true do
    field(:tournament_name, String.t())
    field(:tournament_id, String.t())
    field(:team_name, String.t())
    field(:stage_stats, [{Backend.Tournament.bracket_type(), TeamStats.t()}])
  end

  @doc """
  Get the stats the represent the whole tournament over all stages
  """
  @spec total_stats(__MODULE__) :: TeamStats.t()
  def total_stats(%{stage_stats: stage_stats}) do
    {_, final_stage} = stage_stats |> Enum.at(-1)

    total =
      stage_stats
      |> Enum.map(fn {_, s} -> s end)
      |> TeamStats.calculate_team_stats()

    %{total | positions: final_stage.positions}
  end

  def filter_stages(%{stage_stats: stage_stats}, bracket_type),
    do: stage_stats |> Enum.find_value(fn {bt, ts} -> bt == bracket_type && ts end)
end

defmodule Backend.TournamentStats do
  @moduledoc false
  alias Backend.TournamentStats.Standings
  alias Backend.TournamentStats.TeamStats
  alias Backend.TournamentStats.TournamentTeamStats
  @type stage_spec :: {Backend.Tournament.bracket_type(), [any]}
  @spec create_standings([any]) :: [Standings.t()]
  def create_standings(standings) when is_list(standings),
    do: standings |> Enum.map(&Standings.create_team_standings/1)

  @spec create_tournament_team_stats([stage_spec], String.t(), String.t()) :: [
          TournamentTeamStats
        ]
  def create_tournament_team_stats(stage_specs, tournament_name, tournament_id) do
    stage_specs
    |> Enum.flat_map(fn {bracket_type, standings_list} ->
      standings_list
      |> Enum.map(fn s ->
        stats =
          s
          |> Standings.create_team_standings()
          |> TeamStats.create()

        {bracket_type, stats}
      end)
    end)
    |> Enum.group_by(fn {_, %{name: n}} -> n end)
    |> Enum.map(fn {name, stage_stats} ->
      %Backend.TournamentStats.TournamentTeamStats{
        tournament_name: tournament_name,
        tournament_id: tournament_id,
        team_name: name,
        stage_stats: stage_stats
      }
    end)
  end

  def create_team_stats_collection(tournament_stats_list),
    do: create_team_stats_collection(tournament_stats_list, &Util.id/1)

  def create_team_stats_collection(tournament_stats_list, name_mapper) do
    tournament_stats_list
    |> List.flatten()
    |> Enum.group_by(fn ts -> ts.team_name |> name_mapper.() end)
  end
end
