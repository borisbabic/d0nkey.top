defmodule BackendWeb.HSReplayController do
  use BackendWeb, :controller
  alias Backend.HSReplay

  def live_feed(conn, params) do
    feed = HSReplay.get_latest(params)
    archetypes = HSReplay.get_archetypes()
    render(conn, "live_feed.html", %{feed: feed, archetypes: archetypes})
  end

  def extract_archetype_ids(params) do
    params
    |> Util.to_list()
    |> Enum.map(fn a ->
      case Integer.parse(a) do
        :error ->
          {[archetype], _} = HSReplay.find_archetypes_by_names([a])
          archetype.id

        {int_val, _remainder} ->
          int_val
      end
    end)
  end

  def matchups(conn, params = %{"as" => as_raw, "vs" => vs_raw}) do
    cookies = params["cookies"]

    archetype_matchups =
      Backend.Infrastructure.HSReplayCommunicator.get_archetype_matchups(cookies)

    archetypes = HSReplay.get_archetypes()
    as = extract_archetype_ids(as_raw)
    vs = extract_archetype_ids(vs_raw)

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
