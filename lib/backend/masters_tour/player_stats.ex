defmodule Backend.MastersTour.PlayerStats do
  @moduledoc false
  use TypedStruct
  alias Backend.MastersTour.Qualifier

  typedstruct do
    field :battletag_full, :string
    field :wins, :integer
    field :losses, :integer
    field :won, :boolean
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

  @spec create(Qualifier.Standings.t()) :: Player.t()
  def create(s) do
    %__MODULE__{
      battletag_full: s.battletag_full,
      wins: s.wins,
      losses: s.losses,
      won: s.position == 1,
      top8: if(s.position < 8, do: 1, else: 0),
      top16: if(s.position < 16, do: 1, else: 0),
      positions: [s.position]
    }
  end

  @spec update(Player.t(), Qualifier.Standings.t()) :: Player.t()
  @spec update(Qualifier.Standings.t(), Player.t()) :: Player.t()
  def update(s, p = %__MODULE__{}), do: update(p, s)

  def update(p = %__MODULE__{}, s) do
    if p.battletag_full != s.battletag_full, do: raise("Battletags don't match, wtf")

    %__MODULE__{
      battletag_full: p.battletag_full,
      wins: p.wins + s.wins,
      losses: p.losses + s.losses,
      won: p.won || s.position == 1,
      top8: if(s.position < 8, do: 1, else: 0) + p.top8,
      top16: if(s.position < 16, do: 1, else: 0) + p.top16,
      positions: [s.position | p.positions]
    }
  end
end
