defmodule BackendWeb.IyingdiController do
  use BackendWeb, :controller
  alias Backend.Iyingdi

  def lineups(conn, %{"set_id" => set_id}) do
    Iyingdi.ensure_lineups(set_id)

    conn
    |> redirect(to: Iyingdi.lineup_url(set_id))
  end
end
