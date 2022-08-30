defmodule Hearthstone.Leaderboards.Response do
  use TypedStruct
  alias Hearthstone.Leaderboards.Response.Leaderboard
  alias Hearthstone.Leaderboards.Season

  typedstruct do
    field :leaderboard, Leaderboard.t()
    field :season, Season.t()
    field :raw_response, Map.t()
  end

  @spec from_raw_map(Map.t(), integer() | Season.t() | nil) ::
          {:ok, Response.t()} | {:error, any()}
  def from_raw_map(raw, leaderboard_id \\ nil)
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
    field :columns, [String.t()]
    field :rows, [Row.t()]
    field :pagination, Pagination.t() | nil
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
    field :account_id, integer(), enforce: true
    field :rank, integer(), enforce: true
    field :rating, integer() | nil, enforce: false
  end

  @spec from_raw_list([Map.t()]) :: [Row.t()]
  def from_raw_list(raw), do: Enum.map(raw, &from_raw_map/1)

  @spec from_raw_map(Map.t()) :: Row.t()
  def from_raw_map(raw) do
    %__MODULE__{
      account_id: raw["accountid"] || raw["account_id"] || raw["battletag"],
      rank: raw["rank"],
      rating: raw["rating"]
    }
  end
end

defmodule Hearthstone.Leaderboards.Response.Pagination do
  use TypedStruct

  typedstruct enforce: true do
    field :total_pages, integer()
    field :total_size, integer()
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
