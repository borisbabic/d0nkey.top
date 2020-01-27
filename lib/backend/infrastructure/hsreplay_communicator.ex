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
end
