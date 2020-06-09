defmodule Backend.MastersTour.QualifierStats do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.MastersTour.Qualifier
  alias Backend.MastersTour.QualifierStats.Player
  @non_embed_attrs [:tour_stop, :region, :cups_counted]
  @embed_attrs [:player_stats]
  @all_attrs @non_embed_attrs ++ @embed_attrs
  schema "qualifier_stats" do
    field :tour_stop, :string
    field :region, :string
    field :cups_counted, :integer
    embeds_many(:player_stats, Player)
    timestamps()
  end

  @doc false
  def changeset(stats = %__MODULE__{tour_stop: nil}, attrs) do
    stats
    |> cast(attrs, @non_embed_attrs)
    |> cast_embed(:player_stats)
    |> validate_required(@all_attrs)
  end

  @doc false
  def add_cups(stats, []) do
    change(stats)
  end

  def add_cups(stats, cups = [%{standings: _} | _]) do
    add_cups(stats, Enum.map(cups, fn q -> q.standings end))
  end

  def add_cups(stats, cups) do
    stats_map = Map.new(stats.player_stats, fn ps -> {ps.battletag_full, ps} end)

    changes = %{
      cups_counted: stats.cups_counted + Enum.count(cups),
      player_stats: cups |> Enum.reduce(stats_map, &add_player_stats/2) |> Map.values()
    }

    stats
    |> change(changes)
  end

  @spec add_player_stats([Qualifier.Standings], Map.t()) :: [Player]
  def add_player_stats(qualifier_standings, stats_map) do
    qualifier_standings
    |> Enum.reduce(stats_map, fn ps, stats ->
      Map.update(stats, ps.battletag_full, Player.create(ps), fn existing ->
        Player.update(
          existing,
          ps
        )
      end)
    end)
  end
end

defmodule Backend.MastersTour.QualifierStats.Player do
  @moduledoc false
  use Ecto.Schema
  alias Backend.MastersTour.Qualifier
  #    @all_attrs [:wins, :losses, :cups, :top8, :top16, :positions]
  #    @empty_attrs %{
  #      battletag_full: "",
  #      wins: 0,
  #      losses: 0,
  #      cups: 0,
  #      top8: 0,
  #      top16: 0,
  #      positions: []
  #    }
  @primary_key {:battletag_full, :string, autogenerate: false}
  embedded_schema do
    field :wins, :integer
    field :losses, :integer
    field :cups, :integer
    field :won, :boolean
    field :top8, :integer
    field :top16, :integer
    field :positions, {:array, :integer}
  end

  @spec create(Qualifier.Standings.t()) :: Player.t()
  def create(s) do
    %__MODULE__{
      battletag_full: s.battletag_full,
      wins: s.wins,
      losses: s.losses,
      cups: 1,
      won: s.position == 1,
      top8: if(s.position < 8, do: 1, else: 0),
      top16: if(s.position < 16, do: 1, else: 0),
      positions: [s.position]
    }
  end

  @spec update(Player.t(), Qualifier.Standings.t()) :: Player.t()
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
