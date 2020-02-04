defmodule Backend.MastersTour do
  @moduledoc """
    The MastersTour context.
  """
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Infrastructure.BattlefyCommunicator

  def create_invited_player(attrs \\ %{}) do
    %InvitedPlayer{}
    |> InvitedPlayer.changeset(attrs)
  end

  def list_invited_players() do
    Repo.all(InvitedPlayer)
  end

  def list_invited_players(tour_stop) do
    query =
      from ip in InvitedPlayer,
        where: ip.tour_stop == ^to_string(tour_stop),
        select: ip,
        order_by: [desc: ip.upstream_time]

    Repo.all(query)
  end

  def fetch(tour_stop) do
    existing =
      Repo.all(
        from ip in InvitedPlayer, where: ip.tour_stop == ^tour_stop, select: ip.battletag_full
      )
      |> MapSet.new()

    BattlefyCommunicator.get_invited_players(tour_stop)
    |> Enum.filter(fn ip -> !MapSet.member?(existing, ip.battletag_full) end)
    |> insert_all
  end

  def fetch() do
    existing =
      Repo.all(
        from ip in InvitedPlayer, select: fragment("concat(?,?)", ip.battletag_full, ip.tour_stop)
      )
      |> MapSet.new()

    BattlefyCommunicator.get_invited_players()
    |> Enum.filter(fn ip -> !MapSet.member?(existing, ip.battletag_full <> ip.tour_stop) end)
    |> insert_all
  end

  def insert_all(new_players) do
    new_players
    |> Enum.filter(fn np -> np.battletag_full && np.tour_stop end)
    |> Enum.uniq_by(&InvitedPlayer.uniq_string/1)
    |> Enum.reduce(Multi.new(), fn np, multi ->
      changeset = create_invited_player(np)
      Multi.insert(multi, InvitedPlayer.uniq_string(np), changeset)
    end)
    |> Repo.transaction()
  end

  def process_invited_player(
        invited = %{
          "battletag" => battletag_full,
          "reason" => reason,
          "type" => type,
          "tourStop" => tour_stop,
          "createdAt" => upstream_time
        }
      ) do
    create_invited_player(%{
      battletag_full: battletag_full,
      reason: reason,
      type: type,
      tour_stop: tour_stop,
      upstream_time: upstream_time,
      tournament_slug: invited["tournamentSlug"],
      tournament_id: invited["tournamentID"]
    })
  end

  def process_invited_player(
        args = %{
          "battletag" => _battletag_full,
          "type" => type,
          "tourStop" => _tour_stop
        }
      ) do
    process_invited_player(Map.put(args, "reason", type))
  end

  @spec get_masters_date_range(:week) :: {Date.t(), Date.t()}
  def get_masters_date_range(:week) do
    start_time = get_latest_tuesday()
    end_time = Date.add(start_time, 7)
    {start_time, end_time}
  end

  defp get_latest_tuesday() do
    %{year: year, month: month, day: day} = now = Date.utc_today()
    day_of_the_week = :calendar.day_of_the_week(year, month, day)
    days_to_subtract = 0 - rem(day_of_the_week + 5, 7)
    Date.add(now, days_to_subtract)
  end
end
