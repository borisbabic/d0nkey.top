defmodule Backend.Leaderboards.SeasonBag do
  @moduledoc false
  require Backend.Blizzard
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
    :ets.delete_all_objects(table)
    :ets.insert(table, season_objects)
  end

  def update(), do: GenServer.cast(__MODULE__, :update)
  @spec get(Season.t() | ApiSeason.t()) :: {:ok, Season.t()} | {:error, any()}
  def get(s = %Season{id: id}) when is_integer(id), do: {:ok, s}

  def get(base = %{season_id: nil}) do
    filled = ensure(base)

    {:ok, :ets.foldl(&max_season_id/2, filled, table())}
  end

  def get(season = %{season_id: id, leaderboard_id: l})
      when is_integer(id) and l in ["BG", :BG] and Backend.Blizzard.is_unrealistic_bg_season(id) do
    season
    |> Map.delete(:season_id)
    |> get()
  end

  def get(season = %{season_id: id}) when is_integer(id) do
    key = key(season)

    case Util.ets_lookup(table(), key) do
      s = %{id: _} -> {:ok, s}
      _ -> GenServer.call(__MODULE__, {:create_season, season})
    end
  end

  def get(season), do: {:ok, ensure(season)}

  defp ensure(season),
    do: season |> ApiSeason.ensure_region() |> ApiSeason.ensure_leaderboard_id()

  defp max_season_id({_, s}, acc) do
    if to_string(s.leaderboard_id) == to_string(acc.leaderboard_id) and
         to_string(s.region) == to_string(acc.region) and
         s.season_id > (acc.season_id || 0) do
      s
    else
      acc
    end
  end

  def handle_cast(:update, state) do
    update_table(state.table)
    {:noreply, state}
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

  @spec get_database_id(Season.t() | ApiSeason.t()) :: {:ok, integer()} | :error
  def get_database_id(%{id: id}) when is_integer(id), do: {:ok, id}

  def get_database_id(s) do
    case get(s) do
      {:ok, %{id: id}} when is_integer(id) -> {:ok, id}
      _ -> :error
    end
  end
end
