defmodule Backend.Infrastructure.HSReplayCommunicator do
  import Backend.Infrastructure.CommunicatorUtil
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  @behaviour Backend.HSReplay.Communicator
  def get_replay_feed() do
    get_body("https://hsreplay.net/api/v1/live/replay_feed/")
    |> Poison.decode!()
    |> Access.get("data")
    |> Enum.map(&ReplayFeedEntry.from_raw_map/1)
  end

  def get_archetypes() do
    get_body("https://hsreplay.net/api/v1/archetypes/")
    |> Poison.decode!()
    |> Enum.map(&Archetype.from_raw_map/1)
  end

  def get_archetype_matchups() do
    url =
      "https://hsreplay.net/analytics/query/head_to_head_archetype_matchups/?GameType=RANKED_STANDARD&RankRange=LEGEND_THROUGH_TWENTY&Region=ALL&TimeRange=LAST_7_DAYS"

    get_body(url)
    |> Poison.decode!()
    |> Backend.HSReplay.ArchetypeMatchups.from_raw_map()
  end

  def get_archetype_matchups(cookies) when is_nil(cookies) do
    get_archetype_matchups()
  end

  def get_archetype_matchups(cookies) do
    url =
      "https://hsreplay.net/analytics/query/head_to_head_archetype_matchups/?GameType=RANKED_STANDARD&RankRange=LEGEND_THROUGH_FIVE&Region=ALL&TimeRange=LAST_7_DAYS"

    response = HTTPoison.get!(url, %{}, hackney: [cookie: [cookies]])

    response.body
    |> Poison.decode!()
    |> Backend.HSReplay.ArchetypeMatchups.from_raw_map()
  end
end
