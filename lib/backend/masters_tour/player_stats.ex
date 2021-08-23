defmodule Backend.MastersTour.PlayerStats do
  @moduledoc false
  use TypedStruct
  alias Backend.MastersTour.Qualifier.Standings

  typedstruct do
    field :battletag_full, :string
    field :wins, :integer
    field :losses, :integer
    field :num_won, :integer
    field :only_losses, :integer
    field :no_results, :integer
    field :top8, :integer
    field :top16, :integer
    field :positions, {:array, :integer}
  end

  def create_collection(qualifiers) do
    qualifiers
    |> Enum.flat_map(fn q -> q.standings end)
    |> Enum.group_by(fn p -> p.battletag_full end)
    |> Enum.map(&calculate_player_stats/1)
  end

  def calculate_player_stats({_, ps}), do: calculate_player_stats(ps)
  def calculate_player_stats([first | rest]), do: rest |> Enum.reduce(create(first), &update/2)

  @spec create(Standings.t()) :: PlayerStats.t()
  def create(s) do
    %__MODULE__{
      battletag_full: s.battletag_full,
      wins: 0,
      losses: 0,
      num_won: 0,
      only_losses: 0,
      no_results: 0,
      top8: 0,
      top16: 0,
      positions: []
    }
    |> update(s)
  end

  @spec update(Player.t(), Standings.t()) :: Player.t()
  @spec update(Standings.t(), Player.t()) :: Player.t()
  def update(s, p = %__MODULE__{}), do: update(p, s)

  def update(p = %__MODULE__{}, s) do
    if p.battletag_full != s.battletag_full, do: raise("Battletags don't match, wtf")

    %__MODULE__{
      battletag_full: p.battletag_full,
      wins: p.wins + s.wins,
      losses: p.losses + s.losses,
      num_won: Standings.won(s) + p.num_won,
      only_losses: Standings.only_losses(s) + p.only_losses,
      top8: Standings.top8(s) + p.top8,
      top16: Standings.top16(s) + p.top16,
      no_results: Standings.no_result(s) + p.no_results,
      positions: [s.position | p.positions]
    }
  end

  @doc """
  iex> Backend.MastersTour.PlayerStats.with_result(%{positions: [1,2,3,5], no_results: 2})
  2
  """
  @spec with_result(PlayerStats.t()) :: integer()
  def with_result(%{positions: pos, no_results: nr}), do: Enum.count(pos) - nr

  @doc """
  iex> Backend.MastersTour.PlayerStats.best(%{positions: [5,1,2,3], no_results: 2})
  1
  """
  @spec best(PlayerStats.t()) :: integer()
  def best(%{positions: pos}), do: pos |> Enum.min()

  @doc """
  iex> Backend.MastersTour.PlayerStats.worst(%{positions: [2,5,3,1,], no_results: 2})
  5
  """
  @spec worst(PlayerStats.t()) :: integer()
  def worst(%{positions: pos}), do: pos |> Enum.max()

  @doc """
  iex> Backend.MastersTour.PlayerStats.median(%{positions: [1,2,3], no_results: 2})
  2
  iex> Backend.MastersTour.PlayerStats.median(%{positions: [1,2,3,5], no_results: 2})
  3
  """
  @spec median(PlayerStats.t()) :: integer()
  def median(%{positions: pos}), do: pos |> Enum.sort() |> Enum.at(Enum.count(pos) |> div(2))

  @doc """
  iex> Backend.MastersTour.PlayerStats.only_losses_percent(%{positions: [1,2,3,5,257], no_results: 0, only_losses: 1})
  20.0
  """
  @spec only_losses_percent(PlayerStats.t()) :: float()
  def only_losses_percent(ps = %{only_losses: ol}), do: Util.percent(ol, with_result(ps))

  @doc """
  iex> Backend.MastersTour.PlayerStats.matches(%{wins: 5, losses: 2})
  7
  """
  @spec matches(PlayerStats.t()) :: integer()
  def matches(%{wins: wins, losses: losses}), do: wins + losses

  @doc """
  iex> Backend.MastersTour.PlayerStats.matches_won_percent(%{wins: 8, losses: 2})
  80.0
  """
  @spec matches_won_percent(PlayerStats.t()) :: float
  def matches_won_percent(ps = %{wins: wins}), do: Util.percent(wins, matches(ps))

  @spec projected_matches_won_percent(PlayerStats.t(), integer, float) :: float
  def projected_matches_won_percent(ps = %{wins: wins}, min_cups, adjusted_winrate) do
    adjusted_wins_per_loss = adjusted_winrate / (1 - adjusted_winrate)

    {adjusted_matches, adjusted_wins} =
      case with_result(ps) do
        cups when cups >= min_cups ->
          {matches(ps), wins}

        cups when cups < min_cups ->
          {matches(ps) + (1 + adjusted_wins_per_loss) * (min_cups - cups),
           wins + adjusted_wins_per_loss * (min_cups - cups)}
      end

    Util.percent(adjusted_wins, adjusted_matches)
  end
end
