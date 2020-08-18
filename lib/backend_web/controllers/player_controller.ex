defmodule BackendWeb.PlayerController do
  @moduledoc false
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.PlayerInfo
  alias Backend.MastersTour.InvitedPlayer

  def player_profile(conn, %{"battletag_full" => bt}) do
    qualifier_stats =
      Backend.MastersTour.get_player_stats(2020)
      |> elem(0)
      |> Enum.find(fn ps -> ps.battletag_full == bt end)

    player_info = PlayerInfo.get_info(bt)

    tournaments = Backend.MastersTour.list_qualifiers_for_player(bt)

    mt_earnings =
      Backend.MastersTour.get_gm_money_rankings({2021, 1})
      |> Enum.find(fn {player, total, per_stop} ->
        player == InvitedPlayer.shorten_battletag(bt)
      end)
      |> case do
        nil -> 0
        {_, earnings, _} -> earnings
      end

    render(conn, "player_profile.html", %{
      qualifier_stats: qualifier_stats,
      player_info: player_info,
      battletag_full: bt,
      tournaments: tournaments,
      mt_earnings: mt_earnings
    })
  end
end
