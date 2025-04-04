defmodule Hearthstone.Leaderboards.Response do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.Leaderboard
  alias Hearthstone.Leaderboards.Response.SeasonMetadata
  alias Hearthstone.Leaderboards.Response.Row
  alias Hearthstone.Leaderboards.Response.Pagination
  alias Hearthstone.Leaderboards.Season

  typedstruct do
    field(:leaderboard, Leaderboard.t())
    field(:season, Season.t())
    field(:raw_response, Map.t())
    field(:season_metadata, SeasonMetadata.t())
  end

  @spec rows(Response.t()) :: [Hearthstone.Leaderboards.Response.Row.t()]
  def rows(%{leaderboard: %{rows: rows}}), do: rows
  def rows(_), do: []
  @spec total_pages(Response.t()) :: {:ok, integer()} | :error
  def total_pages(%{leaderboard: %{pagination: %{total_pages: total}}}), do: {:ok, total}
  def total_pages(_), do: :error

  @spec from_raw_map(Map.t(), integer() | Season.t() | nil) ::
          {:ok, Response.t()} | {:error, any()}
  def from_raw_map(raw, leaderboard_id \\ nil)

  def from_raw_map(raw, %{region: r} = season) when r in ["CN", :CN] do
    from_china_map(raw, season)
  end

  def from_raw_map(raw, %{leaderboard_id: leaderboard_id}), do: from_raw_map(raw, leaderboard_id)

  def from_raw_map(raw, leaderboard_id) do
    {
      :ok,
      %__MODULE__{
        leaderboard: (raw["leaderboard"] || raw["entries"]) |> Leaderboard.from_raw_map(),
        season: %Season{
          season_id: raw["seasonId"] || raw["season_id"] || raw["seasonID"],
          region: raw["region"],
          leaderboard_id: leaderboard_id
        },
        raw_response: raw,
        season_metadata:
          SeasonMetadata.from_raw_map(raw["seasonMetaData"] || raw["seasonMetadata"])
      }
    }
  end

  @spec get_leaderboard_metadata(t(), leaderboard_id :: String.t(), region :: String.t()) ::
          {:ok, Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata.t()}
          | {:error, atom()}
  def get_leaderboard_metadata(%{season_metadata: sm}, leaderboard_id, region),
    do: SeasonMetadata.get_leaderboard_metadata(sm, leaderboard_id, region)

  @spec from_china_map(Map.t(), Season.t()) :: {:ok, Response.t()}
  def from_china_map(raw, season) do
    total = get_in(raw, ["data", "total"]) || 100
    pages = (total / 25) |> Float.ceil() |> trunc()
    rows = get_in(raw, ["data", "list"]) || []
    pagination_shim = %{"totalPages" => pages, "totalSize" => total}

    leaderboard_shim = %{
      "columns" => [],
      "pagination" => pagination_shim,
      "rows" => rows
    }

    {
      :ok,
      %__MODULE__{
        leaderboard: Leaderboard.from_raw_map(leaderboard_shim),
        season: season,
        raw_response: raw
      }
    }
  end
end

defmodule Hearthstone.Leaderboards.Response.Leaderboard do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.Row
  alias Hearthstone.Leaderboards.Response.Pagination

  typedstruct do
    field(:columns, [String.t()])
    field(:rows, [Row.t()])
    field(:pagination, Pagination.t() | nil)
  end

  @spec from_raw_map(Map.t()) :: Leaderboard.t()
  def from_raw_map(raw) do
    %__MODULE__{
      columns: raw["columns"],
      rows: Row.from_raw_list(raw["rows"]),
      pagination: Pagination.from_raw_map(raw["pagination"])
    }
  end
end

defmodule Hearthstone.Leaderboards.Response.Row do
  use TypedStruct

  typedstruct do
    field(:account_id, integer(), enforce: true)
    field(:rank, integer(), enforce: true)
    field(:rating, integer() | nil, enforce: false)
  end

  @spec from_raw_list([Map.t()]) :: [Row.t()]
  def from_raw_list(raw), do: Enum.map(raw, &from_raw_map/1)

  @spec from_raw_map(Map.t()) :: Row.t()
  def from_raw_map(raw) do
    %__MODULE__{
      account_id: raw["accountid"] || raw["account_id"] || raw["battletag"] || raw["battle_tag"],
      rank: raw["rank"] || raw["position"],
      rating: raw["rating"] || raw["score"]
    }
  end
end

defmodule Hearthstone.Leaderboards.Response.Pagination do
  use TypedStruct

  typedstruct enforce: true do
    field(:total_pages, integer())
    field(:total_size, integer())
  end

  @spec from_raw_map(Map.t()) :: Pagination.t()
  def from_raw_map(%{"totalPages" => total_pages, "totalSize" => total_size}) do
    %__MODULE__{
      total_pages: total_pages,
      total_size: total_size
    }
  end

  def from_raw_map(_), do: nil
end

defmodule Hearthstone.Leaderboards.Response.SeasonMetadata do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.RegionMetadata

  typedstruct do
    field(:ap, RegionMetadata.t())
    field(:eu, RegionMetadata.t())
    field(:us, RegionMetadata.t())
  end

  @spec from_raw_map(Map.t()) :: SeasonMetadata.t()
  def from_raw_map(%{"AP" => ap, "EU" => eu, "US" => us}) do
    %__MODULE__{
      ap: RegionMetadata.from_raw_map(ap),
      eu: RegionMetadata.from_raw_map(eu),
      us: RegionMetadata.from_raw_map(us)
    }
  end

  @spec get_leaderboard_metadata(t(), leaderboard_id :: String.t(), region :: String.t()) ::
          {:ok, Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata.t()}
          | {:error, atom()}
  def get_leaderboard_metadata(season_metadata, leaderboard_id, region) do
    case Backend.Blizzard.get_region_identifier(region) do
      {:ok, :EU} -> RegionMetadata.get_leaderboard_metadata(season_metadata.eu, leaderboard_id)
      {:ok, :AP} -> RegionMetadata.get_leaderboard_metadata(season_metadata.ap, leaderboard_id)
      {:ok, :US} -> RegionMetadata.get_leaderboard_metadata(season_metadata.us, leaderboard_id)
      _ -> {:error, :unsupported_region}
    end
  end
end

defmodule Hearthstone.Leaderboards.Response.SeasonMetadata.RegionMetadata do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata

  typedstruct enforce: false do
    field(:arena, LeaderboardMetadata.t(), enforce: true)
    field(:battlegrounds, LeaderboardMetadata.t(), enforce: true)
    field(:classic, LeaderboardMetadata.t())
    field(:mercenaries, LeaderboardMetadata.t(), enforce: true)
    field(:standard, LeaderboardMetadata.t(), enforce: true)
    field(:twist, LeaderboardMetadata.t())
    field(:wild, LeaderboardMetadata.t(), enforce: true)
  end

  @spec from_raw_map(Map.t()) :: SeasonMetadata.t()
  def from_raw_map(
        %{
          "arena" => arena,
          "battlegrounds" => battlegrounds,
          "mercenaries" => mercenaries,
          "standard" => standard,
          "wild" => wild
        } = map
      ) do
    %__MODULE__{
      arena: LeaderboardMetadata.from_raw_map(arena),
      battlegrounds: LeaderboardMetadata.from_raw_map(battlegrounds),
      classic: LeaderboardMetadata.from_raw_map(map["classic"]),
      mercenaries: LeaderboardMetadata.from_raw_map(mercenaries),
      standard: LeaderboardMetadata.from_raw_map(standard),
      twist: LeaderboardMetadata.from_raw_map(map["twist"]),
      wild: LeaderboardMetadata.from_raw_map(wild)
    }
  end

  @spec get_leaderboard_metadata(t(), leaderboard_id :: String.t()) ::
          {:ok, LeaderboardMetadata.t()} | {:error, atom()}
  def get_leaderboard_metadata(season_metadata, leaderboard_id) do
    with {:ok, identifier} <-
           Hearthstone.Leaderboards.Api.get_leaderboard_identifier(leaderboard_id),
         %{name: _} = metadata <-
           Map.get(season_metadata, identifier, {:error, :unsupported_leaderbaord}) do
      {:ok, metadata}
    end
  end
end

defmodule Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata do
  use TypedStruct

  typedstruct do
    field(:name, String.t())
    field(:rating_id, integer() | nil)
    field(:seasons, [integer()])
  end

  def get_max_season_id(%{seasons: seasons}) do
    max =
      Enum.map(seasons, fn
        s when is_integer(s) -> s
        %{"season_id" => s} -> s
        %{season_id: s} -> s
        _ -> nil
      end)
      |> Enum.filter(& &1)
      |> Enum.max()

    {:ok, max}
  end

  def get_max_season_id(_), do: {:error, :invalid_leaderboard_metadata}

  @spec from_raw_map(Map.t()) :: SeasonMetadata.t()
  def from_raw_map(m = %{"name" => name, "seasons" => seasons}) do
    %__MODULE__{
      name: name,
      rating_id: Map.get(m, "ratingId"),
      seasons: seasons
    }
  end
end
