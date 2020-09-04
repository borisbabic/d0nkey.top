defmodule Backend.Leaderboards.PlayerStats do
  @moduledoc false
  use TypedStruct
  alias Backend.Leaderboards.Snapshot

  typedstruct do
    field :account_id, :string
    field :ranks, :string
  end

  def create_collection(snapshots) do
    snapshots
    |> Enum.flat_map(fn s -> s.entries end)
    |> Enum.group_by(fn e -> e.account_id end)
    |> Enum.map(&create_player_stats/1)
  end

  @spec create_player_stats([Snapshot.Entry]) :: PlayerStats
  def create_player_stats({account_id, player_entries}) do
    %__MODULE__{
      account_id: account_id,
      ranks: player_entries |> Enum.map(fn e -> e.rank end)
    }
  end

  @spec create(Snapshot.t()) :: PlayerStats.t()
  def create(e) do
  end

  @spec num_top(__MODULE__.t(), integer) :: integer
  def num_top(player_stats, inclusive_cutoff) do
    player_stats.ranks
    |> Enum.filter(fn f -> f <= inclusive_cutoff end)
    |> Enum.count()
  end
end
