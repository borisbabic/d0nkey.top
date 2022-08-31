defmodule Backend.Leaderboards.SeasonBag do
  @moduledoc false
  use GenServer
  alias Backend.Leaderboards
  alias Backend.Leaderboards.Season
  alias Hearthstone.Leaderboards.Season, as: ApiSeason

  def start_link(default), do: GenServer.start_link(__MODULE__, default, name: __MODULE__)

  def init(_args) do
    table = :ets.new(__MODULE__, [:named_table])
    {:ok, %{table: table}, {:continue, :init}}
  end

  def handle_continue(:init, state = %{table: table}) do
    update_table(table)
    {:noreply, state}
  end

  def update_table(table) do
    season_objects = Leaderboards.all_seasons() |> Enum.map(&{key(&1), &1})
    :ets.insert(table, season_objects)
  end

  @spec get(Season.t() | ApiSeason.t()) :: {:ok, Season.t()} | {:error, any()}
  def get(s = %Season{id: id}) when is_integer(id), do: {:ok, s}

  def get(base = %{season_id: nil}) do
    filled =
      base
      |> ApiSeason.ensure_region()
      |> ApiSeason.ensure_leaderboard_id()

    {:ok, :ets.foldl(&max_season_id/2, filled, table())}
  end

  def get(season) do
    key = key(season)

    case Util.ets_lookup(table(), key) do
      s = %{id: _} -> {:ok, s}
      _ -> GenServer.call(__MODULE__, {:create_season, season})
    end
  end

  defp max_season_id({_, s}, acc) do
    if to_string(s.leaderboard_id) == to_string(acc.leaderboard_id) and
         to_string(s.region) == to_string(acc.region) and
         s.season_id > (acc.season_id || 0) do
      s
    else
      acc
    end
  end

  def handle_call({:create_season, season}, _, state) do
    created = Leaderboards.create_season(season)
    set_season(created)
    {:reply, created, state}
  end

  defp set_season({:ok, season}), do: set_season(season)

  defp set_season(season = %{region: _}) do
    key = key(season)
    :ets.insert(table(), {key, season})
  end

  defp set_season(_), do: nil

  defp key(season), do: Season.uniq_string(season)

  def table(), do: :ets.whereis(__MODULE__)
end
