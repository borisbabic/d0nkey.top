defmodule Command.ImportOldLeaderboards do
  @moduledoc "Import old leaderbaords from a csv"

  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.Blizzard
  alias Backend.Blizzard.Leaderboard
  alias Backend.Blizzard.Leaderboard.Entry
  alias Backend.Leaderboards
  alias Backend.Leaderboards.Snapshot

  def import(file \\ "lib/data/old_leaderboards.csv") do
    with {:ok, body} <- File.read(file) do
      body
      |> String.split("\r\n")
      |> Enum.drop(1)
      |> Enum.map(&String.split(&1, ","))
      |> Enum.group_by(fn [region, month, year, _position, _battletag] ->
        "#{region}-#{month}-#{year}"
      end)
      |> Enum.reduce(Multi.new(), fn {snapshot, grouped}, multi ->
        {:ok, ldb} = create_leaderboard(grouped)
        attrs = Leaderboards.create_snapshot_attrs(ldb)
        cs = Snapshot.changeset(%Snapshot{}, attrs)
        Multi.insert(multi, "multi_#{snapshot}", cs)
      end)
      |> Repo.transaction()
    end
  end

  @spec create_leaderboard([]) :: Leaderboard.t()
  defp create_leaderboard(csv_entries = [[region, month_raw, year_raw | _] | _]) do
    with {:ok, month} <- Util.get_month_number(month_raw),
         {year, _} <- Integer.parse(year_raw),
         {:ok, date} <- Date.new(year, month, 13),
         {:ok, updated_at} <- NaiveDateTime.new(year, month, 13, 0, 0, 0),
         season_id <- Blizzard.get_season_id(date) do
      {:ok,
       %Leaderboard{
         season_id: season_id,
         leaderboard_id: "STD",
         region: region(region),
         updated_at: updated_at,
         entries: Enum.map(csv_entries, &create_entry/1)
       }}
    else
      e = {:error, _} -> e
      _ -> {:error, "Couldn't create ldb for #{region} #{month_raw} #{year_raw}"}
    end
  end

  def create_entry([_, _, _, position, battletag]) do
    {rank, _} = Integer.parse(position)

    %Entry{
      account_id: battletag,
      rank: rank,
      rating: nil
    }
  end

  defp region("Eu"), do: "EU"
  defp region("Na"), do: "US"
  defp region("Asia"), do: "AP"
end
