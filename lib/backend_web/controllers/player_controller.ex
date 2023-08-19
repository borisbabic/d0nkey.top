defmodule BackendWeb.PlayerController do
  @moduledoc false
  use BackendWeb, :controller
  alias Backend.PlayerInfo
  alias Backend.MastersTour
  alias Backend.MastersTour.TourStop
  alias Backend.Battlenet.Battletag

  def add_current_qualifiers(periods) do
    case TourStop.get_current_qualifiers() do
      %{id: id} -> [id | periods]
      _ -> periods
    end
  end

  defp player_profile_battletags(bt) do
    # move this elsewhere and don't do it like this
    case Backend.Battlenet.get_old_for_btag(bt) do
      [] ->
        [bt]

      changes ->
        Enum.flat_map(changes, &[&1.old_battletag, &1.new_battletag])
        |> Enum.uniq()
    end
  end

  def qualifier_stats(battletags) do
    %{year: year} = Date.utc_today()

    2020..year
    |> Enum.to_list()
    |> add_current_qualifiers()
    |> Enum.flat_map(fn period ->
      period
      |> Backend.MastersTour.get_player_stats()
      |> elem(0)
      |> Enum.filter(fn ps -> ps.battletag_full in battletags end)
      |> case do
        [] -> []
        stats -> [{period, Enum.reduce(stats, &Backend.MastersTour.PlayerStats.merge/2)}]
      end
    end)
  end

  @default_competitions ["leaderboard", "mt"]
  def default_competitions(), do: @default_competitions

  def player_profile(conn, params = %{"battletag_full" => bt}) do
    battletags = player_profile_battletags(bt) |> Enum.reverse()
    short_btags = Enum.map(battletags, &Battletag.shorten/1)
    mt_names = Enum.map(short_btags, &MastersTour.name_hacks/1)

    competitions =
      case multi_select_to_array(params["competition"]) do
        [] -> @default_competitions
        c -> c
      end

    qualifier_stats =
      if Battletag.long?(bt) do
        qualifier_stats(battletags)
      else
        []
      end

    country = PlayerInfo.get_country(bt)

    tournaments =
      if "qualifiers" in competitions do
        Backend.MastersTour.list_qualifiers_for_player(battletags)
      else
        []
      end

    mt_stats =
      MastersTour.masters_tours_stats()
      |> MastersTour.create_mt_stats_collection()
      |> Enum.filter(fn {name, _tts} -> MastersTour.name_hacks(name) in mt_names end)
      |> Enum.reduce([], fn {_name, tts}, carry ->
        tts ++ carry
      end)

    ldb_criteria =
      Enum.flat_map(params, fn
        {"ldb_" <> actual_key, val} -> [{actual_key, val}]
        _ -> []
      end)

    finishes =
      if "leaderboard" in competitions do
        Backend.Leaderboards.finishes_for_battletag(battletags, ldb_criteria)
      else
        []
      end

    render(conn, "player_profile.html", %{
      qualifier_stats: qualifier_stats,
      player_info: %{country: country, region: nil},
      battletags: battletags,
      tournaments: tournaments,
      finishes: finishes,
      competitions: competitions,
      battletag_full: bt,
      page_title: bt,
      tournament_team_stats: mt_stats
    })
  end
end
