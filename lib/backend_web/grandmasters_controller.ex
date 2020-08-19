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
        "5f0cc029685620138a169469",
        # APAC W2
        "5f0cc0da26cc57765b463cc1",
        # EU W2
        "5f0cc1439760c878cf3e6984",
        # AM W2
        "5f0cc19b773ffd3455b9e843"
        # APAC W3
        # EU W3
        # AM W3
      ]
      |> Enum.map(&Battlefy.get_tournament/1)

    render(conn, "grandmasters_season.html", %{conn: conn, tournaments: tournaments})
  end

  def grandmasters_season(conn, params),
    do: grandmasters_season(conn, Map.put(params, "season", "2020_2"))
end
