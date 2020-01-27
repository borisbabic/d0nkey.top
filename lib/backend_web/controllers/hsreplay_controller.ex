defmodule BackendWeb.HSReplayController do
  use BackendWeb, :controller
  alias Backend.HSReplay

  def live_feed(conn, params) do
    feed = HSReplay.get_latest(params)
    archetypes = HSReplay.get_archetypes()
    render(conn, "live_feed.html", %{feed: feed, archetypes: archetypes})
  end
end
