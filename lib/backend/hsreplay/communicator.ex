defmodule Backend.HSReplay.Communicator do
  @moduledoc false
  alias Backend.HSReplay.ReplayFeedEntry
  alias Backend.HSReplay.Archetype
  @callback get_replay_feed() :: [ReplayFeedEntry.t()]
  @callback get_archetypes() :: [Archetype.t()]
  @callback get_archetype_matchups() :: [Backend.HSReplay.ArchetypeMatchups.t()]
end
