defmodule BackendWeb.PlayerController do
  @moduledoc false
  use BackendWeb, :controller
  alias Backend.PlayerInfo
  alias Backend.MastersTour
  alias Backend.MastersTour.InvitedPlayer

  def player_profile(conn, params = %{"battletag_full" => bt}) do
    qualifier_stats =
      [2020, 2021]
      |> Enum.flat_map(fn year ->
        year
        |> Backend.MastersTour.get_player_stats()
        |> elem(0)
        |> Enum.find(fn ps -> ps.battletag_full == bt end)
        |> case do
          ps = %{wins: _} -> [{year, ps}]
          nil -> []
        end
      end)

    country = PlayerInfo.get_country(bt)

    tournaments = Backend.MastersTour.list_qualifiers_for_player(bt)
    short_bt = bt |> InvitedPlayer.shorten_battletag()

    mt_earnings =
      Backend.MastersTour.get_gm_money_rankings({2021, 1}, :earnings_2020)
      |> Enum.find(fn {player, _total, _per_stop} ->
        player == short_bt
      end)
      |> case do
        nil -> 0
        {_, earnings, _} -> earnings
      end

    mt_stats =
      MastersTour.masters_tours_stats()
      |> MastersTour.create_mt_stats_collection()
      |> Enum.find_value([], fn {name, tts} -> name == short_bt && tts end)

    finishes = Backend.Leaderboards.finishes_for_battletag(bt)

    render(conn, "player_profile.html", %{
      qualifier_stats: qualifier_stats,
      player_info: %{country: country, region: nil},
      battletag_full: bt,
      tournaments: tournaments,
      finishes: finishes,
      competitions: multi_select_to_array(params["competition"]),
      page_title: bt,
      tournament_team_stats: mt_stats,
      mt_earnings: mt_earnings
    })
  end
end
