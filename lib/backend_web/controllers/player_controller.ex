defmodule BackendWeb.PlayerController do
  @moduledoc false
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.PlayerInfo
  alias Backend.MastersTour.InvitedPlayer

  def player_profile(conn, params = %{"battletag_full" => bt}) do
    qualifier_stats =
      Backend.MastersTour.get_player_stats(2020)
      |> elem(0)
      |> Enum.find(fn ps -> ps.battletag_full == bt end)

    player_info = PlayerInfo.get_info(bt)

    tournaments = Backend.MastersTour.list_qualifiers_for_player(bt)
    tour_stops = Backend.MastersTour.tour_stops_tournaments()

    mt_earnings =
      Backend.MastersTour.get_gm_money_rankings({2021, 1})
      |> Enum.find(fn {player, total, per_stop} ->
        player == InvitedPlayer.shorten_battletag(bt)
      end)
      |> case do
        nil -> 0
        {_, earnings, _} -> earnings
      end

    finishes = Backend.Leaderboards.finishes_for_battletag(bt)

    render(conn, "player_profile.html", %{
      qualifier_stats: qualifier_stats,
      player_info: player_info,
      battletag_full: bt,
      tournaments: tournaments,
      finishes: finishes,
      competitions: multi_select_to_array(params["competition"]),
      mt_earnings: mt_earnings
    })
  end
end
