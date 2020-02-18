defmodule BackendWeb.HSReplayController do
  use BackendWeb, :controller
  alias Backend.HSReplay

  def live_feed(conn, params) do
    feed = HSReplay.get_latest(params)
    archetypes = HSReplay.get_archetypes()
    render(conn, "live_feed.html", %{feed: feed, archetypes: archetypes})
  end

  def matchups(conn, %{"as" => as, "vs" => vs}) do
    IO.inspect(as)
    archetype_matchups = HSReplay.get_archetype_matchups()
    archetypes = HSReplay.get_archetypes()

    render(conn, "matchups.html", %{
      matchups: archetype_matchups,
      as: Util.to_list(as),
      vs: Util.to_list(vs),
      archetypes: archetypes
    })
  end

  def matchups(conn, _params) do
    render(conn, "matchups_empty.html")
  end
end
