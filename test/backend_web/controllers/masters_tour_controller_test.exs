defmodule BackendWeb.MastersTourControllerTest do
  @moduledoc false
  use BackendWeb.ConnCase
  ##### MT Stats #####
  # test "GET /mt/stats?country[UK]=true INCLUDES DeadDraw and flag", %{conn: conn} do
  # params = %{
  # "country" => %{"GB" => true}
  # }

  # url = Routes.masters_tour_path(conn, :masters_tours_stats, params)
  # conn = get(conn, url)
  # assert html_response(conn, 200) =~ "/player-profile/DeadDraw"
  # assert html_response(conn, 200) =~ "https://www.countryflags.io/UK/flat/64.png"
  # end

  test "GET /mt/qualifier-stats/ responds with 200", %{conn: conn} do
    params = %{
      "min" => 1000
    }

    url = Routes.masters_tour_path(conn, :qualifier_stats, params)
    conn = get(conn, url)
    assert html_response(conn, 200)
  end

  test "GET /mt/qualifier-stats/Ironforge creates the proper links in the page size dropdown", %{
    conn: conn
  } do
    url = Routes.masters_tour_path(conn, :qualifier_stats, :Ironforge)
    conn = get(conn, url)
    assert html_response(conn, 200) =~ "/mt/qualifier-stats/Ironforge?limit="
  end
end
