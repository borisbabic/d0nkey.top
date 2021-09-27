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
  @all_attrs @non_embed_attrs ++ @embed_attrs
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

  defp map_raw_rows(rows_raw),
    do:
      rows_raw
      |> Enum.map(fn row ->
        %{
          battletag: row["accountid"],
          position: row["rank"],
          rating: row["rating"]
        }
      end)

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
end

defmodule Backend.Leaderboards.Snapshot.Entry do
  use Ecto.Schema
  import Ecto.Changeset
  @all_attrs [:account_id, :rank, :rating]
  @required [:account_id, :rank]
  # @primary_key {:rank, :integer, autogenerate: false}
  embedded_schema do
    field :rank, :integer
    field :account_id, :string
    field :rating, :integer
  end

  @doc false
  def changeset(entry, attrs) do
    entry
    |> cast(attrs, @all_attrs)
    |> validate_required(@required)
  end
end
