defmodule Backend.TournamentStats do
  @moduledoc false
  defprotocol Backend.TournamentStats.PlayerPerformance do
    def get_player_performance(standings)
  end
end

defmodule Backend.TournamentStats.TeamStandings do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: true do
    field :position, integer
    field :name, String.t()
    field :wins, integer
    field :losses, integer
    field :auto_wins, integer
    field :auto_losses, integer
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
    field :name, String.t()
    field :wins, integer
    field :losses, integer
    field :auto_wins, integer
    field :auto_losses, integer
    field :only_losses, integer
    field :no_results, integer
    field :positions, [integer]
  end

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
    %__MODULE__{
      name: s.name,
      wins: 0,
      losses: 0,
      auto_wins: 0,
      auto_losses: 0,
      only_losses: 0,
      no_results: 0,
      positions: []
    }
    |> update(s)
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
  def median(%{positions: pos}), do: pos |> Enum.sort() |> Enum.at(Enum.count(pos) |> div(2))

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
