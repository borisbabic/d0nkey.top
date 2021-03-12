defmodule BackendWeb.AdminView do
  use BackendWeb, :view
  alias Backend.MastersTour.TourStop

  def render("index.html", %{conn: conn}) do
    dropdowns = [
      mt_player_nationality_dropdown(conn),
      recalculate_archetypes_dropdown(conn),
      fantasy_mt_btag_dropdown(conn)
    ]

    links = [
      {
        Routes.admin_path(conn, :check_new_region_data),
        "Check new region data (shows discrepancies)"
      }
    ]

    render("index.html", %{dropdowns: dropdowns, links: links})
  end

  def recalculate_archetypes_dropdown(conn) do
    options =
      [
        {"Last hour", "min_ago_60"},
        {"Last day", "min_ago_1440"},
        {"Last 3 days", "min_ago_4320"},
        {"Last 7 days", "min_ago_10080"},
        {"Last 15 days", "min_ago_21600"}
      ]
      |> Enum.map(fn {display, ma} ->
        %{
          link: Routes.admin_path(conn, :recalculate_archetypes, to_string(ma)),
          selected: false,
          display: display
        }
      end)

    {options, "Recalculate Archetypes"}
  end

  def mt_player_nationality_dropdown(conn) do
    options =
      TourStop.all()
      |> Enum.map(fn ts -> ts.id end)
      |> Enum.map(fn ts ->
        %{
          link: Routes.admin_path(conn, :mt_player_nationality, to_string(ts)),
          display: to_string(ts),
          selected: false
        }
      end)

    {options, "MT Player Nationality"}
  end

  def fantasy_mt_btag_dropdown(conn) do
    options =
      TourStop.all()
      |> Enum.map(fn ts -> ts.id end)
      |> Enum.map(fn ts ->
        %{
          link: Routes.admin_path(conn, :fantasy_fix_btag, to_string(ts)),
          display: to_string(ts),
          selected: false
        }
      end)

    {options, "Fantasy fix mt battletag"}
  end
end
