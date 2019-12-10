defmodule Backend.MastersTour do
  @moduledoc """
    The MastersTour context.
  """
  import Ecto.Query, warn: false
  alias Backend.Repo
  alias Backend.MastersTour.InvitedPlayer

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
        select: ip
    Repo.all(query)
  end

  def fetch() do
    # until I figure out better storage than I'll get old ones as well
    tour_stop = "Indonesia"

    response =
      HTTPoison.get!(
        "https://majestic.battlefy.com/hearthstone-masters/invitees?tourStop=#{tour_stop}"
      )

    Poison.decode!(response.body)
    |> Enum.each(fn ip ->
      process_invited_player(ip)
    end)
  end

  def process_invited_player(%{
        "battletag" => battletag_full,
        "reason" => reason,
        "type" => type,
        "tourStop" => tour_stop
      }) do
    with [] <-
           Repo.all(
             from ip in InvitedPlayer,
               where: ip.battletag_full == ^battletag_full and ip.tour_stop == ^tour_stop,
               select: ip
           ) do
      create_invited_player(%{
        battletag_full: battletag_full,
        reason: reason,
        type: type,
        tour_stop: tour_stop
      })
    end
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
