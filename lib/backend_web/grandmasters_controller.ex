defmodule BackendWeb.GrandmastersController do
  use BackendWeb, :controller
  alias Backend.Battlefy
  @moduledoc false

  def grandmasters_season(conn, params = %{"season" => "2020_2"}) do
    tournaments =
      [
        # APAC W1
        "5f0cba9b848c145565fc04b5",
        # EU W1
        "5f0cbf5ba6d594120443125e",
        # AM W1
        "5f0cc029685620138a169469"
      ]
      |> Enum.map(&Battlefy.get_tournament/1)

    render(conn, "grandmasters_season.html", %{conn: conn, tournaments: tournaments})
  end

  def grandmasters_season(conn, params),
    do: grandmasters_season(conn, Map.put(params, "season", "2020_2"))
end
