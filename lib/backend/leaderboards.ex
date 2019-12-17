defmodule Backend.Leaderboards do
  @moduledoc """
  The Leaderboards context.
  """

  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.Leaderboards.Leaderboard
  alias Backend.Leaderboards.LeaderboardEntry
  alias Backend.Leaderboards.LeaderboardSnapshot

  @last_leaderboard_key "last_leaderboard"

  @doc """
  Returns the list of leaderboard_snapshot.

  ## Examples

      iex> list_leaderboard_snapshot()
      [%LeaderboardSnapshot{}, ...]

  """
  def list_leaderboard_snapshot do
    Repo.all(LeaderboardSnapshot)
  end

  @doc """
  Gets a single leaderboard_snapshot.

  Raises `Ecto.NoResultsError` if the Leaderboard snapshot does not exist.

  ## Examples

      iex> get_leaderboard_snapshot!(123)
      %LeaderboardSnapshot{}

      iex> get_leaderboard_snapshot!(456)
      ** (Ecto.NoResultsError)

  """
  def get_leaderboard_snapshot!(id), do: Repo.get!(LeaderboardSnapshot, id)

  @doc """
  Creates a leaderboard_snapshot.

  ## Examples

      iex> create_leaderboard_snapshot(%{field: value})
      {:ok, %LeaderboardSnapshot{}}

      iex> create_leaderboard_snapshot(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_leaderboard_snapshot(attrs \\ %{}) do
    %LeaderboardSnapshot{}
    |> LeaderboardSnapshot.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a leaderboard_snapshot.

  ## Examples

      iex> update_leaderboard_snapshot(leaderboard_snapshot, %{field: new_value})
      {:ok, %LeaderboardSnapshot{}}

      iex> update_leaderboard_snapshot(leaderboard_snapshot, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_leaderboard_snapshot(%LeaderboardSnapshot{} = leaderboard_snapshot, attrs) do
    leaderboard_snapshot
    |> LeaderboardSnapshot.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LeaderboardSnapshot.

  ## Examples

      iex> delete_leaderboard_snapshot(leaderboard_snapshot)
      {:ok, %LeaderboardSnapshot{}}

      iex> delete_leaderboard_snapshot(leaderboard_snapshot)
      {:error, %Ecto.Changeset{}}

  """
  def delete_leaderboard_snapshot(%LeaderboardSnapshot{} = leaderboard_snapshot) do
    Repo.delete(leaderboard_snapshot)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking leaderboard_snapshot changes.

  ## Examples

      iex> change_leaderboard_snapshot(leaderboard_snapshot)
      %Ecto.Changeset{source: %LeaderboardSnapshot{}}

  """
  def change_leaderboard_snapshot(%LeaderboardSnapshot{} = leaderboard_snapshot) do
    LeaderboardSnapshot.changeset(leaderboard_snapshot, %{})
  end

  alias Backend.Leaderboards.Leaderboard

  @doc """
  Returns the list of leaderboard.

  ## Examples

      iex> list_leaderboard()
      [%Leaderboard{}, ...]

  """
  def list_leaderboard do
    Repo.all(Leaderboard)
  end

  @doc """
  Gets a single leaderboard.

  Raises `Ecto.NoResultsError` if the Leaderboard does not exist.

  ## Examples

      iex> get_leaderboard!(123)
      %Leaderboard{}

      iex> get_leaderboard!(456)
      ** (Ecto.NoResultsError)

  """
  def get_leaderboard!(id), do: Repo.get!(Leaderboard, id)

  @doc """
  Creates a leaderboard.

  ## Examples

      iex> create_leaderboard(%{field: value})
      {:ok, %Leaderboard{}}

      iex> create_leaderboard(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_leaderboard(attrs \\ %{}) do
    %Leaderboard{}
    |> Leaderboard.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a leaderboard.

  ## Examples

      iex> update_leaderboard(leaderboard, %{field: new_value})
      {:ok, %Leaderboard{}}

      iex> update_leaderboard(leaderboard, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_leaderboard(%Leaderboard{} = leaderboard, attrs) do
    leaderboard
    |> Leaderboard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Leaderboard.

  ## Examples

      iex> delete_leaderboard(leaderboard)
      {:ok, %Leaderboard{}}

      iex> delete_leaderboard(leaderboard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_leaderboard(%Leaderboard{} = leaderboard) do
    Repo.delete(leaderboard)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking leaderboard changes.

  ## Examples

      iex> change_leaderboard(leaderboard)
      %Ecto.Changeset{source: %Leaderboard{}}

  """
  def change_leaderboard(%Leaderboard{} = leaderboard) do
    Leaderboard.changeset(leaderboard, %{})
  end

  alias Backend.Leaderboards.LeaderboardEntry

  @doc """
  Returns the list of leaderboard_entry.

  ## Examples

      iex> list_leaderboard_entry()
      [%LeaderboardEntry{}, ...]

  """
  def list_leaderboard_entry do
    Repo.all(LeaderboardEntry)
  end

  @doc """
  Gets a single leaderboard_entry.

  Raises `Ecto.NoResultsError` if the Leaderboard entry does not exist.

  ## Examples

      iex> get_leaderboard_entry!(123)
      %LeaderboardEntry{}

      iex> get_leaderboard_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_leaderboard_entry!(id), do: Repo.get!(LeaderboardEntry, id)

  @doc """
  Creates a leaderboard_entry.

  ## Examples

      iex> create_leaderboard_entry(%{field: value})
      {:ok, %LeaderboardEntry{}}

      iex> create_leaderboard_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_leaderboard_entry(attrs \\ %{}) do
    %LeaderboardEntry{}
    |> LeaderboardEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a leaderboard_entry.

  ## Examples

      iex> update_leaderboard_entry(leaderboard_entry, %{field: new_value})
      {:ok, %LeaderboardEntry{}}

      iex> update_leaderboard_entry(leaderboard_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_leaderboard_entry(%LeaderboardEntry{} = leaderboard_entry, attrs) do
    leaderboard_entry
    |> LeaderboardEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a LeaderboardEntry.

  ## Examples

      iex> delete_leaderboard_entry(leaderboard_entry)
      {:ok, %LeaderboardEntry{}}

      iex> delete_leaderboard_entry(leaderboard_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_leaderboard_entry(%LeaderboardEntry{} = leaderboard_entry) do
    Repo.delete(leaderboard_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking leaderboard_entry changes.

  ## Examples

      iex> change_leaderboard_entry(leaderboard_entry)
      %Ecto.Changeset{source: %LeaderboardEntry{}}

  """
  def change_leaderboard_entry(%LeaderboardEntry{} = leaderboard_entry) do
    LeaderboardEntry.changeset(leaderboard_entry, %{})
  end

  defp get_latest_cached_leaderboard() do
    case Backend.ApiCache.get(@last_leaderboard_key) do
      nil -> {[], nil}
      lb -> lb
    end
  end
  defp save_latest_cached_leaderboard(to_save) do
    Backend.ApiCache.set(@last_leaderboard_key, to_save)
    to_save
  end

  def process_current_entries(raw_snapshot = %{"leaderboard" => %{"metadata" => _}}) do
    updated_at = get_updated_at(raw_snapshot)
    {cached_leaderboard, cached_updated_at} = get_latest_cached_leaderboard()
    if is_nil(cached_updated_at) || DateTime.diff(updated_at, cached_updated_at) do
      entries = Enum.map(raw_snapshot["leaderboard"]["rows"], fn row ->
        %{
          battletag: row["accountid"],
          position: row["rank"],
          rating: row["rating"]
        }
      end)
      save_latest_cached_leaderboard({entries, updated_at})
    else
      {cached_leaderboard, cached_updated_at}
    end
  end

  def process_current_entries(_raw_snapshot) do
    get_latest_cached_leaderboard()
  end

  def get_updated_at(%{"leaderboard" => %{"metadata" => metadata}}) do
    metadata["last_updated_time"]
    |> String.split(" ")
    |> Enum.take(2)
    |> Enum.join(" ")
    |> Kernel.<>("+00:00")
    |> DateTime.from_iso8601()
    |> case do
      {:ok, time, _} -> time
      {:error, _} -> nil
    end
  end

  def fetch_current_entries(region, leaderboard_id, season_id) do
    case HTTPoison.get(
           "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
             leaderboard_id
           }&seasonId=#{season_id}"
         ) do
      {:error, _} ->
        get_latest_cached_leaderboard()

      {:ok, %{body: body}} ->
        body
        |> Poison.decode!()
        |> process_current_entries
    end

    # response =
    #   HTTPoison.get!(
    #   )

    # raw_snapshot = Poison.decode!(response.body)
    # process_current_entries(raw_snapshot)
  end

  def fetch_current_entries(region, leaderboard_id) do
    response =
      HTTPoison.get!(
        "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboardId=#{
          leaderboard_id
        }"
      )

    raw_snapshot = Poison.decode!(response.body)
    process_current_entries(raw_snapshot)
  end

  @doc """
  Fetches all leaderboards from upstream and saves them

  ## Examples

      iex> fetch_all()
      nil

  """
  def fetch_all() do
    Enum.each(['WLD', 'STD', 'BG'], fn leaderboard ->
      Enum.each(['EU', 'US', 'AP'], fn region ->
        response =
          HTTPoison.get!(
            "https://playhearthstone.com/en-us/api/community/leaderboardsData?region=#{region}&leaderboard_id=#{
              leaderboard
            }"
          )

        Poison.decode!(response.body) |> process_snapshot
      end)
    end)
  end

  defp process_snapshot(raw_snapshot) do
    season_id = to_string(raw_snapshot["season_id"])
    region = raw_snapshot["region"]
    leaderboard_id = raw_snapshot["leaderboard"]["leaderboard_id"]

    existing =
      Repo.one(
        from l in Leaderboard,
          where:
            l.region == ^region and l.season_id == ^season_id and
              l.leaderboard_id == ^leaderboard_id,
          select: l
      )

    leaderboard =
      case existing do
        nil -> create_leaderboard!(season_id, region, leaderboard_id)
        _ -> existing
      end

    snapshot = create_snapshot!(leaderboard)

    Enum.each(raw_snapshot["leaderboard"]["table"]["rows"], fn row ->
      create_entry(row, snapshot)
    end)
  end

  # defp delete_older_entries(snapshot) do
  #   Repo.dele
  # end
  defp create_entry(
         %{
           "player" => [%{"key" => "id", "battleTag" => battletag}],
           "cells" => [
             %{"data" => [%{"number" => rank, "type" => "NUMBER"}]},
             %{"data" => [%{"number" => rating, "type" => "NUMBER"}]}
           ]
         },
         snapshot
       ) do
    create_leaderboard_entry(%{
      snapshot: snapshot,
      battletag: battletag,
      position: rank,
      rating: rating
    })
  end

  defp create_entry(
         %{
           "player" => [%{"key" => "id", "battleTag" => battletag}],
           "cells" => [%{"id" => "rank", "data" => [%{"number" => rank, "type" => "NUMBER"}]}]
         },
         snapshot
       ) do
    create_leaderboard_entry(%{snapshot: snapshot, battletag: battletag, position: rank})
  end

  def create_snapshot!(leaderboard) do
    Repo.insert!(%LeaderboardSnapshot{leaderboard: leaderboard})
  end

  def create_leaderboard!(season_id, region, leaderboard_id) do
    {upstreamId, _} = Integer.parse(season_id)

    Repo.insert!(%Leaderboard{
      season_id: season_id,
      region: region,
      leaderboard_id: leaderboard_id,
      upstream_id: upstreamId
    })
  end

  @doc """
  Gets entries for the latest snapshot of the leaderboard.

  ## Examples

      iex> get_current_entries!("EU", "BG")
      [%LeaderboardEntry{}]

  """
  def get_current_entries!(region, leaderboard_id) do
    leaderboard =
      Repo.one!(
        from l in Leaderboard,
          where: l.region == ^region and l.leaderboard_id == ^leaderboard_id,
          order_by: [{:desc, l.season_id}],
          limit: 1
      )

    snapshot =
      Repo.one!(
        from ls in LeaderboardSnapshot,
          where: ls.leaderboard_id == ^leaderboard.id,
          order_by: [{:desc, ls.inserted_at}],
          limit: 1
      )

    Repo.all(
      from le in LeaderboardEntry,
        where: le.snapshot_id == ^snapshot.id,
        order_by: [{:asc, le.position}]
    )
  end
end
