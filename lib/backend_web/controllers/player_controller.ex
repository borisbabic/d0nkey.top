defmodule BackendWeb.PlayerController do
  @moduledoc false
  use BackendWeb, :controller
  alias Backend.Blizzard
  alias Backend.PlayerInfo

  def player_profile(conn, %{"battletag_full" => bt}) do
    qualifier_stats =
      Backend.MastersTour.get_player_stats(2020)
      |> elem(0)
      |> Enum.find(fn ps -> ps.battletag_full == bt end)

    player_info = PlayerInfo.get_info(bt)

    mt_earnings =
      Backend.MastersTour.get_gm_money_rankings({2020, 2})
      |> Enum.find(fn {player, total, per_stop} ->
        player == bt
      end)
      |> case do
        nil -> 0
        earnings -> earnings
      end

    render(conn, "player_profile.html", %{
      qualifier_stats: qualifier_stats,
      player_info: player_info,
      battletag_full: bt,
      mt_earnings: mt_earnings
    })
  end
end
