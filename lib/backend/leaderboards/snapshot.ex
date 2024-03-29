defmodule Backend.Leaderboards.Snapshot do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  alias Backend.Leaderboards.Snapshot.Entry

  @non_embed_attrs [
    :upstream_updated_at,
    :season_id,
    :leaderboard_id,
    :region
  ]
  @required [:season_id, :leaderboard_id, :region]
  @embed_attrs [:entries]
  schema "leaderboard_snapshot" do
    field :upstream_updated_at, :utc_datetime
    field :season_id, :integer
    field :leaderboard_id, :string
    field :region, :string
    embeds_many(:entries, Entry)
    timestamps()
  end

  @doc false
  def changeset(snapshot, attrs) do
    snapshot
    |> cast(attrs, @non_embed_attrs)
    |> cast_embed(:entries)
    |> validate_required(@required ++ @embed_attrs)
    |> unique_constraint(:region, name: :snapshot_unique_index)
  end

  @spec extract_updated_at(any) ::
          nil
          | %{
              :__struct__ => DateTime | NaiveDateTime,
              :calendar => atom,
              :day => pos_integer,
              :hour => non_neg_integer,
              :microsecond => {non_neg_integer, non_neg_integer},
              :minute => non_neg_integer,
              :month => pos_integer,
              :second => non_neg_integer,
              :year => integer,
              optional(:std_offset) => integer,
              optional(:time_zone) => binary,
              optional(:utc_offset) => integer,
              optional(:zone_abbr) => binary
            }
  def extract_updated_at(%{"last_updated_time" => last_updated_time}) do
    with {:error, _reason} <-
           last_updated_time |> Timex.parse("{YYYY}/{M}/{D} {ISOtime} {WDshort}"),
         {:error, _reason} <-
           last_updated_time
           |> String.split(" ")
           |> Enum.take(2)
           |> Enum.join(" ")
           |> Kernel.<>("+00:00")
           |> DateTime.from_iso8601() do
      nil
    else
      {:ok, time} -> time
      {:ok, time, 0} -> time
    end
  end

  def extract_updated_at(_) do
    nil
  end

  def official_link(%{region: r, leaderboard_id: ldb, season_id: s}) do
    "https://hearthstone.blizzard.com/en-us/community/leaderboards?region=#{r}&leaderboardId=#{Hearthstone.Leaderboards.Api.ldb_id(ldb)}&seasonId=#{s}"
  end

  def official_link(_), do: nil
end

defmodule Backend.Leaderboards.Snapshot.Entry do
  @moduledoc "A player entry in the leaderboard snapshot"
  use Ecto.Schema
  import Ecto.Changeset
  @all_attrs [:account_id, :rank, :rating]
  @required [:account_id, :rank]
  @primary_key {:rank, :integer, autogenerate: false}
  embedded_schema do
    field :account_id, :string, default: "------"
    field :rating, :integer
  end

  @doc false
  def changeset(entry, attrs = %{account_id: nil}) do
    new_attrs = Map.put(attrs, :account_id, "------")
    changeset(entry, new_attrs)
  end

  def changeset(entry, attrs) do
    entry
    |> cast(attrs, @all_attrs)
    |> validate_required(@required)
  end
end
