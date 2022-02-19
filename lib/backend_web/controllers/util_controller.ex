defmodule  BackendWeb.UtilController do
  use BackendWeb, :controller

  def update_pony_dojo(conn, _) do
    Backend.PonyDojo.update()
    text(conn, "Updating in the background, refresh the power rankings to see if it's done (should be done in seconds)")
  end
end
