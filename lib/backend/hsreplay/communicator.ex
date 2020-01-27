defmodule Backend.HSReplay.Communicator do
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  @callback get_replay_feed() :: [ReplayFeedEntry.t()]
  @callback get_archetypes() :: [Archetype.t()]
end
