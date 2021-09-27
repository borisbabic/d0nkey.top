defmodule Backend.Blizzard.Leaderboard do
  @moduledoc false
  use TypedStruct
  alias Backend.Blizzard.Leaderboard.Entry

  typedstruct enforce: true do
    field :updated_at, NaiveDateTime.t()
    field :season_id, integer
    field :region, String.t()
    field :leaderboard_id, String.t()
    field :entries, [Entry.t()]
  end

  @spec old_entries(%__MODULE__{}) :: [Backend.Leaderboards.entry()]
  def old_entries(%{entries: entries}),
    do:
      entries
      |> Enum.map(fn e ->
        %{
          rating: e.rating,
          battletag: e.account_id,
          position: e.rank
        }
      end)

  def from_raw_map(map = %{"seasonId" => _}),
    do:
      map
      |> Recase.Enumerable.convert_keys(&Recase.to_snake/1)
      |> from_raw_map()

  def from_raw_map(%{
        "season_id" => season_id,
        "region" => region,
        "leaderboard" => %{
          "leaderboard_id" => leaderboard_id,
          "rows" => rows_raw,
          "metadata" => metadata
        }
      }) do
    %__MODULE__{
      updated_at: extract_updated_at(metadata),
      season_id: season_id |> parse_season_id(),
      leaderboard_id: leaderboard_id,
      region: region,
      entries: Entry.from_raw_map(rows_raw)
    }
  end

  def from_raw_map(_), do: nil

  defp parse_season_id(s) when is_integer(s), do: s

  defp parse_season_id(s) when is_binary(s),
    do: s |> Integer.parse() |> elem(0) |> parse_season_id()

  defp parse_season_id(_), do: 0

  defp extract_updated_at(map), do: map |> Backend.Leaderboards.Snapshot.extract_updated_at()
end

defmodule Backend.Blizzard.Leaderboard.Entry do
  @moduledoc false
  use TypedStruct

  typedstruct enforce: false do
    field :account_id, String.t()
    field :rank, integer
    field :rating, String.t()
  end

  def from_raw_map(entries = [%{"rank" => _} | _]), do: entries |> Enum.map(&from_raw_map/1)

  def from_raw_map(map = %{"accountid" => account_id, "rank" => rank}) do
    %__MODULE__{
      account_id: account_id,
      rank: rank,
      rating: map["rating"]
    }
  end
end
