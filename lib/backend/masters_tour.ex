defmodule Backend.MastersTour do
  @moduledoc """
    The MastersTour context.
  """
  import Ecto.Query, warn: false
  alias Ecto.Multi
  alias Backend.Repo
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Infrastructure.BattlefyCommunicator
  alias Backend.Blizzard

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

  @spec copy_grandmasters(Backend.Blizzard.tour_stop(), String.t() | nil) :: any
  def delete_copied(tour_stop, copied_search \\ "%copied") do
    ts = to_string(tour_stop)

    from(ip in InvitedPlayer, where: like(ip.reason, ^copied_search), where: ip.tour_stop == ^ts)
    |> Repo.delete_all()
  end

  @spec copy_grandmasters(
          Backend.Blizzard.tour_stop(),
          Backen.Blizzard.tour_stop(),
          String.t() | nil,
          String.t() | nil
        ) :: any
  def copy_grandmasters(
        from_ts,
        to_ts,
        reason_append \\ " *copied",
        reason_search \\ "%Grandmaster%"
      ) do
    from = to_string(from_ts)
    to = to_string(to_ts)

    Repo.all(
      from ip in InvitedPlayer,
        where: ip.tour_stop == ^from,
        where: like(ip.reason, ^reason_search)
    )
    |> Enum.uniq_by(&InvitedPlayer.uniq_string/1)
    |> Enum.reduce(Multi.new(), fn gm, multi ->
      # changeset = create_invited_player(%{gm | tour_stop: to_ts, reason: gm.reason <>})
      changeset =
        create_invited_player(%{
          tour_stop: to,
          battletag_full: gm.battletag_full,
          reason: gm.reason <> reason_append,
          upstream_time: gm.upstream_time
        })

      Multi.insert(multi, InvitedPlayer.uniq_string(gm), changeset)
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

  @spec get_masters_date_range(:month) :: {Date.t(), Date.t()}
  def get_masters_date_range(:month) do
    today = %{year: year, month: month, day: day} = Date.utc_today()

    start_of_month =
      case Date.new(year, month, 1) do
        {:ok, date} -> date
        # this should never happen
        {:error, reason} -> throw(reason)
      end

    end_of_month = Date.add(start_of_month, Date.days_in_month(today) - day)
    {start_of_month, end_of_month}
  end

  defp get_latest_tuesday() do
    %{year: year, month: month, day: day} = now = Date.utc_today()
    day_of_the_week = :calendar.day_of_the_week(year, month, day)
    days_to_subtract = 0 - rem(day_of_the_week + 5, 7)
    Date.add(now, days_to_subtract)
  end

  def get_qualifiers_for_tour(tour_stop) do
    {start_date, end_date} = guess_qualifier_range(tour_stop)
    Backend.Infrastructure.BattlefyCommunicator.get_masters_qualifiers(start_date, end_date)
  end

  def guess_qualifier_range(tour_stop) do
    {:ok, seasons} = Blizzard.get_ladder_seasons(tour_stop)
    {min, max} = seasons |> Enum.min_max()
    start_date = Blizzard.get_month_start(min)

    end_date =
      (max + 1)
      |> Blizzard.get_month_start()
      |> Date.add(-1)

    {start_date, end_date}
  end

  def create_qualifier_link(%{slug: slug, id: id}) do
    create_qualifier_link(slug, id)
  end

  @spec create_qualifier_link(String.t(), String.t()) :: String.t()
  def create_qualifier_link(slug, id) do
    "https://battlefy.com/hsesports/#{slug}/#{id}/info"
  end
end
