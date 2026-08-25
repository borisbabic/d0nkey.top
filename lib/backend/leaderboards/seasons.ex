defmodule Backend.Leaderboards.Seasons do
  @moduledoc """
  Maintains in-memory cache of current leaderboard seasons from the Blizzard API.
  Uses an ETS table for high-concurrency non-blocking reads and a GenServer for
  periodic refresh and lifecycle management.
  """
  use GenServer
  require Logger

  alias Hearthstone.Leaderboards.Response
  alias Hearthstone.Leaderboards.Response.SeasonMetadata
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.RegionMetadata
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata
  alias Hearthstone.Leaderboards.Api
  alias Hearthstone.Leaderboards.Season, as: ApiSeason

  @table_name :leaderboard_seasons
  @refresh_interval :timer.hours(6)

  @default_bg_seasons [
    {"Season 14", 19},
    {"Season 13", 18},
    {"Season 12", 17},
    {"Season 11", 16},
    {"Season 10", 15},
    {"Season 9", 14},
    {"Season 8", 13},
    {"Season 7", 12},
    {"Season 6", 11},
    {"Season 5", 10},
    {"Season 4", 9},
    {"Season 3", 8},
    {"Season 2", 7}
  ]

  @default_duo_seasons [
    {"Season 14", 19},
    {"Season 13", 18},
    {"Season 12", 17},
    {"Season 11", 16},
    {"Season 10", 15},
    {"Season 9", 14},
    {"Season 8", 13},
    {"Season 7", 12}
  ]

  @default_ug_seasons [
    {"Season 8", 8},
    {"Season 7", 7},
    {"Season 6", 6},
    {"Season 5", 5},
    {"Season 4", 4},
    {"Season 3", 3},
    {"Season 2", 2},
    {"Season 1", 1}
  ]

  @default_arena_seasons 56..36 |> Enum.map(&{"Season #{&1}", &1})

  @doc """
  Starts the Seasons GenServer worker.
  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  # ============================================================================
  # Public API
  # ============================================================================

  @doc """
  Returns a list of selectable seasons `[{display_name, season_id}]` for the given mode and region.
  """
  @spec get_seasons(atom() | String.t(), atom() | String.t() | nil) :: [{String.t(), integer()}]
  def get_seasons(mode, region \\ :EU) do
    canon_mode = normalize_mode(mode)
    canon_region = normalize_region(region)

    case lookup_seasons(canon_mode, canon_region) do
      [_ | _] = seasons ->
        seasons

      _ ->
        case lookup_seasons(canon_mode, :EU) do
          [_ | _] = seasons -> seasons
          _ -> default_seasons(canon_mode)
        end
    end
  end

  @doc """
  Returns the current (latest) season_id for the given mode and region.
  """
  @spec get_current_season(atom() | String.t(), atom() | String.t() | nil) :: integer()
  def get_current_season(mode, region \\ :EU) do
    case get_seasons(mode, region) do
      [{_, season_id} | _] when is_integer(season_id) ->
        season_id

      _ ->
        default_current_season(normalize_mode(mode))
    end
  end

  @doc """
  Returns the display name for a specific season_id in a game mode.
  """
  @spec get_season_name(integer() | String.t(), atom() | String.t(), atom() | String.t() | nil) ::
          String.t()
  def get_season_name(season_id, mode, region \\ :EU)

  def get_season_name(season_id, mode, region) when is_binary(season_id) do
    case Integer.parse(season_id) do
      {int_id, ""} -> get_season_name(int_id, mode, region)
      _ -> season_id
    end
  end

  def get_season_name(season_id, mode, region) when is_integer(season_id) do
    seasons = get_seasons(mode, region)

    case Enum.find(seasons, fn {_, s} -> s == season_id end) do
      {display_name, _} ->
        display_name

      nil ->
        fallback_season_name(season_id, normalize_mode(mode))
    end
  end

  @doc """
  Updates ETS cache from a `Hearthstone.Leaderboards.Response.SeasonMetadata` struct or raw map.
  """
  @spec update_from_metadata(SeasonMetadata.t() | map() | nil) :: :ok
  def update_from_metadata(nil), do: :ok

  def update_from_metadata(%SeasonMetadata{} = metadata) do
    ensure_table()

    regions = [
      {:EU, metadata.eu},
      {:US, metadata.us},
      {:AP, metadata.ap}
    ]

    for {region, region_meta} <- regions, region_meta != nil do
      store_region_metadata(region_meta, region)
    end

    :ok
  end

  def update_from_metadata(%{} = raw_map) do
    case SeasonMetadata.from_raw_map(raw_map) do
      %SeasonMetadata{} = metadata -> update_from_metadata(metadata)
      _ -> :ok
    end
  end

  def update_from_metadata(_), do: :ok

  @doc """
  Updates ETS cache from a `Hearthstone.Leaderboards.Response` struct.
  """
  @spec update_from_response(Response.t() | map()) :: :ok
  def update_from_response(%Response{season_metadata: %SeasonMetadata{} = metadata}) do
    update_from_metadata(metadata)
  end

  def update_from_response(%{"seasonMetaData" => sm}) when is_map(sm) do
    update_from_metadata(sm)
  end

  def update_from_response(%{"seasonMetadata" => sm}) when is_map(sm) do
    update_from_metadata(sm)
  end

  def update_from_response(_), do: :ok

  @doc """
  Fetches the latest leaderboard page from Blizzard API to refresh season metadata.
  """
  @spec fetch_and_update() :: :ok | {:error, any()}
  def fetch_and_update do
    case Api.get_page(%ApiSeason{region: "EU", leaderboard_id: "battlegrounds"}, 1) do
      {:ok, %Response{season_metadata: %SeasonMetadata{} = metadata}} ->
        update_from_metadata(metadata)
        :ok

      {:ok, %Response{}} ->
        {:error, :no_season_metadata}

      {:error, reason} = err ->
        Logger.warning("Failed to fetch leaderboard seasons from API: #{inspect(reason)}")
        err

      other ->
        {:error, other}
    end
  end

  # ============================================================================
  # GenServer Callbacks
  # ============================================================================

  @impl true
  def init(_opts) do
    ensure_table()
    seed_defaults()

    # Schedule initial background fetch and periodic refresh
    schedule_fetch(1_000)

    {:ok, %{}}
  end

  @impl true
  def handle_info(:fetch_seasons, state) do
    Task.start(fn ->
      try do
        fetch_and_update()
      rescue
        e -> Logger.warning("Error fetching leaderboard seasons: #{inspect(e)}")
      catch
        kind, reason -> Logger.warning("Caught error fetching leaderboard seasons: #{inspect({kind, reason})}")
      end
    end)

    schedule_fetch(@refresh_interval)
    {:noreply, state}
  end

  @impl true
  def handle_info(_other, state) do
    {:noreply, state}
  end

  # ============================================================================
  # Internal Helpers
  # ============================================================================

  defp schedule_fetch(after_ms) do
    Process.send_after(self(), :fetch_seasons, after_ms)
  end

  defp ensure_table do
    case :ets.whereis(@table_name) do
      :undefined ->
        :ets.new(@table_name, [:set, :public, :named_table, read_concurrency: true])

      _ ->
        @table_name
    end
  end

  @doc """
  Resets and populates the ETS cache with initial default seasons.
  """
  def seed_defaults do
    ensure_table()

    for region <- [:EU, :US, :AP, :CN] do
      insert_seasons(:BG, region, @default_bg_seasons)
      insert_seasons(:DUO, region, @default_duo_seasons)
      insert_seasons(:undergroundarena, region, @default_ug_seasons)
      insert_seasons(:arena, region, @default_arena_seasons)
    end

    :ok
  end

  defp store_region_metadata(%RegionMetadata{} = region_meta, region) do
    modes = [
      {:BG, region_meta.battlegrounds},
      {:DUO, region_meta.battlegroundsduo},
      {:undergroundarena, region_meta.undergroundarena},
      {:arena, region_meta.arena},
      {:STD, region_meta.standard},
      {:WLD, region_meta.wild},
      {:twist, region_meta.twist},
      {:MRC, region_meta.mercenaries},
      {:CLS, region_meta.classic}
    ]

    for {mode, %LeaderboardMetadata{} = mode_meta} <- modes do
      case LeaderboardMetadata.get_seasons(mode_meta) do
        [_ | _] = seasons ->
          insert_seasons(mode, region, seasons)

        _ ->
          :ok
      end
    end
  end

  defp insert_seasons(mode, region, seasons) do
    :ets.insert(@table_name, {{mode, region}, seasons})
  rescue
    _ -> :ok
  end

  defp lookup_seasons(mode, region) do
    case :ets.lookup(@table_name, {mode, region}) do
      [{{^mode, ^region}, seasons}] -> seasons
      _ -> nil
    end
  rescue
    _ -> nil
  end

  defp default_seasons(:BG), do: @default_bg_seasons
  defp default_seasons(:DUO), do: @default_duo_seasons
  defp default_seasons(:undergroundarena), do: @default_ug_seasons
  defp default_seasons(:arena), do: @default_arena_seasons
  defp default_seasons(_), do: []

  defp default_current_season(:BG), do: 19
  defp default_current_season(:DUO), do: 19
  defp default_current_season(:undergroundarena), do: 8
  defp default_current_season(:arena), do: 56
  defp default_current_season(_), do: 0

  defp fallback_season_name(season_id, mode) when mode in [:BG, :DUO] do
    cond do
      season_id >= 7 -> "Season #{season_id - 5}"
      season_id >= 0 -> "Season #{season_id + 1}"
      true -> "Season #{season_id}"
    end
  end

  defp fallback_season_name(season_id, mode) when mode in [:arena, :undergroundarena] do
    "Season #{season_id}"
  end

  defp fallback_season_name(season_id, _mode) do
    "Season #{season_id}"
  end

  defp normalize_mode(mode)
       when mode in [:BG, "BG", :bg, "bg", :battlegrounds, "battlegrounds", :BGS, "BGS"],
       do: :BG

  defp normalize_mode(mode)
       when mode in [
              :DUO,
              "DUO",
              :duo,
              "duo",
              :battlegroundsduo,
              "battlegroundsduo",
              :battlegroundsduos,
              "battlegroundsduos"
            ],
       do: :DUO

  defp normalize_mode(mode)
       when mode in [:arena, "arena", :Arena, "Arena"],
       do: :arena

  defp normalize_mode(mode)
       when mode in [
              :undergroundarena,
              "undergroundarena",
              :"Underground Arena",
              "Underground Arena",
              "Undergound Arena"
            ],
       do: :undergroundarena

  defp normalize_mode(mode)
       when mode in [:STD, "STD", :std, "std", :standard, "standard", :Standard, "Standard"],
       do: :STD

  defp normalize_mode(mode)
       when mode in [:WLD, "WLD", :wld, "wld", :wild, "wild", :Wild, "Wild"],
       do: :WLD

  defp normalize_mode(mode)
       when mode in [:twist, "twist", :Twist, "Twist"],
       do: :twist

  defp normalize_mode(mode)
       when mode in [:MRC, "MRC", :mrc, "mrc", :mercenaries, "mercenaries"],
       do: :MRC

  defp normalize_mode(mode)
       when mode in [:CLS, "CLS", :cls, "cls", :classic, "classic"],
       do: :CLS

  defp normalize_mode(mode) when is_binary(mode) do
    case String.downcase(mode) do
      "bg" -> :BG
      "duo" -> :DUO
      "arena" -> :arena
      "undergroundarena" -> :undergroundarena
      "std" -> :STD
      "wld" -> :WLD
      "twist" -> :twist
      "mrc" -> :MRC
      "cls" -> :CLS
      _ -> mode
    end
  end

  defp normalize_mode(mode), do: mode

  defp normalize_region(region)
       when region in [:EU, "EU", :eu, "eu", :Europe, "Europe", "europe"],
       do: :EU

  defp normalize_region(region)
       when region in [:US, "US", :us, "us", :America, "America", :Americas, "Americas"],
       do: :US

  defp normalize_region(region)
       when region in [:AP, "AP", :ap, "ap", :Asia, "Asia", :APAC, "APAC"],
       do: :AP

  defp normalize_region(region)
       when region in [:CN, "CN", :cn, "cn", :China, "China"],
       do: :CN

  defp normalize_region(_), do: :EU
end
