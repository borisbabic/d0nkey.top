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
    field(:raw_response, map())
    field(:season_metadata, SeasonMetadata.t())
  end

  @spec rows(Response.t()) :: [Hearthstone.Leaderboards.Response.Row.t()]
  def rows(%{leaderboard: %{rows: rows}}), do: rows
  def rows(_), do: []
  @spec total_pages(Response.t()) :: {:ok, integer()} | :error
  def total_pages(%{leaderboard: %{pagination: %{total_pages: total}}}), do: {:ok, total}
  def total_pages(_), do: :error

  @spec total_size(Response.t()) :: {:ok, integer()} | :error
  def total_size(%{leaderboard: %{pagination: %{total_size: total}}}), do: {:ok, total}
  def total_size(_), do: :error

  @spec from_raw_map(map(), integer() | Season.t() | nil) ::
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
        season_metadata: SeasonMetadata.from_raw_map(raw["seasonMetaData"] || raw["seasonMetadata"])
      }
    }
  end

  @spec get_leaderboard_metadata(t(), leaderboard_id :: String.t(), region :: String.t()) ::
          {:ok, Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata.t()}
          | {:error, atom()}
  def get_leaderboard_metadata(%{season_metadata: sm}, leaderboard_id, region),
    do: SeasonMetadata.get_leaderboard_metadata(sm, leaderboard_id, region)

  @spec from_china_map(map(), Season.t()) :: {:ok, Response.t()}
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

  @spec from_raw_map(map()) :: Leaderboard.t()
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

  @spec from_raw_list([map()]) :: [Row.t()]
  def from_raw_list(raw), do: Enum.map(raw, &from_raw_map/1)

  @spec from_raw_map(map()) :: Row.t()
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

  @spec from_raw_map(map()) :: Pagination.t()
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
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata

  typedstruct do
    field(:ap, RegionMetadata.t())
    field(:eu, RegionMetadata.t())
    field(:us, RegionMetadata.t())
  end

  @spec from_raw_map(map() | nil) :: SeasonMetadata.t() | nil
  def from_raw_map(%{} = map) do
    eu = Map.get(map, "EU") || Map.get(map, "eu") || Map.get(map, :eu) || Map.get(map, :EU)
    us = Map.get(map, "US") || Map.get(map, "us") || Map.get(map, :us) || Map.get(map, :US)
    ap = Map.get(map, "AP") || Map.get(map, "ap") || Map.get(map, :ap) || Map.get(map, :AP)

    if eu || us || ap do
      %__MODULE__{
        ap: RegionMetadata.from_raw_map(ap),
        eu: RegionMetadata.from_raw_map(eu),
        us: RegionMetadata.from_raw_map(us)
      }
    else
      nil
    end
  end

  def from_raw_map(_), do: nil

  @spec get_region_metadata(t(), region :: String.t() | atom()) ::
          {:ok, RegionMetadata.t()} | {:error, atom()}
  def get_region_metadata(%__MODULE__{} = season_metadata, region) do
    case get_region_key(region) do
      {:ok, :eu} ->
        if season_metadata.eu, do: {:ok, season_metadata.eu}, else: {:error, :unsupported_region}

      {:ok, :ap} ->
        if season_metadata.ap, do: {:ok, season_metadata.ap}, else: {:error, :unsupported_region}

      {:ok, :us} ->
        if season_metadata.us, do: {:ok, season_metadata.us}, else: {:error, :unsupported_region}

      _ ->
        {:error, :unsupported_region}
    end
  end

  def get_region_metadata(_, _), do: {:error, :invalid_season_metadata}

  @spec get_leaderboard_metadata(t(), leaderboard_id :: String.t() | atom(), region :: String.t() | atom()) ::
          {:ok, LeaderboardMetadata.t()} | {:error, atom()}
  def get_leaderboard_metadata(%__MODULE__{} = season_metadata, leaderboard_id, region) do
    with {:ok, region_meta} <- get_region_metadata(season_metadata, region) do
      RegionMetadata.get_leaderboard_metadata(region_meta, leaderboard_id)
    end
  end

  def get_leaderboard_metadata(_, _, _), do: {:error, :invalid_season_metadata}

  defp get_region_key(region)
       when region in ["EU", :EU, "eu", :eu, "Europe", :Europe, :europe, "europe"],
       do: {:ok, :eu}

  defp get_region_key(region)
       when region in ["US", :US, "us", :us, "America", :America, "Americas", :Americas, :americas, "americas"],
       do: {:ok, :us}

  defp get_region_key(region)
       when region in ["AP", :AP, "ap", :ap, "Asia", :Asia, :asia, "asia", "APAC", :APAC, :apac, "apac"],
       do: {:ok, :ap}

  defp get_region_key(region)
       when region in ["CN", :CN, "cn", :cn, "China", :China, :china, "china"],
       do: {:ok, :cn}

  defp get_region_key(_), do: {:error, :unsupported_region}
end

defmodule Hearthstone.Leaderboards.Response.SeasonMetadata.RegionMetadata do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata

  typedstruct enforce: false do
    field(:undergroundarena, LeaderboardMetadata.t())
    field(:arena, LeaderboardMetadata.t())
    field(:battlegrounds, LeaderboardMetadata.t())
    field(:battlegroundsduo, LeaderboardMetadata.t())
    field(:classic, LeaderboardMetadata.t())
    field(:mercenaries, LeaderboardMetadata.t())
    field(:standard, LeaderboardMetadata.t())
    field(:twist, LeaderboardMetadata.t())
    field(:wild, LeaderboardMetadata.t())
  end

  @spec from_raw_map(map() | nil) :: RegionMetadata.t() | nil
  def from_raw_map(%{} = map) do
    %__MODULE__{
      arena: LeaderboardMetadata.from_raw_map(map["arena"] || map[:arena]),
      undergroundarena: LeaderboardMetadata.from_raw_map(map["undergroundarena"] || map[:undergroundarena]),
      battlegrounds: LeaderboardMetadata.from_raw_map(map["battlegrounds"] || map[:battlegrounds]),
      battlegroundsduo: LeaderboardMetadata.from_raw_map(map["battlegroundsduo"] || map[:battlegroundsduo]),
      classic: LeaderboardMetadata.from_raw_map(map["classic"] || map[:classic]),
      mercenaries: LeaderboardMetadata.from_raw_map(map["mercenaries"] || map[:mercenaries]),
      standard: LeaderboardMetadata.from_raw_map(map["standard"] || map[:standard]),
      twist: LeaderboardMetadata.from_raw_map(map["twist"] || map[:twist]),
      wild: LeaderboardMetadata.from_raw_map(map["wild"] || map[:wild])
    }
  end

  def from_raw_map(_), do: nil

  @spec get_leaderboard_metadata(t(), leaderboard_id :: String.t() | atom()) ::
          {:ok, LeaderboardMetadata.t()} | {:error, atom()}
  def get_leaderboard_metadata(%__MODULE__{} = season_metadata, leaderboard_id) do
    with {:ok, identifier} <-
           Hearthstone.Leaderboards.Api.get_leaderboard_identifier(leaderboard_id),
         %LeaderboardMetadata{} = metadata <- Map.get(season_metadata, identifier) do
      {:ok, metadata}
    else
      nil -> {:error, :unsupported_leaderboard}
      {:error, _} = e -> e
      _ -> {:error, :unsupported_leaderboard}
    end
  end

  def get_leaderboard_metadata(_, _), do: {:error, :invalid_region_metadata}
end

defmodule Hearthstone.Leaderboards.Response.SeasonMetadata.SeasonItem do
  use TypedStruct

  typedstruct do
    field(:season_id, integer(), enforce: true)
    field(:display_name, map() | String.t() | nil)
    field(:mode, map() | nil)
    field(:key, map() | nil)
  end

  @spec from_raw(map() | integer()) :: t() | nil
  def from_raw(season_id) when is_integer(season_id) do
    %__MODULE__{
      season_id: season_id,
      display_name: nil
    }
  end

  def from_raw(%{} = map) do
    season_id = map["season_id"] || map[:season_id] || map["seasonId"] || map[:seasonId]

    if is_integer(season_id) do
      %__MODULE__{
        season_id: season_id,
        display_name: map["display_name"] || map[:display_name] || map["displayName"] || map[:displayName],
        mode: map["mode"] || map[:mode],
        key: map["key"] || map[:key]
      }
    else
      nil
    end
  end

  def from_raw(_), do: nil

  @spec display_name(t(), String.t()) :: String.t()
  def display_name(%__MODULE__{season_id: season_id, display_name: %{} = dn_map}, locale) do
    Map.get(dn_map, locale) ||
      Map.get(dn_map, "en_US") ||
      Map.get(dn_map, :en_US) ||
      "Season #{season_id}"
  end

  def display_name(%__MODULE__{display_name: dn}, _locale) when is_binary(dn) and dn != "", do: dn
  def display_name(%__MODULE__{season_id: season_id}, _locale), do: "Season #{season_id}"
end

defmodule Hearthstone.Leaderboards.Response.SeasonMetadata.LeaderboardMetadata do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.SeasonMetadata.SeasonItem

  typedstruct do
    field(:name, String.t())
    field(:rating_id, integer() | nil)
    field(:seasons, [SeasonItem.t()])
  end

  @spec get_max_season_id(t()) :: {:ok, integer()} | {:error, atom()}
  def get_max_season_id(%__MODULE__{seasons: seasons}) do
    seasons
    |> Enum.map(& &1.season_id)
    |> case do
      [_ | _] = season_ids -> {:ok, Enum.max(season_ids)}
      _ -> {:error, :no_seasons}
    end
  end

  def get_max_season_id(_), do: {:error, :invalid_leaderboard_metadata}

  @spec get_seasons(t() | any(), String.t()) :: [{String.t(), integer()}]
  def get_seasons(metadata, locale \\ "en_US")

  def get_seasons(%__MODULE__{seasons: seasons}, locale) do
    seasons
    |> Enum.map(fn item ->
      {SeasonItem.display_name(item, locale), item.season_id}
    end)
    |> Enum.sort_by(&elem(&1, 1), :desc)
  end

  def get_seasons(_, _), do: []

  @spec from_raw_map(map() | nil) :: t() | nil
  def from_raw_map(%{} = m) do
    raw_seasons = m["seasons"] || m[:seasons] || []

    parsed_seasons =
      raw_seasons
      |> Enum.map(&SeasonItem.from_raw/1)
      |> Enum.filter(& &1)

    %__MODULE__{
      name: m["name"] || m[:name],
      rating_id: m["ratingId"] || m[:ratingId] || m["rating_id"] || m[:rating_id],
      seasons: parsed_seasons
    }
  end

  def from_raw_map(_), do: nil
end
