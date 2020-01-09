defmodule Backend.MastersTour do
  @moduledoc """
    The MastersTour context.
  """
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.MastersTour.InvitedPlayer
  alias Backend.Infrastructure.BattlefyCommunicator

  def create_invited_player(attrs \\ %{}) do
    %InvitedPlayer{}
    |> InvitedPlayer.changeset(attrs)
    |> Repo.insert()
  end

  def list_invited_players() do
    Repo.all(InvitedPlayer)
  end

  def list_invited_players(tour_stop) do
    query =
      from ip in InvitedPlayer,
        where: ip.tour_stop == ^tour_stop,
        select: ip,
        order_by: [desc: ip.upstream_time]

    Repo.all(query)
  end

  def fetch() do
    # until I figure out better storage than I'll get old ones as well
    tour_stop = "Indonesia"

    existing =
      Repo.all(
        from ip in InvitedPlayer, where: ip.tour_stop == ^tour_stop, select: ip.battletag_full
      )
      |> MapSet.new()

    BattlefyCommunicator.get_invited_players(tour_stop)
    |> Enum.filter(fn ip -> !MapSet.member?(existing, ip.battletag_full) end)
    |> Enum.each(&create_invited_player/1)
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
end
