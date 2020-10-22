defmodule BackendWeb.AdminView do
  use BackendWeb, :view
  alias Backend.MastersTour.TourStop

  def render("index.html", %{conn: conn}) do
    dropdowns = [
      mt_player_nationality_dropdown(conn)
    ]

    links = [
      {
        Routes.admin_path(conn, :check_new_region_data),
        "Check new region data (shows discrepancies)"
      }
    ]

    render("index.html", %{dropdowns: dropdowns, links: links})
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
end
