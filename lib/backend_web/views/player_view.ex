defmodule BackendWeb.PlayerView do
  use BackendWeb, :view
  alias Backend.MastersTour.PlayerStats
  alias Backend.Blizzard

  def render("player_profile.html", %{
        battletag_full: battletag_full,
        qualifier_stats: qs,
        player_info: pi,
        mt_earnings: mt_earnings
      }) do
    stats_rows =
      case qs do
        nil ->
          []

        ps ->
          [
            {"2020 MTQ played", ps |> PlayerStats.with_result()},
            {"2020 MTQ winrate", ps |> PlayerStats.matches_won_percent() |> Float.round(2)}
          ]
      end

    player_rows =
      case {pi.country, pi.region} do
        {nil, nil} -> []
        {country, nil} -> [{"Country", pi.country}]
        {nil, region} -> [{"Region", pi.region |> Blizzard.get_region_name(:long)}]
        {country, region} -> [{"Country", pi.country}, {"Region", pi.region}]
      end

    earnings_rows = [{"2020 MT earnings", mt_earnings |> IO.inspect()}]

    rows =
      (player_rows ++ stats_rows ++ earnings_rows)
      |> Enum.map(fn {title, val} -> "#{title}: #{val}" end)

    render("player_profile.html", %{title: battletag_full, rows: rows})
  end
end
